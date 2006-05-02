lib_LTLIBRARIES = libXCBobjc.la
libXCBobjc_la_SOURCES = xcb_conn.m xcb_events.m xcb_win.m

EXTRA_DIST = xcb_conn.h xcb_events.h xcb_win.h obj-xcb.h

installed_headersdir = $(prefix)/include/X11/XCB/bindings/objc
#installed_headers_DATA = $(XCBOBJCHEADERS)

libXCBobjc_la_LDDADD = -lobjc -lpthread -lXCB
libXCBobjc_la_LDFLAGS = -version-info 0:0:0
