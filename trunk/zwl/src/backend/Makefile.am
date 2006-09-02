lib_LTLIBRARIES = libzwlbackend.la
libzwlbackend_la_SOURCES = backend.m

INCLUDES = \
-I$(top_builddir) \
-I$(top_srcdir) \
$(OBJXCB_CFLAGS) $(IMP_CFLAGS) $(CAIRO_CFLAGS) $(CAIRO_XCB_CFLAGS) -g3

EXTRA_DIST = backend.h 

ZWLHEADERS = \
	backend.h
 
libzwl_la_LDDADD = -lobjc -lpthread $(OBJXCB_LIBS) $(IMP_LIBS) $(CAIRO_LIBS) $(CAIRO_XCB_LIBS)
libzwl_la_LDFLAGS = -version-info 1:0:0
