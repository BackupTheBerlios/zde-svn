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

@implementation IMPStack : IMPList

- (Protocol *)push:(int)type:(void *)user_data
{
	IMPStack *new_node;

	new_node = [IMPStack alloc];
	[new_node init:type];
	
	new_node->data = user_data;
	
	new_node->next = self;
	
	return new_node;
}

- (Protocol *)push:(void *)user_data
{
	IMPStack *new_node;

	new_node = [IMPStack alloc];
	[new_node init:1];
	
	new_node->data = user_data;
	
	new_node->next = self;
	
	return new_node;
}

- (void *)pop
{
	void *temp = self->data;

	self->next = NULL;
	self->data = NULL;
	
	[self release];
	
	return temp;	
}

- (void *)peek
{
	return self->data;
}

- (int)invert
{
	/* FIXME */
	return -1;
}

@end

@implementation IMPSimpleStack : IMPObject

- init:(int)num
{
	[super init];

	self->num = num;
	self->stack = i_calloc(num,sizeof(Object));
	self->head = -1;
}

- (Protocol *)push:(int)type:(void *)data
{
	return [self push:data];
}

- (Protocol *)push:(void *)data
{
	if(self->head == self->num)
		return NULL;
	
	self->stack[++self->head] = (Object *)data;

	return self;
}

- (void *)pop
{
	Object *tmp;

	if(self->head >= 0) {
		if(self->stack[self->head] != NULL) {
			tmp = self->stack[self->head];
			self->stack[self->head--] = NULL;

			return tmp;
		}
		else {
			return NULL;
		}
	}

	return NULL;
}

- (void *)peek
{
	return self->stack[self->head];
}

- (Object *)get_array
{
	return self->stack;
}

- (int)get_size
{
	return self->head + 1;
}

- (int)invert
{
	IMPSimpleStack *tmp = [IMPSimpleStack alloc];

	[tmp init:[self get_size] + 5];

	[tmp push:[self pop]];

	[self push:[tmp pop]];

	[tmp release];
	return 0;
}

@end
