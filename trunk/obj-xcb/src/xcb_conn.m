/*
   Copyright (c) 2005, 2006 Thomas Coppi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 */

#include "obj-xcb.h"

@implementation ObjXCBConnection

/* FIXME error handling */
- init
{
	[super init];

	self->c = XCBConnect(NULL,&defscreen);
	
	if(!self->c)
		return NULL;

	self->s = ((XCBSCREENIter)XCBSetupRootsIter([self get_setup_data])).data;

	if(!self->s) 
		return NULL;

	return self;
}

/* FIXME error handling */
- init:(const char *)display:(int *)screen
{
	[super init];

	self->c = XCBConnect(display,screen);
	self->defscreen = *screen;

	if(!self->c)
		return NULL;

	self->s = ((XCBSCREENIter)XCBSetupRootsIter([self get_setup_data])).data;

	return self;
}
/* FIXME error handling */
- init_auth:(const char *)display:(XCBAuthInfo *)auth:(int *)screen
{
	[super init];

	if(!auth)
		return NULL;

	self->c = XCBConnectToDisplayWithAuthInfo(display,auth,screen);
	self->defscreen = *screen;

	if(!self->c)
		return NULL;
	
	self->s = ((XCBSCREENIter)XCBSetupRootsIter([self get_setup_data])).data;

	[self init];
	return self;
}

/* FIXME error handling */
- init_auth:(int)fd:(XCBAuthInfo *)auth
{
	[super init];

	if(!auth)
		return NULL;

	self->c = XCBConnectToFD(fd,auth);
	
	/* FIXME XXX defscreen? XXX FIXME */
	
	if(!self->c)
		return NULL;
	
	self->s = ((XCBSCREENIter)XCBSetupRootsIter([self get_setup_data])).data;
	
	[self init];
	return self;
}

- (int)get_fd;
{
	return XCBGetFileDescriptor(self->c);
}

- (XCBConnection *)get_connection
{
	return self->c;
}

- (XCBSCREEN *)get_screen
{
	return self->s;
}

- (const XCBSetup *)get_setup_data
{
	return XCBGetSetup(self->c);
}

/*
 *
 * Handy functions, mostly just members of structures.
 *
 */

- (int)get_default_screen
{
	return self->defscreen;
}

- (int)get_screen_count
{
	return XCBSetupRootsLength([self get_setup_data]);
}

- (char *)get_vendor
{
	char *vendor = NULL;
	int len;

	len = XCBSetupVendorLength([self get_setup_data]);
	vendor = calloc(len + 1,1);
	
	if(!vendor)
		return NULL;
	
	memcpy(vendor,XCBSetupVendor([self get_setup_data]),len);
	vendor[len] = '\0';
}

- (int)get_major_protover
{
	return [self get_setup_data]->protocol_major_version;
}

- (int)get_minor_protoversion
{
	return [self get_setup_data]->protocol_minor_version;
}

- (int)get_vendor_version
{
	return [self get_setup_data]->release_number;
}

- (XCBWINDOW)get_root_window_raw
{
	return self->s->root;	
}

- (int)get_black_pixel
{
	return self->s->black_pixel;
}

- (int)get_white_pixel
{
	return self->s->white_pixel;
}

- (int)get_width
{
	return self->s->width_in_pixels;
}

- (int)get_height
{
	return self->s->height_in_pixels;
}

- (int)get_depth
{
	return self->s->root_depth;
}

- (BOOL)has_saveunders
{
	return self->s->save_unders;
}

- (int)get_backing_store
{
	return self->s->backing_stores;
}

- (int)get_input_masks
{
	return self->s->current_input_masks;
}

/*
 * Functions that do stuff.
 */

- (int)flush
{
	return XCBFlush(self->c);
}

- (const XCBQueryExtensionRep *)get_extension_data:(XCBExtension *)ext
{
	return XCBGetExtensionData(self->c,ext);
}

- (XCBGenericEvent *)next_event
{
	return XCBWaitForEvent(self->c);
}

- (XCBGenericEvent *)poll_next_event:(int *)error
{
	return XCBPollForEvent(self->c,error);
}

- free
{
	XCBDisconnect(self->c);
	
	self->c = NULL;

	[super free];
}

@end
