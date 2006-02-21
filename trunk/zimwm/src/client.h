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

@interface ZimClient : IMPObject
{
	@public
	ZWindow *window; /**< A ZWindow that encapsulates the X11 window. */	
	unsigned int border; /**< Border width in pixels. */
	unsigned int title_height; /**< Titlebar height in pixels. */
	Atom *atoms; /**< Array of atoms this window has. */
	
}

/** Register an new client with zimwm.
  \param window X11 Window pointer
  */
- init:(Window *)window;
- free;

/** Used to get and store all atom properties of the client, such as WM_PROTOCOLS
  */
- (void)get_properties;

/** Sends a ClientMessage to the X11 Window represented by this client.
  */
- (void)send_client_message:(int)format:(Atom)type:(Atom)data;

@end
