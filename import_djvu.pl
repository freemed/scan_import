#!/usr/bin/perl
# $Id$
#
# Authors:
#      Jeff Buchbinder <jeff@freemedsoftware.org>
#
# FreeMED Electronic Medical Record and Practice Management System
# Copyright (C) 1999-2007 FreeMED Software Foundation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

use FindBin;
use lib "$FindBin::Bin/../lib/perl";
my $rootpath = "$FindBin::Bin";

# Libraries for configuration
use Config::IniFiles;

# Transport
use FreeMED::Relay;

# First, we get the name of the tiff image
my $original = shift || die "No DjVu image filename given!\n";
print "Fax Import ------\n";
print "original file name = $original\n";

my $config = new Config::IniFiles ( -file => $rootpath.'/freemed.ini' );

# Initialize relay
my $f = FreeMED::Relay->new( debug => $config->val('freemed', 'debug') );
$f->set_credentials(
	$config->val('freemed', 'url'),
	$config->val('freemed', 'username'),
	$config->val('freemed', 'password'),
);
if ( ! $f->login() ) {
	print "Could not login!\n";
	exit;
}

# Store the name of the fax file
my $document = $original;
my $local_filename = `basename "$document"`;
$local_filename =~ s/\n//g;
my $path = $config->val('freemed', 'path'); 
print "document = $document, local filename = $local_filename, path = $path\n";

chomp ( my $dt = `date +%Y-%m-%d` );

my $result = $f->call(
	'org.freemedsoftware.module.UnfiledDocuments.add',
	{
		'uffdate' => $dt
	},
	{ '@var' => 'file', '@filename' => $local_filename }
);
print "result = ".Dumper($result)."\n";

# Remove *original* document (tiff)
if ( $config->val( 'freemed', 'archive' ) ) {
	system( "mv '${original}' '".$config->val( 'freemed', 'archive' )."' " );
} else {
	#print "Removing original file\n";
	#unlink($original);
}

