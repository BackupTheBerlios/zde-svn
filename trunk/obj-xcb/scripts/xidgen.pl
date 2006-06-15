#!/usr/bin/perl -w
use strict;

#Generates output source code from xproto.xml
#Arguments: xid and xml to use as input

use XML::Twig;

my $copyright = '/*
   Copyright (c) 2005, 2006 Thomas Coppi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 This code has been automatically generated, modify at your own risk.

 */
';

sub start_class_header($);
sub start_class_source($$);
sub output_method_header($$);
sub end_class_header();
sub end_class_source();
sub request_handle();

my $headerfh;
my $sourcefh;

my @xids;

#create the output filenames
my $xid = $ARGV[0];
$xid =~ tr/A-Z/a-z/;
my $outfile = "xcb_" . $xid;

my $outheaderfile = $outfile . ".h";
my $outsourcefile = $outfile . ".m";

start_class_header($outheaderfile);
start_class_source($outsourcefile,$outheaderfile);

#create twig
my $twig = XML::Twig->new(twig_handlers=> {
		xidtype => \&xid_handle,
		union => \&xid_handle,
		struct => \&xid_handle,
		request => \&request_handle
		});

$twig->parsefile($ARGV[1]);
$twig->purge;

end_class_header();
end_class_source();

#loads @xids with the name of every xid
sub xid_handle()
{ my($twig, $section) = @_;
	$xids[@xids] = $section->{'att'}->{'name'};
}

sub request_handle()
{ my($twig, $section) = @_;
	my $xid = $ARGV[0];
	$xid =~ tr/A-Z/a-z/;

	my $firstxid;
	my $numfirstxid;
	my $numotherxid;
	my $lastreqname;

	my @fields = $section->children('field');

	#orphan
	if(!@fields) {
		return;
	}
	
	foreach my $field (@fields) {
		
		foreach my $xidtmp (@xids) {
#	if(($field->{'att'}->{'type'} eq $xidtmp) {	
#				if(!defined $firstxid) {
#					$firstxid = $xidtmp;
#					$numfirstxid++;
#				}
#			}	
#
#			if(defined $firstxid and $xidtmp eq $firstxid) {
#				$numfirstxid++;
#			}
#			elsif($field->{'att'}->{'type'} eq $xidtmp) {
#				$numotherxid++;
#			}
#
			#if we find a field with an XID and that XID is not what we are doing, skip this request, it belongs elsewhere.
			if(($field->{'att'}->{'type'} eq $xidtmp) and ($xidtmp ne $ARGV[0])) {
				next;
			}
		}

		if((defined $lastreqname) and $lastreqname eq $section->{'att'}->{'name'}) {
			return;
		}

		#it belongs here
		if($field->{'att'}->{'type'} eq $ARGV[0]) {
			$lastreqname = $section->{'att'}->{'name'};
			output_method_header($xid,$section);
		}
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
	print $headerfh "$copyright";

	#interface declaration (needs to take into accout WINDOW and PIXMAP, which inherit from DRAWABLE
	print $headerfh "\@interface ObjXCB$capxid : Object \n{\n";

	#variables
	print $headerfh "\tXCB$ARGV[0]" . ' xid;' . "\n";
	print $headerfh "\t" . 'ObjXCBConnection *c;' . "\n";

	print $headerfh "\n}\n";

	#all classes have init and free
	print $headerfh '/** Creates a new XID and initializes the object. */' . "\n";
	print $headerfh '- (id)init:(ObjXCBConnection *)c;' . "\n";
	print $headerfh '/** Takes in an XID and initializes the object. */' . "\n";
	print $headerfh '- (id)init:(ObjXCBConnection *) c:(' . "XCB$ARGV[0]" . ')xid;' . "\n";
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
	print $sourcefh '#include<' . "$_[1]" . '>' . "\n\n";

	#generic init and free code
	print $sourcefh "\@implementation ObjXCB$capxid : Object \n\n";
	print $sourcefh '- (id)init:(ObjXCBConnection *)c' . "\n" . '{' . "\n" .
		'self->c = c;'.
		'self->xid = XCB'.$ARGV[0] . 'New([self->c get_connection]);' . "\n" . '}' . "\n\n";
	print $sourcefh '- (id)init:(ObjXCBConnection *)c:(' . "XCB$ARGV[0]" . ')xid;' . "\n" . '{' . "\n" .
		'self->c = c;'.
		'self->xid = xid;' . "\n" . '}' . "\n\n";
	print $sourcefh '- free' . "\n" . '{' . "\n" .
		'self->c = NULL;' . "\n" . '[super free];' . "\n" . '}' . "\n\n";

}

sub end_class_header()
{
	print $headerfh "\n\@end\n";
}

sub end_class_source()
{
	print $sourcefh "\n\@end\n";
}

sub output_method_header($$)
{ my($xid,$request) = @_;
	
	my @fields = $request->children('field');
	my @valueparam = $request->children('valueparam');
	my @reply = $request->children('reply');

	if(!@reply) {
		print $headerfh '- (void)' . "$request->{'att'}->{'name'}";
	}
	else {	
		#create a new header file for the reply
		my @repfields = $reply[0]->children('field');
		my $repname = $request->{'att'}->{'name'};
		$repname =~ tr/A-Z/a-z/;
		my $repnamefull = $repname . "reply";

		open(my $repfh,">","objxcb_$repnamefull.h") or die("Couldn't open file.");
		print $repfh $copyright;
		print $repfh "\@interface ObjXCB$request->{'att'}->{'name'}Reply : Object\n{\n";
		print $repfh "\tXCB$request->{'att'}->{'name'}" . "Cookie repcookie;\n}\n\n";
		
		foreach my $repfield (@repfields) {
			my $rtype = $repfield->{'att'}->{'type'};
			foreach my $xidtmp (@xids) {
				if($rtype eq $xidtmp) {
					$rtype = ("XCB" . $xidtmp);
				}
			}
			print $repfh "- \($rtype\)get_$repfield->{'att'}->{'name'};\n";	
		}

		print $repfh "\@end\n";

		#include us in objxproto.h
		open(my $xprotofh,">>","objxproto.h") or die("Couldn't open objxproto.h");
		print $xprotofh '#include<' . "objxcb_$repnamefull.h" . ">\n";
		close($xprotofh);

		#output the correct method declaration now
		print $headerfh '- (' . "ObjXCB$request->{'att'}->{'name'}Reply *" . "\)$request->{'att'}->{'name'}";
	}

	foreach my $field (@fields) {
		my $ftype = $field->{'att'}->{'type'};
		#print $field->{'att'}->{'name'};
		if(!defined $field) {
			last;
		}
		foreach my $xidtmp (@xids) {
			if($ftype eq $xidtmp) {
				$ftype = ("XCB" . $xidtmp);
			}
		}

		print $headerfh ":\($ftype\)$field->{'att'}->{'name'}";	
	}

	print $headerfh ";\n";
}
0;
