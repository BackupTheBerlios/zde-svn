#include "../../zimwm.h"

#include "../zimwm_module.h"

#define MOD_NAME "systray"
#define MOD_VERSION_STRING "systray 0.0.1"

ZWindow *win;

static void on_close(IMPObject *widget, void *data);

int zimwm_module_init(void)
{
	printf("systray module has been loaded.\n");
	
	win = zimwm_module_create_window();
	
	[win attatch_cb:CLOSE:on_close];

	return 0;
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

static void on_close(IMPObject *widget, void *data)
{
	zimwm_module_quit();
	zimwm_close_module(MOD_NAME);
}
