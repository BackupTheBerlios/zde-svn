/*
    zimwm
    Copyright (C) 2004,2005,2006 zimwm Developers

    zimwm is the legal property of its developers, whose names are
    too numerous to list here.  Please refer to the COPYING file
    for the full text of this license and to the AUTHORS file for
    the complete list of developers.

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation, version 2.1.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

#include "zimwm.h"

void on_win_configure(IMPObject *widget, void *data);

/* Helper functions */
static ZWindow *create_frame_for_client(ZimClient *c);
static inline int absmin(int a, int b);

@implementation ZimClient : IMPObject

- init:(Window *)window
{
	ZWindow *w = [ZWindow alloc];
	ZWindow *frame = NULL;
	char *name = NULL;
	Window w1,w2;
	XSetWindowAttributes sattr;
	int x,x1;
	int y,y1;
	unsigned int mask;
	
	sattr.event_mask = PropertyChangeMask;
	
	XGrabServer(zdpy);
	
	self->atoms = NULL;
	self->strut_extents = NULL;
	self->no_use_area = False;
	self->maximised = False;

	w->window = window;
	
	self->window = w;
	
	[self get_properties];
	
	XQueryPointer(zdpy,(Window)root_window->window,&w1,&w2,&x,&y,&x1,&y1,&mask);
	self->window->x = x - self->window->width / 2;
	self->window->y = y - self->window->height / 2;
	
	XChangeWindowAttributes(zdpy,(Window)self->window->window,CWEventMask,&sattr);
	XFetchName(zdpy,(Window)w->window,&name);
	
	if(name) {
		[w set_title:name];
		XFree(name);
	}
	else {
		[w set_title:strdup("(null)")];
	}
	
	[self->window set_name:"XWINDOW"];
	[self->window grab];
	
	self->border = 3;
	self->title_height = 15;

	frame = create_frame_for_client(self);

	XReparentWindow(zdpy,(Window)self->window->window,(Window)frame->window,self->border,self->title_height);
	
	[frame add_child:self->window]; 
		
	[self->window attatch_cb:UNMAP:(ZCallback *)on_win_unmap];
	[self->window attatch_cb:CONFIGURE:(ZCallback *)on_win_configure];
	[self->window attatch_cb:PROPERTY:(ZCallback *)on_win_property_notify];
	[self->window attatch_cb:BUTTON_DOWN:(ZCallback *)on_win_button_down];
	
	zwl_main_loop_add_widget(self->window);
	
	[frame show];
	[self->window show];

	/* Grab mouse buttons so we can intercept things like alt-click for moving, etc. */
	XGrabButton(zdpy,AnyButton,Mod1Mask,(Window)self->window->window,True,ButtonPressMask,GrabModeAsync,GrabModeAsync,None,None);

	[self get_properties];
	[self resize:self->window->width:self->window->height];
	
	XSync(zdpy,False);
	XUngrabServer(zdpy);
}

- free
{
	[self->window release];

	if(self->atoms)
		i_free(self->atoms);
	if(self->size_hints)
		i_free(self->size_hints);
	
	[super free];
}

