#!/usr/bin/perl -w
use strict;

#Generates output source code from xproto.xml
#Arguments: xid and xml to use as input

use XML::Twig;

#create the output filenames
my $xid = $ARGV[0];
$xid =~ tr/A-Z/a-z/;
my $outfile = "xcb_" . $xid;

my $outheaderfile = $outfile . ".h";
my $outsourcefile = $outfile . ".m";

#create twig
my $twig = XML::Twig->new(twig_handlers=> {
		request => \&request_handle
		});

$twig->parsefile($ARGV[1]);
$twig->purge;

sub request_handle()
{ my($twig, $section) = @_;
	print $section->first_child('field')->{'att'}->{'name'};
}

0;
