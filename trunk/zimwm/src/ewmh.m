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
	int *workarea = i_calloc(4,sizeof(int));
	Window ewmhwin;

	workarea[0] = 0;
	workarea[1] = 0;
	workarea[2] = DisplayWidth(zdpy,zscreen);
	workarea[3] = DisplayHeight(zdpy,zscreen);
	
	/* All that we support for now... */
	net_supported[0] = z_atom[_NET_CLOSE_WINDOW];
	net_supported[1] = z_atom[_NET_SUPPORTING_WM_CHECK];
	net_supported[2] = z_atom[_NET_CLIENT_LIST];
	net_supported[3] = z_atom[_NET_WORKAREA];
	XChangeProperty(zdpy,root_window->window,z_atom[_NET_SUPPORTED],XA_ATOM,32,PropModeReplace,net_supported,4);

	/* Setup window for EWMH compatiablity. */
	ewmhwin = XCreateSimpleWindow(zdpy,root_window->window,-100,-100,1,1,0,0,0);
	XChangeProperty(zdpy,ewmhwin,z_atom[_NET_WM_NAME],z_atom[UTF8_STRING],32,PropModeReplace,"zimwm",1);
	XChangeProperty(zdpy,ewmhwin,z_atom[_NET_SUPPORTING_WM_CHECK],XA_WINDOW,32,PropModeReplace,(unsigned char *)&ewmhwin,1);

	XChangeProperty(zdpy,root_window->window,z_atom[_NET_SUPPORTING_WM_CHECK],XA_WINDOW,32,PropModeReplace,(unsigned char *)&ewmhwin,1);
	XChangeProperty(zdpy,root_window->window,z_atom[_NET_WORKAREA],XA_CARDINAL,32,PropModeReplace,(unsigned char *)workarea,4);

	i_free(workarea);
}

void handle_ewmh_client_message(XClientMessageEvent *ev)
{
	ZimClient *c = NULL;

	if(ev->message_type == z_atom[_NET_CLOSE_WINDOW]) {
		c = zimwm_find_client_by_window(ev->window);
		
		if(!c)
			return;
		
		zimwm_delete_client(c);
	}
	/* FIXME */
	else if(ev->message_type == z_atom[_NET_MOVERESIZE_WINDOW]) {
		c = zimwm_find_client_by_window(ev->window);

		if(!c)
			return;
		
		c->window->parent->x = ev->data.l[1];
		c->window->parent->y = ev->data.l[2];
		c->window->parent->width = ev->data.l[3];
		c->window->parent->height = ev->data.l[4];

		[c->window->parent move:c->window->parent->x:c->window->parent->y];
		[c->window->parent resize:c->window->parent->width:c->window->parent->y];
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

	XChangeProperty(zdpy,root_window->window,z_atom[_NET_CLIENT_LIST],XA_WINDOW,32,PropModeReplace,(unsigned char *)windows,i);
}

