unit module AoC::Day16;

use AoC::Ext::Pt;


# Day 16: The Floor Will Be Lava
# ------------------------------

sub read-map(IO::Handle $in) {
	my @pattern;

	for $in.lines.kv -> $y, $line {
		last if $line.chars == 0;
		@pattern[$y; (0 ..^ $line.chars)] = $line.comb;
	}

	return @pattern;
}

sub illuminati(@map, @q) {
	my %lights;
	my %seen;

	STASH: while @q && my ($p, $v) = @q.shift {
		while 0 <= $p.y <= @map.end && 0 <= $p.x <= @map[0].end {
			next STASH if %seen{$p.y}{$p.x}.any eqv $v;
			%lights{$p.y}{$p.x}++;
			%seen{$p.y}{$p.x}.push($v);

			given @map[$p.y; $p.x] {
				when '\\' { $v = pt($v.y, $v.x); }
				when '/'  { $v = pt(-$v.y, -$v.x); }
				when '-' {
					if $v.x == 0 {
						@q.push([$p + pt(-1, 0), pt(-1, 0)]);
						$v = pt(1, 0);
					}
				}
				when '|' {
					if $v.y == 0 {
						@q.push([$p + pt(0, -1), pt(0, -1)]);
						$v = pt(0, 1);
					}
				}
			}

			$p += $v;
		}
	}

	return %lights;
}

our sub part1(IO::Handle $in) {
	my @map = read-map($in);
	[+] illuminati(@map, [[pt(0, 0), pt(+1, 0)],]).values.map(*.elems)
}

sub all-edges(@map) {
	|(((0 .. @map[0].end) X (0)) X ((0, 1),)),
	|(((0 .. @map[0].end) X (@map.end)) X ((0, -1),)),
	|(((0) X (0 .. @map.end)) X ((1, 0),)),
	|(((@map[0].end) X (0 .. @map.end)) X ((-1, 0),)),
}

our sub part2(IO::Handle $in) {
	my @map = read-map($in);

	[max] all-edges(@map).race.map(-> ($p, $v) {
		[+] illuminati(@map, [[pt(|$p), pt(|$v)],]).values.map(*.elems)
	})
}
