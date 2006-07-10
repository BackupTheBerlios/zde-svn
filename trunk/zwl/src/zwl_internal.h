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

#include "zwl.h"

/** 
 * FIXME This should go in ObjXCBConnection ?
 */
XCBVISUALTYPE *_get_root_visual_type(XCBSCREEN *s);

/**
 * Internal extension to ZWidget
 */
@interface ZWidget (_internal_)

/**
 * Set the widget's backend.
 */
- (void)set_backend:(unsigned int)back;

/**
 * Set the widget's cairo surface.
 */
- (void)set_window_surf:(cairo_surface_t *)surf;

/** Used to attatch internal callbacks. Should not be used by application programs unless you want trouble, or REALLY know what you are doing.
 Using this, it is possible to override how widgets react to basic zwl and X11 events, such as button presses and exposes.  Unless you are 
 writing a widget, this is dangerous for normal use.
 */
- (void)attatch_internal_cb:(int)signal:(ZCallback *)callback;

@end
