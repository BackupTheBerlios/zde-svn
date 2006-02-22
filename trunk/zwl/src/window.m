/*
    zwl
    Copyright (C) 2004,2005,2006 zwl Developers

    zwl is the legal property of its developers, whose names are
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

#include "zwl.h"

/* Internal callback prototypes */
static void on_configure(IMPObject *widget, void *data);

@implementation ZWindow : ZWidget

- init:(ZWidget *)parent:(int)x:(int)y:(int)width:(int)height
{
	XSetWindowAttributes attr;
	self->xftdraw = NULL;
	
	[super init];
	
	attr.event_mask = ButtonPressMask |
    			  ButtonReleaseMask |
     			  EnterWindowMask |
     			  LeaveWindowMask |
     		 	  PointerMotionMask |
     			  ExposureMask |
     		  	  StructureNotifyMask |
			  SubstructureNotifyMask |
     			  KeyPressMask |
     			  KeyReleaseMask;
	
	
	self->title = NULL;
	
	if(!parent) {
		self->window = (Window *)XCreateSimpleWindow(zdpy,XRootWindow(zdpy,0),x,y,width,height,1,1,1);
		self->parent = NULL;
		//self->parent = XRootWindow(zdpy,0);
	}
	else {
		self->window = (Window *)XCreateSimpleWindow(zdpy,parent->window,x,y,width,height,1,1,1);
		[self set_parent:parent];
	}

	self->x = x;
	self->y = y;
	self->width = width;
	self->height = height;
	
	XChangeWindowAttributes(zdpy,self->window,CWEventMask,&attr);

	if(self->window)
		zwl_main_loop_add_widget(self);
	
	self->xftdraw = XftDrawCreate(zdpy,self->window,DefaultVisual(zdpy,DefaultScreen(zdpy)),DefaultColormap(zdpy,DefaultScreen(zdpy)));

	/* We want to be notified when we are going to be closed */
	XChangeProperty(zdpy,self->window,z_atom[WM_PROTOCOLS],XA_ATOM,32,PropModeReplace,&z_atom[WM_DELETE_WINDOW],1);

	XChangeProperty(zdpy,self->window,z_atom[NET_WM_WINDOW_TYPE],XA_ATOM,32,PropModeReplace,&z_atom[NET_WM_WINDOW_TYPE_NORMAL],1);
	
	[self attatch_internal_cb:CONFIGURE:(ZCallback *)on_configure];
}

- init:(int)x:(int)y:(int)width:(int)height
{
	[super init];
	
	self->title = NULL;
	self->xftdraw = NULL;
	
	self->x = x;
	self->y = y;
	self->width = width;
	self->height = height;

}

- free
{
	if(self->title)
		free(self->title);

	if(self->xftdraw)
		XftDrawDestroy(self->xftdraw);
	
	self->xftdraw = NULL;
	
	[super free];
}

- (int)set_title:(char *)title
{
	if(title && self->window) {
		if(self->title)
			free(self->title);

		self->title = strdup(title);
		XChangeProperty(zdpy,self->window,z_atom[WM_NAME],z_atom[UTF8_STRING],8,PropModeReplace,self->title,strlen(self->title));

		return 0;
	}

	return -1;
}

- (char *)get_title
{
	return self->title;
}

- (void)raise
{
	if(self->window) {
		XRaiseWindow(zdpy,self->window);
	}
}

- (XftDraw *)get_xftdraw
{
	return self->xftdraw;
}

@end

static void on_configure(IMPObject *widget, void *data)
{
	ZWidget *w = (ZWidget *)widget;
	XConfigureEvent *configure = (XConfigureEvent *)data;

	w->x = configure->x;
	w->y = configure->y;
	w->width = configure->width;
	w->height = configure->height;
}

