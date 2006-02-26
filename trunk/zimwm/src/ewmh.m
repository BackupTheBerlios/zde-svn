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

void setup_ewmh_root_properties(void)
{
	char *net_supported[10];
	Window ewmhwin;

	/* All that we support for now... */
	net_supported[0] = z_atom[_NET_CLOSE_WINDOW];
	net_supported[1] = z_atom[_NET_SUPPORTING_WM_CHECK];
	net_supported[2] = z_atom[_NET_CLIENT_LIST];
	XChangeProperty(zdpy,root_window->window,z_atom[_NET_SUPPORTED],XA_ATOM,32,PropModeReplace,net_supported,3);

	/* Setup window for EWMH compatiablity. */
	ewmhwin = XCreateSimpleWindow(zdpy,root_window->window,-100,-100,1,1,0,0,0);
	XChangeProperty(zdpy,ewmhwin,z_atom[_NET_WM_NAME],z_atom[UTF8_STRING],32,PropModeReplace,"zimwm",1);
	XChangeProperty(zdpy,ewmhwin,z_atom[_NET_SUPPORTING_WM_CHECK],XA_WINDOW,32,PropModeReplace,(unsigned char *)&ewmhwin,1);
	XChangeProperty(zdpy,root_window->window,z_atom[_NET_SUPPORTING_WM_CHECK],XA_WINDOW,32,PropModeReplace,(unsigned char *)&ewmhwin,1);
}

void handle_ewmh_client_message(XClientMessageEvent *ev)
{
	ZimClient *c = NULL;

	if(ev->message_type = z_atom[_NET_CLOSE_WINDOW]) {
		c = zimwm_find_client_by_window(ev->window);
		
		if(!c)
			return;
		
		zimwm_delete_client(c);
	}
	
}

void update_client_list(IMPList *list)
{
	Window **windows = i_calloc([list get_size],sizeof(Window));
	ZimClient *c = NULL;
	int i = 0;
	
	while(list) {
		c = list->data;
		windows[i++] = c->window->window;

		list = list->next;
	}
printf("UPDATING\n");
	XChangeProperty(zdpy,root_window->window,z_atom[_NET_CLIENT_LIST],XA_WINDOW,32,PropModeReplace,(unsigned char *)windows,i);
}

