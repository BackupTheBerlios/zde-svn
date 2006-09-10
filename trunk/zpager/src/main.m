#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/time.h>
#include <pthread.h>

#include <cairo.h>
#include <cairo-xcb.h>
#include <cairo-xcb-xrender.h>

#include <X11/XCB/xcb.h>
#include <X11/XCB/composite.h>
#include <X11/XCB/damage.h>
#include <X11/XCB/xcb_renderutil.h>

/* Function protos */
void *event_thread(void *p);

/* Global vars */
XCBConnection *c;
XCBDRAWABLE win;
cairo_surface_t *win_surf = NULL;

int win_width = 500;
int win_height = 500;

int main(void)
{
	XCBSCREEN *screen;
 	CARD32 mask = 0;
	CARD32 values[2];
	pthread_t thr;
	XCBCompositeQueryVersionRep *rep;

	c = XCBConnect(NULL,NULL);
	screen = XCBSetupRootsIter(XCBGetSetup(c)).data;

	XCBRenderInit(c);
	XCBCompositeInit(c);

	rep = XCBCompositeQueryVersionReply(c,
			XCBCompositeQueryVersion(c,0,2),NULL);

	if(!(rep->major_version > 0 || rep->minor_version >= 2)) {
		fprintf(stderr,"Composite version not new enought.\n");
		return -1;
	}

	win.window = XCBWINDOWNew(c);

	mask = XCBCWBackPixel | XCBCWEventMask;
	values[0] = screen->white_pixel;
	values[1] = XCBEventMaskExposure           | XCBEventMaskButtonPress
             	  | XCBEventMaskButtonRelease      | XCBEventMaskPointerMotion
                  | XCBEventMaskEnterWindow        | XCBEventMaskLeaveWindow
                  | XCBEventMaskKeyPress           | XCBEventMaskKeyRelease
	          | XCBEventMaskSubstructureNotify | XCBEventMaskSubstructureRedirect
	          | XCBEventMaskEnterWindow	   | XCBEventMaskLeaveWindow
	          | XCBEventMaskStructureNotify;

	XCBCreateWindow(c,XCBCopyFromParent,win.window,screen->root,0,0,win_width,win_height,0,XCBWindowClassInputOutput,screen->root_visual,mask,values);

	win_surf = cairo_xcb_surface_create_with_xrender_format(c,win,screen,
			XCBRenderUtilFindStandardFormat(XCBRenderUtilQueryFormats(c),PictStandardRGB24),
			win_width,win_height);

	XCBMapWindow(c,win.window);

	XCBFlush(c);

	pthread_create(&thr,0,event_thread,0);

	return 0;
}

void *event_thread(void *p)
{
	XCBGenericEvent *e;
	XCBButtonPressEvent *bpress;
	XCBMotionNotifyEvent *motion;
	XCBConfigureNotifyEvent *conf;
	cairo_t *cr;
	
	while((e = XCBWaitForEvent(c))) {
		if(e) {
			switch(e->response_type){
				case XCBButtonPress:
					break;
				case XCBMotionNotify:
					break;
				case XCBButtonRelease:
					break;
				case XCBExpose:
					break;
				case XCBConfigureNotify:
					conf = (XCBConfigureNotifyEvent *)e;
					
					win_width = conf->width;
					win_height = conf->height;
					
					cairo_xcb_surface_set_size(win_surf,win_height,win_width);

					break;
				default: 
					break;
			}      
		}

		free(e);
	}

}
