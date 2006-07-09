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

#ifndef ZWLLABEL_H
#define ZWLLABEL_H

/** A widget that displays text and must be set as a child of a ZWindow.
   This widget DOES NOT perform word-wrapping or any other form of text-layout.
   It simply displays text.  Note that it currently uses the "toy" cairo text API, so
   there is currently no capacity for internationalization, but the basic interface
   should stay constant if there is ever a converstion to the glyph-based API.
 */
@interface ZLabel : ZWidget
{
	@public
	double size; /** Font size */

	@protected
	char *text; /** What text this label will display. */
	char *family;
}

/**
 * @param text
 * What you want the label to show
 *
 * @param x
 * X coordinate in the parent window for it to be displayed in.
 *
 * @param y
 * Y coordinate in the parent window for it to be displayed in.
 */
- init:(char *)text:(int)x:(int)y;

- free;

/** 
 * Will override any previously set text and display it.
 */
- (void)set_text:(char *)text;

- (const char *)get_text;

/**
 * Set the the font family for the text, i.e. Sans or Monospace.
 */
- (void)set_font_family:(char *)font;

- (const char *)get_font_family;

/** 
 * Returns the text extents for the label as defined by the cairo_text_extents() function. 
 */
- (cairo_text_extents_t *)get_text_extents; 

@end;

#endif
