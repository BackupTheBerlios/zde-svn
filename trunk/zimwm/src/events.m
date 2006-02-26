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

	update_client_list(client_list);
	
//	XSync(zdpy,False);
//	XUngrabServer(zdpy);
}

void on_key_press(IMPObject *widget, void *data)
{
	ZWidget *w = (ZWidget *)widget;

//	printf("Coolness!\n");
}

void on_client_message(IMPObject *widget, void *data)
{
	XClientMessageEvent *ev = (XClientMessageEvent *)data;
	
	handle_ewmh_client_message(ev);	
}

void on_configure_request(IMPObject *widget, void *data)
{
	printf("wooho\n");
}
