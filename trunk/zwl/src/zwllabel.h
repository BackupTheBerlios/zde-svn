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

/** A widget that displays text and must be a child of a ZWindow.  It can be set to 
   automatically set its own width and height if you are changing the label a lot.
   This widget DOES NOT perform word-wrapping or any other form of text-layout.
   It simply displays text.
 */
@interface ZLabel : ZWindow
{
	@protected
	char *label;
	XftFont *font;

	@public
	int resize;
}

/** Use this form if you know exactly what you want width and height to be.  Any
   text that cannot fix in this space will be truncated.
 */
- init:(int)x:(int)y:(int)width:(int)height;

/** Use this form if you want width and height to be determined automatically.
 */
- init:(int)x:(int)y;

- free;

/** Will override any previously set label and display it.
 */
- (void)set_label:(char *)label;
- (const char *)get_label;

/** Returns the text extents for the label as defined by the XftTextExtents8 function. */
- (XGlyphInfo *)get_text_extents; 

/** Returns the XftFont that this label is using. */
- (const XftFont *)get_font;

@end;

#endif
