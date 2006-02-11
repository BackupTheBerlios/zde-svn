#include "../src/zwl.h"

void on_show(IMPObject *widget, void *data);
void on_keypress(IMPObject *widget, void *data);

int main(void)
{
	ZWindow *win = NULL;
	
	zwl_init();

	win = [ZWindow alloc];
	[win init:NULL:100:100:100:100];

	[win set_name:"Test Window"];
	[win attatch_cb:SHOW:(ZCallback *)on_show];
	[win attatch_cb:KEY_PRESS:(ZCallback *)on_keypress];
	[win show];
	
	zwl_main_loop_start();
	
	return 0;
}

void on_show(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	
	printf("Window %s has been shown.\n",[w get_name]);
}

void on_keypress(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	XKeyEvent *ev = (XKeyEvent *)data;
	char *key = XKeysymToString(XKeycodeToKeysym(zdpy,ev->keycode,1));
	
	printf("Keycode %s has been pressed in window %s.\n",key,[w get_name]);

	if(!strncmp(key,"Q",3)) {
		printf("Quitting...\n");
		exit(0);
	}
}

