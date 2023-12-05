unit module AoC::Day05;


# Day 05: If You Give A Seed A Fertilizer
# ---------------------------------------

class CategoryMap {
	has Str $.src;
	has Str $.dst;
	has Array @!ranges;

	submethod BUILD(:$src, :$dst, :@ranges) {
		$!src = $src;
		$!dst = $dst;
		@!ranges = @ranges;
	}

	method map(Numeric $value --> Numeric) {
		for @!ranges -> [$drs, $srs, $len] {
			return $drs + ($value - $srs) if $srs <= $value < $srs + $len;
		}

		return $value;
	}
}

grammar CategoryMap::Grammar {
	rule TOP { <seed-list> [ <mapping> ]+ }
	rule seed-list { 'seeds:' [ <number> ]+ }
	rule mapping { <from=.word> '-to-' <to=.word> 'map:' [ <range> ]* }
	rule range { <dst=.number> <src=.number> <len=.number> }

	token number { \d+ }
	token word { \w+ }
}

class CategoryMap::Actions {
	method TOP($/) {
		make [$<seed-list>.made, $<mapping>».made]
	}

	method seed-list($/) {
		make $<number>>>.Int
	}

	method mapping($/) {
		make CategoryMap.new(
			src => ~$<from>,
			dst => ~$<to>,
			ranges => $<range>>>.made.flat,
		)
	}

	method range($/) { make [+$<dst>, +$<src>, +$<len> ] }
}

sub remap-direct($from, $to, $start, @maps) {
	for @maps -> $m {
		return $start.map(-> $n { $m.map($n) }) if $m.src eq $from && $m.dst eq $to;
	}

	return ();
}

sub remap($from, $to, $start, @maps) {
	if my @goal = remap-direct($from, $to, $start, @maps) {
		return @goal;
	}

	for @maps -> $m {
		if $m.dst eq $to && my @medium = remap($from, $m.src, $start, @maps) {
			return remap-direct($m.src, $m.dst, @medium, @maps);
		}
	}

	die "Mapping missing for $from --> $to";
}

our sub part1(IO::Handle $in) {
	if !(my $p = CategoryMap::Grammar.parse($in.slurp, actions => CategoryMap::Actions)) {
		die "Failed to parse input";
	}

	my ($seeds, @maps) = $p.made;
	min remap('seed', 'location', $seeds, |@maps);
}
