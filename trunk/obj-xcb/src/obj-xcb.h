/*
   Copyright (c) 2005, 2006 Thomas Coppi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 */

/* Objc includes */
#include <objc/Object.h>

/* XCB includes */
#include <X11/XCB/xcb.h>
#include <X11/XCB/bigreq.h>
#include <X11/XCB/composite.h>
#include <X11/XCB/damage.h>
#include <X11/XCB/dpms.h>
#include <X11/XCB/glx.h>
#include <X11/XCB/randr.h>
#include <X11/XCB/record.h>
#include <X11/XCB/render.h>
#include <X11/XCB/res.h>
#include <X11/XCB/screensaver.h>
#include <X11/XCB/shape.h>
#include <X11/XCB/shm.h>
#include <X11/XCB/sync.h>
#include <X11/XCB/xc_misc.h>
#include <X11/XCB/xevie.h>
#include <X11/XCB/xf86dri.h>
#include <X11/XCB/xfixes.h>
#include <X11/XCB/xprint.h>
#include <X11/XCB/xtest.h>
#include <X11/XCB/xvmc.h>
#include <X11/XCB/xv.h>

/* C Standard library includes */
#include <stdio.h>
#include <stdlib.h>

@class ObjXCBConnection;
@class ObjXCBPixmap;
@class ObjXCBGcontext;
@class ObjXCBFont;
@class ObjXCBCursor;
@class ObjXCBColormap;
@class ObjXCBAtom;
@class ObjXCBWindow;
@class ObjXCBKeycode;
@class ObjXCBDrawable;
@class ObjXCBQueryColorsReply;
@class ObjXCBGetAtomNameReply;

/* This should all be handled in the codegeneration script, but for now it'll do... */
#define VISUALID XCBVISUALID
#define RGB XCBRGB
#define CHARINFO XCBCHARINFO
#define FONTPROP XCBFONTPROP
#define COLORITEM XCBCOLORITEM
#define SEGMENT XCBSEGMENT
#define RECTANGLE XCBRECTANGLE
#define ARC XCBARC
#define CHAR2B XCBCHAR2B
#define POINT XCBPOINT
#define TIMESTAMP XCBTIMESTAMP
#define TIMECOORD XCBTIMECOORD
#define KEYCODE XCBKEYCODE
#define KEYSYM XCBKEYSYM
#define HOST XCBHOST
#define REGION ObjXCBXfixesRegion

/* obj-xcb includes */
#import "objxproto.h"

#import "xcb_conn.h"
#import "xcb_conn_orphan.h"
#import "xcb_drawable.h"
#import "xcb_pixmap.h"
#import "xcb_gcontext.h"
#import "xcb_font.h"
#import "xcb_cursor.h"
#import "xcb_colormap.h"
#import "xcb_atom.h"
#import "xcb_window.h"

#ifdef EXT
#import "extensions/xcb_xfixesregion.h"
#endif

#if 0
#import "extensions/xcb_damagedamage.h"
#import "extensions/xcb_shmseg.h"
#import "extensions/xcb_glxcontext.h"
#import "extensions/xcb_syncalarm.h"
#import "extensions/xcb_glxfbconfig.h"
#import "extensions/xcb_synccounter.h"
#import "extensions/xcb_glxpbuffer.h"
#import "extensions/xcb_xfixesregion.h"
#import "extensions/xcb_glxpixmap.h"
#import "extensions/xcb_xprintpcontext.h"
#import "extensions/xcb_glxwindow.h"
#import "extensions/xcb_xvencoding.h"
#import "extensions/xcb_recordcontext.h"
#import "extensions/xcb_xvmccontext.h"
#import "extensions/xcb_renderglyphset.h"
#import "extensions/xcb_xvmcsubpicture.h"
#import "extensions/xcb_renderpictformat.h"
#import "extensions/xcb_xvmcsurface.h"
#import "extensions/xcb_renderpicture.h"
#import "extensions/xcb_xvport.h"
#endif
