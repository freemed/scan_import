#! /bin/sh
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

PATH=/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/share/scan_import/scan_import.pl
NAME="scan_import"
DESC="FreeMED Scanner Import Bridge"

# Set flags here; need to move this to /etc/defaults/
FLAGS=""

# Don't run if not installed
test -f ${DAEMON} || exit 0

set -e

case "$1" in
  start)
	echo -n "Starting $DESC: "
	#start-stop-daemon --start --quiet --background --make-pidfile \
	#	--pidfile /var/run/$NAME.pid --exec $DAEMON -- $OPTIONS
	${DAEMON} ${FLAGS}
	echo "$NAME."
	;;
	
  stop)
	echo -n "Stopping $DESC: "
		#start-stop-daemon --stop --quiet --pidfile /var/run/$NAME.pid \
		#	--oknodo
		kill `cat /var/run/$NAME.pid` 2>&1 > /dev/null
		rm -f /var/run/$NAME.pid
	echo "$NAME."
	;;
	
  #reload)
	#
	#	If the daemon can reload its config files on the fly
	#	for example by sending it SIGHUP, do it here.
	#
	#	If the daemon responds to changes in its config file
	#	directly anyway, make this a do-nothing entry.
	#
	# echo "Reloading $DESC configuration files."
	# start-stop-daemon --stop --signal 1 --quiet --pidfile \
	#	/var/run/$NAME.pid --exec $DAEMON
  #;;
  
  restart|force-reload)
	#
	#	If the "reload" option is implemented, move the "force-reload"
	#	option to the "reload" entry above. If not, "force-reload" is
	#	just the same as "restart".
	#
	echo -n "Restarting $DESC: "
	$0 stop
	sleep 1
	$0 start
	echo "$NAME."
	;;
	
  *)
	N=/etc/init.d/$NAME
	echo "Usage: $N {start|stop|restart|force-reload}" >&2
	exit 1
	;;
esac

exit 0
