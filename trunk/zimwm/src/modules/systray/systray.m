#include "../../zimwm.h"

#include "../zimwm_module.h"

int zimwm_module_init(void)
{
	ZWindow *win = [ZWindow alloc];

	printf("systray module has been loaded.\n");

	[win init:NULL:10:10:100:100];
	[win show];
	
	return 0;
}
