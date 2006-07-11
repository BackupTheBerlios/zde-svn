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
static void on_add(ZWidget *widget, void *data);
static void on_expose(ZWidget *widget, void *data);
static void on_configure(ZWidget *widget, void *data);
static void on_label_down(ZWidget *widget, void *data);
static void on_label_up(ZWidget *widget, void *data);

@implementation ZButton : ZWidget

- init:(char *)label:(int)x:(int)y:(int)width:(int)height
{
	[super init];

	self->label = [ZLabel alloc];

	[self->label init:label:0:0];

	self->x = x;
	self->y = y;
	self->width = width;
	self->height = height;

	[self attatch_internal_cb:ADDED:(ZCallback *)on_add];
	[self attatch_internal_cb:EXPOSE:(ZCallback *)on_expose];
}

- free
{
	[label release];

	cairo_surface_destroy(self->win_surf);
	
	[super free];
}

- (void)set_label:(char *)label
{
	[self->label set_text:label];
}

- (const char *)get_label
{
	return [self->label get_text];
}

- (void)set_border_width:(unsigned int)width
{
	self->border_width = width;
}

- (unsigned int)get_border_width
{
	return self->border_width;
}


@end

static void on_add(ZWidget *widget, void *data)
{
	ZButton *myself = (ZButton *)widget;
	
	ObjXCBWindow *w = [ObjXCBWindow alloc];
	XCBSCREEN *s;
	XCBDRAWABLE draw;

	CARD32 wvalue[2];

	[w init:zc];

	s = [zc get_screen];

	wvalue[0] = [zc get_black_pixel];
	wvalue[1] = XCBEventMaskExposure           | XCBEventMaskButtonPress
             	  | XCBEventMaskButtonRelease      | XCBEventMaskPointerMotion
                  | XCBEventMaskEnterWindow        | XCBEventMaskLeaveWindow
                  | XCBEventMaskKeyPress           | XCBEventMaskKeyRelease
	          | XCBEventMaskSubstructureNotify | XCBEventMaskSubstructureRedirect
	          | XCBEventMaskEnterWindow	   | XCBEventMaskLeaveWindow
	          | XCBEventMaskStructureNotify;
	
	[w CreateWindow:XCBCopyFromParent:myself->parent->window:myself->x:myself->y:myself->width:myself->height:0:XCBWindowClassInputOutput:
						s->root_visual:XCBCWEventMask | XCBGCForeground:wvalue];

	myself->window = w;

	/* Now setup the cairo surface */
	if([myself->parent get_backend] == ZWL_BACKEND_XCB) {
		draw.window = [myself->window get_xid];
		[myself set_window_surf:cairo_xcb_surface_create(
							[zc get_connection],
							draw,
							_get_root_visual_type(s),
							1,1)];
		[myself set_backend:ZWL_BACKEND_XCB];
	}
	else if([myself->parent get_backend] == ZWL_BACKEND_GL_GLITZ) {
		fprintf(stderr,"OpenGL glitz backend not yet coded, please submit patch.\n");
	}

	zwl_main_loop_add_widget(myself);

	[myself add_child:(ZWidget *)myself->label];

}

static void on_expose(ZWidget *widget, void *data)
{
	ZButton *myself = (ZButton *)widget;
	XCBExposeEvent *ev = (XCBExposeEvent *)data;
	cairo_t *cr;
	cairo_text_extents_t *extents;

	cr = cairo_create([myself get_surf]);

	cairo_set_source_rgb(cr,.5,.5,.5);

	cairo_rectangle(cr,0,0,myself->width,myself->height);
	cairo_fill_preserve(cr);
	
	cairo_set_source_rgb(cr,.4,.4,.4);
	cairo_set_line_width(cr,5);
	cairo_stroke(cr);
	
	cairo_destroy(cr);

	[myself->label show];

	extents = [myself->label get_text_extents];
	[myself->label move:((int)extents->x_bearing + myself->width - ((int)extents->width)) / 2:((int)extents->y_bearing + myself->height) / 2];

	[zc flush];
}

#if 0
static void on_add(IMPObject *widget, void *data)
{
	ZButton *myself = (ZButton *)data;
	ZWidget *parent = myself->parent;
	XSetWindowAttributes attr;
	cairo_t *cr;
	cairo_surface_t *window_surface;
	cairo_surface_t *image_surface;

	attr.event_mask = ButtonPressMask |
    			  ButtonReleaseMask |
     			  EnterWindowMask |
     			  LeaveWindowMask |
     		 	  PointerMotionMask |
     			  ExposureMask |
     		  	  StructureNotifyMask |
	//		  SubstructureNotifyMask |
     			  KeyPressMask |
     			  KeyReleaseMask;
	
	
	myself->window = (Window *)XCreateSimpleWindow(zdpy,(Window)parent->window,
			myself->x,myself->y,myself->width,myself->height,
		[myself get_border_width],WhitePixel(zdpy,DefaultScreen(zdpy)),1);
	
	if(![myself get_image_path]) {
		[myself->zlabel init:0:0];
		[myself add_child:(ZWidget *)myself->zlabel];
		[myself->zlabel attatch_internal_cb:BUTTON_DOWN:(ZCallback *)on_label_down];
		[myself->zlabel attatch_internal_cb:BUTTON_UP:(ZCallback *)on_label_up];

		myself->xftdraw = XftDrawCreate(zdpy,(Window)myself->window,DefaultVisual(zdpy,DefaultScreen(zdpy)),
				DefaultColormap(zdpy,DefaultScreen(zdpy)));
	}

	XChangeWindowAttributes(zdpy,(Window)myself->window,CWEventMask,&attr);

	
	if([myself get_image_path]) {
		image_surface = [myself get_image_surface];
		
		window_surface = cairo_xlib_surface_create(zdpy,(Window)myself->window,DefaultVisual(zdpy,DefaultScreen(zdpy)),
				myself->width,myself->height);

		[myself set_window_surface:window_surface];
		
		cr = cairo_create([myself get_window_surface]);
		[myself set_cairo_t:cr];
		cairo_set_source_surface([myself get_cairo_t],image_surface,0,0);	
	}

	zwl_main_loop_add_widget(myself);
}

static void on_expose(IMPObject *widget, void *data)
{
	ZButton *myself = (ZButton *)widget;

	if([myself get_label] && myself->zlabel->window) {
		[myself->zlabel show];
		[myself->zlabel receive:EXPOSE:myself->zlabel];
	}
	else if([myself get_image_path])
		cairo_paint([myself get_cairo_t]);
}

static void on_configure(IMPObject *widget, void *data)
{
	ZButton *w = (ZWidget *)widget;
	XConfigureEvent *configure = (XConfigureEvent *)data;

	w->x = configure->x;
	w->y = configure->y;
	w->width = configure->width;
	w->height = configure->height;

	cairo_xlib_surface_set_size([w get_window_surface],w->width,w->height);
}
#endif
/* These two functions forward BUTTON_UP and BUTTON_DOWN events
   to the button instead of the label. */
static void on_label_down(ZWidget *widget, void *data)
{
	ZWidget *w = (ZWidget *)widget;
	[w->parent receive:BUTTON_DOWN:data];
}

static void on_label_up(ZWidget *widget, void *data)
{
	ZWidget *w = (ZWidget *)widget;
	[w->parent receive:BUTTON_UP:data];
}

