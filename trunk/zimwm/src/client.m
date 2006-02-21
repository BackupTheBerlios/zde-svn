/*
    zimwm
    Copyright (C) 2004,2005,2006 zimwm Developers

    zimwm is the legal property of its developers, whose names are
    too numerous to list here.  Please refer to the COPYING file
    for the full text of this license and to the AUTHORS file for
    the complete list of developers.

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation, version 2.1.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

#include "zimwm.h"

/* Callbacks */
static void on_win_unmap(IMPObject *widget, void *data);
static void on_close_button_down(IMPObject *widget, void *data);
static void on_frame_button_down(IMPObject *widget, void *data);
static void on_frame_expose(IMPObject *widget, void *data);
static void on_frame_label_button_down(IMPObject *widget, void *data);
static void on_frame_key_press(IMPObject *widget, void *data);

/* Helper functions */
static ZWindow *create_frame_for_client(ZimClient *c);

@implementation ZimClient : IMPObject

- init:(Window *)window
{
	XWindowAttributes attr;
	ZWindow *w = [ZWindow alloc];
	ZWindow *frame = NULL;
	char *name = NULL;
	
	XGetWindowAttributes(zdpy,window,&attr);

	w->x = attr.x;
	w->y = attr.y;
	w->width = attr.width;
	w->height = attr.height;

	w->window = window;
	
	XFetchName(zdpy,w->window,&name);
	
	if(name) {
		[w set_title:name];
		XFree(name);
	}
	else {
		[w set_title:"(null)"];
	}
	
	self->window = w;
	[self->window set_name:"XWINDOW"];
	[self->window grab];
	
	self->border = 3;
	self->title_height = 15;

	frame = create_frame_for_client(self);

	XReparentWindow(zdpy,self->window->window,frame->window,self->border,self->title_height);
	
	[frame add_child:self->window]; 
		
	[self->window attatch_cb:UNMAP:(ZCallback *)on_win_unmap];
//	[self->window attatch_cb:DESTROY:(ZCallback *)on_win_unmap];
	
	zwl_main_loop_add_widget(self->window);

	[self get_properties];
	
	[frame show];
	[self->window show];	
}

- free
{
	[self->window release];
	[super free];
}

- (void)get_properties
{
	int i,len;
	Atom *atom = NULL;
	
	self->atoms = i_calloc(30,sizeof(Atom));

	for(i=0;i<30;i++) {
		atoms[i] = NULL;
	}

	/* WM_PROTOCOLS */
	XGetWMProtocols(zdpy,self->window->window,&atom,&len);
	
	if(atom) {
		self->atoms[WM_PROTOCOLS] = atom;
		
		for(i=0;i<len;i++) {
			if(atom[i] == z_atom[WM_DELETE_WINDOW]) {
				self->atoms[WM_DELETE_WINDOW] = atom[WM_DELETE_WINDOW];
			}
		}
	}
}

- (void)send_client_message:(int)format:(Atom)type:(Atom)data
{
	XClientMessageEvent cv;
	
	cv.type = ClientMessage;
	cv.message_type = type;
	cv.window = self->window->window;
	cv.format = 32;
	cv.data.l[0] = data;
	cv.data.l[1] = CurrentTime;
	
	XSendEvent(zdpy,self->window->window,False,NoEventMask,&cv);
}

@end

static ZWindow *create_frame_for_client(ZimClient *c)
{
	ZButton *close_button = [ZButton alloc];
	ZWindow *f = [ZWindow alloc];
	ZLabel *label = [ZLabel alloc];
	XGlyphInfo extents;
	XftFont *font = XftFontOpenName(zdpy,DefaultScreen(zdpy),"sans-8"); /* This is bad... */

	[f init:root_window:
		c->window->x:
		c->window->y:
		c->window->width + (c->border * 2):
		c->window->height + (c->border + c->title_height)];

//	[f attatch_cb:KEY_PRESS:(ZCallback *)on_frame_key_press];
	[f attatch_cb:BUTTON_DOWN:(ZCallback *)on_frame_button_down];
	[f attatch_cb:EXPOSE:(ZCallback *)on_frame_expose];
	
	[close_button init:0:0:10:10];
	[f add_child:(ZWidget *)close_button];
	[close_button set_name:"CLOSE"];
	[close_button set_label:"X"];
	[close_button attatch_cb:BUTTON_DOWN:(ZCallback *)on_close_button_down];
	[close_button show];

	[label init:0:0];
	[f add_child:(ZWidget *)label];
	[label set_name:"TITLE"];
	[label set_label:c->window->title];

	XftTextExtents8(zdpy,font,[label get_label],strlen([label get_label]),&extents);
	
	[label move:(f->width / 2) - (extents.width / 2):0];
	[label attatch_cb:BUTTON_DOWN:(ZCallback *)on_frame_label_button_down];
	[label show];

	return f;	
}

static void on_win_unmap(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	ZimClient *c = NULL;

	//XGrabServer(zdpy);

	w->window = NULL;
	
	c = zimwm_find_client_by_zwindow(w);

	zimwm_remove_client(c);

	[w->parent destroy];
	//zimwm_delete_client(c);
	
	//XUngrabServer(zdpy);
}

static void on_close_button_down(IMPObject *widget, void *data)
{
	ZWidget *w = (ZWidget *)widget;
	ZWindow *window = NULL;
	IMPList *children = NULL;
	ZimClient *c;
	char *name;

	/* Find the window by searching through the frame's children list. */
	children = w->parent->children;
	
	while(children) {
		window = children->data;
		name = [window get_name];
		
		if(!name)
			name = "";
			
		if(!strncmp(name,"XWINDOW",8)) {
			c = zimwm_find_client_by_zwindow(window);
			zimwm_delete_client(c);
			return;
		}

		children = children->next;
	}
}

