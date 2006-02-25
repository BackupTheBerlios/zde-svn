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

extern Atom *z_atom;

typedef enum {
	UTF8_STRING,
	WM_NAME,
	WM_PROTOCOLS,
	WM_DELETE_WINDOW,
	/* EWMH Atoms */
	_NET_WM_WINDOW_TYPE,
	_NET_WM_WINDOW_TYPE_NORMAL,
	_NET_WM_WINDOW_TYPE_MENU,
	_NET_SUPPORTED,
        _NET_CLIENT_LIST,
        _NET_NUMBER_OF_DESKTOPS,
        _NET_DESKTOP_GEOMETRY,
        _NET_DESKTOP_VIEWPORT,
        _NET_CURRENT_DESKTOP,
        _NET_DESKTOP_NAMES,
        _NET_ACTIVE_WINDOW,
        _NET_WORKAREA,
        _NET_SUPPORTING_WM_CHECK,
        _NET_VIRTUAL_ROOTS,
        _NET_DESKTOP_LAYOUT,
        _NET_SHOWING_DESKTOP,
	_NET_CLOSE_WINDOW,
        _NET_MOVERESIZE_WINDOW,
        _NET_WM_MOVERESIZE,
        _NET_RESTACK_WINDOW,
        _NET_REQUEST_FRAME_EXTENTS,
	_NET_WM_NAME,
        _NET_WM_VISIBLE_NAME,
        _NET_WM_ICON_NAME,
        _NET_WM_VISIBLE_ICON_NAME,
        _NET_WM_DESKTOP,
        _NET_WM_STATE,
        _NET_WM_ALLOWED_ACTIONS,
        _NET_WM_STRUT,
        _NET_WM_STRUT_PARTIAL,
        _NET_WM_ICON_GEOMETRY,
        _NET_WM_ICON,
        _NET_WM_PID,
        _NET_WM_HANDLED_ICONS,
        _NET_WM_USER_TIME,
        _NET_FRAME_EXTENTS,
	_NET_WM_ACTION_MOVE,
	_NET_WM_ACTION_RESIZE,
	_NET_WM_ACTION_MINIMIZE,
	_NET_WM_ACTION_SHADE,
	_NET_WM_ACTION_STICK,
	_NET_WM_ACTION_MAXIMIZE_HORZ,
	_NET_WM_ACTION_MAXIMIZE_VERT,
	_NET_WM_ACTION_FULLSCREEN,
	_NET_WM_ACTION_CHANGE_DESKTOP,
	_NET_WM_ACTION_CLOSE,
	END_ATOM
}ATOM;

extern Display *zdpy;

/** You must call this function before you use
  any zwl widgets. */
void zwl_init(void);
void zwl_receive_xevent(XEvent *ev);

Display *zwl_get_display(void);
void zwl_main_loop_add_widget(ZWidget *w);
void zwl_main_loop_start(void);
void zwl_main_loop_quit(void);

