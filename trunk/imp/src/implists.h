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

/** A singly-linked list implementation, non-circular.
 */
@interface IMPList : IMPObject
{
	@public
	void *data;  /**< Pointer to data that you may want to associate with this node.  Make sure that you set type correctly. */
	IMPList *next;	/**< Pointer to next list node, NULL if this is the last node */
	int type;  /**< Can be set at any time.  0 for malloc data, 1 for IMPObjects */
}

/** Init the list. Set type to 0 if the data you will be storing will be allocated with a 
  C malloc/calloc/realloc function (i_alloc, i_calloc, and i_realloc count).
  Set type to 1 if the data you will be storing will be IMPObjects. 
 */
- init:(int)type;
- free;  /**< Freeing one frees all nodes after it.  This way, you can free a whole list by calling free on the head. */

/** Add a new node at the end of the list and point the new node's "data" field to the parameter supplied. 
  Returns the new end of the list. 
 */
- (IMPList *)append_data:(void *)user_data;  

/** Add a new node at the beginning of the list and point the new node's "data" field to the parameter 
  supplied.  Note that if there is another node before this one, its pointer will not be updated because we 
  have no knowledge of that.  If you do anyway, you will have a hole in the list, so make sure to only use this on the 
  head node of the list, or that you have some way up updating the pointer of the other node. Returns the new 
  beginning of the list 
 */
- (IMPList *)prepend_data:(void *)user_data;  

/** Add a new node at the positing that is "pos" nodes from this one.  If there are not enough nodes to traverse, it returns NULL.
  The nodes preceding and after are updated, as we know where they are when moving in order. 
 */ 
- (IMPList *)insert_data_nth:(int)pos:(void *)user_data;  

/** Deletes the next node in the list. Returns the new next node. */
- (IMPList *)delete_next_node;

/** Deletes the current node.  Make sure you only use this on the head node, or you will be making a hole in the list. 
  Returns the new head of the list. 
 */
- (IMPList *)delete_node;

/** Deletes the current node and all nodes after it. The list should not be accessed after this. */
- (void)delete_list;

/** Gets the current size of the list, i.e. how many nodes it contains. */
- (int)get_size;

@end

#endif
