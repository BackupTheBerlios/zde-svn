bin_PROGRAMS  = zwltest
zwltest_SOURCES = zwl_test.m

INCLUDES = \
	   $(OBJXCB_CFLAGS) $(IMP_CFLAGS) $(CAIRO_CFLAGS) $(CAIRO_XCB_CFLAGS)

zwltest_LDADD = ../src/libzwl.la -lobjc -lpthread $(OBJXCB_LIBS) $(IMP_LIBS) $(CAIRO_LIBS) $(CAIRO_XCB_LIBS)
