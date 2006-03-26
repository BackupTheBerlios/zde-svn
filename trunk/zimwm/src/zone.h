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

#ifndef ZONE_H
#define ZONE_H

/**
  A Zone is a collection of VDesks that are all related together.
  Each zone is completely independant of each other, and each can have
  their own configuration settings, screens, etc.
  */
@interface Zone : IMPObject 
{
	@protected;
	Display *dpy; /**< The display that this zone is located on. */
	int screen; /**< The screen that this zone is located on. */
	ZWidget *root_window; /**< The root window this zone is on. */
	
	IMPList *vdesks; /**< List containing the desktops in this zone. */
	VDesk *curr_desk; /**< Current desktop that this zone is currently at. */
}

/**
  A NULL in first means that a default desk will be the first.
  */
- init:(Display *)dpy:(int)screen:(ZWidget *)root_window:(VDesk *)first;
- free;

/** Adds a vdesk to the zone. */
- (void)add_vdesk:(VDesk *)vdesk;

/** Removes a vdesk from the zone. */
- (void)remove_vdesk:(VDesk *)vdesk;

/** Set the display for the zone. */
- (void)set_dpy:(Display *)disp;

/** Set the screen for the zone. */
- (void)set_screen:(int)scr;

/** Get the display. */
- (const Display *)get_dpy;

/** Get the screen. */
- (int)get_screen;

/** Get the root window for this zone. */
- (const ZWidget *)get_root;

/** Gets the current desktop. */
- (const VDesk *)get_current_desk;

/** 
  Switches to the next desktop in the zone.
  Returns the new current desktop.
 */
- (const VDesk *)move_next;

/** 
  Switches to the previous desktop in the zone. 
  Returns the new current desktop.
 */
- (const VDesk *)move_prev;

@end

#endif
