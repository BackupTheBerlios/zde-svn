#!/usr/bin/perl -w
use strict;

#Generates output source code from xml files in $XCBPROTODIR/extensions

use XML::Twig;

sub xcb_handle();
sub xidtype_handle();
sub gen_header($);
sub gen_source($);

my $headerfh;
my $sourcefh;

my @files = glob($ARGV[0]."/*");

my $currextname;
my $infile;

my @extheadernames;

mkdir("extensions");

my $twig = XML::Twig->new(twig_handlers=> {
		xcb => \&xcb_handle,
		xidtype => \&xidtype_handle
		});

foreach my $file (@files) {
#gen_header($file);
#gen_source($file);

	#remove extension
	$currextname = substr($file, 0, - 4);
	$currextname = substr($currextname,(length $ARGV[0]) + 1);
	$currextname =~ tr/a-z/A-Z/;
	
	$infile = $file;

	$twig->parsefile($file);
	$twig->purge;
}

sub xcb_handle()
{ my ($twig,$section) = @_;

	print $section->{'att'}->{'header'} . "\n";

}

sub xidtype_handle()
{ my ($twig,$section) = @_;
	
	print `../scripts/xidgen.pl $section->{'att'}->{'name'} $infile 0 $currextname`;
}

sub gen_header($)
{ my ($filename) = @_;
	open($headerfh,">","extensions/$filename") or die("Couldn't open file");

	close($headerfh);
}

sub gen_source($)
{ my ($filename) = @_;

}
