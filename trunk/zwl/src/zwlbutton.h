/*
    zwl
    Copyright (C) 2004,2005,2006 zwl Developers

    zwl is the legal property of its developers, whose names are
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

#ifndef ZWLBUTTON_H
#define ZWLBUTTON_H

/**
  A window that must be a child of a ZWindow, which is accomplished by calling [parent add_child:button]
  BEFORE showing the button.  It uses a ZLabel to draw the text in *label, and handles Expose events for
  drawing that text. It can also display a png image using Cairo instead of text when you use the second form of -init.
  */
@interface ZButton : ZWindow
{
	@private
	cairo_surface_t *window_surface;
	cairo_surface_t *image_surface;
	cairo_t *cr;
	
	@protected
	char *label;
	char *image_path; /**< Path to png image to use on button. */
	unsigned int border_width; /**< Set to the pixel width you want displayed around the button, default is 1.
			    		This must be set before you make it a child of any other widgets. */
	
	@public
	ZLabel *zlabel; /**< For internal use only.  Do not manually change it, instead call
			  set_label with the text you want to display. */
}

- init:(int)x:(int)y:(int)width:(int)height;

/**
  image_path is the path to a png image to be used on the button. 
  */
- init:(char *)image_path:(int)x:(int)y:(int)width:(int)height;

- free;

- (void)set_label:(char *)label;
- (char *)get_label;

- (char *)get_image_path;

- (void)set_border_width:(unsigned int)width;

- (int)get_border_width;

/** Returns the cairo_t that is used for this button. */
- (cairo_t *)get_cairo_t;

/** Returns the cairo_surface_t for the button's window. */
- (cairo_surface_t *)get_window_surface;

/** Returns the cairo_surface_t for the button's image. */
- (cairo_surface_t *)get_image_surface;

/** Set the cairo_t for the button. Do not call from an application program. */
- (void)set_cairo_t:(cairo_t *)cr;

/** Set the window surface for the button. Do not call from an application program. */
- (void)set_window_surface:(cairo_surface_t *)window_surface;

@end;

#endif
