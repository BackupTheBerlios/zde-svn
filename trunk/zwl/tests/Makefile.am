bin_PROGRAMS  = zwltest
zwltest_SOURCES = zwl_test.m

INCLUDES = \
	   $(OBJXCB_CFLAGS) $(IMP_CFLAGS) $(XFT_CFLAGS) $(CAIRO_CFLAGS)

zwltest_LDADD = ../src/libzwl.la -lobjc -lpthread $(OBJXCB_LIBS) $(IMP_LIBS) $(XFT_LIBS) $(CAIRO_LIBS)
