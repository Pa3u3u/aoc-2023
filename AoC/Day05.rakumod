unit module AoC::Day05;


# Day 05: If You Give A Seed A Fertilizer
# ---------------------------------------

class Range {
	has Numeric $.src;
	has Numeric $.len;

	method new($src, $len) {
		self.bless(:$src, :$len)
	}

	method end { $.src + $.len }

	method Str(::?CLASS:D:) {
		"⟦" ~ $.src ~ "⟮$.len⟯" ~ "⟧"
	}

	method gist(::?CLASS:D:) { self.Str }
}

sub infix:<∈>(Numeric $n, Range $r) {
	$r.src <= $n < $r.src + $r.len
}

class MapRange is Range {
	has Numeric $.dst;

	method new($dst, $src, $len) {
		self.bless(:$dst, :$src, :$len)
	}

	method Str(::?CLASS:D:) {
		"⟦" ~ $.src ~ "⟮$.len⟯" ~ "-> " ~ $.dst ~ "⟧"
	}
}

class CategoryMap {
	has Str $.src;
	has Str $.dst;
	has MapRange @.ranges;

	method map(Numeric $value --> Numeric) {
		for @!ranges -> $r {
			return $r.dst + ($value - $r.src) if $value ∈ $r;
		}

		return $value;
	}
}

sub cut-range(Range $which, Range $by) {
	my $mid = max($which.src, $by.src);

	grep { .len > 0 },
	Range.new($which.src, $by.src - $which.src),
	Range.new($mid, min($by.len - $mid + $by.src, $which.len - $mid + $which.src)),
	Range.new($by.src + $by.len, $which.len - $by.src + $which.src - $by.len)
}

sub cut-for-mapping(@sources, $mapping) {
	my @queue = |@sources;
	my @result;

	RANGE: while my $r = shift @queue {
		for $mapping.ranges -> $c {
			if (my @cuts = cut-range($r, Range.new($c.src, $c.len))) > 1 {
				push @queue, |@cuts;
				next RANGE;
			}
		}

		push @result, $r;
	}

	return @result;
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

	method range($/) { make MapRange.new(+$<dst>, +$<src>, +$<len>) }
}

sub remap-direct($start, CategoryMap $m) {
	$start.map(-> $n { $m.map($n) })
}

sub remap(Str $from, Str $to, $start, @maps, &remapper = &remap-direct) {
	for @maps -> $m {
		return &remapper($start, $m) if $m.src eq $from && $m.dst eq $to;
	}

	for @maps -> $m {
		if $m.dst eq $to && my @medium = remap($from, $m.src, $start, @maps, &remapper) {
			return remap($m.src, $m.dst, @medium, @maps, &remapper);
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

sub build-seed-ranges($seeds) {
	gather for |$seeds -> $s, $l {
		take Range.new($s, $l);
	}
}

sub recombine($ranges) {
	my $sorted = $ranges.sort: *.src;
	my @result;

	for |$sorted -> $r {
		if @result && @result[*-1].end ∈ $r {
			@result[*-1] = Range.new(
				@result[*-1].src,
				$r.src - @result[*-1].src + $r.len,
			);
		} elsif !@result || @result[*-1].end < $r.src {
			@result.push: $r;
		}
	}

	return @result;
}

sub remap-range($ranges, $map) {
	my @parts = cut-for-mapping($ranges, $map);
	recombine(@parts.map(-> $r { Range.new($map.map($r.src), $r.len) }));
}

our sub part2(IO::Handle $in) {
	if !(my $p = CategoryMap::Grammar.parse($in.slurp, actions => CategoryMap::Actions)) {
		die "Failed to parse input";
	}

	my ($seeds, @maps) = $p.made;
	$seeds = build-seed-ranges($seeds);

	min remap('seed', 'location', $seeds, |@maps, &remap-range)>>.src;
}
