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

/* Global vars */
cairo_surface_t *win_surf = NULL;
ZWindow *w;

int win_width = 500;
int win_height = 500;

int main(void)
{
	XCBSCREEN *screen;
 	pthread_t thr;
	XCBCompositeQueryVersionRep *rep;

	w = [ZWindow alloc];

	zwl_init();

	XCBRenderInit(c);
	XCBCompositeInit(c);

	rep = XCBCompositeQueryVersionReply(c,
			XCBCompositeQueryVersion(c,0,2),NULL);

	if(!(rep->major_version > 0 || rep->minor_version >= 2)) {
		fprintf(stderr,"Composite version not new enought.\n");
		return -1;
	}

	free(rep);

	[win init:win_width:win_height];

	pause();

	return 0;
}

