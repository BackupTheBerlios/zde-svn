MODULE = systray

INCLUDES = \
-I$(top_builddir) \
-I$(top_srcdir) \
-I$(top_srcdir)/modules \
$(IMP_CFLAGS) $(X_CFLAGS) $(XFT_CFLAGS) $(CAIRO_CFLAGS) $(ZWL_CFLAGS)

pkgdir = $(libdir)/zimwm/modules/$(MODULE)

pkg_LTLIBRARIES = module.la
module_la_SOURCES=systray.m ../zimwm_module.m

module_la_LIBADD= -lobjc -lpthread $(IMP_LIBS) $(X_LIBS) $(XFT_LIBS) $(CAIRO_LIBS) $(ZWL_LIBS)
module_la_LDFLAGS = -module -avoid-version
