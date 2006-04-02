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

static int fd;

int open_ipc_fifo(char *path)
{	
	signal(SIGIO,ipc_handle);
	
	mknod(path,S_IFIFO | 0666, 0);

	fd = open(path,O_RDWR);
	
	fcntl(fd, F_SETOWN, getpid());
	
	fcntl(fd,F_SETFL,O_ASYNC | O_NONBLOCK);
	
	return fd;
}

void ipc_handle(int sig)
{
	char *buff = i_calloc(100,sizeof(char));
	char *tmp = NULL;
	char *tok = NULL;
	char *args[5] = {NULL};
	int i,j;
	
	read(fd,buff,100);

	tmp = buff;
	for(i=0;i<5;i++) {
		tok = strtok(tmp," ");

		if(!tok)
			break;
		
		args[i] = tok;

		tmp = NULL;
	}

	if(!args[0])
		return;
	
	j = i;
	
	for(i=0;i<j;i++) {
		if(!strncmp(args[0],"help",4)) {
			write(fd,help_message,strlen(help_message));	
		}
	}
	
	i_free(buff);
}

