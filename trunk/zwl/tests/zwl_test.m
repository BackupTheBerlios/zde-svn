#include "../src/zwl.h"
#include <sys/time.h>
#include <sys/shm.h>

static void on_keypress(IMPObject *widget, void *data);
static void on_buttondown(ZWidget *widget, void *data);
static void on_buttonup(IMPObject *widget, void *data);
static void on_destroy(IMPObject *widget, void *data);
static void on_close(IMPObject *widget, void *data);
static void on_expose(IMPObject *widget, void *data);
static void on_default(ZWidget *widget, void *data);

static void on_button_show(IMPObject *widget, void *data);
static void on_button_buttondown(IMPObject *widget, void *data);
	
static ZButton *button = NULL;
static ZButton *image = NULL;
static ZWindow *win = NULL;
static ZWindow *win2 = NULL;
static ZLabel *label = NULL;

#define BUTTON_WIDTH 50
#define BUTTON_HEIGHT 25

#define PI 3.1415926535

cairo_t *cr;

int main(int argc, char **argv)
{
	ZWindow *win = [ZWindow alloc];
	ZLabel *label = [ZLabel alloc];

	zwl_init();

	srand(time(NULL));
	srand48(time(NULL));	
	
	[win init:ZWL_BACKEND_XCB:640:480];
	[label init:"This is a fancy test label":10:10];

//	[win attatch_cb:KEY_PRESS:(ZCallback *)on_keypress];
	[win attatch_cb:BUTTON_DOWN:(ZCallback *)on_buttondown];
	[win attatch_cb:BUTTON_UP:(ZCallback *)on_buttonup];
	[win attatch_cb:DESTROY:(ZCallback *)on_destroy];
	[win attatch_cb:CLOSE:(ZCallback *)on_close];
	[win attatch_cb:EXPOSE:(ZCallback *)on_expose];
	[win attatch_cb:DEFAULT:(ZCallback *)on_default];

	[win add_child:(ZWidget *)label];
	
	if(argv[1]) {
		if(!fork()) {
			while(1) {
				cr = cairo_create([win get_surf]);
				cairo_set_source_rgba(cr,drand48(),drand48(), drand48(),.50);

				cairo_rectangle(cr,rand() % win->width,rand() % win->height,rand() % win->width,rand() % win->height);
				
				cairo_fill_preserve(cr);
				cairo_stroke(cr);
			}
		}
	}	

	[win show];

	[win clear:0:0:0:1];

	[label show];

	zwl_main_loop_start();

/*	
	win = [ZWindow alloc];
	[win init:NULL:0:0:150:100];
	
	[win set_name:"Test Window"];
	[win set_title:"Test Window":1];
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
	[button set_label:"A Button"];
	[button show];

	label = [ZLabel alloc];
	[label init:0:0];
	[win add_child:(ZWidget *)label];
	[label set_label:"This is a test program for zwl."];
	[label show];

	image = [ZButton alloc];
	[image init:"/home/thisnukes4u/zde/berlios/trunk/zwl/tests/test.png":win->width/2 - (BUTTON_WIDTH/2):win->height/2 + (BUTTON_HEIGHT/2) + 5:BUTTON_WIDTH:BUTTON_HEIGHT];
	[win add_child:(ZWidget *)image];
	[image show];
	
	[win show];
*/
	return 0;
}
/*
static void on_keypress(IMPObject *widget, void *data)
{
	ZWindow *w = (ZWindow *)widget;
	XKeyEvent *ev = (XKeyEvent *)data;
	char *key = XKeysymToString(XKeycodeToKeysym(zdpy,ev->keycode,1));
	
	//printf("Keycode %s has been pressed in window %s.\n",key,[w get_name]);

	if(!strncmp(key,"Q",3)) {
		[w destroy];
	}
	else if(!strncmp(key,"A",3)) {
		[label set_label:"Hey man! Stop it!!"];
	}
}
*/
static void on_default(ZWidget *widget, void *data)
{

}

static void on_buttondown(ZWidget *widget, void *data)
{
	XCBButtonPressEvent *ev = (XCBButtonPressEvent *)data;

	printf("Mouse button %d was pressed down at %d,%d.\n",ev->detail.id,ev->event_x,ev->event_y);
}

static void on_buttonup(IMPObject *widget, void *data)
{	
	XCBButtonPressEvent *ev = (XCBButtonPressEvent *)data;

	printf("Mouse button %d was released at %d,%d.\n",ev->detail.id,ev->event_x,ev->event_y);
}

static void on_destroy(IMPObject *widget, void *data)
{
	printf("Goodbye, cruel world...\n");
	zwl_main_loop_quit();
}

static void on_close(IMPObject *widget, void *data)
{
	printf("Window manager says we must go. Fine then.\n");
	[(ZWidget *)widget destroy];
}

static void on_expose(IMPObject *widget, void *data)
{
	ZWidget *w = (ZWidget *)widget;
	XCBExposeEvent *ev = (XCBExposeEvent *)data;

	[win clear:0:0:0:1];	
}
/*
static void on_button_show(IMPObject *widget, void *data)
{

}

static void on_button_buttondown(IMPObject *widget, void *data)
{
	printf("AH! You pressed me!\n");
}
*/

