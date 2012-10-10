#!/usr/bin/perl 

## can flatten rackspace logs w/ something like:
# find . -name "*.gz" -exec cat {} \; > ../logs.txt.gz
# bad things happen if you use "." and don't exempt output from the search. :)

# Example format

# X.X.X.X - - [24/Jul/2012:23:29:01 +0000] "GET /c281268.r68.cf1.rackcdn.com/The.Impromptu.E26.mp3 HTTP/1.1" 200 65883668 "-" "Instacast/2.2 CFNetwork/548.1.4 Darwin/11.0.0" "-"

# this is not always the format, sometimes the trailing hyphen is missing. Sometimes
# the client info is missing.


$LOGFILE = "/users/protonk/Desktop/logs.txt";
open(LOGFILE) or die("Check the file name!");
foreach $line (<LOGFILE>) {
    chomp($line);  
    # Everything is UTC
    $line =~ s/ \+[0-9]{4}//;
    # Don't need delimiters around the time anymore
    $line =~ s/\[|\]//g;
    # Remove some hyphens
    $line =~ s/ (- -) / /g;
    $line =~ s/"-"/-/g;
    # Rackspace changed formats to have trailing hyphens for some reason
    $line =~ s/ +-$//;
    # drop quotes around requests
    $line =~ s/"([^"]+)"/$1/;
    # Drop lines without client info (vanishingly small proportion)
    if ($line =~ /"([^"]+)"/) {
    	print "$line\n";
    	}
}


