#!/usr/bin/perl -w
use strict;

#Generates output source code from xproto.xml
#Arguments: xid,xml to use as input, whether to do orphans or not,and any "prefix" after ObjXCB, for extensions.

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
sub output_method_source($$);
sub output_decl($$$);
sub end_class_header($);
sub end_class_source($);
sub request_handle();
sub output_orphans();

my $headerfh;
my $sourcefh;

my @xids;
my @orphans;
my $orphan;
my $orphanct = 0;

#create the output filenames
my $xid = $ARGV[0];
$xid =~ tr/A-Z/a-z/;
my $outfile = "xcb_" . $xid;

my $outheaderfile = $outfile . ".h";
my $outsourcefile = $outfile . ".m";

my $inherits = "Object";

if($ARGV[2] == 1) {
	$orphan = defined;
}

my $prefix;

if(!defined $ARGV[3]) {
	$prefix = "";
}
else {
	$prefix = $ARGV[3];
}

if($ARGV[0] eq "WINDOW" or $ARGV[0] eq "PIXMAP") {
	$inherits = "ObjXCBDrawable";
}

start_class_header($outheaderfile);
start_class_source($outsourcefile,$outheaderfile);

#create twig
my $twig = XML::Twig->new(twig_handlers=> {
		xidtype => \&xid_handle,
		union => \&xid_handle,
#	struct => \&xid_handle,
		request => \&request_handle
		});

$twig->parsefile($ARGV[1]);
$twig->purge;

end_class_header($outheaderfile);
end_class_source($outsourcefile);

