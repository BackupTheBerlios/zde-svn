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

ObjXCBConnection *zc;
IMPList *window_list = NULL;

/* Atoms */
ObjXCBAtom **zwl_atom;

static unsigned short int quit = 0;

/* Helper functions */
static ZWidget *find_widget(Window *w);
//static void process_xevent(XEvent *ev);

void zwl_init(void)
{
	ObjXCBInternAtomReply **atom_reps;
	zc = [ObjXCBConnection alloc];
	[zc init];

	window_list = [IMPList alloc];
	[window_list init];

	zwl_atom = i_calloc(100,sizeof(ObjXCBInternAtomReply *));
	atom_reps = i_calloc(100,sizeof(ObjXCBInternAtomReply *));

	atom_reps[UTF8_STRING] = [zc InternAtom:0:11:"UTF8_STRING"];
	atom_reps[WM_NAME] = [zc InternAtom:0:7:"WM_NAME"];
	atom_reps[WM_PROTOCOLS] = [zc InternAtom:0:12:"WM_PROTOCOLS"];
	atom_reps[WM_DELETE_WINDOW] = [zc InternAtom:0:17:"WM_DELETE_WINDOW"];
	atom_reps[WM_TAKE_FOCUS] = [zc InternAtom:0:13:"WM_TAKE_FOCUS"];
	
	atom_reps[_NET_WM_WINDOW_TYPE] = [zc InternAtom:0:19:"_NET_WM_WINDOW_TYPE"];
	atom_reps[_NET_WM_WINDOW_TYPE_NORMAL] = [zc InternAtom:0:26:"_NET_WM_WINDOW_TYPE_NORMAL"];
	atom_reps[_NET_WM_WINDOW_TYPE_MENU] = [zc InternAtom:0:24:"_NET_WM_WINDOW_TYPE_MENU"];
	atom_reps[_NET_WM_WINDOW_TYPE_DIALOG] = [zc InternAtom:0:26:"_NET_WM_WINDOW_TYPE_DIALOG"];
	atom_reps[_NET_SUPPORTED] = [zc InternAtom:0:14:"_NET_SUPPORTED"];
        atom_reps[_NET_CLIENT_LIST] = [zc InternAtom:0:16:"_NET_CLIENT_LIST"];
	atom_reps[_NET_CLIENT_LIST_STACKING] = [zc InternAtom:0:25:"_NET_CLIENT_LIST_STACKING"];
        atom_reps[_NET_NUMBER_OF_DESKTOPS] = [zc InternAtom:0:23:"_NET_NUMBER_OF_DESKTOPS"];
        atom_reps[_NET_DESKTOP_GEOMETRY] = [zc InternAtom:0:21:"_NET_DESKTOP_GEOMETRY"];
        atom_reps[_NET_DESKTOP_VIEWPORT] = [zc InternAtom:0:21:"_NET_DESKTOP_VIEWPORT"];
        atom_reps[_NET_CURRENT_DESKTOP] = [zc InternAtom:0:19:"_NET_CURRENT_DESKTOP"];
        atom_reps[_NET_DESKTOP_NAMES] = [zc InternAtom:0:18:"_NET_DESKTOP_NAMES"];
        atom_reps[_NET_ACTIVE_WINDOW] = [zc InternAtom:0:18:"_NET_ACTIVE_WINDOW"];
        atom_reps[_NET_WORKAREA] = [zc InternAtom:0:13:"_NET_WORKAREA"];
        atom_reps[_NET_SUPPORTING_WM_CHECK] = [zc InternAtom:0:24:"_NET_SUPPORTING_WM_CHECK"];
        atom_reps[_NET_VIRTUAL_ROOTS] = [zc InternAtom:0:18:"_NET_VIRTUAL_ROOTS"];
        atom_reps[_NET_DESKTOP_LAYOUT] = [zc InternAtom:0:19:"_NET_DESKTOP_LAYOUT"];
        atom_reps[_NET_SHOWING_DESKTOP] = [zc InternAtom:0:20:"_NET_SHOWING_DESKTOP"];
	atom_reps[_NET_CLOSE_WINDOW] = [zc InternAtom:0:17:"_NET_CLOSE_WINDOW"];
	atom_reps[_NET_MOVERESIZE_WINDOW] = [zc InternAtom:0:21:"_NET_MOVERESIZE_WINDOW"];
	atom_reps[_NET_WM_MOVERESIZE] = [zc InternAtom:0:18:"_NET_WM_MOVERESIZE"];
        atom_reps[_NET_RESTACK_WINDOW] = [zc InternAtom:0:19:"_NET_RESTACK_WINDOW"];
        atom_reps[_NET_REQUEST_FRAME_EXTENTS] = [zc InternAtom:0:26:"_NET_REQUEST_FRAME_EXTENTS"];
	atom_reps[_NET_WM_NAME] = [zc InternAtom:0:12:"_NET_WM_NAME"];
        atom_reps[_NET_WM_VISIBLE_NAME] = [zc InternAtom:0:20:"_NET_WM_VISIBLE_NAME"];
        atom_reps[_NET_WM_ICON_NAME] = [zc InternAtom:0:17:"_NET_WM_ICON_NAME"];
        atom_reps[_NET_WM_VISIBLE_ICON_NAME] = [zc InternAtom:0:25:"_NET_WM_VISIBLE_ICON_NAME"];
        atom_reps[_NET_WM_DESKTOP] = [zc InternAtom:0:15:"_NET_WM_DESKTOP"];
        atom_reps[_NET_WM_STATE] = [zc InternAtom:0:13:"_NET_WM_STATE"];
        atom_reps[_NET_WM_ALLOWED_ACTIONS] = [zc InternAtom:0:23:"_NET_WM_ALLOWED_ACTIONS"];
        atom_reps[_NET_WM_STRUT] = [zc InternAtom:0:13:"_NET_WM_STRUT"];
        atom_reps[_NET_WM_STRUT_PARTIAL] = [zc InternAtom:0:21:"_NET_WM_STRUT_PARTIAL"];
        atom_reps[_NET_WM_ICON_GEOMETRY] = [zc InternAtom:0:21:"_NET_WM_ICON_GEOMETRY"];
        atom_reps[_NET_WM_ICON] = [zc InternAtom:0:12:"_NET_WM_ICON"];
        atom_reps[_NET_WM_PID] = [zc InternAtom:0:11:"_NET_WM_PID"];
        atom_reps[_NET_WM_HANDLED_ICONS] = [zc InternAtom:0:21:"_NET_WM_HANDLED_ICONS"];
        atom_reps[_NET_WM_USER_TIME] = [zc InternAtom:0:17:"_NET_WM_USER_TIME"];
        atom_reps[_NET_FRAME_EXTENTS] = [zc InternAtom:0:18:"_NET_FRAME_EXTENTS"];
	atom_reps[_NET_WM_ACTION_MOVE] = [zc InternAtom:0:19:"_NET_WM_ACTION_MOVE"];
	atom_reps[_NET_WM_ACTION_RESIZE] = [zc InternAtom:0:20:"_NET_WM_ACTION_RESIZE"];
	atom_reps[_NET_WM_ACTION_MINIMIZE] = [zc InternAtom:0:23:"_NET_WM_ACTION_MINIMIZE"];
	atom_reps[_NET_WM_ACTION_SHADE] = [zc InternAtom:0:20:"_NET_WM_ACTION_SHADE"];
	atom_reps[_NET_WM_ACTION_STICK] = [zc InternAtom:0:20:"_NET_WM_ACTION_STICK"];
	atom_reps[_NET_WM_ACTION_MAXIMIZE_HORZ] = [zc InternAtom:0:28:"_NET_WM_ACTION_MAXIMIZE_HORZ"];
	atom_reps[_NET_WM_ACTION_MAXIMIZE_VERT] = [zc InternAtom:0:28:"_NET_WM_ACTION_MAXIMIZE_VERT"];
	atom_reps[_NET_WM_ACTION_FULLSCREEN] = [zc InternAtom:0:25:"_NET_WM_ACTION_FULLSCREEN"];
	atom_reps[_NET_WM_ACTION_CHANGE_DESKTOP] = [zc InternAtom:0:29:"_NET_WM_ACTION_CHANGE_DESKTOP"];
	atom_reps[_NET_WM_ACTION_CLOSE] = [zc InternAtom:0:20:"_NET_WM_ACTION_CLOSE"];	

	zwl_atom[UTF8_STRING] = [atom_reps[UTF8_STRING] get_atom];
	zwl_atom[WM_NAME] = [atom_reps[WM_NAME] get_atom];
	zwl_atom[WM_PROTOCOLS] = [atom_reps[WM_PROTOCOLS] get_atom];
	zwl_atom[WM_DELETE_WINDOW] = [atom_reps[WM_DELETE_WINDOW] get_atom];
	zwl_atom[WM_TAKE_FOCUS] = [atom_reps[WM_TAKE_FOCUS] get_atom];
	
	zwl_atom[_NET_WM_WINDOW_TYPE] = [atom_reps[_NET_WM_WINDOW_TYPE] get_atom];
	zwl_atom[_NET_WM_WINDOW_TYPE_NORMAL] = [atom_reps[_NET_WM_WINDOW_TYPE_NORMAL] get_atom];
	zwl_atom[_NET_WM_WINDOW_TYPE_MENU] = [atom_reps[_NET_WM_WINDOW_TYPE_MENU] get_atom];
	zwl_atom[_NET_WM_WINDOW_TYPE_DIALOG] = [atom_reps[_NET_WM_WINDOW_TYPE_DIALOG] get_atom];
	zwl_atom[_NET_SUPPORTED] = [atom_reps[_NET_SUPPORTED] get_atom];
        zwl_atom[_NET_CLIENT_LIST] = [atom_reps[_NET_CLIENT_LIST] get_atom];
	zwl_atom[_NET_CLIENT_LIST_STACKING] = [atom_reps[_NET_CLIENT_LIST_STACKING] get_atom];
        zwl_atom[_NET_NUMBER_OF_DESKTOPS] = [atom_reps[_NET_NUMBER_OF_DESKTOPS] get_atom];
        zwl_atom[_NET_DESKTOP_GEOMETRY] = [atom_reps[_NET_DESKTOP_GEOMETRY] get_atom];
        zwl_atom[_NET_DESKTOP_VIEWPORT] = [atom_reps[_NET_DESKTOP_VIEWPORT] get_atom];
        zwl_atom[_NET_CURRENT_DESKTOP] = [atom_reps[_NET_CURRENT_DESKTOP] get_atom];
        zwl_atom[_NET_DESKTOP_NAMES] = [atom_reps[_NET_DESKTOP_NAMES] get_atom];
        zwl_atom[_NET_ACTIVE_WINDOW] = [atom_reps[_NET_ACTIVE_WINDOW] get_atom];
        zwl_atom[_NET_WORKAREA] = [atom_reps[_NET_WORKAREA] get_atom];
        zwl_atom[_NET_SUPPORTING_WM_CHECK] = [atom_reps[_NET_SUPPORTING_WM_CHECK] get_atom];
        zwl_atom[_NET_VIRTUAL_ROOTS] = [atom_reps[_NET_VIRTUAL_ROOTS] get_atom];
        zwl_atom[_NET_DESKTOP_LAYOUT] = [atom_reps[_NET_DESKTOP_LAYOUT] get_atom];
        zwl_atom[_NET_SHOWING_DESKTOP] = [atom_reps[_NET_SHOWING_DESKTOP] get_atom];
	zwl_atom[_NET_CLOSE_WINDOW] = [atom_reps[_NET_CLOSE_WINDOW] get_atom];
	zwl_atom[_NET_MOVERESIZE_WINDOW] = [atom_reps[_NET_MOVERESIZE_WINDOW] get_atom];
	zwl_atom[_NET_WM_MOVERESIZE] = [atom_reps[_NET_WM_MOVERESIZE] get_atom];
        zwl_atom[_NET_RESTACK_WINDOW] = [atom_reps[_NET_RESTACK_WINDOW] get_atom];
        zwl_atom[_NET_REQUEST_FRAME_EXTENTS] = [atom_reps[_NET_REQUEST_FRAME_EXTENTS] get_atom];
	zwl_atom[_NET_WM_NAME] = [atom_reps[_NET_WM_NAME] get_atom];
        zwl_atom[_NET_WM_VISIBLE_NAME] = [atom_reps[_NET_WM_VISIBLE_NAME] get_atom];
        zwl_atom[_NET_WM_ICON_NAME] = [atom_reps[_NET_WM_ICON_NAME] get_atom];
        zwl_atom[_NET_WM_VISIBLE_ICON_NAME] = [atom_reps[_NET_WM_VISIBLE_ICON_NAME] get_atom];
        zwl_atom[_NET_WM_DESKTOP] = [atom_reps[_NET_WM_DESKTOP] get_atom];
        zwl_atom[_NET_WM_STATE] = [atom_reps[_NET_WM_STATE] get_atom];
        zwl_atom[_NET_WM_ALLOWED_ACTIONS] = [atom_reps[_NET_WM_ALLOWED_ACTIONS] get_atom];
        zwl_atom[_NET_WM_STRUT] = [atom_reps[_NET_WM_STRUT] get_atom];
        zwl_atom[_NET_WM_STRUT_PARTIAL] = [atom_reps[_NET_WM_STRUT_PARTIAL] get_atom];
        zwl_atom[_NET_WM_ICON_GEOMETRY] = [atom_reps[_NET_WM_ICON_GEOMETRY] get_atom];
        zwl_atom[_NET_WM_ICON] = [atom_reps[_NET_WM_ICON] get_atom];
        zwl_atom[_NET_WM_PID] = [atom_reps[_NET_WM_PID] get_atom];
        zwl_atom[_NET_WM_HANDLED_ICONS] = [atom_reps[_NET_WM_HANDLED_ICONS] get_atom];
        zwl_atom[_NET_WM_USER_TIME] = [atom_reps[_NET_WM_USER_TIME] get_atom];
        zwl_atom[_NET_FRAME_EXTENTS] = [atom_reps[_NET_FRAME_EXTENTS] get_atom];
	zwl_atom[_NET_WM_ACTION_MOVE] = [atom_reps[_NET_WM_ACTION_MOVE] get_atom];
	zwl_atom[_NET_WM_ACTION_RESIZE] = [atom_reps[_NET_WM_ACTION_RESIZE] get_atom];
	zwl_atom[_NET_WM_ACTION_MINIMIZE] = [atom_reps[_NET_WM_ACTION_MINIMIZE] get_atom];
	zwl_atom[_NET_WM_ACTION_SHADE] = [atom_reps[_NET_WM_ACTION_SHADE] get_atom];
	zwl_atom[_NET_WM_ACTION_STICK] = [atom_reps[_NET_WM_ACTION_STICK] get_atom];
	zwl_atom[_NET_WM_ACTION_MAXIMIZE_HORZ] = [atom_reps[_NET_WM_ACTION_MAXIMIZE_HORZ] get_atom];
	zwl_atom[_NET_WM_ACTION_MAXIMIZE_VERT] = [atom_reps[_NET_WM_ACTION_MAXIMIZE_VERT] get_atom];
	zwl_atom[_NET_WM_ACTION_FULLSCREEN] = [atom_reps[_NET_WM_ACTION_FULLSCREEN] get_atom];
	zwl_atom[_NET_WM_ACTION_CHANGE_DESKTOP] = [atom_reps[_NET_WM_ACTION_CHANGE_DESKTOP] get_atom];
	zwl_atom[_NET_WM_ACTION_CLOSE] = [atom_reps[_NET_WM_ACTION_CLOSE] get_atom];	

	free(atom_reps);
}

