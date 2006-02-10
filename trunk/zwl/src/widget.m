/*
    zwl
    Copyright (C) 2004,2005,2006 zwl Developers

    zwl is the legal property of its developers, whose names are
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

#include "zwl.h"

@implementation ZWidget : IMPObject

- init
{
	self->name = NULL;
	self->window = NULL;
	self->parent = NULL;

	zwl_main_loop_add_widget(self);
}

- show
{
	if(self->window)
		XMapWindow(zdpy,self->window);

	XSync(zdpy,False);
}

- set_name:(char *)name
{
	if(name)
		self->name = strdup(name);
}

- set_parent:(ZWidget *)parent
{
	if(parent) {
		self->parent = parent;
		[self->parent grab];
	}
}

- (void)recieve:(int)signal
{
	ZCallback *sig_callback = NULL;
	
	if(signal >= 0) {
		sig_callback = self->callbacks[signal];
		sig_callback(self,NULL);
	}
			
}

- (void)attatch_cb:(int)signal:(ZCallback *)callback
{
	if(signal >= 0) {
		self->callbacks[signal] = callback;
	}	
}

@end
