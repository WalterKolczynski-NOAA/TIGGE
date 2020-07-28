use strict;
sub testTarArchive($);

my ($r1,$l1,$t1,@out1) = main::testTarArchive("/home/nomads/tigge/bad.tar");
my @t2 = main::testTarArchive("/home/nomads/tigge/output/archive/gens-ncdc_3_2015042100.g2.tar.gz");
my @t3 = main::testTarArchive("/home/nomads/tigge/output/archive/gens-tigge_3_2015042006.tar");

print STDOUT "\nresults: (($r1,$l1,$t1,@out1)) $#t2 $#t3\n\n";

exit 0;

# Verifies a target tar archive with [tar -tvf ] 
#  ->    $ PATH to target
#  1 <-  $ Test Return code.  - zero indicates subroutine successful exit.
#  2 <-  $ Count of Lines of STDERR output (0 indicates a good test)
#  3 <-  $  elapsed time
# ;4 <- [@] The actual STDERR output, if any.

sub testTarArchive($)
	{
	my $target = shift(@_);
	unless( (-f $target) && (-e $target) && (-r $target) ) 
		{ return(-1,-1,0); }
	my $sizeCheck = (-s $target);
	if( $sizeCheck < 500 ) 	# if size is zero or near-zero, get out.
		{ return(-1,-1,0); }
	print STDOUT "Testing $target: $sizeCheck bytes\n";
	my $st = time;
	undef my @msgs;

# save STDERR filehandle
	open(my $ORIGSTDERR, ">&", STDERR);

# create temporary filehandle to catch STDERR
	open(my $CATCHERR, "+>", undef) or die("cannot open temp file :: $!");
	open(STDERR, ">&", $CATCHERR); # redirection

## Runs Tar - STDERR is captured here ##
# No need to monkey with STDOUT, just ignore it.

        open( my $TEST,"-|","tar","-tvf",$target );
        while(<$TEST>)  { }	# send STDOUT to the aether.
        close( $TEST );

# restore STDERR filehandle
	open(STDERR, ">&", $ORIGSTDERR);

# read captured STDERR from temporary filehandle
	seek($CATCHERR, 0, 0 );
	while( <$CATCHERR> )  { push(@msgs,$_); }
#print "From CATCHERR: $_" while <$CATCHERR>;
	close($CATCHERR);

	my $et = time - $st;

	return( 0,$#msgs+1,$et,@msgs );
	}
