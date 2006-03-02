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

void on_button_down(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	XButtonEvent *ev = (XButtonEvent *)data;
	
	if(1)	
		printf("KICKASS!\n");
}

void on_map_request(IMPObject *widget, void *data)
{
	XMapRequestEvent *ev = (XMapRequestEvent *)data;
	ZimClient *client = [ZimClient alloc];

//	XGrabServer(zdpy);
	
//	printf("Window %d requests to be mapped.\n",ev->window);
	
	[client init:ev->window];
	
	zimwm_add_client(client);

	focus_client(client);
	update_client_list(client_list);
	
//	XSync(zdpy,False);
//	XUngrabServer(zdpy);
}

void on_key_press(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	XEvent ev;
	ZimClient *c = NULL;
	Window w1;
	int x;
	
	XGetInputFocus(zdpy,&w1,&x);
		
	c = zimwm_find_client_by_window(w1);

	if(c) {
		XGrabButton(zdpy,Button1,AnyModifier,w1,True,ButtonPressMask,GrabModeAsync,GrabModeAsync,None,None);		
		while(1) {
			XNextEvent(zdpy,&ev);
			
			switch(ev.type) {
				case ButtonPress:
					[c->window->parent receive:BUTTON_DOWN:&ev.xbutton];
					XUngrabButton(zdpy,Button1,AnyModifier,w1);
					return;
				default:
					zwl_receive_xevent(&ev);	
			}
		}
	}
}

void on_client_message(IMPObject *widget, void *data)
{
	XClientMessageEvent *ev = (XClientMessageEvent *)data;
	
	handle_ewmh_client_message(ev);	
}

void on_configure(IMPObject *widget, void *data)
{
	XConfigureEvent *ev = (XConfigureEvent *)data;
	ZimClient *c = NULL;
	
//	if(ev->send_event == True) {
		c = zimwm_find_client_by_window(ev->window);
	printf("COOLNESS\n");	
		c->window->parent->x = ev->x;
		c->window->parent->y = ev->y;
		c->window->parent->width = ev->width;
		c->window->parent->height = ev->height;

		[c->window->parent move:c->window->parent->x:c->window->parent->y];
		[c->window->parent resize:c->window->parent->width:c->window->parent->height];
//	}
}

