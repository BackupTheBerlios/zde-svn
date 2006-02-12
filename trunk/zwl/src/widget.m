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

/* Internal callback prototypes */
static void on_destroy(IMPObject *widget, void *data);

@implementation ZWidget : IMPObject

- init
{
	int i;

	[super init];
	
	self->name = NULL;
	self->window = NULL;
	self->parent = NULL;

	zwl_main_loop_add_widget(self);

	for(i=0;i<100;i++) {
		self->children[i] = NULL;
		self->internal_callbacks[i] = NULL;
		self->callbacks[i] = NULL;
	}

	/* Attatch internal callbacks */
	[self attatch_internal_cb:DESTROY:(ZCallback *)on_destroy];

}

- free
{
	if(self->name)
		free(self->name);
	if(self->parent)
		[self->parent release];
	
	[super free];	
}

- (void)show
{
	if(self->window)
		XMapWindow(zdpy,self->window);

	XSync(zdpy,False);

	[self receive:SHOW:NULL];
}

- (void)destroy
{
	if(self->window)
		XDestroyWindow(zdpy,self->window);

	XSync(zdpy,False);
}

- set_name:(char *)name
{
	if(name)
		self->name = strdup(name);
}

- get_name
{
	return self->name;
}

- add_child:(ZWidget *)child
{
	int i;

	/* find the next open spot and add it */
	for(i=0;i<100;i++) {
		if(self->children[i] == NULL) {
			self->children[i] = child;
		
			[child set_parent:self];
			[child receive:ADDED:child];
			
			break;
		}
	}
}

- set_parent:(ZWidget *)parent
{
	if(parent) {
		self->parent = parent;
		[self->parent grab];
	}
}

- (void)receive:(int)signal:(void *)data
{
	ZCallback *sig_internal_callback = NULL;
	ZCallback *sig_callback = NULL;

	/* Make sure the internal callback is called first. */
	if(signal >=0 && self->internal_callbacks[signal] != NULL) {
		sig_internal_callback = self->internal_callbacks[signal];
		sig_internal_callback(self,data);
	}
	
	if(signal >= 0 && self->callbacks[signal] != NULL) {
		sig_callback = self->callbacks[signal];
		sig_callback(self,data);
	}
			
}

- (void)attatch_cb:(int)signal:(ZCallback *)callback
{
	if(signal >= 0) {
		self->callbacks[signal] = callback;
	}	
}

- (void)attatch_internal_cb:(int)signal:(ZCallback *)callback
{
	if(signal >= 0) {
		self->internal_callbacks[signal] = callback;
	}
}

@end

/* Internal callbacks. */
static void on_destroy(IMPObject *widget, void *data)
{
	[widget release];
}
