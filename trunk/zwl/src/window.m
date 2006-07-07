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

/* Internal function 
 * FIXME This should go in ObjXCBConnection ?
 */
static XCBVISUALTYPE *_get_root_visual_type(XCBSCREEN *s);

/* Internal callback prototypes */
static void on_configure(IMPObject *widget, void *data);

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
	wvalue[1] = XCBEventMaskExposure;
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
							0,0);
	}
	else if(backend == ZWL_BACKEND_XCB_XRENDER) {
		fprintf(stderr,"XCB XRender backend not yet coded, please submit patch.\n");
		self->win_surf = NULL;
	}

	return self;
}

- (void)resize:(int)width:(int)height
{
	[super resize:width:height];
	
	cairo_xcb_surface_set_size(self->win_surf,self->width,self->height);
}

@end

static XCBVISUALTYPE *_get_root_visual_type(XCBSCREEN *s)
{
	XCBVISUALID root_visual;
	XCBVISUALTYPE  *visual_type = NULL; 
	XCBDEPTHIter depth_iter;

	depth_iter = XCBSCREENAllowedDepthsIter(s);

	for(;depth_iter.rem;XCBDEPTHNext(&depth_iter)) {
		XCBVISUALTYPEIter visual_iter;

		visual_iter = XCBDEPTHVisualsIter(depth_iter.data);
		for(;visual_iter.rem;XCBVISUALTYPENext(&visual_iter)) {
		    if(s->root_visual.id == visual_iter.data->visual_id.id) {
			visual_type = visual_iter.data;
			break;
		    }
		}
      	}

	return visual_type;
}

/*
static void on_configure(IMPObject *widget, void *data)
{
	ZWidget *w = (ZWidget *)widget;
	XConfigureEvent *configure = (XConfigureEvent *)data;

	w->x = configure->x;
	w->y = configure->y;
	w->width = configure->width;
	w->height = configure->height;
}
*/
