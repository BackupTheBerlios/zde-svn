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

@implementation IMPList : IMPObject

- init:(int)type
{
	[super init];

	self->data = NULL;
	self->next = NULL;
	self->type = type;
}

- free
{	
	if(self->type == 0)
		i_free(self->data);
	else if(self->type == 1)
		[(IMPObject *)self->data release];
	else fprintf(stderr, "Error. list->type not 0 or 1.\n");

	if(self->next != NULL)	
		[self->next free];

	[super free];
}

- (IMPList *)append_data:(void *)user_data
{
	IMPList *temp = self;
	IMPList *new_node;
	
	/* find end of list */
	while(temp->next != NULL) {
		temp = temp->next;
	}

	new_node = [IMPList alloc];
	[new_node init:self->type];

	new_node->data = user_data;
	temp->next = new_node;
	
	return temp->next;
}

- (IMPList *)prepend_data:(void *)user_data
{
	IMPList *new_node;

	new_node = [IMPList alloc];
	[new_node init];

	new_node->data = data;
	new_node->next = self;
	new_node->type = self->type;

	return new_node;	
}

- (IMPList *)insert_data_nth:(int)pos:(void *)user_data
{
	fprintf(stderr,"insert_data_nth not yet implemented.  Please implement it!\n");
}

- (IMPList *)delete_next_node
{
	IMPList *tmp = NULL;

	tmp = self->next->next;

	[self->next free];

	self->next = tmp;

	return self->next;
}

- (IMPList *)delete_node
{
	IMPList *tmp = self->next;

	[self free];
	
	return tmp;
}

@end

