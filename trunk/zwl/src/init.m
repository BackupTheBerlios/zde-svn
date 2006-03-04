/*
    zwl
    Copyright (C) 2004,2005,2006 zwl Developers

    zwl is the legal property of its developers, whose names are
    too numerous to list here.  Please refer to the COPYING file
    for the full text of this license and to the AUTHORS file for
    the complete list of developers.

    This program is i_free software; you can redistribute it and/or
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
int zscreen = 0;
IMPList *window_list = NULL;

/* Atoms */
Atom *z_atom;

static unsigned short int quit = 0;

/* Helper functions */
static ZWidget *find_widget(Window *w);
static void process_xevent(XEvent *ev);

void zwl_init(void)
{
	zdpy = XOpenDisplay(NULL);
	zscreen = DefaultScreen(zdpy);
	
	z_atom = i_calloc(100,sizeof(Atom));
	
	z_atom[UTF8_STRING] = XInternAtom(zdpy,"UTF8_STRING",False);
	z_atom[WM_NAME] = XInternAtom(zdpy,"WM_NAME",False);
	z_atom[WM_PROTOCOLS] = XInternAtom(zdpy,"WM_PROTOCOLS",False);
	z_atom[WM_DELETE_WINDOW] = XInternAtom(zdpy,"WM_DELETE_WINDOW",False);
	z_atom[WM_TAKE_FOCUS] = XInternAtom(zdpy,"WM_TAKE_FOCUS",False);
	
	z_atom[_NET_WM_WINDOW_TYPE] = XInternAtom(zdpy,"_NET_WM_WINDOW_TYPE",False);
	z_atom[_NET_WM_WINDOW_TYPE_NORMAL] = XInternAtom(zdpy,"_NET_WM_WINDOW_TYPE_NORMAL",False);
	z_atom[_NET_WM_WINDOW_TYPE_MENU] = XInternAtom(zdpy,"_NET_WM_WINDOW_TYPE_MENU",False);
	z_atom[_NET_SUPPORTED] = XInternAtom(zdpy,"_NET_SUPPORTED",False);
        z_atom[_NET_CLIENT_LIST] = XInternAtom(zdpy,"_NET_CLIENT_LIST",False);
        z_atom[_NET_NUMBER_OF_DESKTOPS] = XInternAtom(zdpy,"_NET_NUMBER_OF_DESKTOPS",False);
        z_atom[_NET_DESKTOP_GEOMETRY] = XInternAtom(zdpy,"_NET_DESKTOP_GEOMETRY",False);
        z_atom[_NET_DESKTOP_VIEWPORT] = XInternAtom(zdpy,"_NET_DESKTOP_VIEWPORT",False);
        z_atom[_NET_CURRENT_DESKTOP] = XInternAtom(zdpy,"_NET_CURRENT_DESKTOP",False);
        z_atom[_NET_DESKTOP_NAMES] = XInternAtom(zdpy,"_NET_DESKTOP_NAMES",False);
        z_atom[_NET_ACTIVE_WINDOW] = XInternAtom(zdpy,"_NET_ACTIVE_WINDOW",False);
        z_atom[_NET_WORKAREA] = XInternAtom(zdpy,"_NET_WORKAREA",False);
        z_atom[_NET_SUPPORTING_WM_CHECK] = XInternAtom(zdpy,"_NET_SUPPORTING_WM_CHECK",False);
        z_atom[_NET_VIRTUAL_ROOTS] = XInternAtom(zdpy,"_NET_VIRTUAL_ROOTS",False);
        z_atom[_NET_DESKTOP_LAYOUT] = XInternAtom(zdpy,"_NET_DESKTOP_LAYOUT",False);
        z_atom[_NET_SHOWING_DESKTOP] = XInternAtom(zdpy,"_NET_SHOWING_DESKTOP",False);
	z_atom[_NET_CLOSE_WINDOW] = XInternAtom(zdpy,"_NET_CLOSE_WINDOW",False);
	z_atom[_NET_MOVERESIZE_WINDOW] = XInternAtom(zdpy,"_NET_MOVERESIZE_WINDOW",False);
	z_atom[_NET_WM_MOVERESIZE] = XInternAtom(zdpy,"_NET_WM_MOVERESIZE",False);
        z_atom[_NET_RESTACK_WINDOW] = XInternAtom(zdpy,"_NET_RESTACK_WINDOW",False);
        z_atom[_NET_REQUEST_FRAME_EXTENTS] = XInternAtom(zdpy,"_NET_REQUEST_FRAME_EXTENTS",False);
	z_atom[_NET_WM_NAME] = XInternAtom(zdpy,"_NET_WM_NAME",False);
        z_atom[_NET_WM_VISIBLE_NAME] = XInternAtom(zdpy,"_NET_WM_VISIBLE_NAME",False);
        z_atom[_NET_WM_ICON_NAME] = XInternAtom(zdpy,"_NET_WM_ICON_NAME",False);
        z_atom[_NET_WM_VISIBLE_ICON_NAME] = XInternAtom(zdpy,"_NET_WM_VISIBLE_ICON_NAME",False);
        z_atom[_NET_WM_DESKTOP] = XInternAtom(zdpy,"_NET_WM_DESKTOP",False);
        z_atom[_NET_WM_STATE] = XInternAtom(zdpy,"_NET_WM_STATE",False);
        z_atom[_NET_WM_ALLOWED_ACTIONS] = XInternAtom(zdpy,"_NET_WM_ALLOWED_ACTIONS",False);
        z_atom[_NET_WM_STRUT] = XInternAtom(zdpy,"_NET_WM_STRUT",False);
        z_atom[_NET_WM_STRUT_PARTIAL] = XInternAtom(zdpy,"_NET_WM_STRUT_PARTIAL",False);
        z_atom[_NET_WM_ICON_GEOMETRY] = XInternAtom(zdpy,"_NET_WM_ICON_GEOMETRY",False);
        z_atom[_NET_WM_ICON] = XInternAtom(zdpy,"_NET_WM_ICON",False);
        z_atom[_NET_WM_PID] = XInternAtom(zdpy,"_NET_WM_PID",False);
        z_atom[_NET_WM_HANDLED_ICONS] = XInternAtom(zdpy,"_NET_WM_HANDLED_ICONS",False);
        z_atom[_NET_WM_USER_TIME] = XInternAtom(zdpy,"_NET_WM_USER_TYPE",False);
        z_atom[_NET_FRAME_EXTENTS] = XInternAtom(zdpy,"_NET_FRAME_EXTENTS",False);
	z_atom[_NET_WM_ACTION_MOVE] = XInternAtom(zdpy,"_NET_WM_ACTION_MOVE",False);
	z_atom[_NET_WM_ACTION_RESIZE] = XInternAtom(zdpy,"_NET_WM_ACTION_RESIZE",False);
	z_atom[_NET_WM_ACTION_MINIMIZE] = XInternAtom(zdpy,"_NET_WM_ACTION_MINIMIZE",False);
	z_atom[_NET_WM_ACTION_SHADE] = XInternAtom(zdpy,"_NET_WM_ACTION_SHADE",False);
	z_atom[_NET_WM_ACTION_STICK] = XInternAtom(zdpy,"_NET_WM_ACTION_STICK",False);
	z_atom[_NET_WM_ACTION_MAXIMIZE_HORZ] = XInternAtom(zdpy,"_NET_WM_ACTION_MAXIMIZE_HORZ",False);
	z_atom[_NET_WM_ACTION_MAXIMIZE_VERT] = XInternAtom(zdpy,"_NET_WM_ACTION_MAXIMIZE_VERT",False);
	z_atom[_NET_WM_ACTION_FULLSCREEN] = XInternAtom(zdpy,"_NET_WM_ACTION_FULLSCREEN",False);
	z_atom[_NET_WM_ACTION_CHANGE_DESKTOP] = XInternAtom(zdpy,"_NET_WM_ACTION_CHANGE_DESKTOP",False);
	z_atom[_NET_WM_ACTION_CLOSE] = XInternAtom(zdpy,"_NET_WM_ACTION_CLOSE",False);
}

