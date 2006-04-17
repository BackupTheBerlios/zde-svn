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

#include "ipc_commands.h"

static int fd;

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
	int i;
	Bool sent = False;
	char *buff = i_calloc(256,1);
	char *cmd;

	recv(f,buff,256,0);
		
	cmd = strtok(buff," ");
	
	for(i=0;i<ZIM_IPC_NUM_CMDS;i++) {
		if(!strncmp(cmd,ipc_cmds[i],strlen(ipc_cmds[i]))) {
			ipc_execute_command(i,cmd);
			send(f,ipc_msgs[i],strlen(ipc_msgs[i]),0);
			sent = True;
		}
	}
	
	if(!sent)
		send(f,"Command not recognized",22,0);
	
	i_free(buff);
	close(f);
}

void ipc_execute_command(int cmd_num,char *cmd)
{
	IMPList *list;
	ZimClient *c;
	char *tmp, *tmp2;
	ZimModule *modinfo;
	char *(*mod_version_handle)(void);
	char *(*mod_about_handle)(void);
	
	switch(cmd_num) {
		case IPC_CMD_WORKSPACE_LIST:
			list = [[zones[curr_zone] get_current_workspace] get_clients];
			
			tmp = i_calloc(3000,1);
			
			while(list) {
					c = (ZimClient *)list->data;

				if(!c) {
					list = list->next;
					continue;
				}
			
				tmp2 = i_calloc(500,1);
				
				snprintf(tmp2,500,"%s - %d\n",[c->window get_title],(int)c->window->window);
				
				strncat(tmp,tmp2,500);
				
				i_free(tmp2);
				
				list = list->next;
			}
			
			if(ipc_msgs[IPC_CMD_WORKSPACE_LIST])
				i_free(ipc_msgs[IPC_CMD_WORKSPACE_LIST]);
			
			ipc_msgs[IPC_CMD_WORKSPACE_LIST] = tmp;
			
			break;
		case IPC_CMD_WORKSPACE_LIST_SIZE:
			tmp = i_calloc(500,1);
			
			snprintf(tmp,500,"%d",[[[zones[curr_zone] get_current_workspace] get_clients] get_size] - 1);
			
			if(ipc_msgs[IPC_CMD_WORKSPACE_LIST_SIZE])
				i_free(ipc_msgs[IPC_CMD_WORKSPACE_LIST_SIZE]);
			
			ipc_msgs[IPC_CMD_WORKSPACE_LIST_SIZE] = tmp;
			
			break;
		case IPC_CMD_CLIENT_LIST:
			list = client_list;
			
			tmp = i_calloc(3000,1);
			
			while(list) {
				c = (ZimClient *)list->data;

				if(!c) {
					list = list->next;
					continue;
				}
			
				tmp2 = i_calloc(500,1);
				
				snprintf(tmp2,500,"%s - %d\n",[c->window get_title],(int)c->window->window);
				
				strncat(tmp,tmp2,500);
				
				i_free(tmp2);
				
				list = list->next;
			}
			
			if(ipc_msgs[IPC_CMD_CLIENT_LIST])
				i_free(ipc_msgs[IPC_CMD_CLIENT_LIST]);
			
			ipc_msgs[IPC_CMD_CLIENT_LIST] = tmp;

			break;
		case IPC_CMD_CLIENT_LIST_SIZE:
			tmp = i_calloc(500,1);
			
			snprintf(tmp,500,"%d",[client_list get_size]);
			
			if(ipc_msgs[IPC_CMD_CLIENT_LIST_SIZE])
				i_free(ipc_msgs[IPC_CMD_CLIENT_LIST_SIZE]);
			
			ipc_msgs[IPC_CMD_CLIENT_LIST_SIZE] = tmp;
			
			break;
		case IPC_CMD_LOAD_MODULE:
			modinfo = zimwm_open_module(strtok(NULL," ")); /* FIXME XXX BAD NO STRTOK FOR YOU XXX FIXME */

			if(modinfo)
				ipc_msgs[IPC_CMD_LOAD_MODULE] = "Module successfully loaded.";
			else
				ipc_msgs[IPC_CMD_LOAD_MODULE] = "Module could not be loaded.";

			break;
		case IPC_CMD_UNLOAD_MODULE:
			if(!zimwm_close_module(strtok(NULL, " "))) /* FIXME XXX BAD NO STRTOK FOR YOU XXX FIXME */
				ipc_msgs[IPC_CMD_UNLOAD_MODULE] = "Module successfully unloaded.";
			else
				ipc_msgs[IPC_CMD_UNLOAD_MODULE] = "Module could not be unloaded.";

			break;
		case IPC_CMD_MOD_INFO:
			list = modules_list;
			
			while(list) {
				modinfo = list->data;
				list = list->next;

				if(!strncmp(modinfo->path,strtok(NULL," "),50)) { /* FIXME XXX BAD NO STRTOK FOR YOU XXX FIXME */
					mod_version_handle = dlsym(modinfo->handle,"zimwm_module_version");
					mod_about_handle = dlsym(modinfo->handle,"zimwm_module_about");

					if(ipc_msgs[IPC_CMD_MOD_INFO]) 
						i_free(ipc_msgs[IPC_CMD_MOD_INFO]);

					tmp = i_calloc(strlen((mod_version_handle)()) + strlen((mod_about_handle())) + 50,1);

					sprintf(tmp,"Module Version:%s\n\nAbout this module:%s",(mod_version_handle)(),(mod_about_handle)());

					ipc_msgs[IPC_CMD_MOD_INFO] = tmp;
					
					return;
				}
			}
			ipc_msgs[IPC_CMD_MOD_INFO] = "Module was not found.";
			break;
		default:
			break;
	}
}

