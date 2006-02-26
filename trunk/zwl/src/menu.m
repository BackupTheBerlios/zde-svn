/*
    zwl
    Copyright (C) 2004,2005,2006 zwl Developers

    zwl is the legal property of its developers, whose names are
    too numerous to list here.  Please refer to the COPYING file
    for the full text of this license and to the AUTHORS file for
    the complete list of developers.

    This program is i_free software; you can redistribute it and/or
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

#include "zwl.h"

/* Internal callback prototypes */
void on_added(IMPObject *widget, void *data);

@implementation ZMenu : ZWindow

- init:(int)x:(int)y
{
	self->window = NULL;
	self->parent = NULL;
	self->label = NULL;
	
	[super init:NULL:x:y:1:1];

	//XChangeProperty(zdpy,self->window,net_wm_window_type,XA_ATOM,32,PropModeReplace,&net_wm_window_type_menu,1);	

	[self attatch_internal_cb:ADDED:(ZCallback *)on_added];
}

- free
{
	if(self->label)
		i_free(label);

	[super i_free];
}

- (void)set_label:(char *)label
{
	if(label) {
		if(self->label)
			i_free(self->label);

		self->label = i_strdup(label);	
	}

}

- (void)get_label
{
	return self->label;
}

@end

void on_added(IMPObject *widget, void *data)
{

}

