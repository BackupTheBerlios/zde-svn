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
	
//	[self->window attatch_cb:UNMAP:(ZCallback *)on_win_unmap];
	[self->window attatch_cb:DESTROY:(ZCallback *)on_win_unmap];
	
	zwl_main_loop_add_widget(self->window);
	zimwm_add_client(self);
	
	[frame show];
	[self->window show];	
}

- free
{
	[self->window release];
	[super free];
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

	[f attatch_cb:BUTTON_DOWN:(ZCallback *)on_frame_button_down];
	[f attatch_cb:EXPOSE:(ZCallback *)on_frame_expose];
	
	[close_button init:0:0:10:10];
	[f add_child:(ZWidget *)close_button];
	[close_button set_label:"X"];
	[close_button attatch_cb:BUTTON_DOWN:(ZCallback *)on_close_button_down];
	[close_button show];

	[label init:0:0];
	[f add_child:(ZWidget *)label];
	[label set_label:c->window->title];

	XftTextExtents8(zdpy,font,[label get_label],strlen([label get_label]),&extents);
	
	[label move:(f->width / 2) - (extents.width / 2):0];
	[label attatch_cb:BUTTON_DOWN:(ZCallback *)on_frame_label_button_down];
	[label show];

	return f;	
}

static void on_win_unmap(IMPObject *widget, void *data)
{
	ZimClient *c = NULL;
	
	c = zimwm_find_client_by_zwindow((ZWindow *)widget);

	zimwm_delete_client(c);
}

static void on_close_button_down(IMPObject *widget, void *data)
{
	ZWidget *w = (ZWidget *)widget;
	ZWindow *window = NULL;
	IMPList *children = NULL;
	char *name;

	/* Find the window by searching through the frame's children list. */
	children = w->parent->children;
	
	while(children) {
		window = children->data;
		name = [window get_name];
		
		if(!name)
			name = "";
			
		if(!strncmp(name,"XWINDOW",8)) {
			zimwm_delete_client(zimwm_find_client_by_zwindow(window));
			return;
		}

		children = children->next;
	}
}

static void on_frame_button_down(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	Window w1,w2;
	XEvent ev;
	int mask;
	int x,x1;
	int y,y1;
	
	XGrabPointer(zdpy,w->window,True,PointerMotionMask | ButtonReleaseMask,GrabModeAsync,GrabModeAsync,None,None,CurrentTime);

	XQueryPointer(zdpy,w->window,&w1,&w2,&x,&y,&x1,&y1,&mask);
	
	while(1) {
		XNextEvent(zdpy,&ev);

		switch(ev.type) {
			case MotionNotify:
				[w move:ev.xmotion.x_root - x1:ev.xmotion.y_root - y1];
				[w raise];
				break;
			case ButtonRelease:
				XUngrabPointer(zdpy,CurrentTime);
				[w raise];
				[w receive:EXPOSE:w];
				return;
			default:
				break;
		}
	}
}

static void on_frame_expose(IMPObject *widget, void *data)
{
	ZWidget *w = (ZWidget *)widget;
	ZWindow *window = NULL;
	IMPList *children = NULL;
	char *name;

	/* Give expose events to all our children except the XWINDOW */
	children = w->children;
	
	while(children) {
		window = children->data;
		name = [window get_name];
		
		if(!name) {
			[window receive:EXPOSE:window];
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
