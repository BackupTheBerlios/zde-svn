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

ZimModule *zimwm_open_module(char *path)
{
	ZimModule *modinfo = i_calloc(1,sizeof(ZimModule));
	char *path_buff = i_calloc(500,1);

	/* Function pointer for the module's zimwm_module_init() */
	int(*mod_init_handle)(void);

	/* FIXME Should be the REAL library path and such. */
	snprintf(path_buff,500,"/usr/local/lib/zimwm/modules/%s/module.so",path,path);
	modinfo->path = path_buff;
	modinfo->handle = dlopen(modinfo->path,RTLD_LAZY);

	if(!modinfo->handle) {
		fprintf(stderr,"Cannot find module %s - %s.\n",path,dlerror());
		
		i_free(modinfo);
		return NULL;
	}
	else {
		/* Run the zimwm_module_init() for this module. */
		mod_init_handle = dlsym(modinfo->handle,"zimwm_module_init");
		(mod_init_handle)();

		return modinfo;
	}
	
	return NULL;
}
