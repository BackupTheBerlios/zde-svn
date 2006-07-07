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

#ifndef ZWLWINDOW_H
#define ZWLWINDOW_H

/**
 * Plain XCB backend, safest.
 */
#define ZWL_BACKEND_XCB 0

/**
 * XCB XRender backend, may be slow or render incorrectly.
 */
#define ZWL_BACKEND_XCB_XRENDER 1

/**
	A widget that represents an X11 toplevel window.
 */
@interface ZWindow : ZWidget
{
	@protected

	/** 
	 * The title of this window.
	 */
	char *title;

	/** 
	 * The cairo surface that represents this window. 
	 */
	cairo_surface_t *win_surf;
}

- (id)init:(unsigned int)backend;

- (void)free;

/**
 * Set the title variable of the window, and also update any X11 atoms/properties that may use this variable.
 */
- (void)set_title:(char *)title;

/**
 * Force an update of any X11 atoms/properties that may use the title variable.
 */
- (void)update_title;

/**
 * Returns the title of the window as stored in the variable title, not through any X11 atoms/properties that may mirror the title variable.
 * FIXME XXX Maybe it should get what is stored in the x11 atoms first and then return?  More research to find what is more useful.
 */
- (const char *)get_title;

/** 
 * Raises the window. 
 */
- (void)raise;

@end

#endif
