#!/usr/bin/perl 
my $f = shift(@ARGV);
if( !(-f $f) ) { exit 0; }
open(FILE,"<",$f);
my @infile = readline(FILE);
close(FILE);
open(OUT,">","$f.new");

foreach $line ( @infile ) 
{
$line =~ s/"identificationOfOriginatingGeneratingCentre"/"centre"/g;
$line =~ s/"identificationOfOriginatingGeneratingSubCentre"/"subCentre"/g;
$line =~ s/"gribMasterTablesVersionNumber"/"tablesVersion"/g;
$line =~ s/"versionNumberOfGribLocalTables"/"localTablesVersion"/g;
$line =~ s/"numberOfOctetsForOptionalListOfNumbersDefiningNumberOfPoints"/"numberOfOctectsForNumberOfPoints"/g;
$line =~ s/"interpretationOfListOfNumbersDefiningNumberOfPoints"/"interpretationOfNumberOfPoints"/g;
$line =~ s/"scaleFactorOfMajorAxisOfOblateSpheroidEarth"/"scaleFactorOfEarthMajorAxis"/g;
$line =~ s/"scaledValueOfMajorAxisOfOblateSpheroidEarth"/"scaledValueOfEarthMajorAxis"/g;
$line =~ s/"scaleFactorOfMinorAxisOfOblateSpheroidEarth"/"scaleFactorOfEarthMinorAxis"/g;
$line =~ s/"scaledValueOfMinorAxisOfOblateSpheroidEarth"/"scaledValueOfEarthMinorAxis"/g;
$line =~ s/"numberOfPointsAlongAParallel"/"Ni"/g;
$line =~ s/"numberOfPointsAlongAMeridian"/"Nj"/g;
$line =~ s/"numberOfVerticalCoordinateValues"/"NV"/g;
$line =~ s/"backgroundGeneratingProcessIdentifier"/"backgroundProcess"/g;
$line =~ s/"hoursAfterReferenceTimeOfDataCutoff"/"hoursAfterDataCutoff"/g;
$line =~ s/"minutesAfterReferenceTimeOfDataCutoff"/"minutesAfterDataCutoff"/g;
$line =~ s/"totalNumberOfDataValuesMissingInStatisticalProcess"/"numberOfMissingInStatisticalProcess"/g;
$line =~ s/"timeIncrementBetweenSuccessiveFields"/"timeIncrement"/g;
$line =~ s/"numberOfBitsContainingEachPackedValue"/"bitsPerValue"/g;
print OUT $line;
}

close(OUT);

exit 0;
