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

#	Scanner import via FTP daemon using FAM

use FindBin;
use lib "$FindBin::Bin/../freemed/lib/perl";
my $rootpath = $FindBin::Bin;

use SGI::FAM;
use File::Basename;
use File::Glob ':globally';
use Sys::Syslog;
use Getopt::Long;
use POSIX qw(setsid);

my $options;
my $debug;
$options->{'watch'} = "/home/scan";
my $_opt = GetOptions (
	$options,
	'watch=s',
	'debug',
	'fax',
	'help'
);

if (defined($options->{'help'})) {
	print "\t$0 [--watch=watchdir] [--fax] [--debug] [--help]\n";
	exit 0;
}

openlog("scan_import", "cons,pid", "user");

if (defined($options->{'debug'})) {
	$debug = 1;
	syslog("info", "debug on");
} else {
	$debug = 0;
	syslog("info", "debug off");
}

# Make sure there is only one copy of this running
my $processes = `ps ax | grep -v grep | grep -v "^ $$ " | grep -v "^$$ " | grep "$0"`;
if ($processes) {
	print $processes;
	syslog("info", "Found a process running; terminating current attempt");
	exit;
}

my $_handlers;

sub trim { my $string = shift; for ($string) { s/^\s+//; s/\s+$//; } return $string; }
sub register_handler {
	my $regex = shift;
	my $function = shift;
	$_handlers->{$regex} = $function;
}
sub file_open {
	my $file = shift;
	my $lsof = `lsof | grep "$file"`;
	$lsof = trim($lsof);
	if (length($lsof) > 1) {
		return 1;
	} else {
		return 0;
	}
}

# Load handlers
my @handlers = <$rootpath/handlers/*.pl>;
foreach my $handler (@handlers) {
	require $handler;
	syslog("info", "registered handler ".basename($handler));
}

sub daemonize {
	open STDIN, '/dev/null'   or die "Can't read /dev/null: $!";
	open STDOUT, '>>/dev/null' or die "Can't write to /dev/null: $!";
	open STDERR, '>>/dev/null' or die "Can't write to /dev/null: $!";
	defined(my $pid = fork)   or die "Can't fork: $!";
	exit if $pid;
	setsid                    or die "Can't start a new session: $!";
	umask 0;
}

&daemonize;

my $fam = new SGI::FAM;
$fam->monitor($options->{'watch'});
$fam->monitor('/var/spool/hylafax/recvq') if ($options->{'fax'});
while (1) {
	my $event = $fam->next_event;
	syslog("info", "DEBUG: event ".$event->type.", filename = ".$event->filename.", which = ".$fam->which($event)) if ($debug);
	if (-f $fam->which($event).'/'.$event->filename and ($event->type eq 'create' or $event->type eq 'exist')) {
		syslog("info", "DEBUG: caught ".$event->type." event for '".$event->filename."'") if ($debug);
		while (file_open($event->filename)) { 
			syslog("info", "DEBUG: ".$event->filename." is still open, waiting for it to be available") if ($debug);
			sleep 1;
		}
		my $has_been_handled = 0;
		foreach my $thisone (keys %$_handlers) {
			syslog("info", "DEBUG: trying handler $thisone") if ($debug);
		       	if ($event->filename =~ /$thisone/ and !$has_been_handled) {
				$has_been_handled = 1;
				$_handlers->{$thisone}($fam->which($event), $event->filename);
			}
		}
		if (!$has_been_handled) {
			syslog("info", "file ".$event->filename." has not been handled");
		}
	} else {
		#	This is FAR TOO VERBOSE!
		#syslog("info", "DEBUG: ignored event '".$event->type." / ".$event->filename."'");
	}
}

