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

#ifndef IMPSTACK_H
#define IMPSTACK_H


/** A simple stack implementation. */
@interface IMPStack : IMPList
{
}

/** Add a new node with user_data to the top of the stack. Make sure you use this on the head, or what you want to be the new head. Returns the new head. */
- (IMPStack *)push:(int)type:(void *)user_data;

/** Pop the node off the top of the stack. Make sure you use this on the head. The new head is head->next. */
- (IMPStack *)pop;

@end

#endif
