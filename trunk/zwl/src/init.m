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

#include "zwl.h"

Display *zdpy = NULL;
IMPList *window_list = NULL;

void zwl_init(void)
{
	zdpy = XOpenDisplay(NULL);
}

Display *zwl_get_display(void)
{
	return zdpy;
}

void zwl_main_loop_add_widget(ZWidget *w)
{
	if(window_list) {
		if(w) {
			[window_list append_data:w];
		}
	}
	else {
		window_list = [IMPList alloc];
		[window_list init:1];
		window_list->data = w;
	}
}

void zwl_main_loop_start(void)
{
	XEvent ev;

	for(;;) {
		XNextEvent(zdpy,&ev);
		
		switch(ev.type) {
				printf("HUZZA!!!\n");
		}
	}
}

