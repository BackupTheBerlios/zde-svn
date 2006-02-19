#!/bin/sh

rm -rf autom4te.cache
rm -f aclocal.m4

echo "Running autoheader..."; autoheader \
	     && echo "Running libtoolize..."; libtoolize --force \
     	     && echo "Running aclocal..."; aclocal \
	     && echo "Running autoconf..."; autoconf \
	     && echo "Running automake..."; automake --add-missing --copy --gnu

./configure "$@"
	     
