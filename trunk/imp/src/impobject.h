/*
    imp
    Copyright (C) 2004,2005,2006 imp Developers

    imp is the legal property of its developers, whose names are
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

/**

The class from which all other objects in imp are derived from. 

IMPObject implements reference counting for objects.  It is recommended that only these methods be used for
memory management on IMPObject classes and its derivatives.

All IMPObject classes and its derivatives manage their own memory. For example, if you pass it
a character pointer, you can free it independent of the class as it makes its own copy and frees it as it needs to, except in the case of Obj-C objects.  Then we just "grab" it.
Note that in get methods the pointer returned is NOT A COPY, SO YOU MAY NOT FREE IT!
*/

@interface IMPObject : Object
{
	@protected
	unsigned long int ID; /**< Unique ID assigned at creation. */
	int refcount; /**< The current reference count of the object. */
}

- init;  /**< Sets refcount to one */
- free;

- (int)grab; /**< Increases the reference count of the object by one. Returns the new count.*/
- (int)release; /**< Decreases the reference count of the object by one. Returns the new count.*/
- (int)get_refcount; /**< Returns the current reference count of this object. */
- (int)get_id; /**< Returns the unique ID of this Object */

@end
