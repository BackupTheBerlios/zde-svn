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

int main(void)
{
	XCBSCREEN *screen;
 	pthread_t thr;
	XCBCompositeQueryVersionRep *rep;
	ObjXCBInternAtomReply *atomrep;
	ObjXCBAtom *atom;
	ObjXCBGetSelectionOwnerReply *selectionrep;
	XCBDRAWABLE win;
	XCBDRAWABLE pix;
	XCBQueryTreeRep *qrep;
	XCBWINDOW *child;
	XCBWINDOWIter iter;

	int i;

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

	/* Check if there is a composite manager running. CURRENTLY BROKEN ON E16*/
	atomrep = [zc InternAtom:0:12:"_NET_WM_CM_S0"];
	//atomrep = [zc InternAtom:0:19:"_NET_SYSTEM_TRAY_S0"];
	atom = [atomrep get_atom];

	selectionrep = [atom GetSelectionOwner];

	printf("%d\n",win);

	win.window = [[selectionrep get_owner] get_xid];

	printf("%d\n",win.window);

	if(win.window.xid != 0) {
		printf("hey\n");
	}

	[w init:ZWL_BACKEND_XCB:win_width:win_height];
	[w attatch_cb:EXPOSE:(ZCallback *)on_expose];

	[w show];

	/* Redirect all windows to offscreen storage.  This is only necessary
	 * if there is no composite manager running, */
//	XCBCompositeRedirectSubwindows(c,[zc get_root_window_raw],XCBCompositeRedirectAutomatic);

	/* QueryTree */
	qrep = XCBQueryTreeReply(c,XCBQueryTree(c,[zc get_root_window_raw]),NULL);

	iter = XCBQueryTreeChildrenIter(qrep);

	char buf[100];
/*	for(;iter.rem;XCBWINDOWNext(&iter)) {
		child = iter.data;

		pix.window = *child;

		XCBCompositeNameWindowPixmap(c,pix.window,pix.pixmap);

		[zc flush];

	//	win_surf = cairo_xcb_surface_create(c,pix,get_root_visual_type([zc get_screen]),500,500);
		win_surf = cairo_xcb_surface_create_with_xrender_format(c,pix,[zc get_screen],
				XCBRenderUtilFindStandardFormat(XCBRenderUtilQueryFormats(c),PictStandardRGB24),
				1280,1024);

		snprintf(buf,100,"test/test%d.png",iter.rem);

		cairo_surface_write_to_png(win_surf,buf);
		printf("%d\n",iter.rem);
	}
*/
	/* Let's get a pixmap! */
//	pix.window = [w->window get_xid];

	pix.window = *child;

	printf("%d\n",pix.window);

	XCBCompositeNameWindowPixmap(c,pix.window,pix.pixmap);

	[zc flush];

//	win_surf = cairo_xcb_surface_create(c,pix,get_root_visual_type([zc get_screen]),500,500);
	win_surf = cairo_xcb_surface_create_with_xrender_format(c,pix,[zc get_screen],
			XCBRenderUtilFindStandardFormat(XCBRenderUtilQueryFormats(c),PictStandardRGB24),
			600,600);

	cairo_surface_write_to_png(win_surf,"test.png");


	cr = cairo_create([w get_surf]);

	cairo_set_source_surface(cr,win_surf,0,0);

	printf("rootsurface:%s\n",cairo_status_to_string(cairo_surface_status(win_surf)));
	printf("winsurface:%s\n",cairo_status_to_string(cairo_surface_status([w get_surf])));
	printf("cairo:%s\n",cairo_status_to_string(cairo_status(cr)));

	[zc flush];

	zwl_main_loop_start();

	return 0;
}

static void on_expose(ZWidget *widget, void *data)
{
	XCBExposeEvent *ev = (XCBExposeEvent *)data;
	
	cairo_paint_with_alpha(cr,.5);
	[zc flush];
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


