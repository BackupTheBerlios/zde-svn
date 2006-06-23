#
# I wish there was a way to dynamically tell it to compile all .m files... 
#
#

lib_LTLIBRARIES = libXCBobjc.la
libXCBobjc_la_SOURCES = xcb_conn.m xcb_window.m \
			xcb_atom.m xcb_colormap.m xcb_cursor.m xcb_font.m xcb_gcontext.m xcb_pixmap.m xcb_drawable.m xcb_fontable.m \
			objxcb_alloccolorcellsreply.m      objxcb_listinstalledcolormapsreply.m \
			objxcb_alloccolorplanesreply.m     objxcb_listpropertiesreply.m \
			objxcb_alloccolorreply.m           objxcb_lookupcolorreply.m \
			objxcb_allocnamedcolorreply.m      objxcb_querybestsizereply.m \
			objxcb_getatomnamereply.m          objxcb_querycolorsreply.m \
			objxcb_getgeometryreply.m          objxcb_queryfontreply.m \
			objxcb_getimagereply.m             objxcb_querytextextentsreply.m \
			objxcb_getpropertyreply.m          objxcb_querytreereply.m \
			objxcb_getselectionownerreply.m    objxcb_translatecoordinatesreply.m \
			objxcb_getwindowattributesreply.m  xcb_conn_orphan.m


XCBOBJCHEADERS = xcb_conn.h obj-xcb.h objxproto.h xcb_window.h xcb_atom.h xcb_colormap.h xcb_cursor.h xcb_font.h xcb_gcontext.h xcb_pixmap.h \
		 xcb_drawable.h xcb_fontable.h \
		 objxcb_alloccolorcellsreply.h      objxcb_listinstalledcolormapsreply.h \
		 objxcb_alloccolorplanesreply.h     objxcb_listpropertiesreply.h \
		 objxcb_alloccolorreply.h           objxcb_lookupcolorreply.h \
		 objxcb_allocnamedcolorreply.h      objxcb_querybestsizereply.h \
		 objxcb_getatomnamereply.h          objxcb_querycolorsreply.h \
		 objxcb_getgeometryreply.h          objxcb_queryfontreply.h \
		 objxcb_getimagereply.h             objxcb_querytextextentsreply.h \
		 objxcb_getpropertyreply.h          objxcb_querytreereply.h \
		 objxcb_getselectionownerreply.h    objxcb_translatecoordinatesreply.h \
		 objxcb_getwindowattributesreply.h  xcb_conn_orphan.h 


EXTRA_DIST = $(XCBOBJCHEADERS)

installed_headersdir = $(prefix)/include/X11/XCB/bindings/objc
installed_headers_DATA = $(XCBOBJCHEADERS)

libXCBobjc_la_LDDADD = -lobjc -lpthread -lXCB
libXCBobjc_la_LDFLAGS = -version-info 0:0:0

vpath %.xml $(XCBPROTO_XCBINCLUDEDIR) $(XCBPROTO_XCBINCLUDEDIR)/extensions

obj%.h: %.xml ../scripts/codegen.pl 
#	../scripts/codegen.pl $@ $<
	../scripts/codegen.pl $@ $<

#core files
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
xcb_drawable.m: objxproto.h
xcb_drawable.h: objxproto.h
xcb_fontable.h: objxproto.h
xcb_fontable.m: objxproto.h

xcb_conn_orphan.m: objxproto.h

#replies
objxcb_alloccolorcellsreply.m: objxproto.h      
objxcb_listinstalledcolormapsreply.m: objxproto.h
objxcb_alloccolorplanesreply.m: objxproto.h     
objxcb_listpropertiesreply.m: objxproto.h
objxcb_alloccolorreply.m: objxproto.h
objxcb_lookupcolorreply.m: objxproto.h
objxcb_allocnamedcolorreply.m: objxproto.h
objxcb_querybestsizereply.m: objxproto.h
objxcb_getatomnamereply.m: objxproto.h
objxcb_querycolorsreply.m: objxproto.h
objxcb_getgeometryreply.m: objxproto.h
objxcb_queryfontreply.m: objxproto.h
objxcb_getimagereply.m: objxproto.h
objxcb_querytextextentsreply.m: objxproto.h
objxcb_getpropertyreply.m: objxproto.h
objxcb_querytreereply.m: objxproto.h
objxcb_getselectionownerreply.m: objxproto.h
objxcb_translatecoordinatesreply.m: objxproto.h
objxcb_getwindowattributesreply.m: objxproto.h


clean-local:
	rm -f objxproto.h xcb_window.h xcb_window.m xcb_atom.m xcb_colormap.m xcb_cursor.m xcb_font.m xcb_gcontext.m xcb_pixmap.m \
		xcb_atom.h xcb_colormap.h xcb_cursor.h xcb_font.h xcb_gcontext.h xcb_pixmap.h xcb_drawable.h xcb_drawable.m xcb_fontable.h xcb_fontable.m \
		objxcb* *.loT
