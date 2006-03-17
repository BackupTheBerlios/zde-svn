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
static void on_destroy(IMPObject *widget, void *data);

@implementation ZWidget : IMPObject

- init
{
	int i;

	[super init];
	
	self->name = NULL;
	self->window = NULL;
	self->parent = NULL;
	self->children = NULL;

	for(i=0;i<100;i++) {
		self->internal_callbacks[i] = NULL;
		self->callbacks[i] = NULL;
	}

	/* Attatch internal callbacks */
	[self attatch_internal_cb:DESTROY:(ZCallback *)on_destroy];

}

- free
{
	if(self->name)
		i_free(self->name);
	
	[super free];
}

- (void)show
{
	if(self->window)
		XMapWindow(zdpy,(Window)self->window);

	XSync(zdpy,False);

	[self receive:SHOW:NULL];
}

- (void)destroy
{
	if(self->window) {
		XDestroyWindow(zdpy,(Window)self->window);
		self->window = NULL;
	}

	[self receive:DESTROY:NULL];

	zwl_main_loop_remove_widget(self);
		
	XSync(zdpy,False);
}

- (void)set_name:(char *)name
{
	if(name) {
		if(self->name)
			i_free(self->name);

		self->name = i_strdup(name);
	}
}

- (char *)get_name
{
	return self->name;
}

- (void)add_child:(ZWidget *)child
{
	if(child) {
		if(!self->children) {
			self->children = [IMPList alloc];
			[self->children init:1];

			self->children->data = child;
		}
		else {
			[self->children append_data:child];
		}	
		
		[child set_parent:self];
		[child receive:ADDED:child];
	}	
}

- (void)set_parent:(ZWidget *)parent
{
	if((parent) && parent != (ZWidget *)self->window) {
		self->parent = parent;
		[self->parent grab];
	}
}

- (void)move:(int)x:(int)y
{
	self->x = x;
	self->y = y;

	XMoveResizeWindow(zdpy,(Window)self->window,self->x,self->y,self->width,self->height);
}

- (void)resize:(int)width:(int)height
{
	self->width = width;
	self->height = height;

	XMoveResizeWindow(zdpy,(Window)self->window,self->x,self->y,self->width,self->height);
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

