#! /bin/sh
set +o noclobber
#
#   $1 = scanner device
#   $2 = friendly name
#

#   
#       100,200,300,400,600
#
resolution=100
device=$1
mkdir -p ~/brscan
if [ "`which usleep`" != '' ];then
    usleep 10000
else
    sleep  0.01
fi
output_file=`mktemp ~/brscan/brscan.XXXXXX`
echo "Emulating 'scan to ocr' by pushing into FreeMED scan_import"
echo "scan from $2($device) to $output_file"
scanimage --device-name "$device" --resolution $resolution> $output_file
/usr/share/scan_import/convert_and_import_pdf.sh "$output_file"
rm -f $output_file

