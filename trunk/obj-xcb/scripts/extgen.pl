#!/usr/bin/perl -w
use strict;

#Generates output source code from xml files in $XCBPROTODIR/extensions

use XML::Twig;

sub gen_header($);
sub gen_source($);

@files = glob($ARGV[0]);

foreach $file (@files) {
	gen_header($file);
	gen_source($file);
}

sub gen_header($)
{ my ($filename) = @_;

}

sub gen_source($)
{ my ($filename) = @_;

}
