unit module AoC::Day12;


# Day 12: Hot Springs
# -------------------

sub parse(Str $line) {
	if $line ~~ /^^ ( <[ # . ? ]>+ ) \s+ ( \d+ | ',' )+ $$/ {
		return ($/[0].comb, $/[1].split(',')>>.Int);
	}

	die "Cannot parse '$line' as input instance";
}

sub search-space(@template, @control, $tx is copy, $cx, %cache) {
	if (my $cv = %cache{$tx}{$cx}) !=== Any {
		return $cv;
	}

	# Skip literal '.'
	$tx++ while $tx < @template.elems && @template[$tx] eq '.';

	return 1 if $tx >= @template.elems && $cx >= @control.elems;
	return 0 if $tx >= @template.elems;

	# If there are no groups left, all characters must be '?' or '.'
	if $cx >= @control.elems {
		for @template[$tx .. *] -> $c {
			return 0 if $c eq '#';
		}

		return 1;
	}

	# There must be enough elements left.
	return 0 if $tx + @control[$cx] > @template.elems;

	# From now on, if something breaks down, we may still continue.
	my $recurse = True;
	my $skip = @template[$tx] eq '?';

	# There must be no '.' in the slice, otherwise skip
	for @template[$tx ..^ $tx + @control[$cx]] -> $c {
		{ $recurse = False; last } if $c eq '.';
	}

	# If there is another character, it must be '.' or '?'
	$recurse = False if (@template[$tx + @control[$cx]] // ' ') eq '#';

	# Try to assign other parts.
	%cache{$tx}{$cx} = ($recurse ?? search-space(@template, @control, $tx + @control[$cx] + 1, $cx + 1, %cache) !! 0)
		+ ($skip ?? search-space(@template, @control, $tx + 1, $cx, %cache) !! 0)
}

sub solve(@template, @control) {
	[+] search-space(@template, @control, 0, 0, %());
}

our sub part1(IO::Handle $in) {
	[+] $in.lines.map({ parse($^a) }).map({ solve($^a[0], $^a[1]) })
}

sub intersperse(@what, $by-whom) {
	gather for @what -> $e {
		FIRST { take $e; next }
		take $by-whom;
		take $e;
	}
}

sub unfold(@template, @control) {
	(intersperse(@template xx 5, '?')>>.List.flat, (@control xx 5).flat)
}

our sub part2(IO::Handle $in) {
	[+] $in.lines.map({ parse($^a) }).map({ unfold($^a[0], $^a[1]) }).map({ solve($^a[0], $^a[1]) })
}
