#!/usr/bin/perl -w
use strict;

#Generates output source code from xproto.xml
#Arguments: xid and xml to use as input

use XML::Twig;

sub start_class_header($);
sub start_class_source($);
sub request_handle();

#create the output filenames
my $headerfh;
my $sourcefh;

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

start_class_header($outheaderfile);
start_class_source($outsourcefile);

sub request_handle()
{ my($twig, $section) = @_;
	my $xid = $ARGV[0];
	$xid =~ tr/A-Z/a-z/;

	my $firstfield = $section->first_child('field');

	if(!defined $firstfield) {
		#print "No fields\n";
		return;
	}

	if($firstfield->{'att'}->{'name'} eq $xid) {
			
	}

}

sub start_class_header($)
{
	open($headerfh,">>",$_[0]) or die("Couldn't open header file.");
}

sub start_class_source($)
{

}
0;
