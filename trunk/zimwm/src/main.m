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

IMPList *clients = NULL;
ZWidget *root_window = NULL;

void setup_root_window(void);
void on_button_down(IMPObject *widget, void *data);

int main(int argc, char **argv)
{	
	zwl_init();

	setup_root_window();
	
	zwl_main_loop_start();
	
	return 0;
}

void setup_root_window(void)
{
	XSetWindowAttributes attr;

	root_window = [ZWidget alloc];
	[root_window init];

	root_window->window = XRootWindow(zdpy,0);
	
	attr.event_mask = ButtonPressMask |
    			  ButtonReleaseMask |
     			  EnterWindowMask |
     			  LeaveWindowMask |
     		 	  PointerMotionMask |
     			  ExposureMask |
     		  	  StructureNotifyMask |
			  SubstructureRedirectMask |
     			  KeyPressMask |
     			  KeyReleaseMask;

	XChangeWindowAttributes(zdpy,root_window->window,CWEventMask,&attr);

	zwl_main_loop_add_widget(root_window);

	[root_window attatch_cb:BUTTON_DOWN:(ZCallback *)on_button_down];
	[root_window attatch_cb:MAP_REQUEST:(ZCallback *)on_map_request];
}

