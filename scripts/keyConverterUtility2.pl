#!/usr/bin/perl 
my $f = shift(@ARGV);
if( !(-f $f) ) { exit 0; }
open(FILE,"<",$f);
my @infile = readline(FILE);
close(FILE);
open(OUT,">","$f");

foreach $line ( @infile ) 
{
$line =~ s/"indicatorOfUnitOfTimeForTheIncrementBetweenTheSuccessiveFieldsUsed"/"indicatorOfUnitForTimeIncrement"/g;
print OUT $line;
}

close(OUT);

exit 0;


__END__

lengthOfTheTimeRangeOverWhichStatisticalProcessingIsDone
lengthOfTimeRange

indicatorOfUnitOfTimeForTheIncrementBetweenTheSuccessiveFieldsUsed 
indicatorOfUnitForTimeIncrement

