#ifndef IPC_CMDS_H
#define IPC_CMDS_H

/** \addtogroup IPC
   *  @{
   */

#define ZIM_IPC_NUM_CMDS 5

#define IPC_CMD_HELP 0
#define IPC_CMD_WORKSPACE_LIST 1 /**< Lists out all window titles and their numbers managed by zimwm on the current workspace, 
				in reverse order from creation. */
#define IPC_CMD_WORKSPACE_LIST_SIZE 2 /**< Returns the number of clients managed on the current workspace. */
#define IPC_CMD_CLIENT_LIST 3 /**< Lists all of the clients managed by zimwm. */
#define IPC_CMD_CLIENT_LIST_SIZE 4 /**< Returns the number of clients managed by zimwm. */

char *ipc_cmds[ZIM_IPC_NUM_CMDS] = {"help","wlist","wlist_size","clist","clist_size"};

char *ipc_msgs[ZIM_IPC_NUM_CMDS] = {"zimwm IPC Subsystem Commands List\n\nhelp\twlist\twlist_size\tclist\nclist_size",NULL,NULL,NULL,NULL};

/** @} */

#endif
