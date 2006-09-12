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

#ifndef ZWLWIDGET_H
#define ZWLWIDGET_H

/* Widget event defines. XXX The descriptions all need to be updated to reflect XCB */
#define SHOW 0  /**< When widget is shown. Data is NULL */
#define BUTTON_DOWN 1 /**< When a mouse button is pressed on the widget. Data is an XButtonEvent structure. */
#define BUTTON_UP 2 /**< When a mouse button is released on the widget. Data is an XButtonEvent structure. */
#define DESTROY 3 /**< When the widget is destroyed. All widgets respond to this event internally by decreasing
		    their reference count by one, so you should grab your widgets if you want to do anything with
		    them in your destroy callback. Data is an XDestroyWindowEvent structure. */ 
#define KEY_PRESS 4 /**< When a key is pressed while the widget is focused. Data is an XKeyEvent structure. */ 
#define DEFAULT 5 /**< When the event is not recognized by the main loop.  This is useful if you want your widget to recognize an
		    X11 event that zwl does not yet natively respond to. Data is an XEvent structure. */
#define ADDED 6 /**< When the widget has been added as a child of another widget. If you are creating your own widget, this is
		  an event that you should be responding to. Data is the widget that you have been added to. */
#define EXPOSE 7 /**< When a portion of the widget has been exposed. Most Widgets will handle this for themselves with an internal 
		   callback, but there are cases where it can be useful to either override this callback or do something in addition
		   to the normal processing. If you are creating your own widget, this is one of the most basic events that you should
		   be responding to. Data is an XExposeEvent structure. */
#define CLOSE 8 /**< When the Window is being asked to close itself gracefully. Called by zwl when we receive a WM_DELETE_WINDOW
		  client message from the window manager.  If you are not implementing or using a widget which will be a toplevel window,
		  you should not concern yourself with this. Data is an XClientMessageEvent. */
#define CONFIGURE 9 /**< When the widget's window's properties are being changed.  All widgets respond internally by
		      updating the appropriate variables. Data is an XConfigureEvent. */
#define MAP_REQUEST 10 /**< When a window requests to be mapped. Data is a XMapRequestEvent. */
#define CLIENT_MESSAGE 11 /**< When a window receives a ClientMessage event that is not encapsulated by other zwl events, such
			    as EWMH events. Data is an XClientMessageEvent. */
#define UNMAP 12 /**< When a window requests to be unmapped. Data is an XUnmapEvent. */
#define CONFIGURE_REQUEST 13 /**< When a ConfigureRequest event is recieved by the window. Data is an XConfigureRequestEvent. */
#define POINTER_ENTER 14 /**< When the mouse pointer enters the window. Data is an XCrossingEvent. */
#define POINTER_LEAVE 15 /**< When the mouse pointer leaves the window. Data is an XCrossingEvent. */
#define PROPERTY 16 /**< When a property on the window has changed. Data is an XPropertyEvent. */

@class ZWidget;

/** Basic callback prototype. Used by most events generated by zwl, and all events generated by X11 forwarded to widgets. */
typedef void (ZCallback)(ZWidget *widget, void *data);

/** The basic widget of zwl.  Never instansiate this by itself, only its subclasses. You can also use this as a base class
 for creating new widgets.
 */
@interface ZWidget : IMPObject
{
	@public
	ObjXCBWindow *window;	 /**< The X11 window that represents this widget. */
	ZWidget *parent;  /**< The ZWidget that this widget is a child of, e.g. a menu item is part of a menu.  NULL if there is no parent. */
	int x; /**< 'x' coordinate.  Can have different meanings in different contexts, such as if this widget is a window or a button, etc. */
	int y; /**< 'y' coordinate.  Can have different meanings in different contexts, such as if this widget is a window or a button, etc. */
	int width;
	int height;		
	IMPList *children; /**< List of widgets that are children of this widget. */
	
	@protected
	char *name;  /**< For identification use only.  Has nothing to do with the WM_NAME atom or similiar. */
	ZCallback *internal_callbacks[100]; /**< For internal use only.  Called before the user callback is called. */
	ZCallback *callbacks[100]; /**< Stores an array of ZCallbacks for when we recieve a signal. */

	/** 
	 * The cairo surface that represents this widget. 
	 */
	cairo_surface_t *win_surf;
	unsigned int backend;
}

- (id)init;

- (void)free;

/** Show the widget. */
- (void)show;

/** Destroys the widget and decreases the reference count. */
- (void)destroy;

/** Set the name */
- (void)set_name:(char *)name;

/** Get the name */
- (char *)get_name;

/** Set the parent widget */
- (void)set_parent:(ZWidget *)parent;

/** Get the cairo surface for the widget. */
- (const cairo_surface_t *)get_surf;

/** Get the backend used by Cairo for the widget. */
- (unsigned int)get_backend;

/** Take a widget, add it to the children array, and emit the ADDED signal on the child. */
- (void)add_child:(ZWidget *)child;

/** Move the widget */
- (void)move:(int)x:(int)y;

/** Resize the widget */
- (void)resize:(int)width:(int)height;

/**
 * Clears the widget by drawing over it with the specified color and alpha value.
 * Color values must be between 0 and 1.
 */
- (void)clear:(double)r:(double)g:(double)b:(double)a;

/** Send signal to this widget */
- (void)receive:(int)signal:(void *)data;

/** Attatch a callback to the widget. Signal is a defined type in zwlwidget.h  Do not directly input a number here, as the numbers
 assigned to events are subject to change at any time.
 */
- (void)attatch_cb:(int)signal:(ZCallback *)callback;

@end

#endif
