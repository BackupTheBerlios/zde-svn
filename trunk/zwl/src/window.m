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

/* Atoms needed by windows */
static Atom atom;
static Atom utf8;
static Atom wm_name;
static Atom wm_protocols;
static Atom wm_delete_window;

@implementation ZWindow : ZWidget

- init:(ZWidget *)parent:(int)x:(int)y:(int)width:(int)height
{
	XSetWindowAttributes attr;

	[super init];
	
	attr.event_mask = ButtonPressMask |
    			  ButtonReleaseMask |
     			  EnterWindowMask |
     			  LeaveWindowMask |
     		 	  PointerMotionMask |
     			  ExposureMask |
     		  	  StructureNotifyMask |
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
		self->parent = parent;
	}

	self->x = x;
	self->y = y;
	self->width = width;
	self->height = height;
	
	XChangeWindowAttributes(zdpy,self->window,CWEventMask,&attr);

	if(self->window)
		zwl_main_loop_add_widget(self);
	
	self->xftdraw = XftDrawCreate(zdpy,self->window,DefaultVisual(zdpy,DefaultScreen(zdpy)),DefaultColormap(zdpy,DefaultScreen(zdpy)));

	utf8 = XInternAtom(zdpy,"UTF8_STRING",False);
	wm_name = XInternAtom(zdpy,"WM_NAME",False);
	wm_protocols = XInternAtom(zdpy,"WM_PROTOCOLS",False);
	wm_delete_window = XInternAtom(zdpy,"WM_DELETE_WINDOW",False);

	/* We want to be notified when we are going to be closed */
	XChangeProperty(zdpy,self->window,wm_protocols,XA_ATOM,32,PropModeReplace,&wm_delete_window,1);

}

- init:(int)x:(int)y:(int)width:(int)height
{
	[super init];
	
	self->title = NULL;
	
	self->x = x;
	self->y = y;
	self->width = width;
	self->height = height;

}

- free
{
	if(self->title)
		free(self->title);
	
	XftDrawDestroy(self->xftdraw);

	[super free];
}

- (int)set_title:(char *)title
{
	if(title && self->window) {
		if(self->title)
			free(self->title);

		self->title = strdup(title);
		XChangeProperty(zdpy,self->window,wm_name,utf8,8,PropModeReplace,self->title,strlen(self->title));

		return 0;
	}

	return -1;
}

@end
