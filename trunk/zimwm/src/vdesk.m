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

@implementation VWorkspace : IMPObject

- init:(unsigned int)vwork:(int)width:(int)height
{
	if(vwork > 0)
		self->vwork = vwork;
	else 
		self->vwork = 1;

	self->clients = [IMPList alloc];
	[self->clients init:1];

	if(width > 0)
		self->width = width;
	if(height > 0)
		self->height = height;
	
	[super init];
}

- free
{
	[self->clients delete_list];

	[super free];
}

- (void)add_client:(ZimClient *)client
{
	if(client)
		[self->clients append_data:client];
}

- (void)remove_client:(ZimClient *)client
{
	IMPList *list = self->clients;
	ZimClient *tmp;
	
	/* remove from client_list */
	if(!client)
		return;

	tmp = (ZimClient *)self->clients->data;
	if(client == tmp && self->clients) {
		list = [list delete_node];
		self->clients = list;
	}
	else {
		while(list) {
			tmp = (ZimClient *)list->next->data;

			if((client == tmp) && list->next) {
				list = [list delete_next_node];
				break;
			}

			list = list->next;
		}
	}
}

- (const IMPList *)get_clients
{
	return self->clients;
}

@end
