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

char *help_message = 
	"zimwm IPC sub-system\n \
	help\tversion\n";

static int fd;

/* Returns the string up to the first occurance of del. */
static char *z_strdel(char *string, char del);

int open_ipc(char *path)
{
	struct sockaddr_un addr;
	
	fd = socket(AF_UNIX,SOCK_STREAM,0);

	if(!fd)
		perror("socket");
	
	addr.sun_family = AF_UNIX;
	strncpy(addr.sun_path,path,sizeof(addr.sun_path) - 1);	
	unlink(addr.sun_path);
	
	if(bind(fd,(struct sockaddr *)&addr,strlen(addr.sun_path) + sizeof(addr.sun_family)) == -1)
		perror("bind");

	if(listen(fd,5) == -1)
		perror("listen");
	
	return fd;
}

void ipc_receive_from_fd(int f)
{
	int num;
	char *buff = i_calloc(256,1);
	char *cmd;

	recv(f,buff,1000000,0);
	printf("%s",buff);
	cmd = z_strdel(buff," ");
	//printf("%s-%s",buff,z_strdel(buff," "));

	if(cmd != NULL) {
		send(f,cmd,strlen(cmd),0);
		puts("SENT!!!");
	}
//	printf(" - %s",z_strdel(buff," "));

	close(f);
	i_free(buff);
}

static char *z_strdel(char *string, char del)
{
	int i;
	char *buff = i_calloc(strlen(string),1);

	for(i=0;i<strlen(string);i++) {
		if(string[i] == del) {
			buff[i] = '\0';
			return buff;
		}	
		else
			buff[i] = string[i];
	}

	return buff;
}

