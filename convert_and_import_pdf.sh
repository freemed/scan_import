#!/bin/bash
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

ORIG="$1"
TS=$(date +%s)

if [ ! -r "${ORIG}" ]; then
	echo "Could not open file '${ORIG}'";
	logger -t convert_and_import_pdf "Could not open file '${ORIG}', exiting."
	exit 1
fi

logger -t convert_and_import_pdf "Converting ${ORIG} into djvu image"
djvudigital --dpi=200 "${ORIG}" "${TS}.$(basename "${ORIG}").djvu" 2>&1
if [ -f "${ORIG}.txt" ]; then
	logger -t convert_and_import_pdf "Importing text into ${TS}.$(basename "${ORIG}").djvu"
	djvused "${TS}.$(basename "${ORIG}").djvu" -e "set-txt ${ORIG}.txt"
fi
logger -t convert_and_import_pdf "Importing ${TS}.$(basename "${ORIG}").djvu"
"$(dirname "$0")/import_djvu.pl" "${TS}.$(basename "${ORIG}").djvu"
rm -f "${ORIG}"
logger -t convert_and_import "Completed convert/import for ${ORIG}"

