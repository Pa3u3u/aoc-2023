unit module AoC::Day14;

use AoC::Ext::Pt;


# Day 14: Parabolic Reflector Dish
# --------------------------------

sub read-map(IO::Handle $in) {
	my @pattern;

	for $in.lines.kv -> $y, $line {
		last if $line.chars == 0;
		@pattern[(0 ..^ $line.chars); $y] = $line.comb;
	}

	die "The map is not a square plan" if @pattern.elems != @pattern[0].elems;
	return @pattern;
}

sub tilt(@map) {
	for @map.kv -> $x, $col {
		my $free = -1;

		for $col.kv -> $y, $c {
			given $c {
				when '#' { $free = -1 }

				when '.' { $free = $y if $free < 0 }

				when 'O' {
					if $free >= 0 {
						$col[$free, $y] = 'O', '.';
						$free++;
					}
				}
			}
		}
	}

	@map
}

sub get-load(@map) {
	[+] gather for @map.kv -> $x, $col {
		for $col.kv -> $y, $c {
			take @map.elems - $y if @map[$x; $y] eq 'O';
		}
	}
}

our sub part1(IO::Handle $in) {
	my @map = read-map($in);
	get-load(tilt(@map));
}

sub rotate(@old) {
	my $size = @old.elems;

	my @new;
	for @old.kv -> $x, $col {
		for $col.kv -> $y, $c {
			@new[$size - $y - 1; $x] = $c;
		}
	}

	@old = @new;
}

sub encode-map(@map) {
	# Quick & dirty hash function
	[+] gather for @map.kv -> $x, $col {
		for $col.kv -> $y, $c {
			take 1109 * $y + 7 * $x if $c eq 'O';
		}
	}
}

sub detect-loop(@cache, $count) {
	my $size = @cache.elems;
	for (0 .. $size - 2) -> $i {
		if @cache[$i][0] == @cache[$size - 1][0] {
			my $loops = ($count - $i) div ($size - $i - 1);
			my $shift = $count - $i - $loops * ($size - $i - 1) - 1;

			return $i + $shift;
		}
	}

	return;
}

our sub part2(IO::Handle $in) {
	my @map = read-map($in);

	my @cache;
	my $count = 1_000_000_000;
	for (0 ..^ $count) -> $cycle {
		rotate(tilt(@map)) for 0 .. 3;
		@cache[$cycle] = [encode-map(@map), get-load(@map)];

		if (my $i = detect-loop(@cache, $count)) !=== Any {
			return @cache[$i][1];
		}
	}

	@cache[*-1][1]
}
