bin_PROGRAMS=zimwm
zimwm_SOURCES=main.m client.m

INCLUDES = \
-I$(top_builddir) \
-I$(top_srcdir) \
$(OBJXCB_CFLAGS) $(IMP_CFLAGS) $(ZWL_CFLAGS) $(CAIRO_CFLAGS) $(CAIRO_XCB_CFLAGS) $(XCB_RENDERUTIL_CFLAGS) -g3

zimwm_LDADD= -lobjc -lpthread $(OBJXCB_LIBS) $(IMP_LIBS) $(ZWL_LIBS) $(CAIRO_LIBS) $(CAIRO_XCB_LIBS) $(XCB_RENDERUTIL_LIBS)
zimwm_LDFLAGS = -rdynamic

#SUBDIRS = modules

