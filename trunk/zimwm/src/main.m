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

/* FIXME NEEDS TO BE A CONFIGURABLE VALUE */
int snap_px = 5;

IMPList *client_list = NULL;
ZWidget *root_window = NULL;

static void setup_root_window(void);

/* exported functions */
void zimwm_add_client(ZimClient *client);
ZimClient *zimwm_find_client_by_zwindow(ZWindow *w);
void zimwm_delete_client(ZimClient *c);

int handle_xerror(Display *dpy, XErrorEvent *ev)
{

}

int main(int argc, char **argv)
{	
	zwl_init();

	setup_root_window();

//	XSetErrorHandler(handle_xerror);
	
	zwl_main_loop_start();
	
	return 0;
}

static void setup_root_window(void)
{
	XSetWindowAttributes attr;
	XWindowAttributes winattr;
	Cursor rootc;
	ZimClient *newc;
	Window root,parent;
	Window **children;
	int i,len;
	
	root_window = [ZWidget alloc];
	[root_window init];

	root_window->window = (Window *)XRootWindow(zdpy,0);
	
	attr.event_mask = ButtonPressMask |
    			  ButtonReleaseMask |
     			  EnterWindowMask |
     			  LeaveWindowMask |
			  SubstructureRedirectMask |
			  SubstructureNotifyMask |
			  PropertyChangeMask |
			  KeyPressMask |
     			  KeyReleaseMask;

	rootc = XCreateFontCursor(zdpy,XC_left_ptr);
		
	attr.cursor = rootc;
	XChangeWindowAttributes(zdpy,(Window)root_window->window,CWEventMask | CWCursor,&attr);

	//XGrabKey(zdpy,XKeysymToKeycode(zdpy,XK_Alt_L),AnyModifier,root_window->window,True,GrabModeAsync,GrabModeAsync);
	
	zwl_main_loop_add_widget(root_window);

	[root_window attatch_cb:BUTTON_DOWN:(ZCallback *)on_button_down];
	[root_window attatch_cb:MAP_REQUEST:(ZCallback *)on_map_request];
	[root_window attatch_cb:KEY_PRESS:(ZCallback *)on_key_press];
	[root_window attatch_cb:CLIENT_MESSAGE:(ZCallback *)on_client_message];
	[root_window attatch_cb:CONFIGURE_REQUEST:(ZCallback *)on_configure_request];
	//[root_window attatch_cb:PROPERTY:(ZCallback *)on_property_notify];
	
	setup_ewmh_root_properties();
/*
	XQueryTree(zdpy,root_window->window,&root,&parent,&children,&len);

	for(i=0;i<len;i++) {
		XGetWindowAttributes(zdpy,children[i],&winattr);

		if(!winattr.override_redirect && winattr.map_state == IsViewable) {
			newc = [ZimClient alloc];
			[newc init:children[i]];
			zimwm_add_client(newc);
		}
	
	}
*/
	XFreeCursor(zdpy,rootc);
}

void zimwm_add_client(ZimClient *client)
{
	if(client_list) {
		if(client) {
			client_list = [client_list prepend_data:client];
			//[client_list append_data:client];
		}
	}
	else {
		client_list = [IMPList alloc];
		[client_list init:1];
		client_list->data = client;
	}
}

ZimClient *zimwm_find_client_by_zwindow(ZWindow *w)
{
	IMPList *list = client_list;
	ZimClient *c;

	if(!w)
		return;
	
	while(list) {
		c = (ZimClient *)list->data;
		if(!c)
			continue;
		if(c->window == w) {
			return c;
		}

		list = list->next;
	}
	
	return NULL;
}

ZimClient *zimwm_find_client_by_window(Window *w)
{
	IMPList *list = client_list;
	ZimClient *c;

	if(!w)
		return;
	
	while(list) {
		c = (ZimClient *)list->data;	
		if(!c)
			continue;
		if(c->window->window == w) {
			return c;
		}
		
		list = list->next;
	}

	return NULL;
}

ZimClient *zimwm_find_client_by_window_frame(Window *w)
{
	IMPList *list = client_list;
	ZimClient *c;

	if(!w)
		return;
	
	while(list) {
		c = (ZimClient *)list->data;	
		if(!c)
			continue;
		if(c->window->parent->window == w) {
			return c;
		}
		
		list = list->next;
	}

	return NULL;
}

void zimwm_delete_client(ZimClient *c)
{
	IMPList *list = client_list;
	XClientMessageEvent cv;
	ZimClient *client;

	if(!c || !c->window || !c->window->window)
		return;
	
	client = (ZimClient *)client_list->data;
	if(client == c) {
		if(c->atoms[WM_DELETE_WINDOW] && c->window && c->window->window) {
			[c send_client_message:32:z_atom[WM_PROTOCOLS]:z_atom[WM_DELETE_WINDOW]];
		}
		else {
			[client->window->parent destroy];
		}
		return;
	}
	
	while(list) {
		client = (ZimClient *)list->next->data;

		if((client == c) && list->next) {
				[client send_client_message:32:z_atom[WM_PROTOCOLS]:z_atom[WM_DELETE_WINDOW]];
				return;
		}
		else {
			[client->window->parent destroy];
		}
		
		list = list->next;
	}
}

void zimwm_remove_client(ZimClient *c)
{
	IMPList *list = client_list;
	ZimClient *client = NULL;

	if(!c)
		return;

	client = (ZimClient *)client_list->data;
	if(client == c && client_list) {
		list = [list delete_node];
		client_list = list;
		return;
	}
	
	while(list) {
		client = (ZimClient *)list->next->data;

		if((client == c) && list->next) {
			list = [list delete_next_node];
			return;
		}

		list = list->next;
	}
}

/* FIXME */
void zimwm_find_and_remove_client(ZWindow *w)
{
	IMPList *list = client_list;
	ZimClient *c;

	while(list) {
		c = (ZimClient *)list->data;

		if(c->window == w) {
			list = [list delete_node];
			client_list = list;
			return;
		}
		
		list = list->next;
	}
}

