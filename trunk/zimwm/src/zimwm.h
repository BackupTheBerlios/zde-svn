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

#ifndef ZIMWM_H
#define ZIMWM_H

#include <zwl.h>

#include <signal.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/stat.h>
#include <arpa/inet.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

#include "../zimwm-config.h"
#include "ewmh.h"
#include "client-events.h"
#include "client.h"
#include "events.h"
#include "focus.h"
#include "vdesk.h"
#include "zone.h"
#include "ipc.h"

/* FIXME Should be from config file. */
extern int snap_px;

/* Index into the array of zones for the one currently used. */
extern int curr_zone;

extern ZWidget *root_window;
extern IMPList *client_list; /**< List of ALL clients managed by zimwm, regardless of what workspace or desktop they belong to. */
extern Zone **zones; /**< Array of all zones used by zimwm. */

/** Main loop that goes through xevents and checks for IPC messages. */
void zimwm_main_loop_start();
void zimwm_main_loop_quit();

void zimwm_add_client(ZimClient *client);
ZimClient *zimwm_find_client_by_zwindow(ZWindow *w);
ZimClient *zimwm_find_client_by_window(Window *w);
ZimClient *zimwm_find_client_by_window_frame(Window *w);
void zimwm_remove_client(ZimClient *c);
void zimwm_find_and_remove_client(ZWindow *w);

#endif
