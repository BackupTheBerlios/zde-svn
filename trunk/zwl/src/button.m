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

@implementation ZButton : ZWidget

- init:(char *)label:(int)x:(int)y:(int)width:(int)height
{
	[super init];

	self->label = [ZLabel alloc];

	[self->label init:label:1:1];

	self->x = x;
	self->y = y;
	self->width = width;
	self->height = height;

//	[self attatch_internal_cb:ADDED:(ZCallback *)on_add];
//	[self attatch_internal_cb:EXPOSE:(ZCallback *)on_expose];
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

