#!/usr/bin/perl -w

#####################################################################################
# Copyright 2011 Normation SAS
#####################################################################################
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ###################################################################################
#
# Last edit by : Matthieu CERDA, on 16/11/2011
#
#####################################################################################

use strict;
use warnings;

use XML::XPath;

my $file = File::Spec->rel2abs($ARGV[0]);

if ( $file =~ m/category.xml$/ )

{

my $xp = XML::XPath->new(filename=>$file);

my $name = $xp->findvalue('/xml/name');

my $description = $xp->findvalue('/xml/description');

print "\n=====$name
$description\n\n";

}

elsif ( $file =~ m/policy.xml$/ )

{

my $xp = XML::XPath->new(filename=>$file);

my $description = $xp->findvalue('/POLICY/DESCRIPTION');

my $name;

open F, $file or print "couldn't open $file\n" && return;

  while (<F>) {
    if (my ($found) = /name=\"(.*)\"\>/) {
      # print "found $found in $file\n";
      $name = $found;
      last;
    }
  }

  close F;

  print "$name\:: $description\n\n";

}

else

{
	exit 0;
}
