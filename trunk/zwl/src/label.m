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
static void on_add(IMPObject *widget, void *data);
static void on_expose(IMPObject *widget, void *data);

@implementation ZLabel : ZWindow

- init:(int)x:(int)y:(int)width:(int)height
{
	self->window = NULL;
	self->label = NULL;

	[super init:x:y:width:height];

	self->resize = 0;
	
	self->font = XftFontOpenName(zdpy,DefaultScreen(zdpy),"sans-8");

	[self attatch_internal_cb:ADDED:(ZCallback *)on_add];
	[self attatch_internal_cb:EXPOSE:(ZCallback *)on_expose];
}

- init:(int)x:(int)y
{
	self->window = NULL;
	self->label = NULL;

	[super init:x:y:1:1];

	self->resize = 1;
	
	self->font = XftFontOpenName(zdpy,DefaultScreen(zdpy),"sans-8");

	[self attatch_internal_cb:ADDED:(ZCallback *)on_add];
	[self attatch_internal_cb:EXPOSE:(ZCallback *)on_expose];
}

- free
{
	if(self->label)
		i_free(self->label);

	if(self->font)
		
	
	[super free];
}

- (void)set_label:(char *)label
{
	if(label) {
		if(self->label)
			i_free(self->label);

		self->label = i_strdup(label);	
		[self receive:EXPOSE:self];
	}
}

- (const char *)get_label
{
	return self->label;
}

- (XGlyphInfo *)get_text_extents
{
	XGlyphInfo *extents = i_calloc(1,sizeof(XGlyphInfo));
			
	XftTextExtents8(zdpy,self->font,(unsigned char *)self->label,strlen(self->label),extents);

	return extents;
}

- (const XftFont *)get_font
{
	return self->font;
}

@end

static void on_add(IMPObject *widget, void *data)
{
	ZLabel *myself = (ZLabel *)data;
	ZWidget *parent = myself->parent;
	XSetWindowAttributes attr;

	attr.event_mask = ButtonPressMask |
    			  ButtonReleaseMask |
     			  EnterWindowMask |
     			  LeaveWindowMask |
     		 	  PointerMotionMask |
     			  ExposureMask |
     		  	  StructureNotifyMask |
		//	  SubstructureNotifyMask |
     			  KeyPressMask |
     			  KeyReleaseMask;
	
	
	myself->window = (Window *)XCreateSimpleWindow(zdpy,(Window)parent->window,
			myself->x,myself->y,myself->width,myself->height,
		0,WhitePixel(zdpy,DefaultScreen(zdpy)),1);

	XChangeWindowAttributes(zdpy,(Window)myself->window,CWEventMask,&attr);

	myself->xftdraw = XftDrawCreate(zdpy,(Window)myself->window,DefaultVisual(zdpy,DefaultScreen(zdpy)),
			DefaultColormap(zdpy,DefaultScreen(zdpy)));
	
	zwl_main_loop_add_widget(myself);
}

static void on_expose(IMPObject *widget, void *data)
{
	ZLabel *myself = (ZLabel *)widget;
	XftColor xftcolor;
	XGlyphInfo *extents;
	char *label = [myself get_label];

	XClearWindow(zdpy,(Window)myself->window);

	XftColorAllocName(zdpy,DefaultVisual(zdpy,DefaultScreen(zdpy)),DefaultColormap(zdpy,DefaultScreen(zdpy)),"white",&xftcolor);

	if(myself->resize && label) {
		extents = [myself get_text_extents];
		
		myself->width = extents->width + 1;
		myself->height = extents->height + 2; /* XXX the +2 helps to compensate for y's and g's. ??!?! */
	
		[myself resize:myself->width:myself->height];
	}
		
	if(label) {	
		XftDrawString8(myself->xftdraw,&xftcolor,[myself get_font],
				0,
				extents->height,
				(unsigned char *)label,strlen(label));	
	}
}
