/*
    zwl
    Copyright (C) 2004,2005,2006 zwl Developers

    zwl is the legal property of its developers, whose names are
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

#include "zwl.h"

Display *zdpy = NULL;
IMPList *window_list = NULL;

static Atom wm_delete_window;
static unsigned short int quit = 0;

/* Helper functions */
static ZWidget *find_widget(Window *w);

void zwl_init(void)
{
	zdpy = XOpenDisplay(NULL);
}

Display *zwl_get_display(void)
{
	return zdpy;
}

void zwl_main_loop_add_widget(ZWidget *w)
{
	if(window_list) {
		if(w) {
			[window_list append_data:w];
		}
	}
	else {
		window_list = [IMPList alloc];
		[window_list init:1];
		window_list->data = w;
	}
}

void zwl_main_loop_start(void)
{
	XEvent ev;
	XKeyEvent key;
	XButtonEvent button;
	XDestroyWindowEvent dest;
	XExposeEvent expose;
	XClientMessageEvent cmessage;
	XConfigureEvent configure;
	
	ZWidget *w = NULL;

	wm_delete_window = XInternAtom(zdpy,"WM_DELETE_WINDOW",False);
	
	while(!quit) {
		XNextEvent(zdpy,&ev);
		
		switch(ev.type) {
			case KeyPress:
				key = ev.xkey;
				w = find_widget(key.window);		
				
				[w receive:KEY_PRESS:&ev.xkey];
				break;
			case ButtonPress:
				button = ev.xbutton;
				w = find_widget(button.window);
				
				[w receive:BUTTON_DOWN:&ev.xbutton];
				break;
			case ButtonRelease:
				button = ev.xbutton;
				w = find_widget(button.window);

				[w receive:BUTTON_UP:&ev.xbutton];
				break;
			case DestroyNotify:
				dest = ev.xdestroywindow;
				w = find_widget(dest.window);

				[w receive:DESTROY:&ev.xdestroywindow];
				break;
			case Expose:
				expose = ev.xexpose;
				w = find_widget(expose.window);

				[w receive:EXPOSE:w];
				break;
			case ClientMessage:
				cmessage = ev.xclient;
				w = find_widget(cmessage.window);

				if(cmessage.data.l[0] == wm_delete_window) {
					[w receive:CLOSE:&ev.xclient];	
				}
				break;
			case ConfigureNotify:
				configure = ev.xconfigure;
				w = find_widget(configure.window);

				[w receive:CONFIGURE:&ev.xconfigure];
				break;
			default:
				w = find_widget(ev.xany.window);
				[w receive:DEFAULT:&ev];
		}
	}
}

void zwl_main_loop_quit(void)
{
	quit = 1;
	[window_list release];
}

static ZWidget *find_widget(Window *w)
{
	int i;
	IMPList *list = window_list;
	ZWidget *widget;
	
	while(list) {
		widget = (ZWidget *)list->data;
		
		//printf("window:%d vs window:%d\n",widget->window,w);
		
		if(widget->window == w) { /* We've found our widget */
			return widget;
		}
		
		list = list->next;
	}

	return NULL;
}
