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
	int vwork; /**< Numerical representation of the workspace. */
}

@end

/**
  Object to hold VWorkspaces together and have a coherent access interface to them.
  */
@interface VDesk : IMPObject
{

}

@end

#endif