Display *zwl_get_display(void)
{
	return zdpy;
}

void zwl_receive_xevent(XEvent *ev)
{
	if(ev) {
		process_xevent(ev);
	}
}

void zwl_main_loop_add_widget(ZWidget *w)
{
	if(window_list) {
		if(w) {
			[window_list append_data:w];
		}
	}
	else if(w){
		window_list = [IMPList alloc];
		[window_list init:1];
		window_list->data = w;
	}
}

void zwl_main_loop_remove_widget(ZWidget *w)
{
	ZWidget *widget = find_widget(w->window);
	ZWidget *w2;
	IMPList *list = window_list;
	
	if(widget) {
		while(list) {
			w2 = (ZWidget *)list->data;
			if(w2 == w->window) {
				[list delete_node];
			}
			list = list->next;	
		}
	}
}

void zwl_main_loop_start(void)
{
	XEvent ev;
	
	while(!quit) {
		XNextEvent(zdpy,&ev);
		process_xevent(&ev);	
	}
}

static void process_xevent(XEvent *ev)
{	
	XKeyEvent key;
	XButtonEvent button;
	XDestroyWindowEvent dest;
	XExposeEvent expose;
	XClientMessageEvent cmessage;
	XConfigureEvent configure;
	XMapRequestEvent mapreq;
	XUnmapEvent unmap;
	XConfigureRequestEvent conreq;
	XCrossingEvent cross;
	XPropertyEvent prop;
	
	ZWidget *w = NULL;

	switch(ev->type) {
			case KeyPress:
				key = ev->xkey;
				w = find_widget(key.window);		
				
				[w receive:KEY_PRESS:&ev->xkey];
				break;
			case ButtonPress:
				button = ev->xbutton;
				w = find_widget(button.window);
				
				[w receive:BUTTON_DOWN:&ev->xbutton];
				break;
			case ButtonRelease:
				button = ev->xbutton;
				w = find_widget(button.window);

				[w receive:BUTTON_UP:&ev->xbutton];
				break;
			case DestroyNotify:
				dest = ev->xdestroywindow;
				w = find_widget(dest.window);
				
				[w receive:DESTROY:&ev->xdestroywindow];
				break;
			case Expose:
				expose = ev->xexpose;
				w = find_widget(expose.window);

				[w receive:EXPOSE:&ev->xexpose];
				break;
			case ClientMessage:
				cmessage = ev->xclient;
				w = find_widget(cmessage.window);
				
				if(cmessage.data.l[0] == z_atom[WM_DELETE_WINDOW]) {
					[w receive:CLOSE:&ev->xclient];	
				}
				else {
					[w receive:CLIENT_MESSAGE:&ev->xclient];
				}
				break;
			case ConfigureNotify:
				configure = ev->xconfigure;
				w = find_widget(configure.window);

				[w receive:CONFIGURE:&ev->xconfigure];
				break;
			case MapRequest:
				mapreq = ev->xmaprequest;
				w = find_widget(mapreq.parent);

				[w receive:MAP_REQUEST:&ev->xmaprequest];
				break;
			case UnmapNotify:
				unmap = ev->xunmap;
				w = find_widget(unmap.window);

				[w receive:UNMAP:&ev->xunmap];				
				break;
			case ConfigureRequest:
				conreq = ev->xconfigurerequest;
				w = find_widget(conreq.window);
				
				[w receive:CONFIGURE_REQUEST:&ev->xconfigurerequest];
				break;
			case EnterNotify:
				cross = ev->xcrossing;
				w = find_widget(cross.window);

				[w receive:POINTER_ENTER:&ev->xcrossing];
				break;
			case LeaveNotify:
				cross = ev->xcrossing;
				w = find_widget(cross.window);

				[w receive:POINTER_LEAVE:&ev->xcrossing];
				break;
		/*	case PropertyNotify:
				prop = ev->xproperty;
				w = find_widget(prop.window);
				
				[w receive:PROPERTY:&ev->xproperty];
				break;
		*/	default:
				w = find_widget(ev->xany.window);
				[w receive:DEFAULT:ev];
		}
}

void zwl_main_loop_quit(void)
{
	quit = 1;
	[window_list delete_list];

	window_list = NULL;
}

static ZWidget *find_widget(Window *w)
{
	IMPList *list = window_list;
	ZWidget *widget;
	
	while(list) {
		widget = (ZWidget *)list->data;
	
		if(widget->window == w) { /* We've found our widget */
			return widget;
		}
		
		list = list->next;
	}

	return NULL;
}
