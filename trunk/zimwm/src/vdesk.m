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
	[super init];
	
	if(vwork > 0)
		self->vwork = vwork;
	else 
		self->vwork = 1;

	self->clients_stacking = NULL;
	
	self->clients = [IMPList alloc];
	[self->clients init:1];
	
	if(width > 0)
		self->width = width;
	if(height > 0)
		self->height = height;
}

- free
{
	[self->clients delete_list];

	[super free];
}

- (void)add_client:(ZimClient *)client
{
	if(!client)
		return;
	
	if(self->clients) {
		[self->clients append_data:client];
	}
	else {
		self->clients = [IMPList alloc];
		[self->clients init:1];
		self->clients->data = client;
	}

	[self add_client_stacking:client];
}

- (void)remove_client:(ZimClient *)client
{
	IMPList *list = self->clients;
	ZimClient *tmp;
	
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

	[self remove_client_stacking:client];
}

- (void)add_client_stacking:(ZimClient *)client
{
	if(self->clients_stacking) {
		[self->clients_stacking push:client];
	}
	else {
		self->clients_stacking = [IMPSimpleStack alloc];
		[self->clients_stacking init:500];
		[self->clients_stacking push:client];
	}

	self->clients_stacking = update_client_list_stacking(self->clients_stacking);
}

- (void)remove_client_stacking:(ZimClient *)client
{
	ZimClient *c = NULL;
	IMPSimpleStack *temp = [IMPSimpleStack alloc];

	[temp init:500];
	
	if(self->clients_stacking) {
		while([self->clients_stacking get_size] > 0) {	
			c = (ZimClient *)[self->clients_stacking pop];
			
			if(c->window == client->window) {
				while([temp get_size] > 0) {
					c = (ZimClient *)[temp pop];
					
					[self->clients_stacking push:(void *)c];
				}
				
				[temp release];
				break;
			}
			else {
				[temp push:c];	
			}
		}
	}

	self->clients_stacking = update_client_list_stacking(self->clients_stacking);
}

- (void)raise_client:(ZimClient *)client
{
	ZimClient *c = NULL;
	IMPSimpleStack *temp = [IMPSimpleStack alloc];

	[temp init:500];
	
	if(self->clients_stacking && client) {
		while([self->clients_stacking get_size] > 0) {	
			c = (ZimClient *)[self->clients_stacking pop];
			
			if(c->window == client->window) {
				while([temp get_size] > 0) {
					c = (ZimClient *)[temp pop];
					
					[self->clients_stacking push:(void *)c];
				}
				
				[temp release];
				[self->clients_stacking push:(void *)client];
				break;
			}
			else {
				[temp push:c];	
			}
		}
	}

	self->clients_stacking = update_client_list_stacking(self->clients_stacking);
}

- (const IMPList *)get_clients
{
	return self->clients;
}

- (const IMPSimpleStack *)get_clients_stacking
{
	return self->clients_stacking;
}

- (unsigned int)get_num
{
	return self->vwork;
}

- (int)get_width
{
	return self->width;
}

- (int)get_height
{
	return self->height;
}

@end

@implementation VDesk : IMPObject

- init:(unsigned int)vdesk:(VWorkspace *)first
{
	VWorkspace *tmp;
	
	[super init];
	
	if(vdesk > 0)
		self->vdesk = vdesk;
	
	self->workspaces = [IMPList alloc];
	[self->workspaces init:1];

	if(!first) {
		tmp = [VWorkspace alloc];
		[tmp init:1:XDisplayWidth(zdpy,zscreen):XDisplayHeight(zdpy,zscreen)];
		[self add_workspace:tmp];
		self->curr_workspace = tmp;
	}
	else {
		[self add_workspace:first];
		self->curr_workspace = first;
	}

	update_current_desktop([[self get_current_workspace] get_num] - 1);
}

- free
{
	[self->workspaces delete_list];
}

- (void)add_workspace:(VWorkspace *)workspace
{
	if(workspace) {
		[self->workspaces append_data:workspace];
	}
}

- (void)remove_workspace:(VWorkspace *)workspace
{
	IMPList *list = self->workspaces;
	VWorkspace *tmp;
	
	if(!workspace)
		return;

	tmp = (VWorkspace *)self->workspaces->data;
	if(workspace == tmp && self->workspaces) {
		list = [list delete_node];
		self->workspaces = list;
	}
	else {
		while(list) {
			tmp = (VWorkspace *)list->next->data;

			if((workspace == tmp) && list->next) {
				list = [list delete_next_node];
				break;
			}

			list = list->next;
		}
	}
}