if(defined $orphan) {
	output_orphans();
}


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
	my $isxid = undef;
	my $lastreqname;

	my @fields = $section->children('field');
	my %numeachtype;

	#orphan
	if(!@fields) {
		if(defined $orphan) {
#			print $section->{'att'}->{'name'}. "\n";
			$orphans[$orphanct++] = $section;
		}
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

	#orphan
	if(!defined $firstxid) {
		if(defined $orphan) {
#			print $section->{'att'}->{'name'} . "\n";
			$orphans[$orphanct++] = $section;
		}
		return;
	}
	
	#it might belong here
	if($firstxid eq $ARGV[0]) {
		my @values = (values %numeachtype);
		if($section->{'att'}->{'name'} =~ /grab/ig or $section->{'att'}->{'name'} =~ /pointer/ig or $section->{'att'}->{'name'} =~ /event/ig
#		or $section->{'att'}->{'name'} =~ /translate/ig or $section->{'att'}->{'name'} =~ /selection/ig) {
		) {
			if(defined $orphan) {
#				print $section->{'att'}->{'name'} . "\n";			
				$orphans[$orphanct++] = $section;
			}
			return;
		}

		if($section->{'att'}->{'name'} =~ /$firstxid/ig) {
			$lastreqname = $section->{'att'}->{'name'};
			output_method_header($xid,$section);
			output_method_source($xid,$section);
			return;
		}

		#see if the number of any other field type is higher than how many of the first xid		
		#	foreach my $num (@values) {
			#then there is only one way for it to redeem itself...
		#	if($num > $numfirstxid){
		#		if($firstxid eq "WINDOW" and $section->{'att'}->{'name'} eq "ClearArea") {
		#			$lastreqname = $section->{'att'}->{'name'};
		#			output_method_header($xid,$section);
		#			output_method_source($xid,$section);
		#			return;
		#		}
				#send off to the orphan script
		#		return;
		#	}
		#}
		
		$lastreqname = $section->{'att'}->{'name'};
		output_method_header($xid,$section);
		output_method_source($xid,$section);
		return;
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

	#interface declaration 
	print $headerfh "\@interface ObjXCB$capxid : $inherits \n{\n";

	#variables
	if($ARGV[0] ne "WINDOW" or $ARGV[0] ne "PIXMAP") {
		print $headerfh "\tXCB$ARGV[0]" . ' xid;' . "\n";
		print $headerfh "\t" . 'ObjXCBConnection *c;' . "\n";
	}
	print $headerfh "\n}\n";

	#most classes have init and free
#if($ARGV[0] ne "DRAWABLE" and $ARGV[0] ne "FONTABLE") {
		print $headerfh '/** Creates a new XID and initializes the object. */' . "\n";
		print $headerfh '- (id)init:(ObjXCBConnection *)c;' . "\n";
		print $headerfh '/** Takes in an XID and initializes the object. */' . "\n";
		print $headerfh '- (id)init:(ObjXCBConnection *) c:(' . "XCB$ARGV[0]" . ')xid;' . "\n";
		print $headerfh '/** Returns the XID the object represents. */' . "\n";
		print $headerfh '- (' . "XCB$ARGV[0]\)get_xid;\n";
		print $headerfh '- free;' . "\n";
#	}
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
	print $sourcefh "\@implementation ObjXCB$prefix$capxid : $inherits \n\n";
	
	if($ARGV[0] eq "WINDOW" or $ARGV[0] eq "PIXMAP") {
		my $var;
		if($ARGV[0] eq "WINDOW") {
			$var = "window";
		}
		else {
			$var = "pixmap";
		}
		print $sourcefh '- (id)init:(ObjXCBConnection *)c' . "\n" . '{' . "\n" .
			"\t" . 'self->c = c;'. "\n" .
			"\t" . 'self->xid.' . "$var" . ' = XCB'.$ARGV[0] . 'New([self->c get_connection]);' . "\n" . '}' . "\n\n";
		print $sourcefh '- (id)init:(ObjXCBConnection *)c:(' . "XCB$ARGV[0]" . ')xid;' . "\n" . '{' . "\n" .
			"\t" . 'self->c = c;'. "\n" .
			"\t" . 'self->xid.' . "$var" . ' = xid;' . "\n" . '}' . "\n\n";
		print $sourcefh '- (' . "XCB$ARGV[0]\)get_xid\n" . '{' . "\n" .
			"\t" . 'return self->xid.' . "$var" . ';' . "\n" . '}' . "\n\n";
		print $sourcefh '- free' . "\n" . '{' . "\n" .
			"\t" . 'self->c = NULL;' . "\n" . '[super free];' . "\n" . '}' . "\n\n";
		return;
	}

	if($ARGV[0] ne "DRAWABLE" and $ARGV[0] ne "FONTABLE") {
		print $sourcefh '- (id)init:(ObjXCBConnection *)c' . "\n" . '{' . "\n" .
			"\t" . 'self->c = c;'. "\n" .
			"\t" . 'self->xid = XCB'.$ARGV[0] . 'New([self->c get_connection]);' . "\n" . '}' . "\n\n";
		print $sourcefh '- (id)init:(ObjXCBConnection *)c:(' . "XCB$ARGV[0]" . ')xid;' . "\n" . '{' . "\n" .
			"\t" . 'self->c = c;'. "\n" .
			"\t" . 'self->xid = xid;' . "\n" . '}' . "\n\n";
		print $sourcefh '- (' . "XCB$ARGV[0]\)get_xid\n" . '{' . "\n" .
			"\t" . 'return self->xid;' . "\n" . '}' . "\n\n";
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

sub output_method_header($$)
{ my($xid,$request) = @_;
	
	my @fields = $request->children('field');
	my @valueparam = $request->children('valueparam');
	my @reply = $request->children('reply');
	my @list = $request->children('list');
	my $firstxid;

	if(!@reply) {
		print $headerfh '- (void)' . "$request->{'att'}->{'name'}";
	}
	else {	
		#create a new header file for the reply
		my @repfields = $reply[0]->children('field');
		my @replist = $reply[0]->children('list');
		my $repname = $request->{'att'}->{'name'};
		$repname =~ tr/A-Z/a-z/;
		my $repnamefull = $repname . "reply";

		open(my $repfh,">","objxcb_$repnamefull.h") or die("Couldn't open file.");
		print $repfh $copyright;
		print $repfh "\@interface ObjXCB$prefix$request->{'att'}->{'name'}Reply : Object\n{\n";
		print $repfh "\tXCB$request->{'att'}->{'name'}" . "Cookie repcookie;\n";
		print $repfh "\tXCB$request->{'att'}->{'name'}" . "Rep *reply;\n";
		print $repfh "\tObjXCBConnection *c;\n";
		print $repfh "\tunsigned int got_rep;\n}\n\n";
		
		#constructor and deconstructor
		print $repfh "- \(id\)init:\(ObjXCBConnection *\)c:\(XCB$request->{'att'}->{'name'}Cookie\)repcookie;\n";
		print $repfh "- \(void\)free;\n";

		foreach my $repfield (@repfields) {
			my $rtype = $repfield->{'att'}->{'type'};
			foreach my $xidtmp (@xids) {
				if($rtype eq $xidtmp) {
					my $capxid = $xidtmp;
					$capxid =~ s/(\w+)/\u\L$1/g;
					$rtype = "ObjXCB$capxid *";
				}
			}
			print $repfh "- \($rtype\)get_$repfield->{'att'}->{'name'};\n";	
		}

		foreach my $lfield (@replist) {
			my $ltype = $lfield->{'att'}->{'type'};
			
			#if its an xid, we need to Objectify its name to the form ObjXCBXid
			foreach my $xidtmp (@xids) {
				if($ltype eq $xidtmp) {
					my $capxid = $xidtmp;
					$capxid =~ s/(\w+)/\u\L$1/g;
					$ltype = "ObjXCB$capxid *";
				}
			}
			print $repfh "- \($ltype*\)get_$lfield->{'att'}->{'name'};\n";
		}

		print $repfh "\@end\n";

		#include us in objxproto.h
		open(my $xprotofh,">>","objxproto.h") or die("Couldn't open objxproto.h");
		print $xprotofh '#import "' . "objxcb_$repnamefull.h" . "\"\n";
		close($xprotofh);

		#output the correct method declaration now
		print $headerfh '- (' . "ObjXCB$prefix$request->{'att'}->{'name'}Reply *" . "\)$request->{'att'}->{'name'}";
	}

	output_decl($headerfh,$request,"el");
	
	print $headerfh ";\n";
}

sub output_method_source($$)
{ my ($xid, $request) = @_;
	
	my @fields = $request->children('field');
	my @valueparam = $request->children('valueparam');
	my @reply = $request->children('reply');
	my @list = $request->children('list');
	my $firstxid;
	my $isxid;

	if(!@reply) {
		print $sourcefh '- (void)' . "$request->{'att'}->{'name'}";
	}
	else {	
		print $sourcefh "- \(ObjXCB$prefix$request->{'att'}->{'name'}Reply *\) $request->{'att'}->{'name'}";
	}

	#output parameters
	
	output_decl($sourcefh,$request,"el");

	print $sourcefh "\n{\n";
	
	if(@reply) {
		#create the source file for the reply
		my @repfields = $reply[0]->children('field');
		my @replist = $reply[0]->children('list');
		my $repname = $request->{'att'}->{'name'};
		$repname =~ tr/A-Z/a-z/;
		my $repnamefull = $repname . "reply";
		my $isxid;

		open(my $repsourcefh,">","objxcb_$repnamefull.m") or die("Couldn't open file.");
		print $repsourcefh '#include "obj-xcb.h"' . "\n\n";
		print $repsourcefh '@implementation ObjXCB' . "$prefix$request->{'att'}->{'name'}Reply : Object\n\n";
	
		#constructor and deconstructor
		print $repsourcefh "- \(id\)init:\(ObjXCBConnection *)c:\(XCB$prefix$request->{'att'}->{'name'}Cookie\)repcookie\n{\n";
		print $repsourcefh "\tself->repcookie = repcookie;\n\tself->reply=NULL;\n\tself->got_rep = 0;\n\tself->c = c;\n}\n\n";
		print $repsourcefh "- \(void\)free\n{\n\tif(self->reply) {\n\t\tfree\(self->reply\);\n\t}\n\t[super free];\n}\n\n";

		foreach my $repfield (@repfields) {
			my $rtype = $repfield->{'att'}->{'type'};
			my $rtypenonpoint;
			foreach my $xidtmp (@xids) {
				if($rtype eq $xidtmp) {
					my $capxid = $xidtmp;
					$capxid =~ s/(\w+)/\u\L$1/g;
					$rtype = "ObjXCB$capxid *";
					$rtypenonpoint = "ObjXCB$capxid";
				}
			}
			#TODO: ERROR HANDLING
			print $repsourcefh "- \($rtype\)get_$repfield->{'att'}->{'name'}\n{\n";
			print $repsourcefh "\t" . 'if(!self->got_rep) {' . "\n\t\t" . 'self->reply = XCB' . "$prefix$request->{'att'}->{'name'}Reply\(" . 
				'[self->c get_connection],self->repcookie,0);' . "\n\t\tself->got_rep = 1;" ."\n\t}\n";

			#figure out if its an xid, this determines how we need to return
			$isxid = undef;
			foreach my $xidtmp (@xids) {
				if($repfield->{'att'}->{'type'} eq $xidtmp) {
					$isxid = defined;
					last;
				}
			}

			if(!defined $isxid) {
				my $rname = $repfield->{'att'}->{'name'};

				if($rname eq "class") {
					$rname = "_$rname";
				}
				
				print $repsourcefh "\n\treturn self->reply->$rname;";
			}
			else {
				print $repsourcefh "\n\t$rtype repobj = [$rtypenonpoint alloc];\n\t[repobj init:self->c:self->reply->$repfield->{'att'}->{'name'}];\n";
				print $repsourcefh "\treturn repobj;";
			}

			print $repsourcefh "\n}\n\n";
			
		}
		
		foreach my $lfield (@replist) {
			my $ltype = $lfield->{'att'}->{'type'};
			
			#if its an xid, we need to Objectify its name to the form ObjXCBXid
			foreach my $xidtmp (@xids) {
				if($ltype eq $xidtmp) {
					my $capxid = $xidtmp;
					$capxid =~ s/(\w+)/\u\L$1/g;
					$ltype = "ObjXCB$capxid *";
				}
			}
			print $repsourcefh "- \($ltype*\)get_$lfield->{'att'}->{'name'}\n{\n";

			print $repsourcefh "\n}\n\n";
		}

		print $repsourcefh "\n" . '@end';

		#now put code in the method to access the reply
		print $sourcefh "\tObjXCB$request->{'att'}->{'name'}Reply *rep = [ObjXCB$prefix$request->{'att'}->{'name'}Reply alloc];\n";
		print $sourcefh "\t[rep init:self->c:XCB$request->{'att'}->{'name'}\([self->c get_connection]";
		
		foreach my $field (@fields) {
			#if its the first xid, we have it stored within the object
			if(($field->{'att'}->{'type'} eq $ARGV[0]) and !defined $firstxid) {
				$firstxid = defined;
				if($ARGV[0] eq "WINDOW" or $ARGV[0] eq "PIXMAP") {
					print $sourcefh ',[self get_xid]';
				}
				else {
					print $sourcefh ',self->xid';
				}
			}
			else {
				foreach my $xid (@xids) {
					#if its an xid, output code to get it from the object.
					if($xid eq $field->{'att'}->{'type'}) {
						print $sourcefh ",[$field->{'att'}->{'name'} get_xid]";
						$isxid = defined;
					}
				}
				if(!defined $isxid) {
					print $sourcefh ",$field->{'att'}->{'name'}";
				}
				$isxid = undef;

			}
		}
		
		foreach my $lfield (@list) {
			my @lfref = $lfield->children('fieldref');
			my @lop = $lfield->children('op');
			if(@lop) {
				@lop = $lop[0]->children('op');
			}

			if(!@lfref and !@lop) {
				print $sourcefh ",$lfield->{'att'}->{'name'}_len";
			}

			print $sourcefh ",$lfield->{'att'}->{'name'}";
		}

		foreach my $vfield (@valueparam) {
			print $sourcefh ",$vfield->{'att'}->{'value-mask-name'}";
			print $sourcefh ",$vfield->{'att'}->{'value-list-name'}";
		}

		print $sourcefh "\)];\n";
		print $sourcefh "\treturn rep;";
	}
	else {
		$isxid = undef;
		print $sourcefh "\t" . "XCB$prefix$request->{'att'}->{'name'}" . '([self->c get_connection]';

		foreach my $field (@fields) {
			#if its the first xid, we have it stored within the object
			if(($field->{'att'}->{'type'} eq $ARGV[0]) and !defined $firstxid) {
				$firstxid = defined;
				if($ARGV[0] eq "WINDOW" or $ARGV[0] eq "PIXMAP") {
					print $sourcefh ',[self get_xid]';
				}
				else {
					print $sourcefh ',self->xid';
				}
			}
			else {	
				foreach my $xid (@xids) {
					#if its an xid, output code to get it from the object.
					if($xid eq $field->{'att'}->{'type'}) {
						print $sourcefh ",[$field->{'att'}->{'name'} get_xid]";
						$isxid = defined;
					}
				}
				if(!defined $isxid) {
					print $sourcefh ",$field->{'att'}->{'name'}";
				}
				$isxid = undef;
			}
		}

		foreach my $lfield (@list) {
			my @lfref = $lfield->children('fieldref');
			my @lop = $lfield->children('op');
			if(@lop) {
				@lop = $lop[0]->children('op');
			}

			if(!@lfref and !@lop) {
				print $sourcefh ",$lfield->{'att'}->{'name'}_len";
			}

			print $sourcefh ",$lfield->{'att'}->{'name'}";
		}

		foreach my $vfield (@valueparam) {
			print $sourcefh ",$vfield->{'att'}->{'value-mask-name'}";
			print $sourcefh ",$vfield->{'att'}->{'value-list-name'}";
		}

		print $sourcefh "\);\n";
	}
	

	print $sourcefh "\n}\n\n";
}

sub output_decl($$$)
{ my ($fh, $request, $mythingy) = @_;

	my @fields = $request->children('field');
	my @valueparam = $request->children('valueparam');
	my @reply = $request->children('reply');
	my @list = $request->children('list');
	my $firstxid;

	#for all the regular fields
	foreach my $field (@fields) {
		my $ftype = $field->{'att'}->{'type'};
		
		#print $field->{'att'}->{'name'};
		if(!defined $field) {
			next;
		}
		
		#if the type of this field is the type we want, and this is the first one, skip it, we keep it inside the object
		if(($ftype eq $ARGV[0]) and !defined $firstxid and $mythingy ne "lucy") {
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

		print $fh ":\($ftype\)$field->{'att'}->{'name'}";	
	}

	#lists
	foreach my $lfield (@list) {
		my $ltype = $lfield->{'att'}->{'type'};
		my @lfref = $lfield->children('fieldref');
		my @lop = $lfield->children('op');
		if(@lop) {
			@lop = $lop[0]->children('op');
		}

		#if its an xid, we need to Objectify its name to the form ObjXCBXid
		foreach my $xidtmp (@xids) {
			if($ltype eq $xidtmp) {
				my $capxid = $xidtmp;
				$capxid =~ s/(\w+)/\u\L$1/g;
				$ltype = "ObjXCB$capxid *";
			}
		}
	
		if(!@lfref and !@lop and $request->{'att'}->{'name'} ne "SendEvent") {
			print $fh ":\(CARD16\)$lfield->{'att'}->{'name'}_len";
		}

		print $fh ":\($ltype *\)$lfield->{'att'}->{'name'}";
	}

	#valueparams
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
		
		print $fh ":\($vtype\)$vparam->{'att'}->{'value-mask-name'}";
		print $fh ":\($vtype *\)$vparam->{'att'}->{'value-list-name'}";
	}
}

sub output_orphans()
{
	my $ftype;
	my $isxid;
	my $firstxid;

	open(my $orphanfh,">","xcb_conn_orphan.h");

	#header
	print $orphanfh '@interface ObjXCBConnection (Orphan)' . "\n\n";
	
	foreach my $orphan (@orphans) {
		#these requests are weird, disable until i figure them out...
		if($orphan->{'att'}->{'name'} eq "ChangeKeyboardMapping" or $orphan->{'att'}->{'name'} eq "SetModifierMapping") {
			next;	
		}

		my @reply = $orphan->children('reply');
		if(!@reply) {
			print $orphanfh '- (void)' . "$orphan->{'att'}->{'name'}";		
		}
		else {
			#create a new header file for the reply
			my @repfields = $reply[0]->children('field');
			my @replist = $reply[0]->children('list');
			my $repname = $orphan->{'att'}->{'name'};
			$repname =~ tr/A-Z/a-z/;
			my $repnamefull = $repname . "reply";

			open(my $repfh,">","objxcb_$repnamefull.h") or die("Couldn't open file.");
			print $repfh $copyright;
			print $repfh "\@interface ObjXCB$orphan->{'att'}->{'name'}Reply : Object\n{\n";
			print $repfh "\tXCB$orphan->{'att'}->{'name'}" . "Cookie repcookie;\n";
			print $repfh "\tXCB$orphan->{'att'}->{'name'}" . "Rep *reply;\n";
			print $repfh "\tObjXCBConnection *c;\n";
			print $repfh "\tunsigned int got_rep;\n}\n\n";
			
			#constructor and deconstructor
			print $repfh "- \(id\)init:\(ObjXCBConnection *\)c:\(XCB$orphan->{'att'}->{'name'}Cookie\)repcookie;\n";
			print $repfh "- \(void\)free;\n";

			foreach my $repfield (@repfields) {
				my $rtype = $repfield->{'att'}->{'type'};
				foreach my $xidtmp (@xids) {
					if($rtype eq $xidtmp) {
						my $capxid = $xidtmp;
						$capxid =~ s/(\w+)/\u\L$1/g;
						$rtype = "ObjXCB$capxid *";
					}
				}
				print $repfh "- \($rtype\)get_$repfield->{'att'}->{'name'};\n";	
			}

			foreach my $lfield (@replist) {
				my $ltype = $lfield->{'att'}->{'type'};
				
				#if its an xid, we need to Objectify its name to the form ObjXCBXid
				foreach my $xidtmp (@xids) {
					if($ltype eq $xidtmp) {
						my $capxid = $xidtmp;
						$capxid =~ s/(\w+)/\u\L$1/g;
						$ltype = "ObjXCB$capxid *";
					}
				}
				print $repfh "- \($ltype*\)get_$lfield->{'att'}->{'name'};\n";
			
			}
			print $repfh "\@end\n";

			#include us in objxproto.h
			open(my $xprotofh,">>","objxproto.h") or die("Couldn't open objxproto.h");
			print $xprotofh '#import "' . "objxcb_$repnamefull.h" . "\"\n";
			close($xprotofh);

			#output the correct method declaration now
			print $orphanfh '- (' . "ObjXCB$orphan->{'att'}->{'name'}Reply *" . "\)$orphan->{'att'}->{'name'}";

			}
		output_decl($orphanfh,$orphan,"lucy");
		print $orphanfh ";\n";
	}

	print $orphanfh "\n" . '@end' . "\n";
	close($orphanfh);

	open($orphanfh,">","xcb_conn_orphan.m");

	#source
	print $orphanfh '#include "obj-xcb.h"' . "\n\n";
	print $orphanfh '@implementation ObjXCBConnection (Orphan)' . "\n\n";

	foreach my $orphan (@orphans) {
		#these requests are weird, disable until i figure them out...
		if($orphan->{'att'}->{'name'} eq "ChangeKeyboardMapping" or $orphan->{'att'}->{'name'} eq "SetModifierMapping") {
			next;	
		}

		my @reply = $orphan->children('reply');
		my @fields = $orphan->children('field');
		my @list = $orphan->children('list');
		my @valueparam = $orphan->children('valueparam');
		
		if(!@reply) {
			print $orphanfh '- (void)' . "$orphan->{'att'}->{'name'}";
		}
		else {	
			print $orphanfh "- \(ObjXCB$orphan->{'att'}->{'name'}Reply *\) $orphan->{'att'}->{'name'}";
		}

		output_decl($orphanfh,$orphan,"lucy");

		print $orphanfh "\n{\n";

		if(@reply) {
			#create the source file for the reply
			my @repfields = $reply[0]->children('field');
			my @replist = $reply[0]->children('list');
			my $repname = $orphan->{'att'}->{'name'};
			$repname =~ tr/A-Z/a-z/;
			my $repnamefull = $repname . "reply";
			my $isxid;

			open(my $repsourcefh,">","objxcb_$repnamefull.m") or die("Couldn't open file.");
			print $repsourcefh '#include "obj-xcb.h"' . "\n\n";
			print $repsourcefh '@implementation ObjXCB' . "$orphan->{'att'}->{'name'}Reply : Object\n\n";
		
			#constructor and deconstructor
			print $repsourcefh "- \(id\)init:\(ObjXCBConnection *)c:\(XCB$orphan->{'att'}->{'name'}Cookie\)repcookie\n{\n";
			print $repsourcefh "\tself->repcookie = repcookie;\n\tself->reply=NULL;\n\tself->got_rep = 0;\n\tself->c = c;\n}\n\n";
			print $repsourcefh "- \(void\)free\n{\n\tif(self->reply) {\n\t\tfree\(self->reply\);\n\t}\n\t[super free];\n}\n\n";

			foreach my $repfield (@repfields) {
				my $rtype = $repfield->{'att'}->{'type'};
				my $rtypenonpoint;
				foreach my $xidtmp (@xids) {
					if($rtype eq $xidtmp) {
						my $capxid = $xidtmp;
						$capxid =~ s/(\w+)/\u\L$1/g;
						$rtype = "ObjXCB$capxid *";
						$rtypenonpoint = "ObjXCB$capxid";
					}
				}
				#TODO: ERROR HANDLING
				print $repsourcefh "- \($rtype\)get_$repfield->{'att'}->{'name'}\n{\n";
				print $repsourcefh "\t" . 'if(!self->got_rep) {' . "\n\t\t" . 'self->reply = XCB' . "$orphan->{'att'}->{'name'}Reply\(" . 
					'[self->c get_connection],self->repcookie,0);' . "\n\t\tself->got_rep = 1;" ."\n\t}\n";

				#figure out if its an xid, this determines how we need to return
				$isxid = undef;
				foreach my $xidtmp (@xids) {
					if($repfield->{'att'}->{'type'} eq $xidtmp) {
						$isxid = defined;
						last;
					}
				}

				if(!defined $isxid) {
					my $rname = $repfield->{'att'}->{'name'};

					if($rname eq "class") {
						$rname = "_$rname";
					}
					
					print $repsourcefh "\n\treturn self->reply->$rname;";
				}
				else {
					print $repsourcefh "\n\t$rtype repobj = [$rtypenonpoint alloc];\n\t[repobj init:self->c:self->reply->$repfield->{'att'}->{'name'}];\n";
					print $repsourcefh "\treturn repobj;";
				}

				print $repsourcefh "\n}\n\n";
				
			}
			
			foreach my $lfield (@replist) {
				my $ltype = $lfield->{'att'}->{'type'};
				
				#if its an xid, we need to Objectify its name to the form ObjXCBXid
				foreach my $xidtmp (@xids) {
					if($ltype eq $xidtmp) {
						my $capxid = $xidtmp;
						$capxid =~ s/(\w+)/\u\L$1/g;
						$ltype = "ObjXCB$capxid *";
					}
				}
				print $repsourcefh "- \($ltype*\)get_$lfield->{'att'}->{'name'}\n{\n";

				print $repsourcefh "\n}\n\n";
			}

			print $repsourcefh "\n" . '@end';

			#now put code in the method to access the reply
			print $orphanfh "\tObjXCB$orphan->{'att'}->{'name'}Reply *rep = [ObjXCB$orphan->{'att'}->{'name'}Reply alloc];\n";
			print $orphanfh "\t[rep init:self:XCB$orphan->{'att'}->{'name'}\([self get_connection]";
			
			foreach my $field (@fields) {
				$isxid = undef;
				#if its the first xid, we have it stored within the object
#	if(($field->{'att'}->{'type'} eq $ARGV[0]) and !defined $firstxid) {
#					$firstxid = defined;
#					if($ARGV[0] eq "WINDOW" or $ARGV[0] eq "PIXMAP") {
#						print $orphanfh ',[self get_xid]';
#					}
#					else {
#						print $orphanfh ',self->xid';
#					}
#				}
#				else {
					foreach my $xid (@xids) {
						#if its an xid, output code to get it from the object.
						if($xid eq $field->{'att'}->{'type'}) {
							print $orphanfh ",[$field->{'att'}->{'name'} get_xid]";
							$isxid = defined;
						}
					}
					if(!defined $isxid) {
						print $orphanfh ",$field->{'att'}->{'name'}";
					}
					$isxid = undef;

#				}
			}
			
			foreach my $lfield (@list) {
				my @lfref = $lfield->children('fieldref');
				my @lop = $lfield->children('op');
				if(@lop) {
					@lop = $lop[0]->children('op');
				}

				if(!@lfref and !@lop) {
					print $orphanfh ",$lfield->{'att'}->{'name'}_len";
				}

				print $orphanfh ",$lfield->{'att'}->{'name'}";
			}

			foreach my $vfield (@valueparam) {
				print $orphanfh ",$vfield->{'att'}->{'value-mask-name'}";
				print $orphanfh ",$vfield->{'att'}->{'value-list-name'}";
			}

			print $orphanfh "\)];\n";
			print $orphanfh "\treturn rep;\n}\n\n";
		}
		###
		else {
			$isxid = undef;
			print $orphanfh "\t" . "XCB$orphan->{'att'}->{'name'}" . '([self get_connection]';

			foreach my $field (@fields) {
				#if its the first xid, we have it stored within the object
#		if(($field->{'att'}->{'type'} eq $ARGV[0]) and !defined $firstxid) {
#					$firstxid = defined;
#					print $orphanfh ',self->xid';
#				}
#				else {
					foreach my $xid (@xids) {
						#if its an xid, output code to get it from the object.
						if($xid eq $field->{'att'}->{'type'}) {
							print $orphanfh ",[$field->{'att'}->{'name'} get_xid]";
							$isxid = defined;
						}

					}
					if(!defined $isxid) {
						print $orphanfh ",$field->{'att'}->{'name'}";
					}
					$isxid = undef;
#				}
			}
				foreach my $lfield (@list) {
					my @lfref = $lfield->children('fieldref');
					my @lop = $lfield->children('op');
					if(@lop) {
						@lop = $lop[0]->children('op');
					}

					if(!@lfref and !@lop and $orphan->{'att'}->{'name'} ne "SendEvent") {
						print $orphanfh ",$lfield->{'att'}->{'name'}_len";
					}

					print $orphanfh ",$lfield->{'att'}->{'name'}";
				}

				foreach my $vfield (@valueparam) {
					print $orphanfh ",$vfield->{'att'}->{'value-mask-name'}";
					print $orphanfh ",$vfield->{'att'}->{'value-list-name'}";
				}
			
			print $orphanfh "\);\n}\n\n";
		}
	}

	print $orphanfh "\n" . '@end' . "\n";
	close($orphanfh);
}

0;
