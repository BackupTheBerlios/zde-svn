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

int main(int argc, char **argv)
{
	IMPObject *obj;
	IMPList *list;
	IMPListIterator *iter;

	int i,j;

	srand(time(NULL));
	
	puts("Starting IMPObject tests...");

	puts("Creating and freeing 10000000 objects...");
	for(i=0;i<1000000;i++) {
		obj = [IMPObject alloc];
		[obj init];
		
		[obj release];

			if(i % 10000 == 0) {
			printf(".");
			fflush(stdout);
		}	
	}

	puts("");
	puts("IMPObject tests completed successfully.");

	puts("");
	puts("Starting IMPList tests...");

	puts("Creating a 100000 node list and freeing it 100 times.");
	for(j=0;j<100;j++) {
		list = [IMPList alloc];
		[list init];

		for(i=0;i<10000;i++) {
			obj = [IMPObject alloc];
			[obj init];

			[list append:obj];
			
			if(i % 1000 == 0) {
				printf(".");
				fflush(stdout);
			}	
		}

		iter = [list iterator];
	
		while([iter has_next]) {
			[iter next];
		}
			
		[list release];
		[iter release];
	
		if(j % 10 == 0) {
			printf(".");
			fflush(stdout);
		}	

	}
	puts("");
	puts("IMPList tests completed successfully.");

	return 0;
}

