#!/bin/bash

if [ $# -ne 2 ] 
then
    echo usage: rm-watermark-pdf folder pattern
    exit
fi
source_dir=$1;
find "$1" -type f -name "*.pdf" -print0|while read -d $'\0' file;
do
    if [ `strings "$file"|grep -c "$2"` -gt 0 ];
    then
	echo "$file";
	cp "$file" /tmp/1.pdf;
	script=$(cat <<'EOF'
use strict;
use warnings;
open(my $in, '<', '/tmp/1.pdf')
or die "Cannot open input: $!";
open(my $out, '>', '/tmp/2.pdf')
or die "Cannot open output: $!";
while (<$in>) {
   print $out $_ unless /__PATTERN__/;
}
close($in);
close($out);
EOF
	      )
	script=${script/'__PATTERN__'/$2}
	#echo $script
	/usr/bin/perl -e "$script"
	mv -v /tmp/2.pdf "$file";
	rm /tmp/1.pdf
    fi;
done
