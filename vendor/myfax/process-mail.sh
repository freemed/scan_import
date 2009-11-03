#!/bin/bash
#
#	$Id$
#

# Get mail
fetchmail --timeout 30

if [ ! -r "/var/spool/mail/${USER}" ]; then
	echo "Nothing, existing." | logger -t "process-mail"
	exit
fi

# Move mail spool local
sudo mv "/var/spool/mail/$USER" /home/$USER/mspool
cp /home/$USER/mspool /home/$USER/backup/mspool.$(date +%s)

# Extract attachments
sudo /home/$USER/extractattach.pl /home/$USER/mspool

rm /home/$USER/mspool -f

