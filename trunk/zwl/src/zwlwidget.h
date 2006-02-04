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
#define KEY_DOWN 4
#define KEY_UP 5

/** Callback prototype */
typedef void (ZCallback)(IMPObject *widget, void *data);

/** The basic widget of zwl.  Never instansiate this by itself, only its subclasses. */
@interface ZWidget : IMPObject
{
	@protected
	char *name;

	@public
	Window *window;	 /**< The X11 window that represents this widget. */
	ZWidget *parent;  /**< The ZWidget that this widget is a child of, e.g. a menu item is part of a menu.  NULL if there is no parent. */
		
	@private
	ZCallback *callbacks[100];
	int x;
	int y;
	int width;
	int height;
	
}

- init;

/** Show the widget */
- show;

/** Set the name */
- set_name:(char *)name;

/** Set the parent widget */
- set_parent:(ZWidget *)parent;

/** Send signal to this widget */
- (void)recieve:(int)signal;

/** Attatch a callback to the widget */
- (void)attatch_cb:(int)signal:(ZCallback *)callback;

@end
