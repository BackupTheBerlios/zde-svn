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

/* Internal callback prototypes */
static void on_add(IMPObject *widget, void *data);
static void on_expose(IMPObject *widget, void *data);
static void on_configure(IMPObject *widget, void *data);
static void on_label_down(IMPObject *widget, void *data);
static void on_label_up(IMPObject *widget, void *data);

@implementation ZButton : ZWindow

- init:(int)x:(int)y:(int)width:(int)height
{
	self->window = NULL;
	self->zlabel = [ZLabel alloc];
	self->label = NULL;
	self->image_path = NULL;
	self->cr = NULL;
	self->window_surface = NULL;
	self->image_surface = NULL;
	self->border_width = 1;
	
	[super init:x:y:width:height];
	
	[self attatch_internal_cb:ADDED:(ZCallback *)on_add];
	[self attatch_internal_cb:EXPOSE:(ZCallback *)on_expose];

}

- init:(char *)image_path:(int)x:(int)y:(int)width:(int)height
{		
	self->window = NULL;
	self->zlabel = NULL;
	self->image_path = NULL;
	self->window_surface = NULL;
	self->image_surface = NULL;
	self->label = NULL;
	self->cr = NULL;
	self->border_width = 1;
	
	if(image_path)
		self->image_path = i_strdup(image_path);
	else
		self->image_path = NULL;

	[super init:x:y:width:height];

	self->image_surface = cairo_image_surface_create_from_png(self->image_path);
	
	[self attatch_internal_cb:ADDED:(ZCallback *)on_add];
	[self attatch_internal_cb:EXPOSE:(ZCallback *)on_expose];
	[self attatch_internal_cb:CONFIGURE:(ZCallback *)on_configure];
		
}

- free
{
	if(self->label)
		i_free(self->label);
	
	if(self->cr) {
		cairo_destroy(self->cr);
		self->cr = NULL;
	}
	if(self->window_surface) {
//		cairo_surface_destroy(self->window_surface);
		self->window_surface = NULL;
	}
	if(self->image_surface) {
		cairo_surface_destroy(self->image_surface);	
		self->image_surface = NULL;
	}
	if(self->image_path) {
		i_free(self->image_path);
		self->image_path = NULL;
	}
	
	[super free];
}

- (void)set_label:(char *)label
{
	XftFont *font = XftFontOpenName(zdpy,DefaultScreen(zdpy),"sans-8"); /* This is bad... */
	XGlyphInfo extents;

	if(label) {
		if(self->label)
			i_free(self->label);

		self->label = i_strdup(label);	
		if(self->window && self->zlabel) {
			[self->zlabel set_label:self->label];
			XftTextExtents8(zdpy,font,[self->zlabel get_label],strlen([self->zlabel get_label]),&extents);
			
			[self->zlabel move:(self->width / 2) - (extents.width / 2):(self->height / 2) - (extents.height / 2)];
			[self receive:EXPOSE:self];
		}
	}
}

- (char *)get_label
{
	return self->label;
}

- (char *)get_image_path
{
	return self->image_path;
}

- (cairo_t *)get_cairo_t
{	
	return self->cr;
}	

- (cairo_surface_t *)get_window_surface
{
	return self->window_surface;
}

- (cairo_surface_t *)get_image_surface
{
	return self->image_surface;
}

- (void)set_cairo_t:(cairo_t *)cr
{
	if(cr) {
		self->cr = cr;
	}
}
- (void)set_window_surface:(cairo_surface_t *)window_surface
{
	if(window_surface) {
		self->window_surface = window_surface;
	}
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
	
	
	myself->window = (Window *)XCreateSimpleWindow(zdpy,parent->window,
			myself->x,myself->y,myself->width,myself->height,
		[myself get_border_width],WhitePixel(zdpy,DefaultScreen(zdpy)),1);
	
	if(![myself get_image_path]) {
		[myself->zlabel init:0:0];
		[myself add_child:(ZWidget *)myself->zlabel];
		[myself->zlabel attatch_internal_cb:BUTTON_DOWN:(ZCallback *)on_label_down];
		[myself->zlabel attatch_internal_cb:BUTTON_UP:(ZCallback *)on_label_up];

		myself->xftdraw = XftDrawCreate(zdpy,myself->window,DefaultVisual(zdpy,DefaultScreen(zdpy)),
				DefaultColormap(zdpy,DefaultScreen(zdpy)));
	}

	XChangeWindowAttributes(zdpy,myself->window,CWEventMask,&attr);

	
	if([myself get_image_path]) {
		image_surface = [myself get_image_surface];
		
		window_surface = cairo_xlib_surface_create(zdpy,myself->window,DefaultVisual(zdpy,DefaultScreen(zdpy)),
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

	if(myself->label && myself->zlabel->window) {
		[myself->zlabel show];
		[myself->zlabel receive:EXPOSE:myself->zlabel];
	}
	else if(myself->image_path)
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

	cairo_xlib_surface_set_size(w->window_surface,w->width,w->height);
}

/* These two functions forward BUTTON_UP and BUTTON_DOWN events
   to the button instead of the label. */
static void on_label_down(IMPObject *widget, void *data)
{
	ZWidget *w = (ZWidget *)widget;
	[w->parent receive:BUTTON_DOWN:data];
}

static void on_label_up(IMPObject *widget, void *data)
{
	ZWidget *w = (ZWidget *)widget;
	[w->parent receive:BUTTON_UP:data];
}

