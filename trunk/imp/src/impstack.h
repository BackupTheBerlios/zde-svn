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

/** 
  Protocol that defines a standard way of using IMPStack.	
 */
@protocol IStack

/** 
  Add a new node with user_data to the top of the stack. 
  Make sure you use this on the head, or what you want to be the new head.
  In this version, you must specify the type.
  Returns the new head, which should be casted to an IStack *, or NULL if it cannot be added. 
  This is an OPTIONAL method.  It must be implemented, but the type parameter may not be meaningful.
 */
- (Protocol *)push:(int)type:(void *)user_data;

/** 
  Add a new node with user_data to the top of the stack. 
  Make sure you use this on the head, or what you want to be the new head.
  In this version, the type is implied to be 1, or an Objective C Object.
  Returns the new head, which should be casted to an IStack *, or NULL if it cannot be added.
 */
- (Protocol *)push:(void *)user_data;

/** 
  Pop the node's data off the top of the stack. 
  Make sure you use this on the head. 
  The new head is head->next.
  Returns the data of the node being popped.
 */
- (void *)pop;

/**
  Returns the data on the top of the stack, i.e. what would be returned if the stack was popped.
  Does not remove the data from the stack.
  */
- (void *)peek;

/**
  Returns the size of the stack. 
 */
- (int)get_size;

/**
  Inverts the stack, i.e. if the stack was 1,2,3,4 it would become 4,3,2,1
  This is optional, if it returns anything other than 1, it should be assumed that the operation had
  no effect.
  */

- (int)invert;

@end

#if 0

/** 
  A stack implementation, built on top of an IMPList.
  This is basically a list with a stack-like interface built on top.
 */
@interface IMPStack : IMPList <IStack>
{
}

- init:(int)type;

@end

#endif

/**
  A simple stack implementation built ontop of an Array.
 */
@interface IMPStack : IMPObject <IStack>
{
	@protected
	Object **stack;
	int num; /**< Size of the array that has been allocated. */
	unsigned int head;
}

/**
  Initializes the stack. This stack works only on Objective C Objects.
  
  \param num The expected maximum size of the stack.
 */
- init:(int)num;

- free;

/**
  Returns a copy of the array used to store the stack.
  */
- (Object *)get_array;

@end
#endif
