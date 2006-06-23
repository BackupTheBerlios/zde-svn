#include "../src/obj-xcb.h"

int main(void)
{
	ObjXCBConnection *c = [ObjXCBConnection alloc];
	ObjXCBWindow *w = [ObjXCBWindow alloc];
	ObjXCBWindow *root = [ObjXCBWindow alloc];
	ObjXCBGetGeometryReply *geomrep;
	ObjXCBGcontext *gc;
	ObjXCBGcontext *bgc = [ObjXCBGcontext alloc];
	ObjXCBGcontext *wgc = [ObjXCBGcontext alloc];
	ObjXCBGcontext *rgc = [ObjXCBGcontext alloc];
	ObjXCBGcontext *ggc = [ObjXCBGcontext alloc];
	ObjXCBGcontext *blugc = [ObjXCBGcontext alloc];
	ObjXCBColormap *cmap;
	ObjXCBAllocColorReply *acolorrep;
	int random;

	XCBGenericEvent *e;
	XCBSCREEN *s;
	XCBRECTANGLE rect[1];
	CARD32 value[1];
	CARD32 wvalue[2];

	/* Create a connection to the server. */
	[c init];
	
	srand(time(NULL));

	/* Get the default screen and root window */
	s = [c get_screen];
	root = [c get_root_window];

	/* Initialize and create a window */
	[w init:c];
	wvalue[0] = [c get_black_pixel];
	wvalue[1] = XCBEventMaskExposure;
	[w CreateWindow:XCBCopyFromParent:root:0:0:300:400:1:XCBWindowClassInputOutput:s->root_visual:XCBCWEventMask | XCBGCForeground:wvalue];
	[w MapWindow];

	geomrep = [w GetGeometry];

	/* Setup the default colormap */
	cmap = [c get_default_colormap];

	/* Create graphics contexts, with b,w,r,g,blu for the window */
	[wgc init:c];
	[bgc init:c];
	[rgc init:c];
	[ggc init:c];
	[blugc init:c];

	value[0] = [c get_white_pixel];
	[wgc CreateGC:w:XCBGCForeground:value];
	value[0] = [c get_black_pixel];
	[bgc CreateGC:w:XCBGCForeground:value];
	
	acolorrep = [cmap AllocColor:65535:0:0];
	value[0] = [acolorrep get_pixel];
	[rgc CreateGC:w:XCBGCForeground:value];

	acolorrep = [cmap AllocColor:0:65535:0];
	value[0] = [acolorrep get_pixel];
	[ggc CreateGC:w:XCBGCForeground:value];

	acolorrep = [cmap AllocColor:0:0:65535];
	value[0] = [acolorrep get_pixel];
	[blugc CreateGC:w:XCBGCForeground:value];
	
	rect[0].x = 0;
	rect[0].y = 0;
	rect[0].width = [geomrep get_width];
	rect[0].height = [geomrep get_height];
	[w PolyFillRectangle:bgc:1:rect];


	/* Flush all requests to the server */
	[c flush];

	printf("The window is positioned at x:%d:y:%d with width:%d and height:%d.\n",[geomrep get_x],[geomrep get_y],[geomrep get_width],[geomrep get_height]);

	while(1) {
		e = [c poll_next_event:NULL];
		if(e) {
			switch(e->response_type) {
				case XCBExpose:
					geomrep = [w GetGeometry];
				//	[w PolyFillRectangle:gc:1:rect];
					break;
				default:
					break;
			}

			free(e);
			e = NULL;
		}

		random = rand();
		
		if(random % 5 == 4) {
			gc = bgc;
		}
		else if(random % 5 == 3) {
			gc = wgc;
		}
		else if(random % 5 == 2) {
			gc = rgc;
		}
		else if(random % 5 == 1) {
			gc = ggc;
		}
		else {
			gc = blugc;
		}

		rect[0].x = rand() % [geomrep get_width];
		rect[0].y = rand() % [geomrep get_height];
		rect[0].width = rand() % [geomrep get_width];
		rect[0].height = rand() % [geomrep get_height];	

		[w PolyFillRectangle:gc:1:rect];
		[c flush];
	}

	[geomrep free];
	[c free];
	[root free];
	[w free];
	[bgc free];
	[wgc free];
	[rgc free];
	[ggc free];
	[blugc free];
	[cmap free];

	return 0;
}