- (const VWorkspace *)get_current_workspace
{
	return self->curr_workspace;
}

- (const VWorkspace *)get_nth_workspace:(int)n
{
	IMPList *list = self->workspaces;
	VWorkspace *tmp;

	while(list) {
		tmp = list->data;

		if(!tmp) {
			list = list->next;
			continue;
		}
		
		if([tmp get_num] == n) {
			return tmp;
		}
		
		list = list->next;
	}

	return NULL;
}

- (const VWorkspace *)move_next
{
	IMPList *list = NULL;
	VWorkspace *tmp = [self get_current_workspace];
	ZimClient *c = NULL;
	int swidth = 0;

	if([self->curr_workspace get_num] + 1 > [self->workspaces get_size] - 1) 
		return;
	
	/* Move all windows on the current workspace over. */
	list = [tmp get_clients];

	swidth = [[self get_current_workspace] get_width];	
	while(list) {
		c = list->data;

		if(!c) {
			list = list->next;
			continue;
		}

		[c move:c->window->x - swidth:c->window->y];
		
		list = list->next;
	}
	
	/* Get the next workspace. */
	list = self->workspaces;
	while(list) {
		tmp = list->data;

		if(!tmp) {
			list = list->next;
			continue;
		}
		
		if([tmp get_num] == [self->curr_workspace get_num] + 1) {	
			self->curr_workspace = tmp;	
			break;
		}
		
		list = list->next;
	}

	if(!tmp)
		return;
	
	list = [tmp get_clients];

	/* Move all windows on the next workspace over. */
	swidth = [[self get_current_workspace] get_width];
	while(list) {
		c = list->data;

		if(!c) {
			list = list->next;
			continue;
		}

		[c move:c->window->x - swidth:c->window->y];
		
		list = list->next;
	}

	[[self get_current_workspace] raise_client:NULL];
	update_current_desktop([[self get_current_workspace] get_num] - 1);

	return [self get_current_workspace];
}

- (const VWorkspace *)move_prev
{
	IMPList *list = NULL;
	VWorkspace *tmp = [self get_current_workspace];
	ZimClient *c = NULL;
	int swidth = 0;

	if([self->curr_workspace get_num] - 1 <= 0) 
		return;

	/* Move all windows on the current workspace over. */
	list = [tmp get_clients];

	swidth = [[self get_current_workspace] get_width];
	
	while(list) {
		c = list->data;

		if(!c) {
			list = list->next;
			continue;
		}

		[c move:c->window->x + swidth:c->window->y];
		
		list = list->next;
	}
	
	/* Get the next workspace. */
	list = self->workspaces;
	while(list) {
		tmp = list->data;

		if(!tmp) {
			list = list->next;
			continue;
		}
		
		if([tmp get_num] == [self->curr_workspace get_num] - 1) {
			self->curr_workspace = tmp;	
			break;
		}
		
		list = list->next;
	}

	if(!tmp)
		return;
	
	list = [tmp get_clients];

	swidth = [[self get_current_workspace] get_width];
	
	/* Move all windows on the next workspace over. */
	while(list) {
		c = list->data;

		if(!c) {
			list = list->next;
			continue;
		}

		[c move:c->window->x + swidth:c->window->y];
		
		list = list->next;
	}

	[[self get_current_workspace] raise_client:NULL];
	update_current_desktop([[self get_current_workspace] get_num] - 1);

	return [self get_current_workspace];
}

- (const VWorkspace *)move_nth:(unsigned int)index
{
	int i = 0;

	if(([[self get_current_workspace] get_num] - 1) < index) {
		for(i=0;i<abs(([[self get_current_workspace] get_num] - 1) - index);i++)
			[self move_prev];
	}
	else if(([[self get_current_workspace] get_num] - 1) > index) {
		for(i=0;i<abs(([[self get_current_workspace] get_num] - 1) - index);i++)
			[self move_next];
	}
	
}

- (void)calculate_dimensions
{
	IMPList *list = self->workspaces;
	VWorkspace *data;
	
	while(list) {
		data = list->data;

		if(!data)
			continue;

		self->height = [data get_height];
		self->width += [data get_width];
		
		list = list->next;
	}
}

- (unsigned int)get_num
{
	return self->vdesk;
}

- (unsigned int)get_num_workspaces
{
	return [self->workspaces get_size];
}

- (int)get_width
{
	return self->width;
}

- (int)get_height
{
	return self->height;
}

@end
