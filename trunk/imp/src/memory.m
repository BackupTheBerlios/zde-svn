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

#include "imp.h"

#include <string.h>

void *i_alloc(unsigned int number, unsigned int size)
{
	void *temp = NULL;
	
	if(size > 0 && number > 0) {
		temp = malloc(number * size);
		if(temp != NULL)
			return temp;
		else { /* FIXME Do something better than this. */
			fprintf(stderr, "Could not allocate memory, failing.\n");
			exit(-1);
		}
	}
	
	return NULL;	
}

void *i_calloc(unsigned int number, unsigned int size)
{
	void *temp = NULL;
	
	if(size > 0 && number > 0) {
		temp = calloc(number, size);
		if(temp != NULL)
			return temp;
		else { /* FIXME Do something better than this. */
			fprintf(stderr, "Could not allocate memory, failing.\n");
			exit(-1);
		}
	}
	
	return NULL;	
}

void *i_realloc(void *ptr, unsigned int number, unsigned int size)
{
	void *temp = NULL;

	if(size > 0 && number > 0) {
		temp = realloc(ptr, number * size);
		if(temp != NULL)
			return temp;
		else { /* FIXME Do something better than this. */
			fprintf(stderr, "Could not allocate memory, failing.\n");
			exit(-1);
		}
	}

	return NULL;
}

char *i_strdup(const char *str)
{
	if(str != NULL)
		return strdup(str);
}

void i_free(void *ptr)
{
	if(ptr != NULL)
		free(ptr);
}
