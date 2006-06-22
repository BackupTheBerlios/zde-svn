#include "../src/obj-xcb.h"

int main(void)
{
	ObjXCBConnection *c = [ObjXCBConnection alloc];
	ObjXCBWindow *w = [ObjXCBWindow alloc];
	ObjXCBWindow *root = [ObjXCBWindow alloc];
	ObjXCBGetGeometryReply *geomrep;
	XCBSCREEN *s;

	/* Create a connection to the server. */
	[c init];
	
	/* Get the default screen and root window */
	s = [c get_screen];
	root = [c get_root_window];

	/* Initialize and create a window */
	[w init:c];
	[w CreateWindow:XCBCopyFromParent:root:0:0:100:200:1:XCBWindowClassInputOutput:s->root_visual:0:NULL];
	[w MapWindow];

	geomrep = [w GetGeometry];

	/* Flush all requests to the server */
	[c flush];

	printf("The window is positioned at x:%d:y:%d with width:%d and height:%d.\n",[geomrep get_x],[geomrep get_y],[geomrep get_width],[geomrep get_height]);

	/* Wait for a second so we can actually see the window */
	sleep(1);

	[geomrep free];
	[c free];
	[root free];
	[w free];

	return 0;
}
