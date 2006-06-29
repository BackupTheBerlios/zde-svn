lib_LTLIBRARIES = libzwl.la
libzwl_la_SOURCES = init.m widget.m
#widget.m init.m window.m button.m label.m menu.m

INCLUDES = \
-I$(top_builddir) \
-I$(top_srcdir) \
$(OBJXCB_CFLAGS) $(IMP_CFLAGS) $(X_CFLAGS) $(XFT_CFLAGS) $(CAIRO_CFLAGS)

EXTRA_DIST = zwl.h zwlinit.h zwlwindow.h zwlbutton.h zwllabel.h zwlmenu.h zwlwidget.h

ZWLHEADERS = \
	     zwl.h \
	     zwlinit.h \
	     zwlwindow.h \
	     zwlbutton.h \
	     zwllabel.h \
	     zwlmenu.h \
	     zwlwidget.h

installed_headersdir = $(prefix)/include/zwl
installed_headers_DATA = $(ZWLHEADERS)
	     
libzwl_la_LDDADD = -lobjc -lpthread $(OBJXCB_LIBS) $(IMP_LIBS) $(X_LIBS) $(XFT_LIBS) $(CAIRO_LIBS)
libzwl_la_LDFLAGS = -version-info 0:0:0
