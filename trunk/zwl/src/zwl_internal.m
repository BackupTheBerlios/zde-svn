#include "zwl_internal.h"

XCBVISUALTYPE *_get_root_visual_type(XCBSCREEN *s)
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

@implementation ZWidget (_internal_)

- (void)set_backend:(unsigned int)back
{
	self->backend = back;
}

- (void)set_window_surf:(cairo_surface_t *)surf
{
	if(surf)
		self->win_surf = surf;
}

- (void)attatch_internal_cb:(int)signal:(ZCallback *)callback
{
	if(signal >= 0) {
		self->internal_callbacks[signal] = callback;
	}
}


@end

