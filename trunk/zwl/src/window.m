/*
    zwl
    Copyright (C) 2004,2005,2006 zwl Developers

    zwl is the legal property of its developers, whose names are
    too numerous to list here.  Please refer to the COPYING file
    for the full text of this license and to the AUTHORS file for
    the complete list of developers.

    This program is i_free software; you can redistribute it and/or
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

#include "zwl.h"
#include "zwl_internal.h"

/* Internal callback prototypes */
static void on_configure(ZWidget *widget, void *data);

@implementation ZWindow : ZWidget

- (id)init:(unsigned int)backend:(int)width:(int)height
{
	ObjXCBWindow *w = [ObjXCBWindow alloc];
	ObjXCBWindow *root = [ObjXCBWindow alloc];
	XCBSCREEN *s;
	XCBDRAWABLE draw;

	CARD32 wvalue[2];

	[super init];

	/* Create a window */

	[w init:zc];	

	s = [zc get_screen];
	root = [zc get_root_window];

	wvalue[0] = [zc get_black_pixel];
	wvalue[1] = XCBEventMaskExposure           | XCBEventMaskButtonPress
             	  | XCBEventMaskButtonRelease      | XCBEventMaskPointerMotion
                  | XCBEventMaskEnterWindow        | XCBEventMaskLeaveWindow
                  | XCBEventMaskKeyPress           | XCBEventMaskKeyRelease
	          | XCBEventMaskSubstructureNotify | XCBEventMaskSubstructureRedirect
	          | XCBEventMaskEnterWindow	   | XCBEventMaskLeaveWindow
	          | XCBEventMaskStructureNotify;
	[w CreateWindow:XCBCopyFromParent:root:1:1:width:height:1:XCBWindowClassInputOutput:s->root_visual:XCBCWEventMask | XCBGCForeground:wvalue];

	self->window = w;
	self->parent = zwl_root;
	self->width = width;
	self->height = height;

	/* Now setup the cairo surface */

	if(backend == ZWL_BACKEND_XCB) {
		draw.window = [self->window get_xid];
		self->win_surf = cairo_xcb_surface_create(
							[zc get_connection],
							draw,
							_get_root_visual_type(s),
							1,1);
		self->backend = backend;
	}
	else if(backend == ZWL_BACKEND_GL_GLITZ) {
		fprintf(stderr,"OpenGL glitz backend not yet coded, please submit patch.\n");
		self->win_surf = NULL;
	}

	[self attatch_internal_cb:CONFIGURE:(ZCallback *)on_configure];

	zwl_main_loop_add_widget(self);

	return self;
}

@end

static void on_configure(ZWidget *widget, void *data)
{
	ZWidget *w = widget;
	XCBConfigureNotifyEvent *configure = (XCBConfigureNotifyEvent *)data;

	w->x = configure->x;
	w->y = configure->y;
	w->width = configure->width;
	w->height = configure->height;

	if([w get_backend] == ZWL_BACKEND_XCB) {
		cairo_xcb_surface_set_size([w get_surf],w->width,w->height);
	}

}

