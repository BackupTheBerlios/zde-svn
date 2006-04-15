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

	w->window = NULL;
	
	c = zimwm_find_client_by_zwindow(w);
	zimwm_remove_client(c);
	
	[w->parent destroy];
	[w destroy];
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

void on_maximise_button_down(IMPObject *widget, void *data)
{
	ZimClient *c = NULL;
	ZWindow *frame = (ZWindow *)widget;
	ZWindow *window = NULL;
	IMPList *children = NULL;
	char *name = NULL;

	frame = (ZWindow *)frame->parent;
	
	children = frame->children;

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
	
	if(!c)
		return;
	
	/* FIXME Should check window's struts via _NET_WORKAREA property and only resize to fit that area... */
	
	if(c->maximised == True) {	
		[c move:c->oldx:c->oldy];
		[c resize:c->oldwidth:c->oldheight];
		c->oldx = -1;
		c->oldy = -1;
		c->oldwidth = 0;
		c->oldy = 0;
		
		c->maximised = False;
		return;
	}

	c->oldx = frame->x;
	c->oldy = frame->y;
	c->oldwidth = frame->width;
	c->oldheight = frame->height;
	
	frame->width = [[zones[curr_zone] get_current_workspace] get_width];
	frame->height = [[zones[curr_zone] get_current_workspace] get_height];
	
	[c move:0:0];
	[c resize:frame->width:frame->height];
	c->maximised = True;
}

void on_minimise_button_down(IMPObject *widget, void *data)
{
	/* FIXME Should iconify the window, whatever that means. */
}

/* Moves the window around. */
void on_frame_button_down(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	Window w1,w2;
	XButtonEvent *button = (XButtonEvent *)data;
	XEvent ev;
	Cursor arrow = XCreateFontCursor(zdpy,XC_fleur);
	ZimClient *c = NULL;
	unsigned int mask;
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
			
			if(button->subwindow != NULL && !(button->state & Mod1Mask))
				return;
			
			break;
		}

		children = children->next;
	}
	
	XGrabPointer(zdpy,(Window)[zones[curr_zone] get_root]->window,True,PointerMotionMask | ButtonReleaseMask,
			GrabModeAsync,GrabModeAsync,None,arrow,CurrentTime);
	XQueryPointer(zdpy,(Window)w->window,&w1,&w2,&x,&y,&x1,&y1,&mask);

	[c raise];
	
	while(1) {
		XNextEvent(zdpy,&ev);

		switch(ev.type) {
			case MotionNotify:
				if(c) {
					[c move:ev.xmotion.x_root - x1:ev.xmotion.y_root - y1];	
					[c snap];
				}
				break;
			case ButtonRelease:
				XUngrabPointer(zdpy,CurrentTime);
				[c raise];
				return;
			default:
				zwl_receive_xevent(&ev);
				break;
		}
	}

	XFreeCursor(zdpy,arrow);
}

/* Recenters the title in the frame. */
void on_frame_configure(IMPObject *widget, void *data)
{
	ZWindow *frame = (ZWindow *)widget;
	ZLabel *label = NULL;
	IMPList *children;
	ZWindow *window = NULL;
	XGlyphInfo *extents;
	char *name = NULL;

	children = frame->children;
	
	while(children) {
		window = (ZWindow *)children->data;
		
		name = [window get_name];
		
		if(!name)
			name = "";
		
		if(!strncmp(name,"TITLE",5)) {
			label = (ZLabel *)window;
			
			extents = [label get_text_extents];
			[label move:(frame->width / 2) - (extents->width / 2):0];

			i_free(extents);
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
			focus_client(c);
			return;
		}

		children = children->next;
	}
}

void on_win_property_notify(IMPObject *widget, void *data)
{
	XPropertyEvent *ev = (XPropertyEvent *)data;
	ZimClient *c = NULL;
	XSizeHints *oldhints;
	char *name1 = NULL;
	IMPList *list;
	ZWindow *w;

	c = zimwm_find_client_by_zwindow((ZWindow *)widget);
	
	if(!c)
		return;
	
	if(ev->atom == XA_WM_NORMAL_HINTS) {
		oldhints = c->size_hints;
		
		[c get_properties];
		[c resize:c->window->parent->width + c->size_hints->base_width - oldhints->base_width:
			  c->window->parent->height + c->size_hints->base_height - oldhints->base_height];
	}
	else if(ev->atom == XA_WM_NAME || ev->atom == z_atom[_NET_WM_NAME]) {
		[c get_properties];
		
		list = c->window->parent->children;

		while(list) {
			w = list->data;
			name1 = [w get_name];

			if(!strncmp(name1,"TITLE",5)) {
				[w set_label:[c->window get_title]];
			
				/* FIXME Need to make a function to recenter the title. */
				on_frame_configure(c->window->parent,NULL);
			}
			
			list = list->next;
		}	
	}
//	else if(ev->atom == z_atom[_NET_WM_STRUT] || ev->atom == z_atom[_NET_WM_STRUT_PARTIAL]) {
//		[c get_properties];
//	}
}

