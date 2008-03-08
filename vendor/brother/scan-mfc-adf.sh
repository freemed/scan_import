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

RESOLUTION=150

if [ $# -ne 1 ]; then
	echo "syntax: $(basename "$0") output.pdf"
	exit
fi

TMPDIR=/tmp/$(basename "$0")-$$.$(date +%s)

mkdir -p "${TMPDIR}"

scanadf \
	--verbose \
	--output-file "${TMPDIR}/image-%d.pnm" \
	--source "Automatic Document Feeder" \
	--mode Gray \
	--resolution "${RESOLUTION}"

# encode
echo "Encoding ..."
i=1
for P in ${TMPDIR}/*.p?m; do
	echo "Source = $P -> $P.tif"
	pnmtotiff -g3 "$P" > "$P.tif"
	ls -l "$P.tif"

	#tesseract "${P}.tif" "${P}.tif"
	#echo "---BEGIN PAGE: $i ---" >> ${TMPDIR}/ocr.txt
	#cat "${P}.txt" >> ${TMPDIR}/ocr.txt
	#echo "---END PAGE: $1 ---" >> ${TMPDIR}/ocr.txt
	#i=$(( $i + 1 ))
done

tiffcp -c lzw ${TMPDIR}/*.tif ${TMPDIR}/output.tif
tiff2pdf ${TMPDIR}/output.tif > "$1"
#cp -f "${TMPDIR}/ocr.txt" "$1.txt"

rm -rf "${TMPDIR}/"

