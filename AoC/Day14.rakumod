unit module AoC::Day14;

use AoC::Ext::Pt;


# Day 14: Parabolic Reflector Dish
# --------------------------------

sub read-map(IO::Handle $in) {
	my @pattern;

	for $in.lines.kv -> $y, $line {
		last if $line.chars == 0;
		@pattern[$y; (0 ..^ $line.chars)] = $line.comb;
	}

	return @pattern;
}

sub print-map(@map) {
	say ('-' xx @map[0].elems).join: '';

	for @map -> $row {
		say $row.join: '';
	}

	say ('-' xx @map[0].elems).join: '';
}

sub infix:<⇝>(@map, Pt $p) is rw {
	@map[$p.y; $p.x]
}

sub infix:<∈>(Pt $p, @map) {
	0 <= $p.x < @map[0].elems && 0 <= $p.y < @map.elems
}

sub shift(@map, $p, $v) {
	my $q = $p + $v;

	if !($q ∈ @map) || @map⇝$q ne '.' {
		@map⇝$p = 'O';
	} else {
		@map⇝$p = '.';
		shift(@map, $q, $v);
	}
}

sub tilt(@map, $v, @ix) {
	for @ix -> $p {
		shift(@map, $p, $v) if @map⇝$p eq 'O';
	}

	return @map
}

sub north(@map) { pt(0, -1), ((0 ..^ @map[0].elems) X (0 ..^ @map.elems))>>.map(&pt).flat }
sub north-eval(@map, Pt $p) { @map.elems - $p.y }

sub get-load(@map, &e) {
	[+] gather for @map.kv -> $y, $row {
		for $row.kv -> $x, $c {
			my $p = pt($x, $y);
			take &e(@map, $p) if @map⇝$p eq 'O';
		}
	}
}

our sub part1(IO::Handle $in) {
	my @map = read-map($in);
	get-load(tilt(@map, |north(@map)), &north-eval);
}
