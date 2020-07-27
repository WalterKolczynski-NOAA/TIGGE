@files = (`ls -1 gens_*.tar.done`);
foreach my $f ( sort @files )
	{
	chomp($f);
	my $nf = $f;
	$nf =~ s/\.tar\.done$/\.tar/g;
	(`mv $f $nf`);
	}