/* XXX Moving the window works perfectly, but resizing, well... This needs to be cleaned up A LOT.  It
   hardly can be called working. */
static void on_frame_button_down(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	Window w1,w2;
	XEvent ev;
	Cursor arrow = XCreateFontCursor(zdpy,XC_fleur);
	IMPList *children = NULL;
	ZimClient *c;
	ZWindow *window;
	char *name;
	int mask;
	int x,x1;
	int y,y1;
	int width;
	int height;
	
	XGrabPointer(zdpy,root_window->window,True,PointerMotionMask | ButtonReleaseMask,GrabModeAsync,GrabModeAsync,None,arrow,CurrentTime);
	XQueryPointer(zdpy,w->window,&w1,&w2,&x,&y,&x1,&y1,&mask);

	if(mask & ControlMask)
		XWarpPointer(zdpy,None,w->window,0,0,0,0,w->width,w->height);
		
	XGrabServer(zdpy);
	while(1) {
		XNextEvent(zdpy,&ev);

		switch(ev.type) {
			case MotionNotify:
				/* XXX RESIZE IS BROKEN BADLY XXX */
				if(ev.xmotion.state & ControlMask) {
					XUngrabServer(zdpy);		
					width = abs(w->x - ev.xmotion.x);
					height = abs(w->y - ev.xmotion.y);

					width -= (width - 10) % 10;
					height -= (height - 10) % 10;
					
					XSync(zdpy,False);
					XGrabServer(zdpy);
					/*
					[w resize:((ev.xmotion.x_root - w->width)) + w->width:
						((ev.xmotion.y_root - w->height)) + w->height];
						*/
					
					/* Find the window by searching through the frame's children list. */
					children = w->children;
	
					while(children) {
						window = children->data;
						name = [window get_name];
						
						if(!name)
							name = "";
							
						if(!strncmp(name,"XWINDOW",8)) {
							c = zimwm_find_client_by_zwindow(window);
							
							[c->window resize:width - c->border:height - c->border * 2];
							[c->window move:c->border:c->title_height];
							break;
						}

						children = children->next;
					}
					
					[w resize:width:height];
					[w raise];
				}
				else {
					[w move:ev.xmotion.x_root - x1:ev.xmotion.y_root - y1];
					[w raise];
					XSync(zdpy,False);
				}
				break;
			case ButtonRelease:
				XUngrabPointer(zdpy,CurrentTime);
				XUngrabServer(zdpy);
				[w raise];
				return;
			default:
				zwl_receive_xevent(&ev);
				break;
		}
	}

	XFreeCursor(zdpy,arrow);
}

/*
static void on_frame_key_press(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	XEvent ev,ev1;
	KeySym *key;
	XKeyEvent *kev = (XKeyEvent *)data;
	Window w1,w2;
	Cursor arrow = XCreateFontCursor(zdpy,XC_bottom_right_corner);
	int mask;
	int x,x1;
	int y,y1;

	key = XKeycodeToKeysym(zdpy,kev->keycode,1);
	
	if(kev->keycode == 64 || kev->keycode == 113) {
		while(1) {
			XNextEvent(zdpy,&ev);
			
			switch(ev.type) {
				case ButtonPress:
					XGrabPointer(zdpy,w->window,True,PointerMotionMask | ButtonReleaseMask,
							GrabModeAsync,GrabModeAsync,None,arrow,CurrentTime);
					XWarpPointer(zdpy,None,w->window,0,0,0,0,w->width,w->height);
						while(1) {
							XNextEvent(zdpy,&ev1);
							
							switch(ev1.type) {
								case MotionNotify:
									x = w->width;
									y = w->height;
									printf("motion x:%d\nmotion y:%d\n",ev1.xmotion.x,ev1.xmotion.y);
									[w resize:((ev1.xmotion.x - x)) + x:
										((ev1.xmotion.y - y)) + y];
									[w raise];
									
									break;
								case ButtonRelease:
									XUngrabPointer(zdpy,CurrentTime);
									[w raise];
									break;
								default:
								//	zwl_receive_xevent(&ev);
									break;
							}
						}
					break;
				default:
					zwl_receive_xevent(&ev);
					break;
			}

		}
	}	
}
*/

static void on_frame_expose(IMPObject *widget, void *data)
{
	ZWindow *frame = (ZWindow *)widget;
	ZLabel *label = NULL;
	IMPList *children;
	ZWindow *window = NULL;
	XGlyphInfo extents;
	XftFont *font = XftFontOpenName(zdpy,DefaultScreen(zdpy),"sans-8"); /* This is bad... */
	char *name = NULL;

	children = frame->children;
	
	while(children) {
		window = (ZWindow *)children->data;
		
		name = [window get_name];
		
		if(!name)
			name = "";
		
		if(!strncmp(name,"TITLE",5)) {
			label = (ZLabel *)window;
			
			XftTextExtents8(zdpy,font,[label get_label],strlen([label get_label]),&extents);
			[label move:(frame->width / 2) - (extents.width / 2):0];
		}

		children = children->next;
	}

	
}

static void on_frame_label_button_down(IMPObject *widget, void *data)
{
	ZWidget *frame = (ZWidget *)widget;

	frame = frame->parent;
	
	[frame receive:BUTTON_DOWN:data];
}
