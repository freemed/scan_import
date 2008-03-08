#! /bin/sh
set +o noclobber
#
#   $1 = scanner device
#   $2 = friendly name
#

#   
#       100,200,300,400,600
#
resolution=200
device=$1

logger -t brscan-skey "Instantiated scan key driver [OCR]"

if [ "$device" == "" ]; then
	logger -t brscan-skey "No parameters, exiting."
	exit 1
fi

logger -t brscan-skey "Called with $1 / $2"

mkdir -p ~/.brscan
if [ "`which usleep`" != '' ];then
    usleep 10000
else
    sleep  0.01
fi
output_file=$( mktemp ~/.brscan/brscan.XXXXXX )
echo "Emulating 'scan to ocr' by pushing into FreeMED scan_import"
echo "scan from $2($device) to $output_file"
scanimage --device-name "$device" --resolution $resolution > $output_file
logger -t brscan-skey "Created file ${output_file} with PPM data"
logger -t brscan-skey "Converting to PDF using imagemagic ... "
convert "${output_file}" "${output_file}.pdf"
logger -t brscan-skey "Created file ${output_file}.pdf with PDF"
/usr/share/scan_import/convert_and_import_pdf.sh "${output_file}.pdf"
rm -f "${output_file}" "${output_file}.pdf"
logger -t brscan-skey "Completed processing of ${output_file}"

