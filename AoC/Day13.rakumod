unit module AoC::Day13;


# Day 13: Point of Incidence
# --------------------------

sub prefix:<↔>(@pattern) { @pattern[0].elems }
sub prefix:<↕>(@pattern) { @pattern.elems }

sub next-pattern(IO::Handle $in) {
	my @pattern;

	for $in.lines.kv -> $y, $line {
		last if $line.chars == 0;
		@pattern[$y; (0 ..^ $line.chars)] = $line.comb;
	}

	return @pattern if @pattern.elems;
	return ();
}

sub is-symmetric(@p, $y, $max-x, $max-y) {
	for (0 .. $y) -> $l {
		my $r = 2 * $y - $l + 1;
		next if $r >= $max-y;
		return False if @p[$l; (0 ..^ $max-x)] !eqv @p[$r; (0 ..^ $max-x)];
	}

	return True;
}

sub find-y-axis($label, @p) {
	my $s = ↔@p;
	for (0 ..^ (↕@p) - 1) -> $y {
		return $label => $y if @p[$y; 0 .. $s - 1] eqv @p[$y + 1; 0 .. $s - 1]
				  && is-symmetric(@p, $y, ↔@p, ↕@p);
	}
}

sub find-axis(@p) {
	find-y-axis('y', @p) // find-y-axis('x', [Z] @p)
}

sub evaluate($axis) {
	given $axis.key {
		when 'x' { return $axis.value + 1 }
		when 'y' { return 100 * ($axis.value + 1) }
	}
}

our sub part1(IO::Handle $in) {
	[+] gather while my $p = next-pattern($in) {
		take evaluate(find-axis($p));
	}
}
