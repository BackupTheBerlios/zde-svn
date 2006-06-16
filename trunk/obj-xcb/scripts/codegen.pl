#!/usr/bin/perl -w
use strict;

#Master control script
#Arguments: file to generate, and file to use as input

use XML::Twig;

sub start_file($);

my $filefh;

#figure out what we are creating and what the input should be
my $outfile = $ARGV[0];
my $infile = $ARGV[1];

if($outfile eq "objxproto.h") {
	start_file($outfile);

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
	print `../scripts/xidgen.pl $section->{'att'}->{'name'} $infile`;
#only do the first one for now
#	exit 0;
}

sub start_file($)
{
	open($filefh,">",$_[0]) or die("Couldn't open file $_[0].");
}

0;
