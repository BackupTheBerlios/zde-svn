#include "../src/zwl.h"

static void on_show(IMPObject *widget, void *data);
static void on_keypress(IMPObject *widget, void *data);
static void on_buttondown(IMPObject *widget, void *data);
static void on_buttonup(IMPObject *widget, void *data);
static void on_destroy(IMPObject *widget, void *data);

static void on_button_show(IMPObject *widget, void *data);
static void on_button_buttondown(IMPObject *widget, void *data);

int main(void)
{
	ZWindow *win = NULL;
	int i;
	ZWindow *win2 = NULL;
	ZButton *button = NULL;
	
	zwl_init();
	
	win = [ZWindow alloc];
	[win init:NULL:100:100:100:100];

	[win set_name:"Test Window"];
	[win set_title:"Test Window"];
	[win attatch_cb:SHOW:(ZCallback *)on_show];
	[win attatch_cb:KEY_PRESS:(ZCallback *)on_keypress];
	[win attatch_cb:BUTTON_DOWN:(ZCallback *)on_buttondown];
	[win attatch_cb:BUTTON_UP:(ZCallback *)on_buttonup];
	[win attatch_cb:DESTROY:(ZCallback *)on_destroy];
	
	button = [ZButton alloc];
	[button init:0:0:50:20];
	[win add_child:(ZWidget *)button];
	[button attatch_cb:SHOW:(ZCallback *)on_button_show];
	[button attatch_cb:BUTTON_DOWN:(ZCallback *)on_button_buttondown];
	[button show];
	[win show];
	[button set_label:"Button"];
/*	
	for(i=0;i<1000;i++) {
		win2 = [ZWindow alloc];
		[win2 init:NULL:100:100:100:100];
		[win2 set_name:"Test Window 2"];
		[win2 set_title:"Test Window 2"];
		[win2 attatch_cb:SHOW:(ZCallback *)on_show];
		[win2 attatch_cb:KEY_PRESS:(ZCallback *)on_keypress];
		[win2 show];
		
		[win2 destroy];
	}
*/		
	zwl_main_loop_start();
	
	return 0;
}

static void on_show(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;	
}

static void on_keypress(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	XKeyEvent *ev = (XKeyEvent *)data;
	char *key = XKeysymToString(XKeycodeToKeysym(zdpy,ev->keycode,1));
	
	//printf("Keycode %s has been pressed in window %s.\n",key,[w get_name]);

	if(!strncmp(key,"Q",3)) {
		[widget destroy];
	}
}

static void on_buttondown(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	XButtonEvent *ev = (XButtonEvent *)data;

	printf("Mouse button %d was pressed down at %d,%d.\n",ev->button,ev->x,ev->y);
}

static void on_buttonup(IMPObject *widget, void *data)
{	
	ZWindow *w = (ZWindow *)widget;
	XButtonEvent *ev = (XButtonEvent *)data;

	printf("Mouse button %d was released at %d,%d.\n",ev->button,ev->x,ev->y);
}

static void on_destroy(IMPObject *widget, void *data)
{
	printf("Goodbye, cruel world...\n");
	zwl_main_loop_quit();
}

static void on_button_show(IMPObject *widget, void *data)
{

}

static void on_button_buttondown(IMPObject *widget, void *data)
{
	printf("AH! You pressed me!\n");
}

