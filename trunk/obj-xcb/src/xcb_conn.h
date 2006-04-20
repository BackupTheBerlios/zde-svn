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

/**
  Closes connection to the X Server.
  */
- free;

@end

#endif

