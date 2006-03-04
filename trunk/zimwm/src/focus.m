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

#include "zimwm.h"

int focus_client(ZimClient *c)
{
	if(!c)
		return -1;

	if(!c->wm_hints)
		return;
	
	if(c->wm_hints->input == True) {
		if(c->atoms[WM_TAKE_FOCUS]) {
			[c send_client_message:32:XA_ATOM:z_atom[WM_TAKE_FOCUS]];
			XSetInputFocus(zdpy,c->window->window,RevertToPointerRoot,CurrentTime);
			return 0;
		}
		else {
			XSetInputFocus(zdpy,c->window->window,RevertToPointerRoot,CurrentTime);
			return 0;
		}
	}
	else { /* We really shouldn't set the focus, but some misbehaved clients need this. */
		XSetInputFocus(zdpy,c->window->window,RevertToPointerRoot,CurrentTime);
	}
	
	return -1;
}

