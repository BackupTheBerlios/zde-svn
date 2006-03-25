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

#ifndef CLIENT_H
#define CLIENT_H

/**
   An Object used to represent a client in zimwm.  Abstracts the window and the frame in one
   object, and allows easy manipulation of both at the same time.
  */
@interface ZimClient : IMPObject
{
	@public
	ZWindow *window; /**< A ZWindow that encapsulates the X11 window. */	
	unsigned int border; /**< Border width in pixels around frame. */
	unsigned int title_height; /**< Titlebar height in pixels. */
	unsigned int win_border; /**< Border width around window to frame, set by window. */
	Bool sticky;
	Bool withdrawn;
	Bool no_use_area; /**< If this is set, the strut_extents structure must contain the values of
			    the _NET_WM_STRUT or _NET_WM_STRUT_PARTIAL properties.
			    */
	Bool maximised;
	Bool shaded;
	Atom *atoms; /**< Array of atoms this window has. */

	XWMHints *wm_hints; /**< Structure containing the WM_HINTS property of the window. */
	XSizeHints *size_hints; /**< Structure containing the size hints contained in the window's WM_NORMAL_HINTS property. */
	ZStrutExtents *strut_extents;

	/* FIXME These are used for remembering old maximisation values.
	   This should probably be changed in the future.
	   */
	int oldx;
	int oldy;
	int oldwidth;
	int oldheight;

	@protected	
	unsigned int vdesk; /**< Specifies offset from the root coordinates vertically. Must be > 1. */
	unsigned int vwork; /**< Specifies offset from the root corrdinates horizontally. Must be > 1. */
}

/** Register an new client with zimwm.
  \param window X11 Window pointer
  */
- init:(Window *)window;
- free;

/** Gets the vdesk that this client is on. */
- (unsigned int)get_vdesk;

/** Gets the vwork that this client is on. */
- (unsigned int)get_vwork;

/** Set the vdesk that this client is on. */
- (void)set_vdesk:(unsigned int)nvdesk;

/** Set the vwork that this client is on. */
- (void)set_vwork:(unsigned int)nvwork;

/** Used to get and store all atom properties of the client, such as WM_PROTOCOLS
  */
- (void)get_properties;

/** Sets the _NET_WM_ALLOWED_ACTIONS property of the client.
  */
- (void)set_allowed_actions;

/** Sends a ClientMessage to the X11 Window represented by this client.
  */
- (void)send_client_message:(int)format:(Atom)type:(Atom)data;

/** Sends a Configure Message to the X11 Window represented by this client.
  */
- (void)send_configure_message:(int)x:(int)y:(int)width:(int)height;

/** "Snaps" the client to the edges of other windows and the screen. */
- (void)snap;

/** Moves the client to a position x,y */
- (void)move:(int)x:(int)y;

/** Resizes the client. */
- (void)resize:(int)width:(int)height;

/** Used internally so that we don't have to find the handles every resize. */
- (void)resize:(int)width:(int)height:(ZWindow *)right:(ZWindow *)left:(ZWindow *)bottom:(ZWindow *)bottom_right;

/** Raises the window to the top of the stacking list. */
- (void)raise;

@end

#endif
