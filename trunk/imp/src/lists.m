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
		self->prev = NULL;
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
	[super free];
}

- (IMPObject *)get_data
{
	if(!valid)
		return NULL;

	return [self->curr get_data];
}

- (int)next
{
	if(!valid)
		return 0;

	if([self->curr get_next]) {
		self->prev = self->curr;
		self->curr = [self->curr get_next];
		return -1;
	}
	else
		return 0;
}

- (int)has_next
{
	if(!valid)
		return -1;

	if([self->curr get_next])
		return -1;
	else
		return 0;
}

- (void)ins_next:(IMPObject *)data
{
	if(!valid)
		return;

	IMPListNode *n = [IMPListNode alloc];
	[n init:data];
	
	[n set_next:[self->curr get_next]];

	[self->curr set_next:n];
}

- (void)invalidate
{
	self->valid = 0;
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

- (id)init:(IMPObject *)data
{
	[self init];
	[self set_data:data];

	return self;
}

- (void)free
{
	if(self->data)
		[self->data release];

	if(self->next)
		[self->next release];

	[super free];
}

- (void)set_data:(IMPObject *)data
{
	self->data = data;
}

- (IMPObject *)get_data
{
	return self->data;
}

- (void)set_next:(IMPListNode *)next
{
	self->next = next;
}

- (IMPListNode *)get_next
{
	return self->next;	
}

@end

@implementation IMPList : IMPObject

- (id)init
{
	[super init];

	self->head = [IMPListNode alloc];
	[self->head init];
	
	self->tail = self->head;

	self->curriter = NULL;

	return self;
}

- (void)free
{
	if(self->curriter)
		[self->curriter invalidate];

	if(self->head)
		[self->head release];

	[super free];
}

- (void)append:(IMPObject *)data
{
	if(self->curriter)
		[self->curriter invalidate];

	IMPListNode *n = [IMPListNode alloc];
	[n init:data];

	[self->tail set_next:n];
	self->tail = n;
}

- (IMPListIterator *)iterator
{
	IMPListIterator *iter = [IMPListIterator alloc];
	[iter init:self->head];

	if(self->curriter) {
		[self->curriter invalidate];
	}

	self->curriter = iter;

	return iter;
}

@end

