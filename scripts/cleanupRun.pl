

# cleanup all cycles output and hidden status files, leaving the input intact for rerun.
#

my $dry = 1;
my $cyc = $ARGV[0];
if( $cyc !~ /^\d{10}$/ )
  { die("\ninvalid YMDH argument 1 = $cyc\n\n"); }
if( scalar grep(/^\-remove/i,@ARGV) > 0 )
    { $dry = 0; }


my @targets = ( "$ENV{TIGGE_INPUT}/${cyc}/.meta\*", "$ENV{TIGGE_INPUT}/${cyc}/.completed", "$ENV{TIGGE_OUTPUT}/archive/${cyc}", "$ENV{TIGGE_OUTPUT}/archive/gens-tigge_3_${cyc}.tar", "$ENV{TIGGE_OUTPUT}/archive/tigge-kwbc-${cyc}.tar" );

foreach my $t ( @targets )
	{
	if( -f $t || $t =~ m/\*/g ) 
		{
		print "TARGET:: rm $t\n"; 
		if( ! $dry )   { print STDOUT (`rm $t`); }
		}
	if( -d $t )
		{
		print STDOUT "DIR:: rm -rf $t\n";
		if( ! $dry )   { print STDOUT (`rm -rf $t`); }
		}

	}

if( $dry ) 
  { print STDOUT "\n\n*NOTICE* Dry Run:  add argument -remove to actually destroy these.\n\n";  }
else 
   { print STDOUT "\n\nCycle $cyc cleaned and should now rerun automatically.\n\n";  }

exit 0;
