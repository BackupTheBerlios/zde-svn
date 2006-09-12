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

static unsigned int quit = 0;

/* Exported variables */
ZWidget *root_window; 

IMPList *client_list = NULL;
ZWidget *root_window = NULL;

/* static functions */
static void init_root_window(void);

int main(int argc, char **argv)
{	
	zwl_init();

	init_root_window();

	zwl_main_loop_start();
	
	return 0;
}

static void init_root_window(void)
{
	ObjXCBGetGeometryReply *geomrep;
	CARD32 wvalue[2];

	root_window = [ZWindow alloc];

	root_window->window = [zc get_root_window];

	geomrep = [root_window->window GetGeometry];

	root_window->parent = NULL;
	root_window->x = 0;
	root_window->y = 0;
	root_window->width = [geomrep get_width];
	root_window->height = [geomrep get_height];

	wvalue[0] = [zc get_white_pixel];
	wvalue[1] = XCBEventMaskExposure           | XCBEventMaskButtonPress
             	  | XCBEventMaskButtonRelease      | XCBEventMaskPointerMotion
                  | XCBEventMaskEnterWindow        | XCBEventMaskLeaveWindow
                  | XCBEventMaskKeyPress           | XCBEventMaskKeyRelease
	          | XCBEventMaskSubstructureNotify | XCBEventMaskSubstructureRedirect
	          | XCBEventMaskEnterWindow	   | XCBEventMaskLeaveWindow
	          | XCBEventMaskStructureNotify;

	[root_window->window ChangeWindowAttributes:XCBCWEventMask | XCBCWBackPixel:wvalue];

	[zc flush];
}

