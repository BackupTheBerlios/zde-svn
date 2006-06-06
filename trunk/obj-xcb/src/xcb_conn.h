/*
   Copyright (c) 2005, 2006 Thomas Coppi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 */

#ifndef OBJXCB_CONN_H
#define OBJXCB_CONN_H

/**
 *  Abstracts an XCBConnection and associated functions, as well as
 *  miscellaneous helper functions from the XCB tutorial and elsewhere that are useful.
 *  FIXME Need to figure out if the event functions presented are optimal/acceptable. 
 * */
@interface ObjXCBConnection : Object
{
	@protected
	XCBConnection *c;
	XCBSCREEN *s;
	int defscreen;
}

/** 
 * Starts a new connection to the X Server on the default display and screen. 
 */
- init;

/**
 * Starts a new connection to the X Server on the specified display and screen. 
 */
- init:(const char *)display:(int *)display; 

/** 
 * Starts a new connection to the X Server on the specified display and screen with
 * authentication info. 
 */
- init_auth:(const char *)display:(XCBAuthInfo *)auth:(int *)screen; 

/**
 * Starts a new connection to the X Server on the specified file descriptor with
 * authentication info.
 */
- init_auth:(int)fd:(XCBAuthInfo *)auth;

/**
 * Returns the file descriptor associated with the running connection to the X Server.
 */
- (int)get_fd;

/** 
 * Get the XCBConnection used. 
 */
- (XCBConnection *)get_connection;

/** 
 * Get the screen on the connection. 
 */
- (XCBSCREEN *)get_screen;

/**
 * Returns some misc. xserver data.
 */
- (const XCBSetup *)get_setup_data;

/**
 * Returns the default screen number of the connected display.
 */
- (int)get_default_screen;

/**
 * Returns the number of screens on the connected display.
 */
- (int)get_screen_count;

/**
 * Returns the name of the server vendor.
 */
- (char *)get_vendor;

/**
 * Returns the major version of the X11 protocol used.
 */
- (int)get_major_protover;

/**
 * Returns the minor version of the X11 protocol used.
 */
- (int)get_minor_protoversion;

/**
 * Returns the vendor release number.
 */
- (int)get_vendor_version;

/**
 * Returns the root window of the default screen.
 * Returns a raw XCB window, not an obj-xcb window!
 */
- (XCBWINDOW)get_root_window_raw;

/**
 * Returns the root window of the default screen.
 * Returns an obj-xcb window, not a raw XCB window!
 * FIXME Need to do autogeneration first.
 */
//- (ObjXCBWindow)get_root_window;

/**
 * Returns the default black pixel value.
 */
- (int)get_black_pixel;

/**
 * Returns the default white pixel value.
 */
- (int)get_white_pixel;

/**
 * Returns the screen width in pixels.
 */
- (int)get_width;

/**
 * Returns the screen height in pixels.
 */
- (int)get_height;

/**
 * Returns the display bit depth.
 */
- (int)get_depth;

/**
 * Returns true if screen supports save unders, false otherwise.
 */
- (BOOL)has_saveunders;

/**
 * Returns the value of the screen's backing store.
 */
- (int)get_backing_store;

/**
 * Returns the current input masks value.
 */
- (int)get_input_masks;

/**
 * Flushes pending requests to the server.
 */
- (int)flush;

- (const XCBQueryExtensionRep *)get_extension_data:(XCBExtension *)ext;

/**
 * Blocks while waiting for the next event.
 * Returns NULL on error.
 */
- (XCBGenericEvent *)next_event;

/**
 * Non-blocking version of next_event.
 * Returns NULL and the error code on error.
 */
- (XCBGenericEvent *)poll_next_event:(int *)error;

/**
  Closes connection to the X Server and frees associated memory.
  */
- free;

@end

#endif

