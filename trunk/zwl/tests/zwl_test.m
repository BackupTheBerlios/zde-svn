#include "../src/zwl.h"

void on_show(IMPObject *widget, void *data);
void on_keypress(IMPObject *widget, void *data);

int main(void)
{
	ZWindow *win = NULL;
	int i;
	ZWindow *wins[1000];
	
	zwl_init();

	
	win = [ZWindow alloc];
	[win init:NULL:100:100:100:100];

	[win set_name:"Test Window"];
	[win attatch_cb:SHOW:(ZCallback *)on_show];
	[win attatch_cb:KEY_PRESS:(ZCallback *)on_keypress];
	[win show];	
	
	for(i=0;i<1000;i++) {
		wins[i] = [ZWindow alloc];
		[wins[i] init:NULL:100:100:100:100];
		[wins[i] set_name:"Test Windows"];
		[wins[i] attatch_cb:SHOW:(ZCallback *)on_show];
		[wins[i] attatch_cb:KEY_PRESS:(ZCallback *)on_keypress];
		[wins[i] show];
		
		[wins[i] destroy];
	}
		
	zwl_main_loop_start();
	
	return 0;
}

void on_show(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;	
}

void on_keypress(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	XKeyEvent *ev = (XKeyEvent *)data;
	char *key = XKeysymToString(XKeycodeToKeysym(zdpy,ev->keycode,1));
	
	//printf("Keycode %s has been pressed in window %s.\n",key,[w get_name]);

	if(!strncmp(key,"Q",3)) {
		printf("Quitting...\n");
		zwl_main_loop_quit();
	}
}

