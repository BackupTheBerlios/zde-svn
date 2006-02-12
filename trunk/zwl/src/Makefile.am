lib_LTLIBRARIES = libzwl.la
libzwl_la_SOURCES = widget.m init.m window.m button.m

INCLUDES = \
-I$(top_builddir) \
-I$(top_srcdir) \
$(IMP_CFLAGS) $(X_CFLAGS) $(XFT_CFLAGS)

ZWLHEADERS = \
	     zwlinit.h \
	     zwlwindow.h \
	     zwlbutton.h \
	     zwlwidget.h

installed_headersdir = $(prefix)/include/zwl
installed_headers_DATA = $(ZWLHEADERS)
	     
libzwl_la_LDDADD = -lobjc -lpthread $(IMP_LIBS) $(X_LIBS) $(XFT_LIBS)
libzwl_la_LDFLAGS = -version-info 0:0:0
