#
# I wish there was a way to dynamically tell it to compile all .m files... 
#
#

lib_LTLIBRARIES = libXCBobjc.la
libXCBobjc_la_SOURCES = xcb_conn.m xcb_window.m \
			xcb_atom.m xcb_colormap.m xcb_cursor.m xcb_font.m xcb_gcontext.m xcb_pixmap.m

XCBOBJCHEADERS = xcb_conn.h obj-xcb.h objxproto.h xcb_window.h xcb_atom.h xcb_colormap.h xcb_cursor.h xcb_font.h xcb_gcontext.h xcb_pixmap.h

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
xcb_atom.m: objxproto.h
xcb_atom.h: objxproto.h
xcb_colormap.m: objxproto.h
xcb_colormap.h: objxproto.h
xcb_cursor.m: objxproto.h
xcb_cursor.h: objxproto.h
xcb_font.m: objxproto.h
xcb_font.h: objxproto.h
xcb_gcontext.m: objxproto.h
xcb_gcontext.h: objxproto.h
xcb_pixmap.m: objxproto.h
xcb_pixmap.h: objxproto.h

clean-local:
	rm -f objxproto.h xcb_window.h xcb_window.m xcb_atom.m xcb_colormap.m xcb_cursor.m xcb_font.m xcb_gcontext.m xcb_pixmap.m \
		xcb_atom.h xcb_colormap.h xcb_cursor.h xcb_font.h xcb_gcontext.h xcb_pixmap.h objxcb* *.loT