void resize(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	ZWindow *myself = (ZWindow *)widget;
	ZWindow *right,*left,*bottom,*bottom_right;
	Window w1,w2;
	XEvent ev;
	Cursor arrow = XCreateFontCursor(zdpy,XC_bottom_right_corner);
	IMPList *children = NULL;
	ZimClient *c = NULL;
	ZWindow *window,*win1;
	char *name;
	int width;
	int height;
	int w_resize_inc = 1;
	int h_resize_inc = 1;
	
	w = (ZWindow *)w->parent;
	

	XGrabPointer(zdpy,(Window)[zones[curr_zone] get_root]->window,True,PointerMotionMask | ButtonReleaseMask,
			GrabModeAsync,GrabModeAsync,None,arrow,CurrentTime);

	/* Find the window by searching through the frame's children list. */
	children = w->children;

	if(!children)
		return;
	
	while(children) {
		window = children->data;
		name = [window get_name];
		
		if(!name)
			name = "";
			
		if(!strncmp(name,"XWINDOW",8)) {
			c = zimwm_find_client_by_zwindow(window);
			
			if(!c)
				return;
			win1 = window;
			if(c && c->size_hints) {
				if(c->size_hints->max_width == c->size_hints->min_width && 
						c->size_hints->max_height == c->size_hints->min_height)
					return;
				
				w_resize_inc = c->size_hints->width_inc;
				h_resize_inc = c->size_hints->height_inc;

				if(w_resize_inc <= 0)
					w_resize_inc = 1;
				if(h_resize_inc <= 0)
					h_resize_inc = 1;
				
			}
		}
		else if(!strncmp(name,"RIGHT_HANDLE",8)) {
			right = window;
		}
		else if(!strncmp(name,"LEFT_HANDLE",7)) {
			left = window;
		}
		else if(!strncmp(name,"BOTTOM_HANDLE",13)) {
			bottom = window;
		}
		else if(!strncmp(name,"BOTTOM_RIGHT_HANDLE",19)) {
			bottom_right = window;
		}

		children = children->next;
	}
	
	while(1) {
		XNextEvent(zdpy,&ev);
		
		switch(ev.type) {
				case MotionNotify:
					name = [myself get_name];
		
					if(!name)
						name = "";
						
					if(!strncmp(name,"RIGHT_HANDLE",8)) {	
						width = abs(w->x - ev.xmotion.x_root);
						width -= (width) % w_resize_inc;
						height = w->height;
					}
					else if(!strncmp(name,"LEFT_HANDLE",7)) {	
						width = abs(w->x - ev.xmotion.x_root);
						width -= (width) % w_resize_inc;
						height = w->height;
					}
					else if(!strncmp(name,"BOTTOM_HANDLE",13)) {	
						height = abs(w->y - ev.xmotion.y_root);
						height -= (height) % h_resize_inc;
						width = w->width;
					}
					else if(!strncmp(name,"BOTTOM_RIGHT_HANDLE",19)) {	
						width = abs(w->x - ev.xmotion.x_root);
						width -= (width) % w_resize_inc;
						height = abs(w->y - ev.xmotion.y_root);
						height -= (height) % h_resize_inc;
					}
					else {
						width = w->width;
						height = w->height;
					}
					
					if(c->size_hints) {
						if((c->size_hints->max_width == c->size_hints->min_width) && 
								c->size_hints->max_width > 0 && c->size_hints->min_width > 0)
							width = c->size_hints->max_width;
						else if((width > c->size_hints->max_width) && c->size_hints->max_width > 0)
							width = c->size_hints->max_width;	
						else if((width < c->size_hints->min_width) && c->size_hints->min_width > 0)
							width = c->size_hints->min_width;
						
						if((c->size_hints->max_height == c->size_hints->min_height) &&
								c->size_hints->max_height > 0 && c->size_hints->min_height > 0)
							height = c->size_hints->max_height;
						else if((height < c->size_hints->min_height) && c->size_hints->min_height > 0)
							height = c->size_hints->min_height;
						else if((height > c->size_hints->max_height) && c->size_hints->max_height > 0)
							height = c->size_hints->max_height;
					}
			
					[c resize:width:height:left:right:bottom:bottom_right];
					
					break;		
				case ButtonRelease:
					XUngrabPointer(zdpy,CurrentTime);
					return;
				default:
					zwl_receive_xevent(&ev);
					break;
		}
	}

	XFreeCursor(zdpy,arrow);
}

void on_win_button_down(IMPObject *widget, void *data)
{
	ZWindow *win = (ZWindow *)widget;
	XButtonEvent *ev = (XButtonEvent *)data;
	ZimClient *c = NULL;
	
	c = zimwm_find_client_by_zwindow(win);

	if(!c)
		return;

	if(ev->state & Mod1Mask)
		[c->window->parent receive:BUTTON_DOWN:ev];
}


