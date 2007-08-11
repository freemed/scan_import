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

register_handler (qw/\.pdf$/, \&import_pdf);
register_handler (qw/\.PDF$/, \&import_pdf);

sub import_pdf {
	my $watch = shift;
	my $orig = shift;
	my $filename = $orig;
	$filename = trim(basename($filename));
	syslog ("info", "importing $filename in $watch");
	`sleep 3`;
	`mkdir -p /usr/share/scan_import/spool`;
	`mv "$watch/$orig" "/usr/share/scan_import/spool/$filename"`;
	`( cd /usr/share/scan_import/spool; sleep 3; /usr/share/scan_import/convert_and_import_pdf.sh "$filename" )`;
	syslog ("info", "import complete for file $filename");
}

