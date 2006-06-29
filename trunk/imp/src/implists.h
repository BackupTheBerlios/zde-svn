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

#ifndef IMPLIST_H
#define IMPLIST_H

/**
 * Holds a piece of data, and another node that it is connected to.
 */
@interface IMPListNode : IMPObject
{
	@protected
	IMPObject *data;
	IMPListNode *next;
}

- (id)init;

- (void)free;

/**
 * Initialize the node with data.
 */
- (id)init:(IMPObject *)data;

/**
 * Set the node's data.
 */
- (void)set_data:(IMPObject *)data;

/**
 * Get the data stored in the node, non-destructive.
 */
- (IMPObject *)get_data;

/** 
 * Set the next node.
 */
- (void)set_next:(IMPListNode *)next;

/**
 * Get the next node.
 */
- (IMPListNode *)get_next;

@end

/**
 * An Iterator for an IMPList.
 */
@interface IMPListIterator : IMPObject <IMPIterator>
{
	IMPListNode *curr;
	IMPListNode *prev;
	int valid; /**< If set to 1, iterator is valid.  Otherwise it is invalid. */
}

- (id)init:(IMPListNode *)head;

- (void)free;

/**
 * Returns the data at the current position.
 */
- (IMPObject *)get_data;

@end

/** A singly-linked list implementation, non-circular.
 */
@interface IMPList : IMPObject
{
	@protected
	IMPListNode *head;
	IMPListNode *tail;
	IMPListIterator *curriter;
}

- (id)init;

- (void)free;

/**
 * Appends data to the end of the list.
 */
- (void)append:(IMPObject *)data;

/**
 * Creates an Iterator for the list.
 * Note that there can only be one active iterator at a time (at least until I need to and then make a set so it can be done elegantly).
 */
- (IMPListIterator *)iterator;

@end

#endif
