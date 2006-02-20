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

IMPList *client_list = NULL;
ZWidget *root_window = NULL;

static void setup_root_window(void);

/* exported functions */
void zimwm_add_client(ZimClient *client);
ZimClient *zimwm_find_client_by_zwindow(ZWindow *w);
void zimwm_delete_client(ZimClient *c);

void on_button_down(IMPObject *widget, void *data);

int main(int argc, char **argv)
{	
	zwl_init();

	setup_root_window();
	
	zwl_main_loop_start();
	
	return 0;
}

static void setup_root_window(void)
{
	XSetWindowAttributes attr;
	Cursor rootc;

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
			  SubstructureNotifyMask |
     			  KeyPressMask |
     			  KeyReleaseMask;

	rootc = XCreateFontCursor(zdpy,XC_left_ptr);
		
	attr.cursor = rootc;
	XChangeWindowAttributes(zdpy,root_window->window,CWEventMask | CWCursor,&attr);
	
	zwl_main_loop_add_widget(root_window);

	[root_window attatch_cb:BUTTON_DOWN:(ZCallback *)on_button_down];
	[root_window attatch_cb:MAP_REQUEST:(ZCallback *)on_map_request];
	[root_window attatch_cb:UNMAP:(ZCallback *)on_unmap];
	//[root_window attatch_cb:DESTROY:(ZCallback *)on_unmap];
}

void zimwm_add_client(ZimClient *client)
{
	if(client_list) {
		if(client) {
			//client_list = [client_list prepend_data:client];
			[client_list append_data:client];
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
			break;
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

	while(list) {
		c = (ZimClient *)list->data;

		if(c->window->window == w) {
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

	if(!c)
		return;
	
	client = (ZimClient *)client_list->data;
	if(client == c) {
		if(c->atoms[WM_DELETE_WINDOW] && c->window->window) {
			cv.type = ClientMessage;
			cv.message_type = z_atom[WM_PROTOCOLS];
			cv.window = c->window->window;
			cv.format = 32;
			cv.data.l[0] = z_atom[WM_DELETE_WINDOW];
			cv.data.l[1] = CurrentTime;
			XSendEvent(zdpy,c->window->window,False,NoEventMask,&cv);		
		}
		else {
			[client->window->parent destroy];
			client_list = [client_list delete_node];
		}
		return;
	}
	
	while(list) {
		client = (ZimClient *)list->next->data;

		if((client == c) && list->next) {
			if(client->atoms[WM_DELETE_WINDOW] && c->window->window) {	
				cv.type = ClientMessage;
				cv.message_type = z_atom[WM_PROTOCOLS];
				cv.window = client->window->window;
				cv.format = 32;
				cv.data.l[0] = z_atom[WM_DELETE_WINDOW];
				cv.data.l[1] = CurrentTime;
				XSendEvent(zdpy,client->window->window,False,NoEventMask,&cv);		
			}
			else {
				[client->window->parent destroy];
				[list delete_next_node];
			}
			return;
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
			[list delete_next_node];
			return;
		}

		list = list->next;
	}
}

