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

#include "../src/imp.h"

int main(void)
{
	IMPObject *obj;
	IMPList *temp = NULL;
	IMPList *cur = NULL;
	IMPStack *tmp = NULL;
	IMPStack *curr = NULL;
	IMPStack *t = NULL;
	
	char *buff = NULL;
	int i,j;

	puts("Starting IMPObject tests...");

	puts("Creating and freeing 10000000 objects...");
	for(i=0;i<10000000;i++) {
		obj = [IMPObject alloc];
		[obj init];
		
		[obj release];

		if(i % 100000 == 0) {
			printf(".");
			fflush(stdout);
		}	
	}

	puts("");	
	puts("Starting IMPList tests...");	

	puts("Creating, populating, and freeing a 100000 node list 100 times...");	
	for(j=0;j<100;j++) {
		temp = [IMPList alloc];
		[temp init:0];

		temp->data = strdup("First node");

		cur = temp;
		for(i=0;i<100000;i++) {	
			buff = i_calloc(1,20);
			snprintf(buff,20,"Node #%d\n",i);
			
			/* keep track of the tail so we don't have to traverse the list every insert(takes a log of CPU time) */	
			cur = [cur append_data:buff];
		}	

//		[temp release];
		[temp delete_list];
		
		printf(".");
		fflush(stdout);
	}
	
	puts("");

	puts("Starting IMPStack tests...");

	puts("Creating, pushing, popping, and freeing a 100000 node stack 100 times...");

	for(j=0;j<100;j++) {
		tmp = [IMPStack alloc];
		[tmp init:0];
		
		tmp->data = strdup("First node");

		curr = tmp;
		for(i=0;i<100000;i++) {
			buff = i_calloc(1,20);
			snprintf(buff,20,"Node #%d\n",i);

			/* keep track of the head */
			curr = [curr push:0:buff];
		}
	
		/* Pop and release all elements */	
		for(i=0;i<100000;i++) {
			t = curr->next;

			[[curr pop] release];
			
			curr = t;
		}	

		[tmp release];

		printf(".");
		fflush(stdout);
	}

	puts("");

	return 0;
}

