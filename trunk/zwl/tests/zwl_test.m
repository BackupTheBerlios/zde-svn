#include "../src/zwl.h"

void on_show(IMPObject *widget, void *data);

int main(void)
{
	ZWindow *win = NULL;
	
	zwl_init();

	win = [ZWindow alloc];
	[win init:NULL:100:100:100:100];

	[win attatch_cb:SHOW:(ZCallback *)on_show];
	[win show];
	
	zwl_main_loop_start();
	
	return 0;
}

void on_show(IMPObject *widget, void *data)
{
	printf("COOLNESS!\n");
}