- (void)get_properties
{
	int i,len,format;
	int *data;
	Atom *atom = NULL;
	long sreturn;
	XWindowAttributes attr;

	XGetWindowAttributes(zdpy,(Window)self->window->window,&attr);
	
	self->window->width = attr.width;
	self->window->height = attr.height;
	self->win_border = attr.border_width;
	
	if(!self->atoms) {
		self->atoms = i_calloc(30,sizeof(Atom));
	}

	if(!self->size_hints) {
		self->size_hints = i_calloc(1,sizeof(XSizeHints));
	}
	else {
		i_free(self->size_hints);
		self->size_hints = i_calloc(1,sizeof(XSizeHints));
	}
	
	/* WM_PROTOCOLS */
	XGetWMProtocols(zdpy,(Window)self->window->window,&atom,&len);
	
	if(atom) {
		self->atoms[WM_PROTOCOLS] = (Atom)atom;
		
		for(i=0;i<len;i++) {
			if(atom[i] == z_atom[WM_DELETE_WINDOW]) {
				self->atoms[WM_DELETE_WINDOW] = atom[i];
			}
			else if(atom[i] == z_atom[WM_TAKE_FOCUS]) {
				self->atoms[WM_TAKE_FOCUS] = atom[i];
			}
		}
	}

	/* WM_HINTS */
	self->wm_hints = XGetWMHints(zdpy,(Window)self->window->window);
		
	/* WM_NORMAL_HINTS */
	XGetWMNormalHints(zdpy,(Window)self->window->window,self->size_hints,&sreturn);
	
	if(self->size_hints->flags & PMinSize) {
		if(self->window->width < self->size_hints->min_width)
			self->window->width = self->size_hints->min_width;
		if(self->window->height < self->size_hints->min_height)
			self->window->height = self->size_hints->min_height;
	}

	if(!(self->size_hints->flags & PMinSize)) {
		self->size_hints->min_width = 5;
		self->size_hints->min_height = 5;
	}
	
	if(!(self->size_hints->flags & PMaxSize)) {
		self->size_hints->max_width = 5000;
		self->size_hints->max_height = 5000;
	}
	
	/* _NET_WM_STRUT */
/*	XGetWindowProperty(zdpy,(Window)self->window->window,z_atom[_NET_WM_STRUT],0,4,False,XA_CARDINAL,atom,
			(int *)&format,(unsigned long *)&len,(unsigned long *)&i,(unsigned char **)&data);
	
	if(!self->strut_extents && len == 4) {
		self->strut_extents = i_calloc(i,sizeof(ZStrutExtents));
		
		self->strut_extents->left = data[0];
		self->strut_extents->right = data[1];
		self->strut_extents->top = data[2];
		self->strut_extents->bottom = data[3];
	}
	else if(len == 4) {
		self->strut_extents->left = data[0];
		self->strut_extents->right = data[1];
		self->strut_extents->top = data[2];
		self->strut_extents->bottom = data[3];
	}

*/	/* _NET_WM_STRUT_PARTIAL */
/*	XGetWindowProperty(zdpy,(Window)self->window->window,z_atom[_NET_WM_STRUT_PARTIAL],0,12,False,XA_CARDINAL,atom,
			(int *)&format,(unsigned long *)&len,(unsigned long *)&i,(unsigned char **)&data);
	
	if(!self->strut_extents && len == 12) {
		self->strut_extents = i_calloc(i,sizeof(ZStrutExtents));
		
		self->strut_extents->left = data[0];
		self->strut_extents->right = data[1];
		self->strut_extents->top = data[2];
		self->strut_extents->bottom = data[3];
		self->strut_extents->left_start_y = data[4];
		self->strut_extents->left_end_y = data[5];
		self->strut_extents->right_start_y = data[6];
		self->strut_extents->right_end_y = data[7];
		self->strut_extents->top_start_x = data[8];
		self->strut_extents->top_end_x = data[9];
		self->strut_extents->bottom_start_x = data[10];
		self->strut_extents->bottom_end_x = data[11];

		self->no_use_area = True;
	}
	else if(len == 12) {
		self->strut_extents->left = data[0];
		self->strut_extents->right = data[1];
		self->strut_extents->top = data[2];
		self->strut_extents->bottom = data[3];
		self->strut_extents->left_start_y = data[4];
		self->strut_extents->left_end_y = data[5];
		self->strut_extents->right_start_y = data[6];
		self->strut_extents->right_end_y = data[7];
		self->strut_extents->top_start_x = data[8];
		self->strut_extents->top_end_x = data[9];
		self->strut_extents->bottom_start_x = data[10];
		self->strut_extents->bottom_end_x = data[11];

		self->no_use_area = True;
	}
*/}

- (void)send_client_message:(int)format:(Atom)type:(Atom)data
{
	XClientMessageEvent cv;
	
	cv.type = ClientMessage;
	cv.message_type = type;
	cv.window = (Window)self->window->window;
	cv.format = 32;
	cv.data.l[0] = data;
	cv.data.l[1] = CurrentTime;
	
	XSendEvent(zdpy,(Window)self->window->window,False,NoEventMask,(XEvent *)&cv);
}

- (void)send_configure_message:(int)x:(int)y:(int)width:(int)height
{
	XConfigureEvent cv;

	cv.type = ConfigureNotify;
	cv.window = (Window)self->window->window;
	cv.x = x;
	cv.y = y;
	cv.width = width;
	cv.height = height;

	self->window->x = x;
	self->window->y = y;
	self->window->width = width;
	self->window->height = height;
	
	XSendEvent(zdpy,(Window)self->window->window,False,StructureNotifyMask | SubstructureNotifyMask,(XEvent *)&cv);
}

