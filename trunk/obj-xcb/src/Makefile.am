#
# I wish there was a way to dynamically tell it to compile all .m files... 
#
#

lib_LTLIBRARIES = libXCBobjc.la
libXCBobjc_la_SOURCES = xcb_conn.m xcb_window.m 

XCBOBJCHEADERS = xcb_conn.h obj-xcb.h objxproto.h xcb_window.h

EXTRA_DIST = $(XCBOBJCHEADERS)

installed_headersdir = $(prefix)/include/X11/XCB/bindings/objc
installed_headers_DATA = $(XCBOBJCHEADERS)

libXCBobjc_la_LDDADD = -lobjc -lpthread -lXCB
libXCBobjc_la_LDFLAGS = -version-info 0:0:0

vpath %.xml $(XCBPROTO_XCBINCLUDEDIR) $(XCBPROTO_XCBINCLUDEDIR)/extensions

obj%.h: %.xml ../scripts/codegen.pl 
#	../scripts/codegen.pl $@ $<
	../scripts/codegen.pl $@ $<

xcb_conn.m: objxproto.h

xcb_window.m: objxproto.h

xcb_window.h: objxproto.h

clean-local:
	rm -f objxproto.h xcb_window.h xcb_window.m
