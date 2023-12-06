unit module AoC::Day06;


# Day 06: Wait For It
# -------------------

grammar Races::Grammar {
	rule TOP { <word> ':' [ <number> ]+ }
	token word { \w+ }
	token number { \d+ }
}

class Races::Actions {
	method TOP($/) {
		make [ ~$<word>, $<number>>>.Int ]
	}
}

sub get-races($in) {
	my %parts;
	for $in.lines -> $line {
		if !(my $p = Races::Grammar.parse($line, actions => Races::Actions)) {
			die "Cannot parse input";
		}

		my ($name, $values) = $p.made;
		%parts{$name} = $values;
	}

	for <Time Distance> -> $key {
		die "Missing '$key'" unless ?%parts{$key};
	}

	die "Fields of different lengths"
		unless +%parts<Time> == +%parts<Distance>;

	gather for %parts<Time>.kv -> $ix, $value {
		take { t => $value, d => %parts<Distance>[$ix] };
	}
}

# These operators look cool, but make the program parse five times longer
# for some reason.
# sub circumfix:<⌊ ⌋>(Real $n) { $n.floor }
# sub circumfix:<⌈ ⌉>(Real $n) { $n.ceiling }

sub wins(%race) {
	# Discriminant
	my $D = %race<t> ** 2 - 4 * %race<d>;
	die "No solution for " ~ %race if $D < 0;

	# x1, x2 solutions
	my @s = (%race<t> + sqrt($D)) / 2, (%race<t> - sqrt($D)) / 2;
	die "Invalid solutions for " ~ %race if @s.map(* < 0).any;

	max(@s).floor - min(@s).ceiling + 1
}

our sub part1(IO::Handle $in) {
	[*] get-races($in).map: &wins
}

our sub part2(IO::Handle $in) {
	my $contents = S:g/<?after \d+> \h+ <?before \d+>// with $in.slurp;
	[*] get-races($contents).map: &wins
}
