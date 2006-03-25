/*
    imp
    Copyright (C) 2004,2005,2006 imp Developers

    imp is the legal property of its developers, whose names are
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

#include "imp.h"

static unsigned long int id_count = 0;

@implementation IMPObject : Object

- init
{
	[super init];
	
	self->ID = id_count++;
	self->refcount = 1;	
}

- (void)free
{
	[super free];
}

- (int)grab
{
	return ++refcount;
}

- (int)release
{
	int count;
	
	count = --refcount;

	if(refcount == 0)
		[self free];

	return count;	
}

- (int)get_refcount
{
	return self->refcount;
}

- (int)get_id
{
	return self->ID;
}

@end

