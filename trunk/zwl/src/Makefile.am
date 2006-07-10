lib_LTLIBRARIES = libzwl.la
libzwl_la_SOURCES = zwl_internal.m init.m widget.m window.m label.m button.m
#widget.m init.m window.m button.m label.m menu.m

INCLUDES = \
-I$(top_builddir) \
-I$(top_srcdir) \
$(OBJXCB_CFLAGS) $(IMP_CFLAGS) $(XFT_CFLAGS) $(CAIRO_CFLAGS) $(CAIRO_XCB_CFLAGS) -g3

EXTRA_DIST = zwl.h zwl_internal.h zwlinit.h zwlwindow.h zwlbutton.h zwllabel.h zwlmenu.h zwlwidget.h

ZWLHEADERS = \
	     zwl.h \
	     zwlinit.h \
	     zwlwindow.h \
	     zwlbutton.h \
	     zwllabel.h \
	     zwlmenu.h \
	     zwlwidget.h \
	     zwl_internal.h

installed_headersdir = $(prefix)/include/zwl
installed_headers_DATA = $(ZWLHEADERS)
	     
libzwl_la_LDDADD = -lobjc -lpthread $(OBJXCB_LIBS) $(IMP_LIBS) $(XFT_LIBS) $(CAIRO_LIBS) $(CAIRO_XCB_LIBS)
libzwl_la_LDFLAGS = -version-info 1:0:0
