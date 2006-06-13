#!/usr/bin/perl -w
use strict;

#Generates output source code from xproto.xml
#Arguments: xid and xml to use as input

use XML::Twig;

sub start_class_header($);
sub start_class_source($$);
sub end_class_header();
sub end_class_source();
sub request_handle();

#create the output filenames
my $headerfh;
my $sourcefh;

my $xid = $ARGV[0];
$xid =~ tr/A-Z/a-z/;
my $outfile = "xcb_" . $xid;

my $outheaderfile = $outfile . ".h";
my $outsourcefile = $outfile . ".m";

start_class_header($outheaderfile);
start_class_source($outsourcefile,$outheaderfile);

#create twig
my $twig = XML::Twig->new(twig_handlers=> {
		request => \&request_handle
		});

$twig->parsefile($ARGV[1]);
$twig->purge;

end_class_header();
end_class_source();

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
	my $xid = $ARGV[0];
	$xid =~ tr/A-Z/a-z/;

	$xid =~ s/(\w+)/\u\L$1/g;
	my $capxid = $xid;

	open($headerfh,">",$_[0]) or die("Couldn't open header file $_[0].");
	#copyright
	print $headerfh '/*
   Copyright (c) 2005, 2006 Thomas Coppi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 This code has been automatically generated, modify at your own risk.

 */
';

	#interface declaration (needs to take into accout WINDOW and PIXMAP, which inherit from DRAWABLE
	print $headerfh "\@interface ObjXCB$capxid : Object \n{\n ";

	#variables
	print $headerfh "XCB".$ARGV[0] . ' xid;';

	print $headerfh "\n}\n";

	#all classes have init and free
	print $headerfh '/** Creates a new XID and initializes the object. */' . "\n";
	print $headerfh '- (id)init;' . "\n";
	print $headerfh '/** Takes in an XID and initializes the object. */' . "\n";
	print $headerfh '- (id)init:(' . "XCB".$ARGV[0] . ')xid;' . "\n";
	print $headerfh '- free;' . "\n";
}

sub start_class_source($$)
{
	my $xid = $ARGV[0];
	$xid =~ tr/A-Z/a-z/;

	$xid =~ s/(\w+)/\u\L$1/g;
	my $capxid = $xid;

	open($sourcefh,">",$_[0]) or die("Couldn't open source file $_[0].");

	#include
	print $sourcefh '#include<obj-xcb.h>' . "\n";
	print $sourcefh '#include<' . "$_[1]" . '>' . "\n";
}

sub end_class_header()
{
	print $headerfh "\n\@end\n";
}

sub end_class_source()
{
	print $sourcefh "\n\@end\n";
}

0;
