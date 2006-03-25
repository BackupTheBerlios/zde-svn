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

#ifndef IMPMEMORY_H
#define IMPMEMORY_H

/** \addtogroup Memory Memory Management
   *  @{
   */

/** Wrapper around the C Standard Library's malloc */
void *i_alloc(unsigned int number, unsigned int size);

/** Wrapper around the C Standard Library's calloc */
void *i_calloc(unsigned int number, unsigned int size);

/** Wrapper around the C Standard Library's realloc */
void *i_realloc(void *ptr, unsigned int number, unsigned int size);

/** Wrapper around the C Standard Library's strdup */
char *i_strdup(const char *str);

/** Wrapper around the C Standard Library's free */
void i_free(void *ptr);

/** @} */

#endif
