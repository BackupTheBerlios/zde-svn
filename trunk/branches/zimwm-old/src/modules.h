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

#ifndef Z_MODULES_H
#define Z_MODULES_H

/** \addtogroup Modules
   *  @{
   */

/** Structure containing things zimwm needs to know about modules. */
typedef struct
{
	char *path; /**< Name of the module, i.e. what was passed as the first
		      argument to dlopen() */
	void *handle; /**< Handle returned by dlopen() */
} ZimModule;

/** 
  Initializes the modules subsytem.  This MUST be called before loading any modules. 
  Returns 0 on success.
 */
int zimwm_init_module_subsystem(void);

/** 
  Loads a module for use by zimwm.
  Path should be the name of the module.
  Returns NULL if the module couldn't be opened.
  */
ZimModule *zimwm_open_module(char *path);

/**
  Unloads a module that has already been loaded by zimwm.
  Path should be the same path passed to zimwm_open_module().
  Returns 0 on success.
  */
int zimwm_close_module(char *path);

/** @} */

#endif
