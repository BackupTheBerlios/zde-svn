#!/usr/bin/perl -w
use strict;

#Master control script
#Arguments: file to generate, and file to use as input

use XML::Twig;

#figure out what we are creating and what the input should be
my $outfile = $ARGV[0];
my $infile;

if($outfile eq "objxcb_types.h") {
	$infile = $ARGV[1] . "/xcb_types.xml";

	#create twig
	my $twig = XML::Twig->new(twig_handlers=> {
		xcb => \&xcb_handle,
		xidtype => \&xid_handle
		}
		);

	$twig->parsefile("$infile");
	$twig->purge;
}


sub xcb_handle()
{ my($twig, $section)= @_;

}

sub xid_handle()
{ my( $twig, $section)= @_;
	#print "$section->{'att'}->{'name'}\n";
	`../scripts/xidgen.pl $section->{'att'}->{'name'} $ARGV[1] . "/xproto.xml"`; 
}


0;
