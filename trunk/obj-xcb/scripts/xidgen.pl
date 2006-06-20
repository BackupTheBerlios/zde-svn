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
sub end_class_header($);
sub end_class_source($);
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

my $inherits = "Object";

if($ARGV[0] eq "WINDOW" or $ARGV[0] eq "PIXMAP") {
	$inherits = "ObjXCBDrawable";
}

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

end_class_header($outheaderfile);
end_class_source($outsourcefile);

#loads @xids with the name of every xid
sub xid_handle()
{ my($twig, $section) = @_;
	$xids[@xids] = $section->{'att'}->{'name'};
}

#
#
#TODO
#Need to put in the other rules to decide what is an orphan, see mailing list discussion
#
#
sub request_handle()
{ my($twig, $section) = @_;
	my $xid = $ARGV[0];
	$xid =~ tr/A-Z/a-z/;

	my $firstxid;
	my $numfirstxid;
	my $isxid = undef;
	my $lastreqname;

	my @fields = $section->children('field');
	my %numeachtype;

	#orphan
	if(!@fields) {
		return;
	}
	
	foreach my $field (@fields) {	
		foreach my $xidtmp (@xids) {			
			#then this is the first xid
			if(($field->{'att'}->{'type'} eq $xidtmp) and (!defined $firstxid)) {
				$firstxid = $xidtmp;
				$isxid = defined;

				#see if this isn't the xid we want.  If so, get outa here
				if($firstxid ne $ARGV[0]) {
					return;
				}
			}
			#even if its not the first xid, it might be an xid
			elsif($field->{'att'}->{'type'} eq $xidtmp) {
				$isxid = defined;
			}
		}
		#remove duplicates, sometimes XML::Twig likes to go batty
		if((defined $lastreqname) and $lastreqname eq $section->{'att'}->{'name'}) {
			return;
		}
	
		if((defined $isxid) and $field->{'att'}->{'type'} eq $firstxid) { 
			$numfirstxid++;
		}

		if(!defined $isxid) {
			$numeachtype{"$field->{'att'}->{'type'}"}++;
		}

		$isxid = undef;
	}

	if(!defined $firstxid) {
		return;
	}
	
	#it might belong here
	if($firstxid eq $ARGV[0]) {
		my @values = (values %numeachtype);
		#see if the number of any other field type is higher than how many of the first xid
		if($section->{'att'}->{'name'} =~ /$firstxid/i) {
			$lastreqname = $section->{'att'}->{'name'};
			output_method_header($xid,$section);
			return;
		}
		foreach my $num (@values) {
			#then there is only one way for it to redeem itself...
			if($num >= $numfirstxid){
				if($firstxid eq "WINDOW" and $section->{'att'}->{'name'} eq "ClearArea") {
					$lastreqname = $section->{'att'}->{'name'};
					output_method_header($xid,$section);
					return;
				}
				#send off to the orphan script
				return;
			}
		}
		$lastreqname = $section->{'att'}->{'name'};
		output_method_header($xid,$section);
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
	print $headerfh "\@interface ObjXCB$capxid : $inherits \n{\n";

	#variables
	if($ARGV[0] ne "DRAWABLE" and $ARGV[0] ne "FONTABLE") {
		print $headerfh "\tXCB$ARGV[0]" . ' xid;' . "\n";
		print $headerfh "\t" . 'ObjXCBConnection *c;' . "\n";
	}
	print $headerfh "\n}\n";

	#most classes have init and free
	if($ARGV[0] ne "DRAWABLE" and $ARGV[0] ne "FONTABLE") {
		print $headerfh '/** Creates a new XID and initializes the object. */' . "\n";
		print $headerfh '- (id)init:(ObjXCBConnection *)c;' . "\n";
		print $headerfh '/** Takes in an XID and initializes the object. */' . "\n";
		print $headerfh '- (id)init:(ObjXCBConnection *) c:(' . "XCB$ARGV[0]" . ')xid;' . "\n";
		print $headerfh '- free;' . "\n";
	}
}

sub start_class_source($$)
{
	my $xid = $ARGV[0];
	$xid =~ tr/A-Z/a-z/;

	$xid =~ s/(\w+)/\u\L$1/g;
	my $capxid = $xid;

	open($sourcefh,">",$_[0]) or die("Couldn't open source file $_[0].");

	#include
	print $sourcefh '#include <obj-xcb.h>' . "\n";
	print $sourcefh '#include <' . "$_[1]" . '>' . "\n\n";

	#generic init and free code
	print $sourcefh "\@implementation ObjXCB$capxid : $inherits \n\n";
	if($ARGV[0] ne "DRAWABLE" and $ARGV[0] ne "FONTABLE") {
		print $sourcefh '- (id)init:(ObjXCBConnection *)c' . "\n" . '{' . "\n" .
			"\t" . 'self->c = c;'. "\n" .
			"\t" . 'self->xid = XCB'.$ARGV[0] . 'New([self->c get_connection]);' . "\n" . '}' . "\n\n";
		print $sourcefh '- (id)init:(ObjXCBConnection *)c:(' . "XCB$ARGV[0]" . ')xid;' . "\n" . '{' . "\n" .
			"\t" . 'self->c = c;'. "\n" .
			"\t" . 'self->xid = xid;' . "\n" . '}' . "\n\n";
		print $sourcefh '- free' . "\n" . '{' . "\n" .
			"\t" . 'self->c = NULL;' . "\n" . '[super free];' . "\n" . '}' . "\n\n";
	}

}

sub end_class_header($)
{
	print $headerfh "\n\@end\n";
	close $headerfh;
}

sub end_class_source($)
{
	print $sourcefh "\n\@end\n";
	close $sourcefh;
}

#
#
# TODO Things to be fixed
# Valueparams must be put in
# DONE - Parameters that are XIDs should be turned into ObjXCBEquivilants
# DONE - The first XID is always redundant, we store that within the class
#
#
sub output_method_header($$)
{ my($xid,$request) = @_;
	
	my @fields = $request->children('field');
	my @valueparam = $request->children('valueparam');
	my @reply = $request->children('reply');
	my $firstxid;

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
					my $capxid = $xidtmp;
					$capxid =~ s/(\w+)/\u\L$1/g;
					#$rtype = ("XCB" . $xidtmp);
					if($xidtmp eq "CHARINFO") {
						$rtype = ("XCB" . $xidtmp);
					}
					else {
						$rtype = "ObjXCB$capxid *";
					}
				}
			}
			print $repfh "- \($rtype\)get_$repfield->{'att'}->{'name'};\n";	
		}

		print $repfh "\@end\n";

		#include us in objxproto.h
		open(my $xprotofh,">>","objxproto.h") or die("Couldn't open objxproto.h");
		print $xprotofh '#import <' . "objxcb_$repnamefull.h" . ">\n";
		close($xprotofh);

		#output the correct method declaration now
		print $headerfh '- (' . "ObjXCB$request->{'att'}->{'name'}Reply *" . "\)$request->{'att'}->{'name'}";
	}

	#for all the regular fields
	foreach my $field (@fields) {
		my $ftype = $field->{'att'}->{'type'};
		
		#print $field->{'att'}->{'name'};
		if(!defined $field) {
			next;
		}
		
		#if the type of this field is the type we want, and this is the first one, skip it, we keep it inside the object
		if(($ftype eq $ARGV[0]) and !defined $firstxid) {
			$firstxid = 0;
			next;
		}

		foreach my $xidtmp (@xids) {
			#if its an xid. we need to Objectify its name to the form ObjXCBXid
			if($ftype eq $xidtmp) {
				my $capxid = $xidtmp;
				$capxid =~ s/(\w+)/\u\L$1/g;
				#$ftype = ("XCB" . $xidtmp);
				$ftype = "ObjXCB$capxid *";
			}
		}

		print $headerfh ":\($ftype\)$field->{'att'}->{'name'}";	
	}

	foreach my $vparam (@valueparam) {
		my $vtype = $vparam->{'att'}->{'value-mask-type'};

		foreach my $xidtmp (@xids) {
			#if its an xid. we need to Objectify its name to the form ObjXCBXid
			if($vtype eq $xidtmp) {
				my $capxid = $xidtmp;
				$capxid =~ s/(\w+)/\u\L$1/g;
				$vtype = "ObjXCB$capxid *";
			}
		}
		
		print $headerfh ":\($vtype\)$vparam->{'att'}->{'value-mask-name'}";
		print $headerfh ":\($vtype *\)$vparam->{'att'}->{'value-list-name'}";
	}

	print $headerfh ";\n";
}
0;
