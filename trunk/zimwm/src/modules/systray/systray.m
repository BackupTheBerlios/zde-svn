#include "../../zimwm.h"

#include "../zimwm_module.h"

#define MODULE_NAME "systray"

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

	zimwm_close_module(MODULE_NAME);
}

static void on_close(IMPObject *widget, void *data)
{
	zimwm_module_quit();
}
