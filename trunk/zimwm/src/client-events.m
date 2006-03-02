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

void on_win_unmap(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	ZimClient *c = NULL;

	//XGrabServer(zdpy);

	w->window = NULL;
	
	//c = zimwm_find_client_by_zwindow(w);
	
	//zimwm_remove_client(c);

	zimwm_find_and_remove_client(w);
	
	update_client_list(client_list);
	
	[w->parent destroy];
	//zimwm_delete_client(c);
	//XUngrabServer(zdpy);
}

void on_close_button_down(IMPObject *widget, void *data)
{
	ZWidget *w = (ZWidget *)widget;
	ZWindow *window = NULL;
	IMPList *children = NULL;
	ZimClient *c;
	char *name;

	/* Find the window by searching through the frame's children list. */
	children = w->parent->children;
	
	while(children) {
		window = children->data;
		name = [window get_name];
		
		if(!name)
			name = "";
			
		if(!strncmp(name,"XWINDOW",8)) {
			c = zimwm_find_client_by_zwindow(window);
			zimwm_delete_client(c);
			return;
		}

		children = children->next;
	}
}

/* Moves the window around. */
void on_frame_button_down(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	Window w1,w2;
	XEvent ev;
	Cursor arrow = XCreateFontCursor(zdpy,XC_fleur);
	ZimClient *c = NULL;
	int mask;
	int x,x1;
	int y,y1;
	ZWindow *window = NULL;
	IMPList *children = NULL;
	char *name;

	
	/* Find the window by searching through the frame's children list. */
	children = w->children;
	
	while(children) {
		window = children->data;
		name = [window get_name];
		
		if(!name)
			name = "";
			
		if(!strncmp(name,"XWINDOW",8)) {
			c = zimwm_find_client_by_zwindow(window);
			break;
		}

		children = children->next;
	}
	
	XGrabPointer(zdpy,root_window->window,True,PointerMotionMask | ButtonReleaseMask,GrabModeAsync,GrabModeAsync,None,arrow,CurrentTime);
	XQueryPointer(zdpy,w->window,&w1,&w2,&x,&y,&x1,&y1,&mask);

	[w raise];
	
	while(1) {
		XNextEvent(zdpy,&ev);

		switch(ev.type) {
			case MotionNotify:
				[w move:ev.xmotion.x_root - x1:ev.xmotion.y_root - y1];	
				[c snap];
				if(c)
					[c send_configure_message:w->x:w->y:c->window->width:c->window->height];

				//XSync(zdpy,False);
				break;
			case ButtonRelease:
				XUngrabPointer(zdpy,CurrentTime);
				[w raise];
				return;
			default:
				zwl_receive_xevent(&ev);
				break;
		}
	}

	XFreeCursor(zdpy,arrow);
}

/* Recenters the title in the frame. */
void on_frame_expose(IMPObject *widget, void *data)
{
	ZWindow *frame = (ZWindow *)widget;
	ZLabel *label = NULL;
	ZWindow *w = NULL;
	IMPList *children;
	ZWindow *window = NULL;
	ZimClient *c = NULL;
	XGlyphInfo extents;
	XftFont *font = XftFontOpenName(zdpy,DefaultScreen(zdpy),"sans-8"); /* This is bad... */
	char *name = NULL;

	children = frame->children;
	
	while(children) {
		window = (ZWindow *)children->data;
		
		name = [window get_name];
		
		if(!name)
			name = "";
		
		if(!strncmp(name,"TITLE",5)) {
			label = (ZLabel *)window;
			
			XftTextExtents8(zdpy,font,[label get_label],strlen([label get_label]),&extents);
			[label move:(frame->width / 2) - (extents.width / 2):0];
			return;
		}
		children = children->next;
	}	
}

void on_frame_label_button_down(IMPObject *widget, void *data)
{
	ZWidget *frame = (ZWidget *)widget;

	frame = frame->parent;
	
	[frame receive:BUTTON_DOWN:data];
}

/* This basically implements a very basic form of sloppy focus. */
void on_frame_enter(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	ZWindow *window;
	ZimClient *c = NULL;
	IMPList *children;
	char *name;
	
	/* Find the window by searching through the frame's children list. */
	children = w->children;
	
	while(children) {
		window = (ZWindow *)children->data;
		name = [window get_name];
		
		if(!name)
			name = "";
			
		if(!strncmp(name,"XWINDOW",8)) {
			c = zimwm_find_client_by_zwindow(window);
			break;
		}

		children = children->next;
	}

	
	focus_client(c);
}

