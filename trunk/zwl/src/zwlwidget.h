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

#define SHOW 0  /**< When widget is shown. */
#define BUTTON_DOWN 1
#define BUTTON_UP 2
#define DESTROY 3
#define KEY_PRESS 4
#define DEFAULT 5
#define ADDED 6

/** Callback prototype */
typedef void (ZCallback)(IMPObject *widget, void *data);

/** The basic widget of zwl.  Never instansiate this by itself, only its subclasses. */
@interface ZWidget : IMPObject
{
	@public
	Window *window;	 /**< The X11 window that represents this widget. */
	ZWidget *parent;  /**< The ZWidget that this widget is a child of, e.g. a menu item is part of a menu.  NULL if there is no parent. */
	int x; /**< 'x' coordinate.  Can have different meanings in different contexts, such as if this widget is a window or a button, etc. */
	int y; /**< 'y' coordinate.  Can have different meanings in different contexts, such as if this widget is a window or a button, etc. */
	int width;
	int height;
			
	@protected
	char *name;  /**< For internal identification use only.  Has nothing to do with WM_NAME or similiar. */
	ZCallback *internal_callbacks[100]; /**< For internal use only.  Called before the user callback is called. */
	ZCallback *callbacks[100]; /**< Stores an array of ZCallbacks for when we recieve a signal */
	ZWidget *children[100];
}

- init;
- free;

/** Show the widget. */
- (void)show;

/** Destroys the widget and decreases the reference count. */
- (void)destroy;

/** Set the name */
- set_name:(char *)name;

/** Get the name */
- get_name;

/** Set the parent widget */
- set_parent:(ZWidget *)parent;

/** Take a widget, add it to the children array, and emit the ADDED signal on the child. */
- add_child:(ZWidget *)child;

/** Send signal to this widget */
- (void)receive:(int)signal:(void *)data;

/** Attatch a callback to the widget. */
- (void)attatch_cb:(int)signal:(ZCallback *)callback;

/** Used to attatch internal callbacks. Should not be used by application programs unless you want trouble, or REALLY know what you are doing.
 Using this, it is possible to override how widgets react to basic XEvents, such as button presses and Exposes.  Unless you are writing a widget,
 this is dangerous.
 */
- (void)attatch_internal_cb:(int)signal:(ZCallback *)callback;

@end
