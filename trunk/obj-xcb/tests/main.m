#include "../src/obj-xcb.h"

int main(void)
{
	ObjXCBConnection *c = [ObjXCBConnection alloc];
	ObjXCBWindow *w = [ObjXCBWindow alloc];
	ObjXCBWindow *root = [ObjXCBWindow alloc];
	XCBSCREEN *s;

	/* Create a connection to the server. */
	[c init];
	
	/* Get the default screen and root window */
	s = [c get_screen];
	[root init:c:s->root];

	/* Initialize and create a window */
	[w init:c];
	[w CreateWindow:XCBCopyFromParent:root:10:10:100:200:1:XCBWindowClassInputOutput:s->root_visual:0:NULL];
	[w MapWindow];
	
	/* Flush all requests to the server */
	[c flush];

	/* Wait so we can actually see the window */
	pause();

	[c free];
	[root free];
	[w free];

	return 0;
}
