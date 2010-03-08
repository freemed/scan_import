#!/usr/bin/perl
# $Id$
#
# Authors:
#      Jeff Buchbinder <jeff@freemedsoftware.org>
#
# FreeMED Electronic Medical Record and Practice Management System
# Copyright (C) 1999-2010 FreeMED Software Foundation
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
##use lib "$FindBin::Bin/../lib/perl";
my $rootpath = "$FindBin::Bin";

# Libraries for configuration
use Config::IniFiles;
use Sys::Syslog;
use Data::Dumper;

# Transport
use FreeMED::Relay;

openlog("import_djvu", "cons,pid", "user");

# First, we get the name of the tiff image
my $original = shift || die "No DjVu image filename given!\n";
syslog( 'debug', "original file name = $original" );

if ( ! -r $original ) {
	syslog( 'err', "Unable to read $original, exiting cowardly" );
	exit 1;
}

my $config = new Config::IniFiles ( -file => $rootpath.'/freemed.ini' );

# Initialize relay
my $f = FreeMED::Relay->new( debug => $config->val('freemed', 'debug') );
$f->set_credentials(
	$config->val('freemed', 'url'),
	$config->val('freemed', 'username'),
	$config->val('freemed', 'password'),
);
if ( ! $f->login() ) {
	syslog( 'error', "Could not login!" );
	exit;
}

# Store the name of the fax file
my $document = $original;
chomp ( my $local_filename = `basename "$document"` );
my $path = $config->val('freemed', 'path'); 
syslog( 'debug', "document = $document, local filename = $local_filename, path = $path" );

chomp ( my $dt = `date +%Y-%m-%d` );

my $result = $f->call(
	'org.freemedsoftware.module.UnfiledDocuments.add',
	{
		'uffdate' => $dt
	},
	{ '@var' => 'file', '@filename' => $local_filename }
);
syslog( 'debug', "result = ".Dumper($result) );

# Remove *original* document (tiff)
if ( $config->val( 'freemed', 'archive' ) ) {
	syslog( 'info', "Archiving original file to ". $config->val( 'freemed', 'archive' ) );
	system( "mv '${original}' '".$config->val( 'freemed', 'archive' )."' " );
} else {
	syslog( 'info', "Removing original file" );
	unlink($original);
}

