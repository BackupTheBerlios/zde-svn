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

@implementation Zone : IMPObject

- init:(Display *)dpy:(int)screen:(ZWidget *)root_window:(VDesk *)first
{
	VDesk *tmp;

	[super init];
	
	if(dpy)
		self->dpy = dpy;
	else
		dpy = NULL;

	self->screen = screen;

	if(root_window) {
		self->root_window = root_window;
		[self->root_window grab];
	}
	
	self->vdesks = [IMPList alloc];
	[self->vdesks init:1];

	if(!first) {
		tmp = [VDesk alloc];
		[tmp init:1:NULL];
		[self->vdesks append_data:tmp];
		self->curr_desk = tmp;
	}
	else {
		[self->vdesks append_data:first];
		self->curr_desk = first;
	}
}

- free
{
	[self->vdesks delete_list];
}

- (void)add_vdesk:(VDesk *)vdesk
{
	if(vdesk)
		[self->vdesks append_data:vdesk];
}

- (void)remove_vdesk:(VDesk *)vdesk
{
	IMPList *list = self->vdesks;
	VDesk *tmp;
	
	if(!vdesk)
		return;

	tmp = (VDesk *)self->vdesks->data;
	if(vdesk == tmp && self->vdesks) {
		list = [list delete_node];
		self->vdesks = list;
	}
	else {
		while(list) {
			tmp = (VDesk *)list->next->data;

			if((vdesk == tmp) && list->next) {
				list = [list delete_next_node];
				break;
			}

			list = list->next;
		}
	}
}

- (void)set_dpy:(Display *)disp
{
	if(disp)
		self->dpy = disp;
}

- (void)set_screen:(int)scr
{
	self->screen = scr;
}

- (const Display *)get_dpy
{
	return self->dpy;
}

- (int)get_screen
{
	return self->screen;
}

- (const ZWidget *)get_root
{
	return self->root_window;
}

- (const VDesk *)get_current_desk
{
	return self->curr_desk;
}

- (const VWorkspace *)get_current_workspace
{
	return [self->curr_desk get_current_workspace];
}

- (const VDesk *)move_next
{

}

- (const VDesk *)move_prev
{

}

@end

