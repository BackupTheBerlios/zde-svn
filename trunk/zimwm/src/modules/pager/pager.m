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

#include "../../zimwm.h"

#include "../zimwm_module.h"

#define MOD_NAME "pager"
#define MOD_VERSION_STRING "pager 0.0.1"

ZWindow *w = NULL; /* Main window */
/* FIXME should be dynamically allocated. */
ZWindow *workwins[5]; /* Sub-windows representing workspaces. */

VDesk *curr_desk;

int zimwm_module_init(void)
{
	int i;

	curr_desk = [zones[curr_zone] get_current_desk];

	w = zimwm_module_create_window(200,50);
	
	for(i=0;i<[curr_desk get_num_workspaces];i++) {
		workwins[i] = [ZWindow alloc];
		[workwins[i] init:w:0:0:40:50];
		[workwins[i] show];
	}


	return 0;
}

void zimwm_module_quit(void)
{

}

char *zimwm_module_version(void)
{
	return MOD_VERSION_STRING;
}

char *zimwm_module_about(void)
{
	return "Pager module that graphically displays workspaces and desktops and the windows contained in them.";
}

