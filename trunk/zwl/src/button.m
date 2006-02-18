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
static void on_add(IMPObject *widget, void *data);
static void on_expose(IMPObject *widget, void *data);
static void on_label_down(IMPObject *widget, void *data);
static void on_label_up(IMPObject *widget, void *data);

@implementation ZButton : ZWindow

- init:(int)x:(int)y:(int)width:(int)height
{
	self->window = NULL;
	self->zlabel = [ZLabel alloc];
	[super init:x:y:width:height];
	
	[self attatch_internal_cb:ADDED:(ZCallback *)on_add];
	[self attatch_internal_cb:EXPOSE:(ZCallback *)on_expose];

}

- free
{
	if(self->label)
		free(self->label);
	
	[super free];
}

- (void)set_label:(char *)label
{
	XftFont *font = XftFontOpenName(zdpy,DefaultScreen(zdpy),"sans-8");;
	XGlyphInfo extents;

	if(label) {
		if(self->label)
			free(self->label);

		self->label = strdup(label);	
		if(self->window) {
			XftTextExtents8(zdpy,font,self->label,strlen(self->label),&extents);
			
			[self->zlabel move:(self->width / 2) - (extents.width / 2):extents.height];
			[self->zlabel set_label:self->label];
			[self receive:EXPOSE:self];
		}
	}
}

- (char *)get_label
{
	return self->label;
}

@end

static void on_add(IMPObject *widget, void *data)
{
	ZButton *myself = (ZButton *)data;
	ZWidget *parent = myself->parent;
	XSetWindowAttributes attr;

	attr.event_mask = ButtonPressMask |
    			  ButtonReleaseMask |
     			  EnterWindowMask |
     			  LeaveWindowMask |
     		 	  PointerMotionMask |
     			  ExposureMask |
     		  	  StructureNotifyMask |
     			  KeyPressMask |
     			  KeyReleaseMask;
	
	
	myself->window = (Window *)XCreateSimpleWindow(zdpy,parent->window,
			myself->x,myself->y,myself->width,myself->height,
		1,WhitePixel(zdpy,DefaultScreen(zdpy)),1);

	[myself->zlabel init:0:0];
	[myself add_child:(ZWidget *)myself->zlabel];
	[myself->zlabel attatch_internal_cb:BUTTON_DOWN:(ZCallback *)on_label_down];
	[myself->zlabel attatch_internal_cb:BUTTON_UP:(ZCallback *)on_label_up];

	XChangeWindowAttributes(zdpy,myself->window,CWEventMask,&attr);

	myself->xftdraw = XftDrawCreate(zdpy,myself->window,DefaultVisual(zdpy,DefaultScreen(zdpy)),DefaultColormap(zdpy,DefaultScreen(zdpy)));
	
	zwl_main_loop_add_widget(myself);
}

static void on_expose(IMPObject *widget, void *data)
{
	ZButton *myself = (ZButton *)data;
/*	XftColor xftcolor;
	XftFont *font;
	XGlyphInfo extents;
	char *label = [myself get_label];

	XClearWindow(zdpy,myself->window);

	XftColorAllocName(zdpy,DefaultVisual(zdpy,DefaultScreen(zdpy)),DefaultColormap(zdpy,DefaultScreen(zdpy)),"white",&xftcolor);
	font = XftFontOpenName(zdpy,DefaultScreen(zdpy),"sans-8");
	XftTextExtents8(zdpy,font,label,strlen(label),&extents);
	
	XftDrawString8(myself->xftdraw,&xftcolor,font,
			(myself->width / 2) - (extents.width / 2),
			(myself->height) - (extents.height),
			label,strlen(label));	
	*/
	[myself->zlabel show];
}

/* These two functions forward BUTTON_UP and BUTTON_DOWN events
   to the button instead of the label. */
static void on_label_down(IMPObject *widget, void *data)
{
	ZWidget *w = (ZWidget *)widget;
	[w->parent receive:BUTTON_DOWN:data];
}

static void on_label_up(IMPObject *widget, void *data)
{
	ZWidget *w = (ZWidget *)widget;
	[w->parent receive:BUTTON_UP:data];
}

