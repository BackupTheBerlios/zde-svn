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

#ifndef EWMH_H
#define EWMH_H

/**
  	Holds values specified in _NET_WM_STRUT or _NET_WM_STRUT_PARTIAL
  */
typedef struct {
	int left;
	int right;
	int top;
	int bottom;
	int left_start_y;
	int left_end_y;
	int right_start_y;
	int right_end_y;
	int top_start_x;
	int top_end_x;
	int bottom_start_x;
	int bottom_end_x;
	
} ZStrutExtents;

#include "client.h"

/** Sets the root window properties, like _NET_SUPPORTED, etc. */
void setup_ewmh_root_properties(void);

/** Responds to EWMH messages to the root window, like _NET_CLOSE_WINDOW, etc. */
void handle_ewmh_client_message(XClientMessageEvent *ev);

/** Gets the window's _NET_WM_NAME property. If that doesn't exist, get the WM_NAME property. */
char *get_net_wm_name(Window *w);

/** Updates the _NET_ACTIVE_WINDOW property. */
void update_active_window(ZimClient *c);

/** Updates the _NET_CLIENT_LIST property of the root window to the current client list, in order of mapping. */
void update_client_list(IMPList *list);

/** Updates the _NET_CLIENT_LIST_STACKING property of the root window to the current stacking list. */
void update_client_list_stacking();

#endif
