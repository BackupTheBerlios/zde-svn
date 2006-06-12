#!/usr/bin/perl -w
use strict;

#Generates output source code from xproto.xml
#Arguments: xid and xml to use as input

use XML::Twig;

#create the output filenames
my $outfile = $ARGV[0];
$outfile =~ tr/A-Z/a-z/;
$outfile = "xcb_" . $outfile;

my $outheaderfile = $outfile . ".h";
my $outsourcefile = $outfile . ".m";

0;
