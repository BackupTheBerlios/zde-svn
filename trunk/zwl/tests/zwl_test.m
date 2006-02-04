#include "../src/zwl.h"

int main(void)
{
	ZWindow *win = NULL;
	
	zwl_init();

	win = [ZWindow alloc];
	[win init:NULL:100:100:100:100];

	[win show];
	
	zwl_main_loop_start();
	
	return 0;
}
