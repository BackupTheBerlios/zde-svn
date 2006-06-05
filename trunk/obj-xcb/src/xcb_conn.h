/*
   Copyright (c) 2005, 2006 Thomas Coppi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 */

#ifndef OBJXCB_CONN_H
#define OBJXCB_CONN_H

@interface ObjXCBConnection : Object
{
	@protected
	XCBConnection *c;
	XCBSCREEN *s;
	Object *event_handler; /**< Object that we use to handle events. */
}

/** Starts a new connection to the X Server on the default display and screen. */
- init;

/**< Starts a new connection to the X Server on the specified display and screen. */
- init:(const char *)display:(int *)display; 

/** 
   Starts a new connection to the X Server on the specified display and screen with
   authentication info. 
*/
- init_auth:(const char *)display:(XCBAuthInfo *)auth:(int *)screen; 

/**
  Starts a new connection to the X Server on the specified file descriptor with
  authentication info.
  */
- init_auth:(int)fd:(XCBAuthInfo *)auth;

/**
  Returns the file descriptor associated with the running connection to the X Server.
  */
- (int)get_fd;

/** Get the XCBConnection used. */
- (XCBConnection *)get_connection;

/** Get the screen on the connection. */
- (XCBSCREEN *)get_screen;

#if 0
/**
  Set the event handler object for the connection.
  */
//- (void)set_event_handler:(Object *)handler;

/**
  Polls for the next X event on the connection, calls the appropriate event handler function,
  and returns NULL.  If there is no event handler available, it returns an XCBGenericEvent that
  can be handled or ignored.  If there is no event, it returns NULL immediatly (does not block).
  */
//- (XCBGenericEvent *)poll_event;
#endif
/**
  Closes connection to the X Server and frees associated memory.
  */
- free;

@end

#endif

