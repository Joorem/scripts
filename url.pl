#!/usr/local/bin/perl
#
#

use strict;
use warnings;
use URI::Escape;

my $BASE_DIR = defined($ARGV[0]) ? $ARGV[0] : '.';
my $BASE_URL = defined($ARGV[2]) ? $ARGV[2] : 'https://joworld.net/';
my $SEARCH = defined($ARGV[1]) ? $ARGV[1] : '';

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
  print STDERR "$0 <directory> <search> [<url>]\n";

  exit 1;
}

# work
if (scalar @ARGV < 2) {
  usage();
}

chdir($BASE_DIR);
doURL($BASE_DIR);
