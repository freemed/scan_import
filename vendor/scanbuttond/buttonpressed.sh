#!/bin/sh
# $Id$
#
# Authors:
#      Jeff Buchbinder <jeff@freemedsoftware.org>
#
# FreeMED Electronic Medical Record and Practice Management System
# Copyright (C) 1999-2008 FreeMED Software Foundation
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

DEVICE="$1"
OUTPUT="$2"

DEVSUM=$( echo "$2" | md5sum -t | cut -c1-16 )
TMPFILE="/tmp/scan.${DEVSUM}.tiff"
LOCKFILE="/tmp/copy.${DEVSUM}.lock"
output_file="/tmp/scan.$(date +%Y%m%d%H%M).${RANDOM}.pdf"

logger -t scanbuttond "Got key press [$1] on device '$2'"

case $1 in
	*)
		if [ -f "${LOCKFILE}" ]; then
		  logger -t scanbuttond "Button pressed, but operation is already in progress."
		  exit
		fi
		touch $LOCKFILE
		rm -f $TMPFILE
		scanimage --device-name "$2" --format tiff --mode Gray \
			--resolution 300 --sharpness 0 --brightness -3 \
			--gamma-correction "High contrast printing" > "${TMPFILE}"
		tiff2pdf -z -w 8.5 -h 11 "${TMPFILE}" > ${output_file}
		rm -f "${LOCKFILE}" "${TMPFILE}"
		logger -t scanbuttond "Created file '${output_file}' with PDF"
		/usr/share/scan_import/convert_and_import_pdf.sh "${output_file}"
		logger -t scanbuttond "Completed processing of ${output_file}"
		;;
esac



