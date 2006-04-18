#include "../../zimwm.h"

#include "../zimwm_module.h"

#define MOD_NAME "systray"
#define MOD_VERSION_STRING "systray 0.0.1"

#define SYSTEM_TRAY_REQUEST_DOCK    0
#define SYSTEM_TRAY_BEGIN_MESSAGE   1
#define SYSTEM_TRAY_CANCEL_MESSAGE  2
#define _NET_SYSTEM_TRAY_ORIENTATION_HORZ 0
#define _NET_SYSTEM_TRAY_ORIENTATION_VERT 1

/* Variables */
ZWindow *win;
Atom systray_opcode;
Atom xembed_info;

/* FIXME This is suboptimal. */
Atom net_sys_tray_for_screen[3];

/* Event handlers */
static void on_systray_close(IMPObject *widget, void *data);
static void on_systray_client_message(IMPObject *widget, void *data);

int zimwm_module_init(void)
{
	printf("systray module is loading.\n");

	systray_opcode = XInternAtom(zdpy,"_NET_SYSTEM_TRAY_OPCODE",False);
	xembed_info = XInternAtom(zdpy,"_XEMBED_INFO",False);

	win = zimwm_module_create_window();
	
	[win attatch_cb:CLOSE:on_systray_close];
	[win attatch_cb:CLIENT_MESSAGE:on_systray_client_message];

	net_sys_tray_for_screen[0] = XInternAtom(zdpy,"_NET_SYSTEM_TRAY_S0",False);
	net_sys_tray_for_screen[1] = XInternAtom(zdpy,"_NET_SYSTEM_TRAY_S1",False);
	net_sys_tray_for_screen[2] = XInternAtom(zdpy,"_NET_SYSTEM_TRAY_S2",False);

	/* FIXME Not sure if the window is correct. */
	XSetSelectionOwner(zdpy,net_sys_tray_for_screen[zscreen],(Window)win->window,CurrentTime);

	return 0;
}

void on_client_message(IMPObject *widget, void *data)
{

}

void zimwm_module_quit()
{
	printf("systray module is unloading.\n");
	[win destroy];
}

char *zimwm_module_version()
{
	return MOD_VERSION_STRING;
}

char *zimwm_module_about()
{
	return "Module that acts as a systray per the System Tray Protocol Specification located at http://standards.freedesktop.org/systemtray-spec/systemtray-spec-0.2.html";
}

static void on_systray_close(IMPObject *widget, void *data)
{
	zimwm_module_quit();
	zimwm_close_module(MOD_NAME);
}

static void on_systray_client_message(IMPObject *widget, void *data)
{

}
