lib_LTLIBRARIES = libimp.la
libimp_la_SOURCES = lists.m impobject.m stack.m memory.m

EXTRA_DIST = imp.h impobject.h implists.h impstack.h impmemory.h impiterator.h

IMPHEADERS = \
	      imp.h \
	      impobject.h \
	      implists.h \
	      impstack.h \
	      impmemory.h

installed_headersdir = $(prefix)/include/imp
installed_headers_DATA = $(IMPHEADERS)

libimp_la_LDDADD = -lobjc -lpthread
libimp_la_LDFLAGS = -version-info 0:0:0
