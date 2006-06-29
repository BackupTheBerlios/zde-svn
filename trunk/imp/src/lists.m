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

@implementation IMPListIterator : IMPObject

- (id)init:(IMPListNode *)head
{
	[super init];

	if(head) {
		self->curr = head;
		[self->curr grab];
		valid = 1;

		return self;
	}
	else {
		/* Throw exception ? */
		valid = 0;	
		return NULL;
	}	
}

- (void)free
{
	if(self->curr)
		[self->curr release];
}

@end

@implementation IMPListNode : IMPObject

- (id)init
{
	[super init];
	self->data = NULL;
	self->next = NULL;

	return self;
}

- (void)free
{
	[self->data release];
	[self->next release];

	[super free];
}

- (void)set_data:(IMPObject *)data
{
	self->data = data;

	if(self->data)
		[self->data grab];
}

- (IMPObject *)get_data
{
	return self->data;
}

- (void)set_next:(IMPListNode *)next
{
	self->next = next;

	if(self->next)
		[self->next grab];
}

- (IMPListNode *)get_next
{
	return self->next;	
}

@end

@implementation IMPList : IMPObject


@end

