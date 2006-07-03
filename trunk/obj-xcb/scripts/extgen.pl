#!/usr/bin/perl -w
use strict;

#Generates output source code from xml files in $XCBPROTODIR/extensions

use XML::Twig;

sub xcb_handle();
sub gen_header($);
sub gen_source($);

my $headerfh;
my $sourcefh;

my @files = glob($ARGV[0]."/*");

my @extheadernames;

mkdir("extensions");

my $twig = XML::Twig->new(twig_handlers=> {
		xcb => \&xcb_handle
		});

foreach my $file (@files) {
#gen_header($file);
#gen_source($file);
	$twig->parsefile($file);
	$twig->purge;
}

sub xcb_handle()
{ my ($twig,$section) = @_;

	print $section->{'att'}->{'header'} . "\n";

}

sub gen_header($)
{ my ($filename) = @_;



	open($headerfh,">","extensions/$filename") or die("Couldn't open file");

	close($headerfh);
}

sub gen_source($)
{ my ($filename) = @_;

}
