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
static ZWidget *_find_widget(XCBWINDOW *w);
//static void process_xevent(XEvent *ev);

void zwl_init(void)
{
	ObjXCBInternAtomReply **atom_reps;
	zc = [ObjXCBConnection alloc];
	[zc init];

	zwl_root = [ZWidget alloc];
	[zwl_root init];
	zwl_root->window = [zc get_root_window];

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
	XCBGenericEvent *ev;
	XCBKeyPressEvent *key;
	XCBButtonPressEvent *button;
	XCBButtonReleaseEvent *buttonrel;
	XCBExposeEvent *expose;
	XCBClientMessageEvent *cmessage;
	XCBConfigureNotifyEvent *configure;
	XCBMapRequestEvent *mapreq;
	XCBUnmapNotifyEvent *unmap;
	XCBConfigureRequestEvent *conreq;
	XCBEnterNotifyEvent *cross;
	XCBLeaveNotifyEvent *crossleave;
	XCBPropertyNotifyEvent *prop;

	ZWidget *w = NULL;
	
	while(!quit) {
		ev = [zc poll_next_event:NULL];
		if(ev) {
			switch(ev->response_type) {
				case XCBKeyPress:
					key = (XCBKeyPressEvent *)ev;
					w = _find_widget(&key->event);	
					
					[w receive:KEY_PRESS:key];
					break;
				case XCBButtonPress:
					button = (XCBButtonPressEvent *)ev;
					w = _find_widget(&button->event);
					printf("%d\n",w);	
					[w receive:BUTTON_DOWN:button];
					break;
				case XCBButtonRelease:
					buttonrel = (XCBButtonReleaseEvent *)ev;
					w = _find_widget(&buttonrel->event);

					[w receive:BUTTON_UP:buttonrel];
					break;
				case XCBExpose:
					expose = (XCBExposeEvent *)ev;
					w = _find_widget(&expose->window);

					[w receive:EXPOSE:expose];
					break;
				case XCBClientMessage:
					cmessage = (XCBClientMessageEvent *)ev;
					w = _find_widget(&cmessage->window);
					/*
					if(cmessage.data.l[0] == zwl_atom[WM_DELETE_WINDOW]) {
						[w receive:CLOSE:cmessage];	
					}
					else {
						[w receive:CLIENT_MESSAGE:cmessage];
					}
					*/
					break;
				case XCBConfigureNotify:
					configure = (XCBConfigureNotifyEvent *)ev;
					w = _find_widget(&configure->event);

					[w receive:CONFIGURE:configure];
					break;
				case XCBMapRequest:
					mapreq = (XCBMapRequestEvent *)ev;
					w = _find_widget(&mapreq->parent);

					[w receive:MAP_REQUEST:mapreq];
					break;
				case XCBUnmapNotify:
					unmap = (XCBUnmapNotifyEvent *)ev;
					w = _find_widget(&unmap->event);

					[w receive:UNMAP:unmap];				
					break;
				case XCBConfigureRequest:
					conreq = (XCBConfigureRequestEvent *)ev;
					w = _find_widget(&conreq->window);
					
					[w receive:CONFIGURE_REQUEST:conreq];
					break;
				case XCBEnterNotify:
					cross = (XCBEnterNotifyEvent *)ev;
					w = _find_widget(&cross->event);

					[w receive:POINTER_ENTER:cross];
					break;
				case XCBLeaveNotify:
					crossleave = (XCBLeaveNotifyEvent *)ev;
					w = _find_widget(&crossleave->event);

					[w receive:POINTER_LEAVE:crossleave];
					break;
				case XCBPropertyNotify:
					prop = (XCBPropertyNotifyEvent *)ev;
					w = _find_widget(&prop->window);
					
					[w receive:PROPERTY:prop];
					break;

				default:
					break;

			}
		}

		[zc flush];
	}
}


void zwl_main_loop_quit(void)
{
	quit = 1;
	[window_list release];

	window_list = NULL;
}

static ZWidget *_find_widget(XCBWINDOW *w)
{
	IMPListIterator *iter = [window_list iterator];
	ZWidget *widget;
	XCBWINDOW win;

	do {		
		widget = (ZWidget *)[iter get_data];
		
		if(widget) {
			printf("nice\n");
			win = [widget->window get_xid];
		}

		if(win.xid == w->xid) {
			return widget;
		}
		
		[iter next];
	} while([iter has_next]);

	return NULL;
}

