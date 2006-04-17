bin_PROGRAMS=zimwm
zimwm_SOURCES=main.m events.m client.m client-events.m widgets.m ewmh.m focus.m vdesk.m zone.m ipc.m modules.m

bin_SCRIPTS=zimsh

EXTRA_DIST=zimwm.h events.h client.h client-events.h widgets.h ewmh.h focus.h vdesk.h zone.h ipc.h ipc_commands.h modules.h zimsh

INCLUDES = \
-I$(top_builddir) \
-I$(top_srcdir) \
$(IMP_CFLAGS) $(X_CFLAGS) $(XFT_CFLAGS) $(CAIRO_CFLAGS) $(ZWL_CFLAGS)

zimwm_LDADD= -lobjc -lpthread $(IMP_LIBS) $(X_LIBS) $(XFT_LIBS) $(CAIRO_LIBS) $(ZWL_LIBS)

SUBDIRS = modules

