#include "../../zimwm.h"

#include "../zimwm_module.h"

ZWindow *win;

int zimwm_module_init(void)
{
	printf("systray module has been loaded.\n");
	
	win = zimwm_module_create_window();

	return 0;
}
