#!/usr/bin/perl -w
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

register_handler (qw/\.(jpg|jpeg|png|gif|bmp)$/, \&import_image);

sub import_image {
	my $watch = shift;
	my $filename = shift;
	$filename = trim(basename($filename));
	syslog ("info", "converting $filename in $watch to PDF");
	`sleep 2`;
	`mkdir -p /usr/share/scan_import/spool/tmp`;
	`mv "$watch/$filename" "/usr/share/scan_import/spool/tmp/$filename"`;
	`( cd /usr/share/scan_import/spool/tmp; convert "$filename" "$filename.pdf" )`;
	`mv "/usr/share/scan_import/spool/tmp/$filename.pdf" "$watch/$filename.pdf"`;
	`rm -f "/usr/share/scan_import/spool/tmp/$filename"`;
	syslog ("info", "conversion complete for file $filename to PDF");
}

