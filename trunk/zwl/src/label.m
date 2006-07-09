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
#include "zwl_internal.h"

/* Internal callback prototypes */
static void on_add(ZWidget *widget, void *data);
static void on_expose(ZWidget *widget, void *data);

@implementation ZLabel : ZWidget


- init:(char *)label:(int)x:(int)y
{
	[super init];

	self->window = NULL;
	[self set_text:label];

	self->x = x;
	self->y = y;

	self->family = i_strdup("Sans");
	self->size = 11;

	[self attatch_internal_cb:ADDED:(ZCallback *)on_add];
	[self attatch_internal_cb:EXPOSE:(ZCallback *)on_expose];
}

- free
{
	if(self->text)
		i_free(self->text);	
	
	[super free];
}

- (void)set_text:(char *)text
{
	if(text) {
		if(self->text)
			i_free(self->text);

		self->text = i_strdup(text);	
		[self receive:EXPOSE:self];
	}
}

- (const char *)get_text
{
	return self->text;
}

- (void)set_font_family:(char *)font
{
	if(font) {
		i_free(self->family);
		self->family = i_strdup(font);
	}
}

- (const char *)get_font_family
{
	return self->family;
}

- (cairo_text_extents_t *)get_text_extents
{
	cairo_text_extents_t *extents = i_calloc(1,sizeof(cairo_text_extents));
	cairo_t *cr;

	if(!self->window)
		return NULL;

	cr = cairo_create(self->win_surf);

	cairo_select_font_face(cr,[self get_font_family],CAIRO_FONT_SLANT_NORMAL,CAIRO_FONT_WEIGHT_NORMAL);	
	cairo_set_font_size(cr,self->size);	
	cairo_text_extents(cr,self->text,extents);

	cairo_destroy(cr);

	return extents;
}

@end

static void on_add(ZWidget *widget, void *data)
{
	ZLabel *myself = (ZLabel *)data;
	ZWidget *parent = myself->parent;
	cairo_text_extents_t *extents;

	ObjXCBWindow *w = [ObjXCBWindow alloc];
	XCBSCREEN *s;
	XCBDRAWABLE draw;
	
	CARD32 wvalue[2];

	[w init:zc];

	s = [zc get_screen];
			
	wvalue[0] = [zc get_black_pixel];
	wvalue[1] = XCBEventMaskExposure           | XCBEventMaskButtonPress
             	  | XCBEventMaskButtonRelease      | XCBEventMaskPointerMotion
                  | XCBEventMaskEnterWindow        | XCBEventMaskLeaveWindow
                  | XCBEventMaskKeyPress           | XCBEventMaskKeyRelease
	          | XCBEventMaskSubstructureNotify | XCBEventMaskSubstructureRedirect
	          | XCBEventMaskEnterWindow	   | XCBEventMaskLeaveWindow
	          | XCBEventMaskStructureNotify;
	
	[w CreateWindow:XCBCopyFromParent:parent->window:myself->x:myself->y:1:1:0:XCBWindowClassInputOutput:
						s->root_visual:XCBCWEventMask | XCBGCForeground:wvalue];

	myself->window = w;
	
	/* Now setup the cairo surface */
	if([parent get_backend] == ZWL_BACKEND_XCB) {
		draw.window = [myself->window get_xid];
		[myself set_window_surf:cairo_xcb_surface_create(
							[zc get_connection],
							draw,
							_get_root_visual_type(s),
							1,1)];
		[myself set_backend:[parent get_backend]];
	}
	else if([parent get_backend] == ZWL_BACKEND_GL_GLITZ) {
		fprintf(stderr,"OpenGL glitz backend not yet coded, please submit patch.\n");
	}

	zwl_main_loop_add_widget(myself);
}

static void on_expose(ZWidget *widget, void *data)
{
	ZLabel *myself = (ZLabel *)widget;
	cairo_t *cr;
	cairo_text_extents_t *extents;

	char *text = [myself get_text];

	if(!text || ![myself get_surf] || !myself->window)
		return;

	extents = [myself get_text_extents];
	myself->width = extents->width + 1;
	myself->height = extents->height + 2;

	[myself resize:myself->width:myself->height];

	[myself clear:1:1:1:0];

	cr = cairo_create([myself get_surf]);

	cairo_move_to(cr,0,myself->height);

	cairo_set_source_rgb(cr,1,1,1);

	cairo_select_font_face(cr,[myself get_font_family],CAIRO_FONT_SLANT_NORMAL,CAIRO_FONT_WEIGHT_NORMAL);
	cairo_set_font_size(cr,myself->size);
	cairo_show_text(cr,[myself get_text]);

	cairo_destroy(cr);	
}

#if 0
static void on_expose(ZWidget *widget, void *data)
{
	ZLabel *myself = (ZLabel *)widget;
	XftColor xftcolor;
	XGlyphInfo *extents;
	char *label = [myself get_label];

	XClearWindow(zdpy,(Window)myself->window);
		
	xftcolor.color.red = ~0;
	xftcolor.color.green = ~0;
	xftcolor.color.blue = ~0;
	
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
#endif
