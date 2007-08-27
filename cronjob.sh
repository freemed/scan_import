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

#------------ Settings ------------

MIN_AGE=120
SCAN_PATH=/home/scan
KEEP_PATH=/root/keep-pdf

#------------ Do not touch below this line ----------------
NOW=$( date +%s )
WHEREAMI=$( dirname "$0" )
TMP_PATH="${WHEREAMI}/spool/${NOW}"
LOCKFILE="/var/run/scan_import.cron"

function log () {
	echo "$(date)| $1"
}

log "Beginning cron run"

log "Checking for lock..."
if [ -f "${LOCKFILE}" ]; then
	log "Lock file '${LOCKFILE}' exists, skipping run"
	exit 1
else
	log "Creating lock file '${LOCKFILE}'"
	touch "${LOCKFILE}"
fi

mkdir -p "${TMP_PATH}"

ls -1 "${SCAN_PATH}/" | grep -iE '\.doc$' | while read I; do
	#----- Check for timestamp
	TS=$( stat -c %Y "${SCAN_PATH}/${I}" )
	DIFF=$(( $NOW - $TS ))

	if [ $DIFF -ge $MIN_AGE ]; then
		log "Importing ${I}"
		log "Converting '${SCAN_PATH}/${I}' -> '${TMP_PATH}/${I}.pdf'"
		wvPDF "${SCAN_PATH}/${I}" "${TMP_PATH}/${I}.pdf"
		( cd "${TMP_PATH}" ; "${WHEREAMI}/convert_and_import_pdf.sh" "${I}.pdf" )
		mkdir -p "${KEEP_PATH}/"
		mv "${SCAN_PATH}/${I}" "${KEEP_PATH}/" -v
	else
		log "Ignoring ${I}, less than ${MIN_AGE} seconds old."
	fi
done

ls -1 "${SCAN_PATH}/" | grep -iE '\.pdf$' | while read I; do
	#----- Check for timestamp
	TS=$( stat -c %Y "${SCAN_PATH}/${I}" )
	DIFF=$(( $NOW - $TS ))

	if [ $DIFF -ge $MIN_AGE ]; then
		log "Importing ${I}"
		mv "${SCAN_PATH}/${I}" "${TMP_PATH}/" -v
		( cd "${TMP_PATH}" ; "${WHEREAMI}/convert_and_import_pdf.sh" "${I}" )
	else
		log "Ignoring ${I}, less than ${MIN_AGE} seconds old."
	fi
done

log "Cleaning up ..."
rmdir -v "${TMP_PATH}"
rm -v "${LOCKFILE}"

log "FINISHED CRON RUN"

