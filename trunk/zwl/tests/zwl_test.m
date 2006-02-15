#include "../src/zwl.h"

static void on_show(IMPObject *widget, void *data);
static void on_keypress(IMPObject *widget, void *data);
static void on_buttondown(IMPObject *widget, void *data);
static void on_buttonup(IMPObject *widget, void *data);
static void on_destroy(IMPObject *widget, void *data);
static void on_default(IMPObject *widget, void *data);
static void on_close(IMPObject *widget, void *data);
static void on_expose(IMPObject *widget, void *data);

static void on_button_show(IMPObject *widget, void *data);
static void on_button_buttondown(IMPObject *widget, void *data);
	
static ZButton *button = NULL;
static ZWindow *win = NULL;
static ZWindow *win2 = NULL;

#define BUTTON_WIDTH 50
#define BUTTON_HEIGHT 20

int main(void)
{
	int i;
	
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
	[win attatch_cb:DEFAULT:(ZCallback *)on_default];
	[win attatch_cb:CLOSE:(ZCallback *)on_close];
	[win attatch_cb:EXPOSE:(ZCallback *)on_expose];
	
	button = [ZButton alloc];
	[button init:win->width/2 - (BUTTON_WIDTH/2):win->height/2 - (BUTTON_HEIGHT/2):BUTTON_WIDTH:BUTTON_HEIGHT];
	[win add_child:(ZWidget *)button];
	[button attatch_cb:SHOW:(ZCallback *)on_button_show];
	[button attatch_cb:BUTTON_DOWN:(ZCallback *)on_button_buttondown];
	[button set_label:"Button"];
	[button show];
	[win show];

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
		[w destroy];
	}
}

static void on_buttondown(IMPObject *widget, void *data)
{
	XButtonEvent *ev = (XButtonEvent *)data;

	printf("Mouse button %d was pressed down at %d,%d.\n",ev->button,ev->x,ev->y);
}

static void on_buttonup(IMPObject *widget, void *data)
{	
	XButtonEvent *ev = (XButtonEvent *)data;

	printf("Mouse button %d was released at %d,%d.\n",ev->button,ev->x,ev->y);
}

static void on_destroy(IMPObject *widget, void *data)
{
	printf("Goodbye, cruel world...\n");
	zwl_main_loop_quit();
}

static void on_default(IMPObject *widget, void *data)
{
//	printf("hmm...\n");
}

static void on_close(IMPObject *widget, void *data)
{
	printf("Window manager says we must go. Fine then.\n");
	[(ZWidget *)widget destroy];
}

static void on_expose(IMPObject *widget, void *data)
{
	/* keep the button centered in the window */
	[button move:win->width/2 - (BUTTON_WIDTH/2):win->height/2 - (BUTTON_HEIGHT/2)];
}

static void on_button_show(IMPObject *widget, void *data)
{

}

static void on_button_buttondown(IMPObject *widget, void *data)
{
	printf("AH! You pressed me!\n");
}

