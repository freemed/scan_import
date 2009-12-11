#!/usr/bin/perl
#
#	$Id$
#

use MIME::Base64;

my $mbox = shift;

open MBOX, $mbox or die "Could not open $mbox: $!";

my %culprits=();
my %dates=();

my $sircam = 0;
my $address = "Unknown";
my $date = "Unknown";
my $boundary = "none";

while(my $line=<MBOX>)
{
	$line =~ m/^From: *(.*)/i and $address = $1;
	$line =~ m/^Date: *(.*)/i and $date = $1;

	if($line =~ m/^Content-Type: multipart\/mixed; *boundary="(.*)"/i)
	{
		$boundary=$1;
	}

	if($line =~ m/^Content-Type: [a-z]+\/pdf; name=(.*)/i ) {
		my $filename = $1;
		$filename =~ s/"//g;
		$filename =~ s/\s/_/g;

		$dates{$filename} = $date;
		# read on to start of base64
		while($line=<MBOX>) 
		{ 
			chomp $line;
			last if $line eq "";
		}
		&extractfile($filename);
	}
	if($line =~ m/^Content-Disposition: attachment; *filename=(.*)/i ) {
		my $filename = $1;
		$filename =~ s/"//g;
		$filename =~ s/\s/_/g;

		$dates{$filename} = $date;
		# read on to start of base64
		while($line=<MBOX>) 
		{ 
			chomp $line;
			last if $line eq "";
		}
		&extractfile($filename);
	}
}

sub extractfile
{
	my $fn = shift;
	my $tmp_fn = "/home/scan/$fn";
	my $ac_len = 0;        # accumlated length of decoded b64
	my $sc_len = 512*268;  # length of sircam virus 

	print "Writing $tmp_fn\n";
	open OUT, ">$tmp_fn" or die "Could not open $tmp_fn for writing: $!";

	while(<MBOX>)
	{
		last if $_ =~ /^\s*$/;
		print OUT decode_base64($_);
		
	}
	close OUT;

}

sub html_escape
{
	my $in=shift;
	$in =~ s/</&lt;/g;
	$in =~ s/>/&gt;/g;
	return $in;
}

