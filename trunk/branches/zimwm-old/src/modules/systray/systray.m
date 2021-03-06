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

#include "../../zimwm.h"

#include "../zimwm_module.h"

#define MOD_NAME "systray"
#define MOD_VERSION_STRING "systray 0.0.1"

#define SYSTEM_TRAY_REQUEST_DOCK    0
#define SYSTEM_TRAY_BEGIN_MESSAGE   1
#define SYSTEM_TRAY_CANCEL_MESSAGE  2
#define _NET_SYSTEM_TRAY_ORIENTATION_HORZ 0
#define _NET_SYSTEM_TRAY_ORIENTATION_VERT 1

/* FIXME Need way of finding out when icons are unmapped so the num variable can keep track. */

/* Variables */
Window winlist[20]; /* Array holding icons in the window. */
ZWindow *win = NULL; /* The window holding the icons. */
Atom systray_opcode;
Atom xembed_info;

/* FIXME This is suboptimal. */
Atom net_sys_tray_for_screen[3];

int next_x = 0;
int num = 0;

/* Event handlers */
static void on_systray_close(IMPObject *widget, void *data);
static void on_systray_client_message(IMPObject *widget, void *data);

int zimwm_module_init(void)
{
	printf("systray module is loading.\n");

	systray_opcode = XInternAtom(zdpy,"_NET_SYSTEM_TRAY_OPCODE",False);
	xembed_info = XInternAtom(zdpy,"_XEMBED_INFO",False);

	win = zimwm_module_create_window(100,50);

	//[win attatch_cb:CLOSE:on_systray_close];
	[win attatch_cb:CLIENT_MESSAGE:on_systray_client_message];

	net_sys_tray_for_screen[0] = XInternAtom(zdpy,"_NET_SYSTEM_TRAY_S0",False);
	net_sys_tray_for_screen[1] = XInternAtom(zdpy,"_NET_SYSTEM_TRAY_S1",False);
	net_sys_tray_for_screen[2] = XInternAtom(zdpy,"_NET_SYSTEM_TRAY_S2",False);

	/* FIXME Not sure if the window is correct. */
	XSetSelectionOwner(zdpy,net_sys_tray_for_screen[zscreen],(Window)win->window,CurrentTime);

	return 0;
}

void on_systray_client_message(IMPObject *widget, void *data)
{
	XClientMessageEvent *ev = (XClientMessageEvent *)data;
	Window w;

	if(ev->message_type == systray_opcode) {
		if(ev->data.l[1] == SYSTEM_TRAY_REQUEST_DOCK) {
			w = (Window)ev->data.l[2];
			printf("systray received request by %d\n",w);

			if(num < 19)
				winlist[num++] = w;
			else 
				return;
			
			XReparentWindow(zdpy,w,(Window)win->window,next_x += 12,0);
			XMapWindow(zdpy,w);	
		}
	}
	
}

void zimwm_module_quit()
{
	IMPList *tmp = NULL;
	Window *w = NULL;
	int i;

	printf("systray module is unloading.\n");
	
	for(i=0;i<num;i++) {
		XUnmapWindow(zdpy,winlist[i]);
		XReparentWindow(zdpy,winlist[i],[zones[curr_zone] get_root]->window,0,0);
	}

	[win destroy];
	win = NULL;

}

char *zimwm_module_version()
{
	return MOD_VERSION_STRING;
}

char *zimwm_module_about()
{
	return "\nModule that acts as a systray per the System Tray Protocol Specification located at http://standards.freedesktop.org/systemtray-spec/systemtray-spec-0.2.html\nThis module is very buggy, as many applications do not follow the spec well or completely ignore some areas, so use this at your own risk.";
}

static void on_systray_close(IMPObject *widget, void *data)
{
	zimwm_close_module(MOD_NAME);
	//zimwm_module_quit();
}

