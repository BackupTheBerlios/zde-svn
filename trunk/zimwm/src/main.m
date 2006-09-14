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

/* Exported variables */
ZWidget *root_window = NULL; 
IMPList *client_list = NULL;
IMPList *modules_list = NULL;

/* static functions */
static void init_root_window(void);

int main(int argc, char **argv)
{	
	zwl_init();

	client_list = [IMPList alloc];
	[client_list init];

	init_root_window();

	zwl_main_loop_start();
	
	return 0;
}

static void init_root_window(void)
{
	ObjXCBGetGeometryReply *geomrep;
	CARD32 wvalue[3];
	CARD32 value;
	ObjXCBFont *cursor_font = [ObjXCBFont alloc];
	XCBCURSOR c;

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

	/* Create a font cursor */
	[cursor_font init:zc];
	[cursor_font OpenFont:6:"cursor"];

	[root_window->window ChangeWindowAttributes:XCBCWEventMask | XCBCWBackPixel:wvalue];

	XCBFONTNew([zc get_connection]);
	c = XCBCURSORNew([zc get_connection]);

	/* FIXME Obj-XCB equivalent gives a syntax error for some reason, need to look into that... */
	XCBCreateGlyphCursor ([zc get_connection], c, [cursor_font get_xid], [cursor_font get_xid],
                      68, 68,
                      255, 255, 255,
                      255, 255, 255);

	value = c.xid;

	[root_window->window ChangeWindowAttributes:XCBCWCursor:&value];

	zwl_main_loop_add_widget(root_window);

	/* Register for events */
	[root_window attatch_cb:MAP_REQUEST:(ZCallback *)on_map_request];
	[root_window attatch_cb:BUTTON_DOWN:(ZCallback *)on_button_down];

	[geomrep free];

	[zc flush];
}

void zimwm_add_client(ZimClient *c)
{
	if(client_list && c)
		[client_list append:c];
}

void zimwm_remove_client(ZimClient *c)
{
	IMPListIterator *iter = [client_list iterator];

	while([iter has_next]) {
		
		if([iter get_data] == c) {
			[iter del];
		}

		[iter next];
	}

	[iter release];
}

ZimClient *find_client_by_xcb_window(ObjXCBWindow *w)
{
	IMPListIterator *iter = [client_list iterator];
	ZimClient *c;

	while([iter has_next]) {
		
		c = (ZimClient *)[iter get_data];

		if(OBJXCBWIN_TO_XID(c->window->window) == OBJXCBWIN_TO_XID(w)) {
			[iter release];
			return c;
		}
	}
}
ZimClient *find_client_by_xcb_parent(ObjXCBWindow *w)
{
	IMPListIterator *iter = [client_list iterator];
	ZimClient *c;

	do {
		c = (ZimClient *)[iter get_data];

		if(OBJXCBWIN_TO_XID(c->parent->window) == OBJXCBWIN_TO_XID(w)) {
			[iter release];
			return c;
		}

	} while([iter has_next]); 
}

ObjXCBWindow *xcb_win_to_objxcb(XCBWINDOW w)
{
	ObjXCBWindow *win = [ObjXCBWindow alloc];

	[win init:zc:w];

	return win;
}

