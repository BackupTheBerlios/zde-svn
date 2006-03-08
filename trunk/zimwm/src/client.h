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
	unsigned int border; /**< Border width in pixels. */
	unsigned int title_height; /**< Titlebar height in pixels. */
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
	
}

/** Register an new client with zimwm.
  \param window X11 Window pointer
  */
- init:(Window *)window;
- free;

/** Resizes the client, correctly moving the frame, etc. */
//- (void)resize:(int)nwidth:(int)nheight;

/** Used to get and store all atom properties of the client, such as WM_PROTOCOLS
  */
- (void)get_properties;

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

@end

#endif
