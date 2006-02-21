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
	NET_WM_WINDOW_TYPE,
	NET_WM_WINDOW_TYPE_NORMAL,
	NET_WM_WINDOW_TYPE_MENU,
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

