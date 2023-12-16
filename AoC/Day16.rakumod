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

	while @q && my ($p, $v) = @q.shift {
		next unless 0 <= $p.y <= @map.end && 0 <= $p.x <= @map[0].end;
		next if %seen{$p.y}{$p.x}.any eqv $v;
		%lights{$p.y}{$p.x}++;
		%seen{$p.y}{$p.x}.push($v);

		given @map[$p.y; $p.x] {
			when '.' { @q.push([$p + $v, $v]) }
			when '\\' {
				my $w = pt($v.y, $v.x);
				@q.push([$p + $w, $w]);
			}
			when '/' {
				my $w = pt(-$v.y, -$v.x);
				@q.push([$p + $w, $w]);
			}
			when '-' {
				if $v.x != 0 {
					@q.push([$p + $v, $v]);
				} else {
					@q.push([$p + pt($_, 0), pt($_, 0)]) for -1, 1;
				}
			}
			when '|' {
				if $v.y != 0 {
					@q.push([$p + $v, $v]);
				} else {
					@q.push([$p + pt(0, $_), pt(0, $_)]) for -1, 1;
				}
			}
		}
	}

	return %lights;
}

our sub part1(IO::Handle $in) {
	my @map = read-map($in);
	[+] illuminati(@map, [[pt(0, 0), pt(+1, 0)],]).values.map(*.elems)
}
