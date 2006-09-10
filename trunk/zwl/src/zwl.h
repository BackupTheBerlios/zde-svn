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

#ifndef ZWL_H
#define ZWL_H

#include <obj-xcb.h>
#include <imp.h>

#include <cairo.h>

#ifndef CAIRO_HAS_XCB_SURFACE
#error Cairo was not compiled with XCB support, no dice
#endif

#include <cairo-xcb.h>
#include <cairo-xcb-xrender.h>
#include <X11/XCB/xcb_renderutil.h>

#include <pthread.h>

#include "zwlwidget.h"
#include "zwlinit.h"
#include "zwlwindow.h"
#include "zwlmenu.h"
#include "zwllabel.h"
#include "zwlbutton.h"

#endif
