unit module AoC::Day11;

use AoC::Ext::Pt;


# Day 11: Cosmic Expansion
# ------------------------

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
	my %map = x => %((0 .. $max.x) X=> $expansion), y => %((0 .. $max.y) X=> $expansion);

	for @stellaris -> $g {
		%map{$_}{$g."$_"()} = 0 for <x y>;
	}

	my %rate = x => {}, y => {};

	for <x y> -> $key {
		for 0 .. $max."$key"() -> $v {
			%rate{$key}{$v} = (%rate{$key}{$v - 1} // 0) + %map{$key}{$v};
		}
	}

	return %rate;
}

sub expand-universe($max, @stellaris, %expansion-rate) {
	for @stellaris -> $g {
		$g."$_"() += %expansion-rate{$_}{$g."$_"()} for <x y>;
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
