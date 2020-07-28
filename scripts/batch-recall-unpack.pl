#!/usr/local/perl -w
# NOTE This should be used under a rerun ENV.
# It unpacks archive GENS units from DS.6177_06 
#     given a tarPool directory full PATH (ARG1)
use strict;
sub clean();
undef our @cleanList;
sub unpackFile($);

our $tarPool = $ARGV[0];
if( !(-d $tarPool) || !(-r $tarPool) ) 
	{ die("### <$tarPool> is not a directory of tar files."); }
my @targets = (`find $tarPool -maxdepth 1 \\( -type l -o -type f \\) -name "gens*.tar"`);
print STDOUT "\n\n -- $#targets targets found\n\n";

foreach my $t ( sort @targets ) 
	{
	if( $t =~ m/gensanl/i )  { next; }
	my $absPath = "$t";
	my $rtn = main::unpackFile( $absPath );
	print STDOUT "$rtn : $absPath\n";
	}

exit(0);



sub main::unpackFile($)
{
my $target = $_[0];
chomp($target);
if( !(-e $target) ) 
	{ return("DNE"); }
if( (-d $target)  )
	{ return("INVALID-DIR <$target>\n"); }

my $tmpDir = "/dev/shm/";
my $outBase = "/raid/nomads/tigge/input-retro";

chdir($tmpDir);
chomp($target);
my @tarout = (`/bin/tar -xf $target`);
my @targets = (`/bin/ls -1 gens*.grb2`);
foreach my $t ( sort @targets ) 
	{
	my $nt = $t;
	chomp($nt);
	my ($extYMD,$extHH) = $nt =~ m/^.*_(\d{8})_(\d{2})00_.*\.grb2$/;
	if( ! $extYMD || ! $extHH ) { next; } 
#	print STDOUT " * $nt >> [$extYMD] [$extHH]\n";

	my $dstDIR = "${outBase}/${extYMD}${extHH}";
	$dstDIR =~ s/\/*\//\//g;
	if( !(-d $dstDIR) ) { mkdir($dstDIR); }
	if( !(-d $dstDIR) ) { next; }

	my $cpSrc = "${tmpDir}/${nt}";
	$cpSrc =~ s/\/*\//\//g;
	push( @cleanList,$cpSrc );
#	print STDOUT "       cp $cpSrc $dstDIR\n";
	my @cpOut = (`cp $cpSrc $dstDIR`);
	}

my @mvOut = (`mv $target $target.done`);
main::clean();
return("ok");
}




sub clean()
	{
	print STDOUT "\n\n$0: Cleanup ($#cleanList items)\n\n";
	foreach my $f ( @cleanList ) 
		{ unlink($f); } 
	undef @cleanList;
	}

sub END 	{ main::clean(); }
