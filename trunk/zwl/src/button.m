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
static void on_add(IMPObject *widget, void *data);

@implementation ZButton : ZWindow

- init:(int)x:(int)y:(int)width:(int)height
{
	self->window = NULL;
	[super init:x:y:width:height];

	[self attatch_internal_cb:ADDED:(ZCallback *)on_add];
}

- free
{
	[super free];
}

@end

static void on_add(IMPObject *widget, void *data)
{
	ZWidget *myself = (ZWidget *)data;
	ZWidget *parent = myself->parent;
	XSetWindowAttributes attr;

	attr.event_mask = ButtonPressMask |
    			  ButtonReleaseMask |
     			  EnterWindowMask |
     			  LeaveWindowMask |
     		 	  PointerMotionMask |
     			  ExposureMask |
     		  	  StructureNotifyMask |
     			  KeyPressMask |
     			  KeyReleaseMask;
	
	
	myself->window = (Window *)XCreateSimpleWindow(zdpy,parent->window,
			myself->x,myself->y,myself->width,myself->height,
		1,WhitePixel(zdpy,DefaultScreen(zdpy)),1);

	XChangeWindowAttributes(zdpy,myself->window,CWEventMask,&attr);
	
	zwl_main_loop_add_widget(myself);
}
