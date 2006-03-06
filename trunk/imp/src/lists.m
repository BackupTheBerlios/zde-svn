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
	IMPObject *data = NULL;;
	if(self->type == 0 && self-data)
		i_free(self->data);
	else if(self->type == 1 && self->data) {
		data = (IMPObject *)self->data;	
		[data free];
	}
	else fprintf(stderr, "Error. list->type not 0 or 1.\n");

	if(self->next)	
		[self->next free];

	[super free];
}

- (IMPList *)append_data:(void *)user_data
{
	IMPList *temp = self;
	IMPList *new_node;
	IMPObject *data = (IMPObject *)user_data;
	
	/* find end of list */
	while(temp->next != NULL) {
		temp = temp->next;
	}

	new_node = [IMPList alloc];
	[new_node init:self->type];

	new_node->data = user_data;
	temp->next = new_node;
	
	if(self->type == 1)
		[data grab];
	
	return temp->next;
}

- (IMPList *)prepend_data:(void *)user_data
{
	IMPList *new_node;

	new_node = [IMPList alloc];
	[new_node init:self->type];

	new_node->data = user_data;
	new_node->next = self;
	new_node->type = self->type;

	if(self->type == 1)
		[new_node->data grab];
	
	return new_node;	
}

- (IMPList *)insert_data_nth:(int)pos:(void *)user_data
{
	int i;
	IMPList *curr = self;
	IMPList *tmp,*tmp1;
	
	/* This gets us to the place BEFORE where we want to insert. */
	for(i=0;i<pos - 1;i++) {
		if(curr->next == NULL)
			return NULL;
		
		curr = curr->next;
	}
	
	tmp = [IMPList alloc];
	[tmp init:self->type];
	tmp->data = user_data;

	tmp1 = curr->next;
	curr->next = tmp;
	tmp->next = tmp1;
	
	return tmp;

	//fprintf(stderr,"insert_data_nth not yet implemented.  Please implement it!\n");
}

- (IMPList *)delete_next_node
{
	IMPList *tmp = NULL;

	if(self->next && self->next->next) {
		tmp = self->next->next;

		self->next->next = NULL;
		[self->next release];

		self->next = tmp;
	
		return self->next;
	}
	else if(self->next){
		tmp = NULL;

		self->next->next = NULL;
		[self->next release];

		self->next = tmp;
		return self->next;
	}
}

- (IMPList *)delete_node
{
	IMPList *tmp = self->next;

	//if(!tmp)
	//	return self;

	self->next = NULL;
	[self release];
	
	return tmp;
}

- (void)delete_list
{
	if(!self->next)
		return;

	[self release];
}

- (int)get_size
{
	IMPList *tmp = self;
	int i;
	
	for(i=0;tmp;i++){
		tmp = tmp->next;
	}
	
	return i;
}

@end

