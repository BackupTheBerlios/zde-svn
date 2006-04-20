/*
    zimwm
    Copyright (C) 2004,2005,2006 zimwm Developers

    zimwm is the legal property of its developers, whose names are
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

#include "zimwm.h"

IMPList *modules_list;

static Bool initialized = False;

int zimwm_init_module_subsystem(void)
{
	if(!initialized) {
		modules_list = [IMPList alloc];
		[modules_list init:0];
		
		initialized = True;
		return 0;
	}
	else
		return -1;
}

ZimModule *zimwm_open_module(char *path)
{
	ZimModule *modinfo = i_calloc(1,sizeof(ZimModule));
	char *path_buff = i_calloc(500,1);

	/* Function pointer for the module's zimwm_module_init() */
	int(*mod_init_handle)(void);

	if(!initialized)
		return NULL;

	/* FIXME Should be the REAL library path and such. */
	snprintf(path_buff,500,"/usr/local/lib/zimwm/modules/%s/module.so",path,path);
	
	modinfo->path = i_strdup(path);
	modinfo->handle = dlopen(path_buff,RTLD_LAZY);
	i_free(path_buff);
	
	if(!modinfo->handle) {
		fprintf(stderr,"Couldn't load module %s - %s.\n",path,dlerror());
		
		i_free(modinfo);
		return NULL;
	}
	else {
		/* Run the zimwm_module_init() for this module. */
		mod_init_handle = dlsym(modinfo->handle,"zimwm_module_init");
		
		if((mod_init_handle)() == 0) {
			if(!modules_list) {
				initialized = False;
				zimwm_init_module_subsystem();
			}
			
			//[modules_list append_data:modinfo];
			modules_list = [modules_list prepend_data:modinfo];
			return modinfo;
		}
	}
	
	return NULL;
}

int zimwm_close_module(char *path)
{
	IMPList *list = modules_list;
	ZimModule *modinfo = NULL;
	void(*mod_close_handle)(void);
	
	if(!path || !list)
		return;

	modinfo = (ZimModule *)list->data;
	if((!strncmp(modinfo->path,path,50)) && list) {
		mod_close_handle = dlsym(modinfo->handle,"zimwm_module_quit");
				
		mod_close_handle();
		dlclose(modinfo->handle);
	
		i_free(modinfo->path);
		list = [list delete_node];
		modules_list = list;
		
		return 0;
	}
	else {
		while(list && list->next) {
			modinfo = (ZimModule *)list->next->data;

			if(!modinfo) {
				list = list->next;
				continue;
			}
			
			if((!strncmp(modinfo->path,path,50)) && list->next) {
				mod_close_handle = dlsym(modinfo->handle,"zimwm_module_quit");
				
				mod_close_handle();
				dlclose(modinfo->handle);
				
				i_free(modinfo->path);
				list = [list delete_next_node];
				return 0;
			}

			list = list->next;
		}
	}

	return -1;
}