- (void)snap
{
	ZWindow *frame = (ZWindow *)self->window->parent;
	int dx,dy;
	IMPList *list = client_list;
	ZimClient *c;
	
	/* This is updated/translated/adapted from some work I did in an
	   earlier attempt to write a window manager that was never released.
	   Therefore, this code is kinda ugly. I do intend to clean it up at
	   some point in the future, and make it more efficient, but until then,
	   this will suffice. 
	 */
	
	if(abs(frame->x) < snap_px)
		frame->x = 0;
	if(abs(frame->y) < snap_px)
		frame->y = 0;

	if(abs(frame->x + frame->width - DisplayWidth(zdpy,zscreen)) < snap_px)
		frame->x = DisplayWidth(zdpy,zscreen) - frame->width;
	if(abs(frame->y + frame->height - DisplayHeight(zdpy,zscreen)) < snap_px)
		frame->y = DisplayHeight(zdpy,zscreen) - frame->height;
	
	dx = dy = snap_px;

	/* snap to other clients */	
	while(list) {
		c = (ZimClient *)list->data;
		if(c && c != self) {
			if(c->window->parent->y - frame->height - frame->y <=
				snap_px && frame->y - c->window->parent->height - c->window->parent->y <= snap_px) {
                               	 
				dx = absmin(dx, c->window->parent->x + c->window->parent->width - frame->x);
                                dx = absmin(dx, c->window->parent->x + c->window->parent->width - frame->x - frame->width);
                                dx = absmin(dx, c->window->parent->x - frame->x - frame->width);
                                dx = absmin(dx, c->window->parent->x - frame->x);
                        }
			if(c->window->parent->x - frame->width - frame->x <=
				snap_px && frame->x - c->window->parent->width - c->window->parent->x <= snap_px) {
                                
				dy = absmin(dy, c->window->parent->y + c->window->parent->height - frame->y);
                                dy = absmin(dy, c->window->parent->y + c->window->parent->height - frame->y - frame->height);
                                dy = absmin(dy, c->window->parent->y - frame->y - frame->height);
                                dy = absmin(dy, c->window->parent->y - frame->y);
                        }			
		}
		
		list = list->next;
	}
	
	if(abs(dx) < snap_px)
                frame->x += dx;
        if(abs(dy) < snap_px)
                frame->y += dy;

	[frame move:frame->x:frame->y];
}

- (void)move:(int)x:(int)y
{
	ZWindow *w = self->window->parent;
	
	[w move:x:y];	
	[self send_configure_message:w->x:w->y:self->window->width:self->window->height];
}

- (void)resize:(int)width:(int)height
{
	IMPList *children = NULL;
	ZWindow *window,*right,*left,*bottom,*bottom_right;
	ZWindow *frame = self->window->parent;
	char *name = NULL;
	
	/* Find the windows by searching through the frame's children list. */
	children = frame->children;

	if(!children)
		return;
	
	while(children) {
		window = children->data;
		name = [window get_name];
		
		if(!name)
			name = "";
			
		if(!strncmp(name,"RIGHT_HANDLE",8)) {
			right = window;
		}
		else if(!strncmp(name,"LEFT_HANDLE",7)) {
			left = window;
		}
		else if(!strncmp(name,"BOTTOM_HANDLE",13)) {
			bottom = window;
		}
		else if(!strncmp(name,"BOTTOM_RIGHT_HANDLE",19)) {
			bottom_right = window;
		}

		children = children->next;
	}
	
	[self resize:width:height:right:left:bottom:bottom_right];
}

- (void)resize:(int)width:(int)height:(ZWindow *)right:(ZWindow *)left:(ZWindow *)bottom:(ZWindow *)bottom_right
{
	ZWindow *frame = self->window->parent;

	if(!right || !left || !bottom || !bottom_right)
		return;

	if(width <= 0 || height <= 0)
		return;
	
	[self->window move:self->border:self->title_height];
	[self->window resize:width - (self->border * 2):height - self->border - self->title_height];
	[self->window raise];
	
	[frame resize:width:height];
	[frame raise];
	
	[right move:frame->width - self->border:self->title_height];
	[right resize:self->border:frame->height];
	[left move:0:self->title_height];
	[left resize:self->border:frame->height];
	[bottom move:0:frame->height - self->border];
	[bottom resize:frame->width:self->border];
	[bottom_right move:frame->width - self->border:frame->height - self->border];
	[bottom_right resize:self->border:self->border];
	
	[right raise];
	[left raise];
	[bottom raise];
	[bottom_right raise];
	
	[self send_configure_message:self->window->x:self->window->y:self->window->width:self->window->height];
	self->maximised = False;
}

@end

