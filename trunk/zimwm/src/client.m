/*
    zimwm
    Copyright (C) 2004,2005,2006 zimwm Developers

    zimwm is the legal property of its developers, whose names are
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

#include "zimwm.h"

@implementation ZimClient : IMPObject

-(id)init:(ObjXCBWindow *)win
{
	ObjXCBGetGeometryReply *geomrep;

	[super init];

	self->window = [ZWindow alloc];
	self->parent = [ZWindow alloc];

	geomrep = [win GetGeometry];

	self->window->window = win;

	/* FIXME This needs to be generalized, for creation of buttons, text label, so on... */
	/* FIXME numbers here should be config options (titleheight,border) FIXME */
	[self->parent init:ZWL_BACKEND_XCB:[geomrep get_width] + 10:[geomrep get_height] + 20];

	[geomrep free];

	[self->parent move:100:100];

	[self->window->window ReparentWindow:self->parent->window:5:15];
	
	self->window->parent = self->parent;

	[self->parent show];
	[self->window show];

	zimwm_add_client(self);

	[zc flush];
}

-(void)free
{

}

@end
