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

static void resize(IMPObject *widget, void *data);

/* Helper functions */
static ZWindow *create_frame_for_client(ZimClient *c);

@implementation ZimClient : IMPObject

- init:(Window *)window
{
	XWindowAttributes attr;
	ZWindow *w = [ZWindow alloc];
	ZWindow *frame = NULL;
	char *name = NULL;

	self->atoms = NULL;
	self->size_hints = NULL;
	
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
	
	zwl_main_loop_add_widget(self->window);

	[self get_properties];
	
	[frame show];
	[self->window show];	
}

- free
{
	[self->window release];

	if(self->atoms)
		i_free(self->atoms);
	if(self->size_hints)
		i_free(self->size_hints);
	
	[super free];
}

- (void)get_properties
{
	int i,len;
	Atom *atom = NULL;
	XSizeHints shints;
	long sreturn;
	
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

	/* WM_NORMAL_HINTS */
	XGetWMNormalHints(zdpy,self->window->window,&shints,&sreturn);

	if(&shints) {
		self->size_hints = memcpy(i_calloc(1,sizeof(XSizeHints)),&shints,sizeof(XSizeHints));
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

- (void)send_configure_message:(int)x:(int)y:(int)width:(int)height
{
	XConfigureEvent cv;

	cv.type = ConfigureNotify;
	cv.window = self->window->window;
	cv.x = x;
	cv.y = y;
	cv.width = width;
	cv.height = height;

	self->window->x = x;
	self->window->y = y;
	self->window->width = width;
	self->window->height = height;
	
	XSendEvent(zdpy,self->window->window,False,StructureNotifyMask | SubstructureNotifyMask,&cv);
}

@end

static ZWindow *create_frame_for_client(ZimClient *c)
{
	ZButton *close_button = [ZButton alloc];
	ZWindow *f = [ZWindow alloc];
	ZWindow *right_handle = [ZWindow alloc];
	ZWindow *left_handle = [ZWindow alloc];
	ZWindow *bottom_handle = [ZWindow alloc];
	ZWindow *bottom_right_handle = [ZWindow alloc];
	ZLabel *label = [ZLabel alloc];
	XGlyphInfo extents;
	XftFont *font = XftFontOpenName(zdpy,DefaultScreen(zdpy),"sans-8"); /* This is bad... */

	[f init:root_window:
		c->window->x:
		c->window->y:
		c->window->width + (c->border * 2):
		c->window->height + (c->border + c->title_height)];

	[f attatch_cb:BUTTON_DOWN:(ZCallback *)on_frame_button_down];
	[f attatch_cb:EXPOSE:(ZCallback *)on_frame_expose];

	[right_handle init:f:f->width - c->border:c->title_height:c->border:f->height];
	[right_handle attatch_cb:BUTTON_DOWN:(ZCallback *)resize];
	[right_handle set_name:"RIGHT_HANDLE"];
	[f add_child:(ZWidget *)right_handle];
	[right_handle show];

	[left_handle init:f:0:c->title_height:c->border:f->height];
	[left_handle attatch_cb:BUTTON_DOWN:(ZCallback *)resize];
	[left_handle set_name:"LEFT_HANDLE"];
	[f add_child:(ZWidget *)left_handle];
	[left_handle show];

	[bottom_handle init:f:0:f->height - c->border:f->width:c->border];
	[bottom_handle attatch_cb:BUTTON_DOWN:(ZCallback *)resize];
	[bottom_handle set_name:"BOTTOM_HANDLE"];
	[f add_child:(ZWidget *)bottom_handle];
	[bottom_handle show];

	[bottom_right_handle init:f:f->width - c->border:f->height - c->border:c->border:c->border];
	[bottom_right_handle attatch_cb:BUTTON_DOWN:(ZCallback *)resize];
	[bottom_right_handle set_name:"BOTTOM_RIGHT_HANDLE"];
	[f add_child:(ZWidget *)bottom_right_handle];
	[bottom_right_handle show];
	
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
	
	//c = zimwm_find_client_by_zwindow(w);
	
	//zimwm_remove_client(c);

	zimwm_find_and_remove_client(w);
	
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

/* Moves the window around. */
static void on_frame_button_down(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	Window w1,w2;
	XEvent ev;
	Cursor arrow = XCreateFontCursor(zdpy,XC_fleur);
	ZimClient *c = NULL;
	int mask;
	int x,x1;
	int y,y1;
	ZWindow *window = NULL;
	IMPList *children = NULL;
	char *name;

	
	/* Find the window by searching through the frame's children list. */
	children = w->children;
	
	while(children) {
		window = children->data;
		name = [window get_name];
		
		if(!name)
			name = "";
			
		if(!strncmp(name,"XWINDOW",8)) {
			c = zimwm_find_client_by_zwindow(window);
			break;
		}

		children = children->next;
	}
	
	XGrabPointer(zdpy,root_window->window,True,PointerMotionMask | ButtonReleaseMask,GrabModeAsync,GrabModeAsync,None,arrow,CurrentTime);
	XQueryPointer(zdpy,w->window,&w1,&w2,&x,&y,&x1,&y1,&mask);

	[w raise];
	
	while(1) {
		XNextEvent(zdpy,&ev);

		switch(ev.type) {
			case MotionNotify:
				[w move:ev.xmotion.x_root - x1:ev.xmotion.y_root - y1];	
				if(c)
					[c send_configure_message:w->x:w->y:c->window->width:c->window->height];

				XSync(zdpy,False);
				break;
			case ButtonRelease:
				XUngrabPointer(zdpy,CurrentTime);
				[w raise];
				return;
			default:
				zwl_receive_xevent(&ev);
				break;
		}
	}

	XFreeCursor(zdpy,arrow);
}

/* Recenters the title in the frame. */
static void on_frame_expose(IMPObject *widget, void *data)
{
	ZWindow *frame = (ZWindow *)widget;
	ZLabel *label = NULL;
	ZWindow *w = NULL;
	IMPList *children;
	ZWindow *window = NULL;
	ZimClient *c = NULL;
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
			return;
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

static void resize(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	ZWindow *myself = (ZWindow *)widget;
	ZWindow *right,*left,*bottom,*bottom_right;
	Window w1,w2;
	XEvent ev;
	Cursor arrow = XCreateFontCursor(zdpy,XC_bottom_right_corner);
	IMPList *children = NULL;
	ZimClient *c = NULL;
	ZWindow *window;
	char *name;
	int width;
	int height;
	int w_resize_inc = 1;
	int h_resize_inc = 1;
	
	w = w->parent;
	
	XGrabPointer(zdpy,root_window->window,True,PointerMotionMask | ButtonReleaseMask,GrabModeAsync,GrabModeAsync,None,arrow,CurrentTime);

	/* Find the window by searching through the frame's children list. */
	children = w->children;

	if(!children)
		return;
	
	while(children) {
		window = children->data;
		name = [window get_name];
		
		if(!name)
			name = "";
			
		if(!strncmp(name,"XWINDOW",8)) {
			c = zimwm_find_client_by_zwindow(window);
			if(c && c->size_hints) {
				w_resize_inc = c->size_hints->width_inc;
				h_resize_inc = c->size_hints->height_inc;
			}
		}
		else if(!strncmp(name,"RIGHT_HANDLE",8)) {
			right = window;
		}
		else if(!strncmp(name,"LEFT_HANDLE",7)) {
			left = window;
		}
		else if(!strncmp(name,"BOTTOM_HANDLE",13)) {
			bottom = window;
		}
		else if(!strncmp(name,"BOTTOM_RIGHT_HANDLE",19)) {
			bottom_right = window;
		}

		children = children->next;
	}
	
	while(1) {
		XNextEvent(zdpy,&ev);
		
		switch(ev.type) {
			case MotionNotify:
				name = [myself get_name];
				
				if(!name)
					name = "";
					
				if(!strncmp(name,"RIGHT_HANDLE",8)) {	
					width = abs(w->x - ev.xmotion.x_root);
					width -= (width) % w_resize_inc;
					height = w->height;
				}
				else if(!strncmp(name,"LEFT_HANDLE",7)) {	
					width = abs(w->x - ev.xmotion.x_root);
					width -= (width) % w_resize_inc;
					height = w->height;
				}
				else if(!strncmp(name,"BOTTOM_HANDLE",13)) {	
					height = abs(w->y - ev.xmotion.y_root);
					height -= (height) % h_resize_inc;
					width = w->width;
				}
				else if(!strncmp(name,"BOTTOM_RIGHT_HANDLE",19)) {	
					width = abs(w->x - ev.xmotion.x_root);
					width -= (width) % w_resize_inc;
					height = abs(w->y - ev.xmotion.y_root);
					height -= (height) % h_resize_inc;
				}
				else {
					width = w->width;
					height = w->height;
				}

				if(c && c->size_hints) {
					if(width < c->size_hints->min_width)
						width = c->size_hints->min_width;
					if(height < c->size_hints->min_height)
						height = c->size_hints->min_height;
				}

				
				/* resize the window before the frame, I think it makes it look smoother... */
				[c->window move:c->border:c->title_height];
				[c->window resize:width - c->border * 2:height - c->border - c->title_height];
		
				[w resize:width:height];
				[w raise];
			
				[right move:w->width - c->border:c->title_height];
				[right resize:c->border:w->height];
				[left move:0:c->title_height];
				[left resize:c->border:w->height];
				[bottom move:0:w->height - c->border];
				[bottom resize:w->width:c->border];
				[bottom_right move:w->width - c->border:w->height - c->border];
				[bottom_right resize:c->border:c->border];
				
				[right raise];
				[left raise];
				[bottom raise];
				[bottom_right raise];
				
				[c send_configure_message:c->window->x:c->window->y:c->window->width:c->window->height];
				
				XSync(zdpy,False);	
				break;		
			case ButtonRelease:
				XUngrabPointer(zdpy,CurrentTime);
				return;
			default:
				zwl_receive_xevent(&ev);
				break;
		}
	}

	XFreeCursor(zdpy,arrow);
	
}

