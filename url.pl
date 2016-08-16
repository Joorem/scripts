#!/usr/local/bin/perl
#
#

use strict;
use warnings;
use Getopt::Std;
use URI::Escape;

# opts
my %opts;
getopts('h', \%opts);
defined($opts{'h'}) and usage();

# vars
my $SEARCH = shift || '';
my $BASE_DIR = shift || '.';
my $BASE_URL = shift || 'https://joworld.net/storage/';

# subs
sub doURL {
  my $dir = shift;

  opendir(D, $dir) or return;
  my @files = grep { !/^\./ } readdir(D);
  closedir(D);

  @files = $dir eq $BASE_DIR ? @files : map { $dir . '/' . $_ } @files;
  foreach (sort @files) {
    if (-d $_) {
      doURL($_);
    } else {
      next if ((not /\.(flac|m4a|mkv|mp4|wav)$/) or (not /$SEARCH/i));

      print $BASE_URL.uri_escape($_, " ")."\n";
    }
  }
}

sub usage {
  print STDERR "$0 [<search>] [<directory>] [<url>]\n";

  exit 1;
}

# start
chdir($BASE_DIR);
doURL($BASE_DIR);
