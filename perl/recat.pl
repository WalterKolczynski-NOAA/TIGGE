use strict;
my $c = $ARGV[0];
if( $c !~ m/^\d{10}$/ )   { exit; }

my $primary    = "/raid/nomads/tigge/output/archive/tigge-kwbc-${c}.tar";
my $secondary  = "/raid/nomads/tigge/rerun/output/archive/gens-tigge_3_${c}.tar";
my $final    = "/raid/nomads/tigge/rerun/output-retro/tigge-kwbc-${c}.tar";

if( ! -f $primary )    { exit; }
if( ! -f $secondary )  { exit; }
print STDOUT (`tar --concatenate --file=$primary  $secondary`);
rename( $primary, $final );
print STDOUT "\n >> $final\n";
