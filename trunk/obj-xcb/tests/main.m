#include "../src/obj-xcb.h"

int main(void)
{
	ObjXCBConnection *c = [ObjXCBConnection alloc];
	ObjXCBWindow *w = [ObjXCBWindow alloc];
	ObjXCBWindow *root = [ObjXCBWindow alloc];
	ObjXCBGetGeometryReply *geomrep;
	ObjXCBGcontext *gc = [ObjXCBGcontext alloc];

	XCBGenericEvent *e;
	XCBSCREEN *s;
	XCBPOINT p[2];
	CARD32 value[1];
	CARD32 wvalue[2];

	/* Create a connection to the server. */
	[c init];
	
	/* Get the default screen and root window */
	s = [c get_screen];
	root = [c get_root_window];

	/* Initialize and create a window */
	[w init:c];
	wvalue[0] = [c get_black_pixel];
	wvalue[1] = XCBEventMaskExposure;
	[w CreateWindow:XCBCopyFromParent:root:0:0:100:200:1:XCBWindowClassInputOutput:s->root_visual:XCBCWEventMask | XCBGCForeground:wvalue];
	[w MapWindow];

	geomrep = [w GetGeometry];

	/* Create a graphics context for the window */
	[gc init:c];

	value[0] = [c get_white_pixel];
	[gc CreateGC:w:XCBGCForeground:value];

	/* Setup the points for a line */
	p[0].x = 10;
	p[0].y = 10;
	p[1].x = 80;
	p[1].y = 100;


	/* Flush all requests to the server */
	[c flush];

	printf("The window is positioned at x:%d:y:%d with width:%d and height:%d.\n",[geomrep get_x],[geomrep get_y],[geomrep get_width],[geomrep get_height]);

	while(e = [c next_event]) {
		switch(e->response_type) {
			case XCBExpose:
				[w PolyLine:XCBCoordModeOrigin:gc:2:p];
				[c flush];
				break;
			default:
				printf("he\n");
				break;
		}

		free(e);
	}

	[geomrep free];
	[c free];
	[root free];
	[w free];

	return 0;
}
