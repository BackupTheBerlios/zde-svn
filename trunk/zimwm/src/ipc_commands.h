#ifndef IPC_CMDS_H
#define IPC_CMDS_H

#define ZIM_IPC_NUM_CMDS 2

#define IPC_CMD_HELP 0
#define IPC_CMD_WINDOW_LIST 1 /**< Lists out all window titles and their numbers managed by zimwm on the current workspace, 
				in reverse order from creation. */

char *ipc_cmds[ZIM_IPC_NUM_CMDS] = {"help","wlist"};

char *ipc_msgs[ZIM_IPC_NUM_CMDS] = {"zimwm IPC Subsystem Commands List\n\nhelp\twlist\twlist_stack",NULL};

#endif
