/*
   Copyright (c) 2005, 2006 Thomas Coppi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 */

#include "obj-xcb.h"

@implementation ObjXCBWindow : Object

- init:(ObjXCBConnection *)con
{
	return [self init:con:0:0:0:100:100:1];
}

- init:(ObjXCBConnection *)con:(int)depth:(int)x:(int)y:(int)width:(int)height:(int)border_width
{
	self->win_id = XCBWINDOWNew([con get_connection]);
	self->c = con;

	XCBCreateWindow(c,                        /* Connection          */
 		   depth,                        /* depth               */
		   self->win_id,               /* window Id           */
		   [con get_screen]->root,             /* parent window       */
		   x, y,                     /* x, y                */
		   width, height,                 /* width, height       */
		   border_width,                       /* border_width        */
		   InputOutput,              /* class               */
		   [con get_screen]->root_visual,      /* visual              */
		   0, NULL);                 /* masks, not used yet */

	return self;
}

- (void)map
{
	XCBMapWindow([self->c get_connection],self->win_id);
}

@end
