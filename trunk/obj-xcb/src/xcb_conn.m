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

	self->c = XCBConnect(NULL,NULL);

	if(!self->c)
		return NULL;
	else 
		return self;
}

/* FIXME error handling */
- init:(const char *)display:(int *)screen
{
	[super init];

	self->c = XCBConnect(display,screen);
	self->event_handler = NULL;

	if(!self->c)
		return NULL;
	

	return self;
}
/* FIXME error handling */
- init_auth:(const char *)display:(XCBAuthInfo *)auth:(int *)screen
{
	[super init];

	if(!auth)
		return NULL;

	self->c = XCBConnectToDisplayWithAuthInfo(display,auth,screen);

	if(!self->c)
		return NULL;
	

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

	if(!self->c)
		return NULL;
	
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

- (void)set_event_handler:(<ObjXCBEventHandler> *)handler
{
	
	if(self->event_handler)
		[self->event_handler free];

	self->event_handler = handler;
}

- (XCBGenericEvent *)poll_event
{
	XCBGenericEvent *ev;

	while((ev = XCBPollForEvent(self->c, 0))) {
     		switch(ev->response_type) {
			case XCBExpose:
				/* Check if the event_handler has a method for expose. */	
				break;
			default:
				break;
		}
    	}

	return NULL;
}

- free
{
	XCBDisconnect(self->c);

	[super free];
}

@end
