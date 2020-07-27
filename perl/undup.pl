#!/usr/bin/perl -w
#  Removes duplicate records from tigge-kwbc tar component files.  [ARG 1]
#    requires running wgrib2 from shell a couple ten-thousand times per archive unit.... very slow.
use strict;
use Digest::MD5;


our $tmpDir = "/dev/shm/reprocess-$$";
our $workDir = "$tmpDir/work";
our $inTarFile = $ARGV[0];
if( ! -f $inTarFile )   
	{ die("\n\n### need a target tigge-kwbc tar file FULL PATH in first arg!\n\n"); }


sub cleanDups( $$ )
{
print STDOUT "Working on : @_ ... \n";
my $workBase = shift( @_ );
my $workFile = shift( @_ );
my $workPath = "$workBase/$workFile";
undef my @files;

my @inv = (`wgrib2 $workPath`);

foreach my $l ( @inv ) 
	{
	my @match = $l =~ m/^(\d*)\:(.*)/;
	if( $match[0] !~ m/\d*/ )   { next; }
	#print "$match[0]\n";
	(`wgrib2 -d $match[0] $workPath | wgrib2 -i $workPath -grib ${workPath}.rec$match[0] >&/dev/null`);
	push( @files, "${workFile}.rec${match[0]}" );
	}

print STDOUT "$#files extracted\n";


# NcdcNomads::explodeGRIB( $workPath, "" );
#   :(  this would have been faster - but it was creating a few bad records.

unlink( $workPath );

#opendir( DIR, $workBase ) || die("\n\nMEEP!\n");
#my @files = grep(/\.gri?b$/, readdir( DIR ));
#closedir( DIR );

undef my %uniq;
foreach my $f ( sort @files )
	{
	chomp($f);
	my $this = "$workBase/$f";
	my $CKSM = Digest::MD5->new;
	open( my $FH, "<", $this ) || next;
	binmode($FH);
	$CKSM->addfile($FH);
	my $md5checksum = $CKSM->hexdigest;
	$CKSM->reset;
	# print STDOUT "$this >> $md5checksum\n";
	if( !defined( $uniq{$md5checksum} ) )	
		{
		seek( $FH, 0, 0 );
		open( OUT, ">>", $workPath );
		binmode( OUT );

		while( my $len = sysread( $FH, my $data, 4096 ) )
			{ syswrite OUT, $data, $len; }

		close( OUT );
		$uniq{$md5checksum} = 1;
		}
	else { }
	close( $FH );
	unlink( $this );
	}
return;
}


if( ! -d $tmpDir )
	{ mkdir( $tmpDir ) || die("### failed to create $tmpDir\n\n" );  }
if( ! -d $workDir )  
	{ mkdir( $workDir ) || die("### failed to create $workDir\n\n" );  }


print STDOUT "\nChop Chop! working under $tmpDir \n\n";
chdir( $tmpDir );

print STDOUT (`tar -xf $inTarFile`);

opendir( MEEP, $tmpDir ) || die("\n\n### target $inTarFile DNE\n\n");
my @units = grep( /^z_tigge_c_kwbc_.*\.grib$/, readdir( MEEP ) );
closedir( MEEP );

print STDOUT " $inTarFile  has  $#units components to proc.\n\n";

chdir( $workDir );

foreach my $gf ( sort @units ) 
	{
	my $this = "$tmpDir/$gf";
	rename( $this, "$workDir/$gf" );

	main::cleanDups( $workDir, $gf );

	rename( "$workDir/$gf", $this );
	}

chdir( $tmpDir );
rmdir( $workDir );
print STDOUT (`tar -cf new.tar ./*.grib`);
print STDOUT (`rm ./*.grib`);


exit 0;

