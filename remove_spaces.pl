#!/usr/bin/perl
#
#

use strict;
use warnings;

opendir(D, '.');
my @files = readdir(D);
closedir(D);

foreach (@files) {
  next if (/^\./);
  next if (not / /);

  my $new = $_;
  $new =~ s/ /\./g;

  print STDOUT "mv '$_' '$new'\n";
}
