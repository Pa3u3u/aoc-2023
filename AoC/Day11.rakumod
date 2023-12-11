unit module AoC::Day11;


# Day 11: Cosmic Expansion
# ------------------------

class Pt {
	has Numeric $.x is rw;
	has Numeric $.y is rw;

	method Str() { "[$.x, $.y]" }
	method gist() { self.Str }
}

sub pt(Numeric $x, Numeric $y) {
	Pt.new(:$x, :$y)
}

sub read-stellar-map($in) {
	my @stellaris;

	my $max_x = 0;
	my $max_y = 0;

	for $in.lines.kv -> $y, $line {
		$max_y = $y;

		for $line.comb.kv -> $x, $c {
			$max_x = max($max_x, $x);
			@stellaris.push(pt($x, $y)) if $c eq '#';
		}
	}

	return (pt($max_x, $max_y), @stellaris);
}

sub dist(Pt $a, Pt $b) {
	abs($a.x - $b.x) + abs($a.y - $b.y)
}

sub all-distances(@stellaris) {
	[+] gather for @stellaris.kv -> $ix, $g {
		for @stellaris[$ix + 1 .. *] -> $q {
			take dist($g, $q)
		}
	}
}

sub expansion-rate($max, @stellaris, $expansion = 1) {
	my %map;
	%map<x>{0 .. $max.x} = $expansion xx $max.x + 1;
	%map<y>{0 .. $max.y} = $expansion xx $max.y + 1;

	for @stellaris -> $g {
		%map<x>{$g.x} = 0;
		%map<y>{$g.y} = 0;
	}

	my %rate = x => {}, y => {};

	for 0 .. $max.x -> $x {
		%rate<x>{$x} = (%rate<x>{$x - 1} // 0) + %map<x>{$x};
	}

	for 0 .. $max.y -> $y {
		%rate<y>{$y} = (%rate<y>{$y - 1} // 0) + %map<y>{$y};
	}

	return %rate;
}

sub expand-universe($max, @stellaris, %expansion-rate) {
	for @stellaris -> $g {
		$g.x = $g.x + %expansion-rate<x>{$g.x};
		$g.y = $g.y + %expansion-rate<y>{$g.y};
	}
}

our sub part1(IO::Handle $in) {
	my ($max, @stellaris) := read-stellar-map($in);

	expand-universe($max, @stellaris, expansion-rate($max, @stellaris));
	all-distances(@stellaris)
}

our sub part2(IO::Handle $in) {
	my ($max, @stellaris) := read-stellar-map($in);

	expand-universe($max, @stellaris, expansion-rate($max, @stellaris, 999_999));
	all-distances(@stellaris)
}