ObjXCBConnection *zwl_get_connection(void)
{
	return zc;
}

/*
void zwl_receive_xevent(XEvent *ev)
{
	if(ev) {
		process_xevent(ev);
	}
}
*/

void zwl_main_loop_add_widget(ZWidget *w)
{
	if(window_list && w)
		[window_list append:w];
}

void zwl_main_loop_remove_widget(ZWidget *w)
{
	IMPListIterator *iter = [window_list iterator];

	while([iter has_next]) {
		
		if([iter get_data] == w) {
			[iter del];
		}

		[iter next];
	}
}

void zwl_main_loop_start(void)
{
	XEvent ev;
#if 0	
	while(!quit) {
		XNextEvent(zdpy,&ev);
		process_xevent(&ev);	
	}
#endif
}

#if 0
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
				w = find_widget((Window *)key.window);		
				
				[w receive:KEY_PRESS:&ev->xkey];
				break;
			case ButtonPress:
				button = ev->xbutton;
				w = find_widget((Window *)button.window);
				
				[w receive:BUTTON_DOWN:&ev->xbutton];
				break;
			case ButtonRelease:
				button = ev->xbutton;
				w = find_widget((Window *)button.window);

				[w receive:BUTTON_UP:&ev->xbutton];
				break;
			case Expose:
				expose = ev->xexpose;
				w = find_widget((Window *)expose.window);

				[w receive:EXPOSE:&ev->xexpose];
				break;
			case ClientMessage:
				cmessage = ev->xclient;
				w = find_widget((Window *)cmessage.window);
				
				if(cmessage.data.l[0] == z_atom[WM_DELETE_WINDOW]) {
					[w receive:CLOSE:&ev->xclient];	
				}
				else {
					[w receive:CLIENT_MESSAGE:&ev->xclient];
				}
				break;
			case ConfigureNotify:
				configure = ev->xconfigure;
				w = find_widget((Window *)configure.window);

				[w receive:CONFIGURE:&ev->xconfigure];
				break;
			case MapRequest:
				mapreq = ev->xmaprequest;
				w = find_widget((Window *)mapreq.parent);

				[w receive:MAP_REQUEST:&ev->xmaprequest];
				break;
			case UnmapNotify:
				unmap = ev->xunmap;
				w = find_widget((Window *)unmap.window);

				[w receive:UNMAP:&ev->xunmap];				
				break;
			case ConfigureRequest:
				conreq = ev->xconfigurerequest;
				w = find_widget((Window *)conreq.window);
				
				[w receive:CONFIGURE_REQUEST:&ev->xconfigurerequest];
				break;
			case EnterNotify:
				cross = ev->xcrossing;
				w = find_widget((Window *)cross.window);

				[w receive:POINTER_ENTER:&ev->xcrossing];
				break;
			case LeaveNotify:
				cross = ev->xcrossing;
				w = find_widget((Window *)cross.window);

				[w receive:POINTER_LEAVE:&ev->xcrossing];
				break;
			case PropertyNotify:
				prop = ev->xproperty;
				w = find_widget((Window *)prop.window);
				
				[w receive:PROPERTY:&ev->xproperty];
				break;
			default:
				w = find_widget((Window *)ev->xany.window);
				[w receive:DEFAULT:ev];
		}
}
#endif

void zwl_main_loop_quit(void)
{
	quit = 1;
	[window_list delete_list];

	window_list = NULL;
}

#if 0
static ZWidget *find_widget(Window *w)
{
}

#endif
