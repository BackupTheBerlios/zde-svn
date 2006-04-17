#include "../zimwm.h"
#include "zimwm_module.h"

ZWindow *zimwm_module_create_window(void)
{
	ZWindow *w = [ZWindow alloc];
	XMapRequestEvent ev;

	[w init:NULL:0:0:100:50];
	[w show];
	ev.window = w->window;

	on_map_request(NULL,&ev);
	
	return w;
}
