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
	
	
	self->name = NULL;
	
	if(!parent) {
		self->window = (Window *)XCreateSimpleWindow(zdpy,XRootWindow(zdpy,0),x,y,width,height,1,1,1);
		//self->parent = XRootWindow(zdpy,0);
	}
	else {
		self->window = (Window *)XCreateSimpleWindow(zdpy,parent->window,x,y,width,height,1,1,1);
		self->parent = parent;
	}

	XChangeWindowAttributes(zdpy,self->window,CWEventMask,&attr);
	
	zwl_main_loop_add_widget(self);

//	[super init];
}

@end
