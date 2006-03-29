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

#ifndef VDESK_H
#define VDESK_H

/**
   \addtogroup VDesks
   @{
	Virtual Desktops are implemented as coordinate changes relative to 0,0, vertically.
	Virtual Workspaces are implemented as coordinate changes relative to 0,0, horizontally.

	Here is an example:

	[1,1] [1,2] [1,3]
	[2,1] [2,2] [2,3]

	This example has two VDesks and six VWorkspaces.  The first VWorkspace is at 1,1, so its coordinates
	will be 0,0 * 1,1 = 0,0.  The second VWorkspace is at 1,2, so its coordinates are 0,0 * 1,2 = 0,screenwidth.
	0,0 is not literally "zero","zero", it means the root coordinates.  So two times the root coordinates if the 
	screen is 800px wide would be 1024.  That means the second Virtual Desktop starts at 1024, so the viewport needs
	to be shifted by +800 pixels. The same procedure can be used for moving horizontally and backwards.
   @}
  */

/**
  Object that contains all the ZimClients in this workspace and all sticky clients.
  */
@interface VWorkspace : IMPObject
{
	@protected
	unsigned int vwork; /**< Numerical representation of the workspace. */
	IMPList *clients; /**< List containing all clients on this workspace. */
	IMPSimpleStack *clients_stacking; /**< Stack containing all clients in stacking order. */
	
	int width; /**< DisplayWidth(), minus any Struts? */
	int height; /**< DisplayHeight(), minus any Struts? */
}

- init:(unsigned int)vwork:(int)width:(int)height;
- free;

/** Adds a client to this workspace. */
- (void)add_client:(ZimClient *)client;

/** Removes a client from this workspace. */
- (void)remove_client:(ZimClient *)client;

/** Adds a client to this workspace's stacking list. */
- (void)add_client_stacking:(ZimClient *)client;

/** Removes a client from this workspace's stacking list. */
- (void)remove_client_stacking:(ZimClient *)client;

/** Gets all the clients in this workspace, including sticky clients. */
- (const IMPList *)get_clients;

/** Get the numerical number representing this workspace. */
- (unsigned int)get_num;

/** Get the workspace's width. */
- (int)get_width;

/** Get the workspace's height. */
- (int)get_height;

@end

/**
  Object to hold VWorkspaces together and have a coherent access interface to them.
  */
@interface VDesk : IMPObject
{
	@protected
	unsigned int vdesk; /**< Numerical representation of the desktop. */
	IMPList *workspaces; /**< List containing all workspaces in this desktop. */
	VWorkspace *curr_workspace; /**< Current workspace this desktop is at. */
	
	int width; /**< Size of one of our workspace's width * number of workspaces. */
	int height; /**> Size of one of our workspace's height * number of workspaces. */
}

/**
  A NULL in first means that a default workspace will be created as the first one.
  */
- init:(unsigned int)vdesk:(VWorkspace *)first;
- free;

/** Adds a workspace to this desktop. */
- (void)add_workspace:(VWorkspace *)workspace;

/** Removes a workspace from this desktop. */
- (void)remove_workspace:(VWorkspace *)workspace;

/** Removes a workspace from this desktop, indexed by number. 
 XXX Not sure if this is needed yet. XXX*/
//- (void)remove_workspace_index:(unsigned int)vwork;

/** Gets the current workspace. */
- (const VWorkspace *)get_current_workspace;

/** Gets the workspace number "n" on this desktop. */
- (const VWorkspace *)get_nth_workspace:(int)n;

/**
  Switches to the next workspace in the desktop.
  Returns the new current workspace.
 */
- (const VWorkspace *)move_next;

/**
  Switches to the previous workspace in the desktop.
  Returns the new current workspace.
 */
- (const VWorkspace *)move_prev;

/** Calculates the desktop's width and height. */
- (void)calculate_dimensions;

/** Get the numerical number representing this desktop. */
- (unsigned int)get_num;

/** Get the desktop's width. */
- (int)get_width;

/** Get the desktop's height. */
- (int)get_height;

@end

#endif