static ZWindow *create_frame_for_client(ZimClient *c)
{
	ZButton *close_button = [ZButton alloc];
	ZButton *maximise_button = [ZButton alloc];
	ZButton *minimise_button = [ZButton alloc];
	ZWindow *f = [ZWindow alloc];
	ZWindow *right_handle = [ZWindow alloc];
	ZWindow *left_handle = [ZWindow alloc];
	ZWindow *bottom_handle = [ZWindow alloc];
	ZWindow *bottom_right_handle = [ZWindow alloc];
	ZLabel *label = [ZLabel alloc];
	XGlyphInfo *extents;

	[f init:root_window:
		c->window->x:
		c->window->y:
		c->window->width + (c->border * 2):
		c->window->height + (c->border + c->title_height)];

	[f attatch_cb:BUTTON_DOWN:(ZCallback *)on_frame_button_down];
	[f attatch_cb:CONFIGURE:(ZCallback *)on_frame_configure];
	[f attatch_cb:POINTER_ENTER:(ZCallback *)on_frame_enter];
	
	[right_handle init:f:f->width - c->border:c->title_height:c->border:f->height];
	[right_handle attatch_cb:BUTTON_DOWN:(ZCallback *)resize];
	[right_handle set_name:"RIGHT_HANDLE"];
	[f add_child:(ZWidget *)right_handle];
	[right_handle show];

	[left_handle init:f:0:c->title_height:c->border:f->height];
	[left_handle attatch_cb:BUTTON_DOWN:(ZCallback *)resize];
	[left_handle set_name:"LEFT_HANDLE"];
	[f add_child:(ZWidget *)left_handle];
	[left_handle show];

	[bottom_handle init:f:0:f->height - c->border:f->width:c->border];
	[bottom_handle attatch_cb:BUTTON_DOWN:(ZCallback *)resize];
	[bottom_handle set_name:"BOTTOM_HANDLE"];
	[f add_child:(ZWidget *)bottom_handle];
	[bottom_handle show];

	[bottom_right_handle init:f:f->width - c->border:f->height - c->border:c->border:c->border];
	[bottom_right_handle attatch_cb:BUTTON_DOWN:(ZCallback *)resize];
	[bottom_right_handle set_name:"BOTTOM_RIGHT_HANDLE"];
	[f add_child:(ZWidget *)bottom_right_handle];
	[bottom_right_handle show];
	
	//[close_button init:0:0:10:10];
	[close_button init:PACKAGE_DATA_DIR"/default_close.png":1:1:10:10];
	[close_button set_border_width:0];
	[f add_child:(ZWidget *)close_button];
	[close_button set_name:"CLOSE"];
	//[close_button set_label:"X"];
	[close_button attatch_cb:BUTTON_DOWN:(ZCallback *)on_close_button_down];
	[close_button show];

	[maximise_button init:PACKAGE_DATA_DIR"/default_maximise.png":12:1:10:10];
	[maximise_button set_border_width:0];
	[f add_child:(ZWidget *)maximise_button];
	[maximise_button set_name:"MAX"];
	[maximise_button attatch_cb:BUTTON_DOWN:(ZCallback *)on_maximise_button_down];
	[maximise_button show];
		
	[minimise_button init:PACKAGE_DATA_DIR"/default_minimise.png":23:1:10:10];
	[minimise_button set_border_width:0];
	[f add_child:(ZWidget *)minimise_button];
	[minimise_button set_name:"MAX"];
	[minimise_button attatch_cb:BUTTON_DOWN:(ZCallback *)on_minimise_button_down];
	[minimise_button show];
	
	[label init:0:0];
	[f add_child:(ZWidget *)label];
	[label set_name:"TITLE"];
	[label set_label:[c->window get_title]];

	extents = [label get_text_extents];
	
	[label move:(f->width / 2) - (extents->width / 2):0];
	[label attatch_cb:BUTTON_DOWN:(ZCallback *)on_frame_label_button_down];
	[label show];

	i_free(extents);
	
	return f;	
}

static inline int absmin(int a, int b)
{
        if(abs(a) < abs(b))
                return a;
        else
                return b;
}

void on_win_configure(IMPObject *widget, void *data)
{
	ZWindow *win = (ZWindow *)widget;
	ZWindow *frame;
	XConfigureEvent *ev = (XConfigureEvent *)data;
	ZimClient *c = NULL;
	IMPList *children = NULL;
	ZWindow *right,*left,*bottom,*bottom_right,*window;
	char *name;

	c = zimwm_find_client_by_zwindow(win);
	
	if(!c)
		return;

	[c get_properties];

/*
	children = win->children;

	if(!children)
		return;
	
	while(children) {
		window = children->data;
		name = [window get_name];
		
		if(!name)
			name = "";
			
		if(!strncmp(name,"RIGHT_HANDLE",8)) {
			right = window;
		}
		else if(!strncmp(name,"LEFT_HANDLE",7)) {
			left = window;
		}
		else if(!strncmp(name,"BOTTOM_HANDLE",13)) {
			bottom = window;
		}
		else if(!strncmp(name,"BOTTOM_RIGHT_HANDLE",19)) {
			bottom_right = window;
		}

		children = children->next;
	}
	
	frame = c->window->parent;

	frame->width += ev->width - frame->width;
	frame->height += ev->height - frame->height;

	[frame resize:frame->width:frame->height];
	
	[right move:win->width - c->border:c->title_height];
	[right resize:c->border:win->height];
	[left move:0:c->title_height];
	[left resize:c->border:win->height];
	[bottom move:0:win->height - c->border];
	[bottom resize:win->width:c->border];
	[bottom_right move:win->width - c->border:win->height - c->border];
	[bottom_right resize:c->border:c->border];
	
	[right raise];
	[left raise];
	[bottom raise];
	[bottom_right raise];
*/
}

