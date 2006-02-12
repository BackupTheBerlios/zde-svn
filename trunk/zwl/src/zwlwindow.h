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
	A widget that represents a Window.
 */
@interface ZWindow : ZWidget
{
	@protected
	char *title;
	XftDraw *xftdraw; /**< For displaying text, used internally. */
}

/** 
  When parent is passed as null, then it is assumed to be the root window of the current display. 
 */
- init:(ZWidget *)parent:(int)x:(int)y:(int)width:(int)height;

/** Defer creation of window and parent until later
  */
- init:(int)x:(int)y:(int)width:(int)height;

- free;

/**
  Set the title of the window. Returns -1 on failure, 0 otherwise.
  */
- (int)set_title:(char *)title;

@end
