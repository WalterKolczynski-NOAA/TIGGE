#!/usr/bin/perl -w
#
#	Searches directories for gens_3*.tar files and busts them into
#		TIGGE_INPUT if found.
#
my $headline = "$0:getGensTar : ";
$ENV{'TIGGE_INPUT'} || die("### $headline : ENV TIGGE_INPUT is not set!\n\n");

my @ingestDirs = qw(/raid6/ingest/ /raid8/ingest/);
# my @ingestDirs = qw( /raid6/test/ );

my $EXPIRE_DAYS = 4.25;		# Retention period for source tar files
my $filesPerMember = 130;	# Count of all a & b files in each member

my @targetTars;

foreach my $dir ( @ingestDirs ) 
	{
	if( !(-d $dir) && !(-r $dir) ) { next; }
	print STDOUT "Scanning $dir for GENS tar files...\n";
	opendir(DIR,$dir);
	my @dirFiles = grep(/^gens_3_\d{4}[0-1]\d[0-3]\d[0-2]\d\_\d{2}\.g2\.tar$/,readdir(DIR));
	closedir(DIR);
	for( $a = 0; $a <= $#dirFiles ; $a++ ) 
		{
		$dirFiles[$a] = "$dir/$dirFiles[$a]";
		$dirFiles[$a] =~ s/\/*\//\//g; 
		}
	push(@targetTars,@dirFiles);
	}

if( $#targetTars == -1 ) 
	{ print "\n\tNo Targets\n\n"; }

	# Directory to untar files.
my $tempDir = "$ENV{'TIGGE_INPUT'}/.untar";
if( !(-d $tempDir) )	
	{ mkdir($tempDir); }
my @LockList;

print "$headline : Found and Processing the following list of files:\n\t[".int($#targetTars)."]\n";
foreach my $tarPath ( reverse sort @targetTars )
	{
	print "  $tarPath\n";
	}
print "\n\n";

my $Counter = 0;
my $CounterMax = $#targetTars +1;
foreach my $tarPath ( reverse sort @targetTars ) 
	{
	my $tar = $tarPath;
	$tar =~ s/^.*\///g;
	my $thisPath = $tarPath;
	$thisPath =~ s/\/$tar$//g;
	$Counter++;

	printf STDOUT (" [ %04d/%04d ] *> %s\n",
			$Counter,$CounterMax,"$thisPath/$tar");
	my $tarLock = ".$tar.getGensTar.lock";
	my $tarLockPath = "$thisPath/$tarLock";
	my $untarPath = "${tempDir}/$tar";

	if( -d $untarPath ) 
		{
		print STDOUT "\t! Working directory in use! Skipping $tar\n";
		print STDOUT "\t$untarPath\n";
		next;
		}

	if( (-e $tarLockPath) )
		{ 
		print "\t* LOCKED * $tarLockPath Exists, delete first if it persists\n\n";  
		next; 
		}

	my @parts = split(/[\_\.]/,$tar);
	my $outDir = "$ENV{'TIGGE_INPUT'}/$parts[2]";
	if( !(-d $outDir) )	{ mkdir($outDir); }
	else
		{
			# Take a peek for existing data, avoid duplicate effort
		opendir(OUTDIR,$outDir) || next;
		my @outdirFiles = grep(/gens-.*\_$parts[3]\.grb2$/,readdir(OUTDIR));
		closedir(OUTDIR);

		my $validation = 0;
		foreach my $f ( @outdirFiles ) 
			{
			my $oPath = "${outDir}/${f}";
			if( !(-z $oPath) ) { $validation++; }
			}

		if( $validation == $filesPerMember ) 
			{
			print "\t o  Data has already been distrubuted.\n\n";
			goto CHECK_EXPIRATION;
				# Skip the untarring and just check for expiration
			}
		}

    mkdir($untarPath);
    chdir($untarPath);
    print STDOUT "\tClaimed temp.directory : $untarPath\n";

	# Set lock
	open(LOCK,">",$tarLockPath) || 
		die("### $headline : Couldn't set lock $tarLockPath\n\n");
	print LOCK "$$ | ".localtime(time);
	close(LOCK);
	push(@LockList,$tarLockPath);
	print STDOUT "\tû $tarLockPath \n";

	my $symLink = "$untarPath/$tar";
	# Untar
	symlink($tarPath,$symLink);
	print(`tar -xf $symLink`);
	unlink($symLink);

	opendir(DIR,".");
	my @componentFiles = grep(/\.grb2$/,readdir(DIR));
	closedir(DIR);

	foreach $cf ( @componentFiles )
		{
		my $destination = "$outDir/$cf";
		my $localSize = (-s $cf);
		my $destSize;
		my $buffer;
		if( !(-e $destination) ) 
			{
			open(IN,"<",$cf) || next;
			read(IN,$buffer,$localSize);
			close(IN);
			open(OUT,">",$destination) || next;
			print OUT $buffer;
			close(OUT);
			}
		else
			{
			$destSize = (-s $destination);
# print "DEBUG : $destination localSize $localSize  destSize $destSize\n\n";
			if( $localSize > $destSize ) 
				{
				open(IN,"<",$cf) || next;
				read(IN,$buffer,$localSize);
				close(IN);
				open(OUT,">",$destination) || next;
				print OUT $buffer;
				close(OUT);
				}
			}
		unlink($cf);
		}

CHECK_EXPIRATION:

	my $tarAge = (-M $tarPath);
	if( $tarAge >= $EXPIRE_DAYS ) 
		{ 
		print STDOUT " - $tarPath expired ($tarAge):($EXPIRE_DAYS) \n";
		$check = unlink($tarPath);
		sleep(1);
		if( (-e $tarPath) ) 
			{
			print STDOUT " ? $tarPath still exists, check permissions?\n"; 
			print STDOUT "   Unlink returned $check\n";
			print STDOUT "   Attempting shell rm call...\n";
			print(`rm -f $tarPath`);
			}
		}
	else { print STDOUT " + $tarPath  ($tarAge):($EXPIRE_DAYS)\n"; }

	chdir($tempDir);

	if( (-d $untarPath) )
		{
		print(`rm -f $untarPath/*`);
		rmdir($untarPath) || print STDOUT "$! Could not clear working directory [$untarPath]\n";
		}

	unlink($tarLockPath);
	}

foreach $lp ( @LockList ) 
	{
	if( -e $lp ) 
		{
		print " ! Removed persisting lock-file : $lp\n\tsomething may have went wrong processing this.\n";
		unlink($lp);
		}
	}

print STDOUT "\n\n$headline Done ".localtime(time)."\n\n";
exit 0;
