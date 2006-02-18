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

/**
	A widget that represents a main window.  This is for windows that are not going to be children.
	If you want a child window, for widgets or similiar, extend from this class.
 */
@interface ZWindow : ZWidget
{
	@protected
	char *title; /**< The title of this window.  This is not useful if you are deriving from this class
		       for creating subclasses, so in that case, it can be safely ignored. */
	@public
	XftDraw *xftdraw; /**< For displaying text, used internally. */
}

/** 
  When parent is passed as null, then it is assumed to be the root window of the current display. 
 */
- init:(ZWidget *)parent:(int)x:(int)y:(int)width:(int)height;

/** Defer creation of the X11 window until later. This is mostly useful for creating subclasses
  that are going to be added as children of another ZWidget.  In that case, make sure you respond to
  the ADDED event internally to create your window the way you want it.
  */
- init:(int)x:(int)y:(int)width:(int)height;

- free;

/**
  Set the title of the window. This is probably not useful if you 
  are calling this from a subclass that creates its window in the 
  ADDED event. Returns -1 on failure, 0 otherwise.
  */
- (int)set_title:(char *)title;

- (char *)get_title;

/** Returns a pointer to the XftDraw that the window uses for drawing text.
  */
- (XftDraw *)get_xftdraw;

@end
