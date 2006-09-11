#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/time.h>
#include <pthread.h>

#include <zwl.h>

#include <cairo.h>
#include <cairo-xcb.h>
#include <cairo-xcb-xrender.h>

#include <X11/XCB/xcb.h>
#include <X11/XCB/composite.h>
#include <X11/XCB/damage.h>
#include <X11/XCB/xcb_renderutil.h>

/* Function protos */
static void on_expose(ZWidget *widget, void *data);
XCBVISUALTYPE *get_root_visual_type(XCBSCREEN *s);

/* Global vars */
cairo_surface_t *win_surf = NULL;
ZWindow *w;

ObjXCBConnection *zc;
XCBConnection *c;

int win_width = 500;
int win_height = 500;

cairo_t *cr = NULL;
cairo_surface_t *rootwin_surf = NULL;

int main(void)
{
	XCBSCREEN *screen;
 	pthread_t thr;
	XCBCompositeQueryVersionRep *rep;
	ObjXCBInternAtomReply *atomrep;
	ObjXCBAtom *atom;
	ObjXCBGetSelectionOwnerReply *selectionrep;
	XCBWINDOW win;
	XCBDRAWABLE pix;

	w = [ZWindow alloc];

	zwl_init();

	zc = zwl_get_connection();
	c = [zc get_connection];

	XCBRenderInit(c);
	XCBCompositeInit(c);

	rep = XCBCompositeQueryVersionReply(c,
			XCBCompositeQueryVersion(c,0,2),NULL);

	if(!(rep->major_version > 0 || rep->minor_version >= 2)) {
		fprintf(stderr,"Composite version not new enought.\n");
		return -1;
	}

	free(rep);

	/* Check if there is a composite manager running. */
	atomrep = [zc InternAtom:0:12:"_NET_WM_CM_0"];
	atom = [atomrep get_atom];

	selectionrep = [atom GetSelectionOwner];
	
	win = [[selectionrep get_owner] get_xid];

	if(win.xid != 0) {
		printf("hey\n");
	}

	[w init:ZWL_BACKEND_XCB:win_width:win_height];

	[w show];

	/* Redirect all windows to offscreen storage.  This is only necessary
	 * if there is no composite manager running, */
//	XCBCompositeRedirectSubwindows(c,[zc get_root_window_raw],XCBCompositeRedirectAutomatic);

	/* Let's get a pixmap! */
	pix.window = [zc get_root_window_raw];
//	pix->window = [w->window get_xid];

	XCBCompositeNameWindowPixmap(c,pix.window,pix.pixmap);
//	XCBCompositeNameWindowPixmap(c,[w->window get_xid],pix->pixmap);

	[zc flush];

	printf("%d\n",pix.pixmap);

//	rootwin_surf = cairo_xcb_surface_create_for_bitmap(c,pix->pixmap,[zc get_screen],1280,1024);
//	rootwin_surf = cairo_xcb_surface_create(c,pix,get_root_visual_type([zc get_screen]),500,500);
	rootwin_surf = cairo_xcb_surface_create_with_xrender_format(c,pix,[zc get_screen],
			XCBRenderUtilFindStandardFormat(XCBRenderUtilQueryFormats(c),PictStandardRGB24),
			1024,768);

	cairo_surface_write_to_png(rootwin_surf,"test.png");

	printf("rootsurface:%s\n",cairo_status_to_string(cairo_surface_status(rootwin_surf)));
	printf("winsurface:%s\n",cairo_status_to_string(cairo_surface_status([w get_surf])));

	cr = cairo_create([w get_surf]);

//	cairo_set_source_rgba(cr,1,0,1,1);
	cairo_set_source_surface(cr,rootwin_surf,0,0);
//	cairo_rectangle(cr,0,0,500,500);

	cairo_paint(cr);

	printf("cairo:%s\n",cairo_status_to_string(cairo_status(cr)));

	[zc flush];

	zwl_main_loop_start();

	return 0;
}

static void on_expose(ZWidget *widget, void *data)
{
	XCBExposeEvent *ev = (XCBExposeEvent *)data;
//	cairo_set_source_surface(cr,rootwin_surf,100,100);
//	cairo_set_source_rgba(cr,1,0,1,1);
//	cairo_rectangle(cr,100,50,100,100);

//	cairo_fill_preserve(cr);
//	cairo_stroke(cr);
//	[zc flush];
}

XCBVISUALTYPE *get_root_visual_type(XCBSCREEN *s)
{
	XCBVISUALID root_visual;
	XCBVISUALTYPE  *visual_type = NULL; 
	XCBDEPTHIter depth_iter;

	depth_iter = XCBSCREENAllowedDepthsIter(s);

	for(;depth_iter.rem;XCBDEPTHNext(&depth_iter)) {
		XCBVISUALTYPEIter visual_iter;

		visual_iter = XCBDEPTHVisualsIter(depth_iter.data);
		for(;visual_iter.rem;XCBVISUALTYPENext(&visual_iter)) {
		    if(s->root_visual.id == visual_iter.data->visual_id.id) {
			visual_type = visual_iter.data;
			break;
		    }
		}
      	}

	return visual_type;
}


