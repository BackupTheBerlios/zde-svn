#include "../zimwm.h"
#include "zimwm_module.h"

ZWindow *zimwm_module_create_window(int width, int height)
{
	ZWindow *w = [ZWindow alloc];
	XMapRequestEvent ev;
	XSizeHints shints;

	[w init:NULL:0:0:width:height];

	shints.min_width = 20;
	shints.min_height = 20;
	shints.width_inc = 3;
	shints.height_inc = 3;

	XSetWMNormalHints(zdpy,(Window)w->window,&shints);

	[w show];
	ev.window = w->window;
	on_map_request(NULL,&ev);
	
	return w;
}
