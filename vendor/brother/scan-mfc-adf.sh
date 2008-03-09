#!/bin/bash
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

RESOLUTION=150

logger -t scan-mfc-adf "Instantiated with parameters $1 $2"

if [ $# -lt 2 ]; then
	echo "syntax: $(basename "$0") device-name output.pdf"
	exit
fi

TMPDIR=/tmp/$(basename "$0")-$$.$(date +%s)
logger -t scan-mfc-adf "Temporary directory = $TMPDIR"

mkdir -p "${TMPDIR}"

scanadf \
	--verbose \
	--device "${DEVICE}" \
	--output-file "${TMPDIR}/image-%d.pnm" \
	--source "Automatic Document Feeder" \
	--mode Gray \
	--resolution "${RESOLUTION}"

# encode
echo "Encoding ..."
i=1
for P in ${TMPDIR}/*.p?m; do
	logger -t scan-mfc-adf "Converting PNM $P to TIFF $P.tif"
	pnmtotiff -g3 "$P" > "$P.tif"
	logger -t scan-mfc-adf "DEBUG: $(ls -l "$P.tif")"

	#tesseract "${P}.tif" "${P}.tif"
	#echo "---BEGIN PAGE: $i ---" >> ${TMPDIR}/ocr.txt
	#cat "${P}.txt" >> ${TMPDIR}/ocr.txt
	#echo "---END PAGE: $1 ---" >> ${TMPDIR}/ocr.txt
	#i=$(( $i + 1 ))
done

logger -t scan-mfc-adf "Combining all TIFF pages into single TIFF document (${TMPDIR}/output.tif)"
tiffcp -c lzw ${TMPDIR}/*.tif ${TMPDIR}/output.tif
logger -t scan-mfc-adf "Converting ${TMPDIR}/output.tif to ${OUTPUT}"
tiff2pdf ${TMPDIR}/output.tif > "${OUTPUT}"
logger -t scan-mfc-adf "DEBUG: $(ls -l "${OUTPUT}")"
#cp -f "${TMPDIR}/ocr.txt" "${OUTPUT}.txt"

logger -t scan-mfc-adf "Cleaning up"
rm -rf "${TMPDIR}/"

