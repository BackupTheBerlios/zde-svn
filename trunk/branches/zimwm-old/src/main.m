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

static unsigned int quit = 0;

/* FIXME NEEDS TO BE A CONFIGURABLE VALUE */
int snap_px = 5;

int curr_zone = 0;

static int ipc_fd = 0;

IMPList *client_list = NULL;
ZWidget *root_window = NULL;
Zone **zones = NULL;

static void setup_root_window(void);
static void setup_zone(ZWidget *root);

/* exported functions */
void zimwm_add_client(ZimClient *client);
ZimClient *zimwm_find_client_by_zwindow(ZWindow *w);
void zimwm_delete_client(ZimClient *c);

int main(int argc, char **argv)
{	
	zwl_init();

	setup_root_window();
	
	setup_ewmh_root_properties();

	/* FIXME path should be configurable or at leas adaptable*/
	ipc_fd = open_ipc("/tmp/zimwm-ipc");

	zimwm_init_module_subsystem();

	zimwm_main_loop_start();
	
	return 0;
}

/**
  A semi-asynchronous event loop that places priority on X events.
  */
void zimwm_main_loop_start()
{
	XEvent ev;
	Bool have_ev;
	int xcon_fd = 0;
	int i;
	fd_set fds;
	fd_set tmp;
	int fd_max = 0;
	int newfd;
	int addrlen;
	struct sockaddr_un remoteaddr;
	
	xcon_fd = ConnectionNumber(zdpy);
		
	FD_ZERO(&fds);	
	FD_ZERO(&tmp);
	FD_SET(ipc_fd,&fds);	
	FD_SET(xcon_fd,&fds);
	
	if(xcon_fd > ipc_fd)
		fd_max = xcon_fd;
	else
		fd_max = ipc_fd;
	
	while(!quit) {
		have_ev = False;
		
		tmp = fds;
		
		/* Process X events already off of the file descriptor but in memory. */	
		if(XPending(zdpy)) {
			have_ev = True;
			XNextEvent(zdpy, &ev);
			zwl_receive_xevent(&ev);
		}

		/* We don't need to watch the fd's then. */
		if(have_ev)
			continue;
	
		if(select(fd_max+1,&tmp,NULL,NULL,NULL) == -1)
			perror("select");
		/* FIXME Make sure the connection is still open, otherwise send() will segv */	
		for(i=0;i<=fd_max;i++) {
			if(FD_ISSET(i,&tmp)) {
				if(i == ipc_fd) { /* IPC has a new connection. */
					addrlen = sizeof(remoteaddr);
					if((newfd = accept(ipc_fd,(struct sockaddr *)&remoteaddr,&addrlen)) == -1) {
						perror("accept");
						continue;
					}
					else {
						ipc_receive_from_fd(newfd);
					}
				}
				else if(i == xcon_fd) /* This is an X event, return to top. */				
					continue;	
			}
		}
	}
}

void zimwm_main_loop_quit()
{
	quit = 1;
	/* FIXME CLEANUP OUR MESS */
}

static void setup_root_window(void)
{
	XSetWindowAttributes attr;
	XWindowAttributes winattr;
	Cursor rootc;
	ZimClient *newc;
	Window root,parent;
	Window *children;
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
	
	XGrabKey(zdpy,50,Mod1Mask,(Window)root_window->window,False,GrabModeAsync,GrabModeAsync);
	
	attr.cursor = rootc;
	XChangeWindowAttributes(zdpy,(Window)root_window->window,CWEventMask | CWCursor,&attr);

	zwl_main_loop_add_widget(root_window);

	[root_window attatch_cb:BUTTON_DOWN:(ZCallback *)on_button_down];
	[root_window attatch_cb:MAP_REQUEST:(ZCallback *)on_map_request];
	[root_window attatch_cb:KEY_PRESS:(ZCallback *)on_key_press];
	[root_window attatch_cb:CLIENT_MESSAGE:(ZCallback *)on_client_message];
	[root_window attatch_cb:CONFIGURE_REQUEST:(ZCallback *)on_configure_request];
	
	setup_zone(root_window);
/*
	XQueryTree(zdpy,root_window->window,&root,&parent,&children,&len);

	for(i=0;i<len;i++) {
		XGetWindowAttributes(zdpy,children[i],&winattr);

		if(!winattr.override_redirect && winattr.map_state == IsViewable) {
			newc = [ZimClient alloc];
			XMapWindow(zdpy,children[i]);
			[newc init:children[i]];
			zimwm_add_client(newc);
		}
	
	}
*/
	XFreeCursor(zdpy,rootc);
}

static void setup_zone(ZWidget *root)
{
	VWorkspace *vwork = [VWorkspace alloc];
	VWorkspace *vwork1 = [VWorkspace alloc];
	
	/* FIXME We are only working with a single zone for now. */
	zones = i_calloc(1,sizeof(Zone *));
	zones[0] = [Zone alloc];
	[zones[0] init:zdpy:zscreen:root:NULL];	

	curr_zone = 0;

	/* FIXME Setup the second workspace. This should be configurable. */
	[vwork init:2:XDisplayWidth(zdpy,zscreen):XDisplayHeight(zdpy,zscreen)];
	[[zones[curr_zone] get_current_desk] add_workspace:vwork];

	/* FIXME Setup the third workspace. */
	[vwork1 init:3:XDisplayWidth(zdpy,zscreen):XDisplayHeight(zdpy,zscreen)];
	[[zones[curr_zone] get_current_desk] add_workspace:vwork1];
}

void zimwm_add_client(ZimClient *client)
{
	/* regular client list */
	if(client_list) {
		if(client) {
			client_list = [client_list prepend_data:client];	
		
			/* add the client to the current workspace. */
			[[zones[curr_zone] get_current_workspace] add_client:client];
			[client set_vwork:[[zones[curr_zone] get_current_workspace] get_num]];
			[client set_vdesk:[[zones[curr_zone] get_current_desk] get_num]];

			//[client_list append_data:client];
		}
	}
	else {
		client_list = [IMPList alloc];
		[client_list init:1];
		client_list->data = client;

		/* add the client to the current workspace. */
		[[zones[curr_zone] get_current_workspace] add_client:client];
		[client set_vwork:[[zones[curr_zone] get_current_workspace] get_num]];
		[client set_vdesk:[[zones[curr_zone] get_current_desk] get_num]];
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

void zimwm_remove_client(ZimClient *c)
{
	IMPList *list = client_list;
	ZimClient *client = NULL;
	IMPSimpleStack *temp = [IMPSimpleStack alloc];
	
	/* remove from client_list */
	if(!c)
		return;

	client = (ZimClient *)client_list->data;
	if(client == c && client_list) {
		[[[zones[curr_zone] get_nth_desk:[c get_vdesk]] get_nth_workspace:[c get_vwork]] remove_client:c];
		list = [list delete_node];
		client_list = list;
	}
	else {
		while(list) {
			client = (ZimClient *)list->next->data;

			if((client == c) && list->next) {
				[[[zones[curr_zone] get_nth_desk:[c get_vdesk]] get_nth_workspace:[c get_vwork]] remove_client:c];
				list = [list delete_next_node];

				break;
			}

			list = list->next;
		}
	}

	update_client_list(client_list);
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

