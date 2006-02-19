bin_PROGRAMS=zimwm
zimwm_SOURCES=main.m events.m client.m

EXTRA_DIST=zimwm.h events.h client.h

INCLUDES = \
-I$(top_builddir) \
-I$(top_srcdir) \
$(IMP_CFLAGS) $(X_CFLAGS) $(XFT_CFLAGS) $(CAIRO_CFLAGS) $(ZWL_CFLAGS)

zimwm_LDADD= -lobjc -lpthread $(IMP_LIBS) $(X_LIBS) $(XFT_LIBS) $(CAIRO_LIBS) $(ZWL_LIBS)

