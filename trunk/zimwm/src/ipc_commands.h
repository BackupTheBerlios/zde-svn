#ifndef IPC_CMDS_H
#define IPC_CMDS_H

#define ZIM_IPC_NUM_CMDS 2

#define IPC_CMD_HELP 1
#define IPC_CMD_WINDOW_LIST 2 /**< Lists out all window titles and their numbers managed by zimwm, in reverse order from creation. */

char *ipc_cmds[ZIM_IPC_NUM_CMDS] = {"help","wlist"};

char *ipc_msgs[ZIM_IPC_NUM_CMDS] = {"zimwm IPC Subsystem Commands\n\nhelp\twlist",NULL};

#endif
