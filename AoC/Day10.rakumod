unit module AoC::Day10;


# Day 10: Pipe Maze
# -----------------

enum Dir <North East South West>;

multi prefix:<↺>(Dir $d) {
	given $d {
		when North { South };
		when South { North };
		when East { West };
		when West { East };
	}
}

class Pt {
	has $.x;
	has $.y;

	method new(Numeric $x, Numeric $y) { self.bless(:$x, :$y) }
	method Str() { "[$.x, $.y]" }
	method gist() { self.Str }
}

multi infix:<eqv>(Pt $a, Pt $b) {
	$a.x == $b.x && $a.y == $b.y
}

multi infix:<↦>(Pt $a, Pt $b --> Dir) {
	given ($b.x - $a.x, $b.y - $a.y) {
		when ( 0, -1) { North }
		when ( 1,  0) { East }
		when ( 0,  1) { South }
		when (-1,  0) { West }
	}
}

sub at(@map, Pt $p) is rw {
	@map[$p.y; $p.x]
}

multi infix:<⋗>(Pt $p, Dir $d) {
	given $d {
		when North { Pt.new($p.x, $p.y - 1) }
		when South { Pt.new($p.x, $p.y + 1) }
		when East { Pt.new($p.x + 1, $p.y) }
		when West { Pt.new($p.x - 1, $p.y) }
	}
}

sub read-map($in) {
	my @map;
	my $start;

	my $y = 0;
	for $in.lines -> $line {
		for $line.comb.kv -> $x, $c {
			given $c {
				when '|' { @map[$y; $x] = (North, South).Set }
				when '-' { @map[$y; $x] = (East, West).Set }
				when 'L' { @map[$y; $x] = (North, East).Set }
				when 'J' { @map[$y; $x] = (North, West).Set }
				when '7' { @map[$y; $x] = (South, West).Set }
				when 'F' { @map[$y; $x] = (South, East).Set }
				when 'S' {
					$start = Pt.new($x, $y);
					@map[$y; $x] = (North, East, South, West).Set
				}
			}
		}

		$y++;
	}

	return ($start, @map);
}

sub is-connected(@map, $a, $b) {
	return False if !at(@map, $a) || !at(@map, $b);

	if abs($a.y - $b.y) == 1 && $a.x == $b.x {
		return South ∈ @map[min($a.y, $b.y); $a.x]
			&& North ∈ @map[max($a.y, $b.y); $a.x];
	}

	if abs($a.x - $b.x) == 1 && $a.y == $b.y {
		return East ∈ @map[$a.y; min($a.x, $b.x)]
			&& West ∈ @map[$a.y; max($a.x, $b.x)];
	}

	die "is-connected: Coordinate $a is not adjacent to $b";
}

sub search(@map, @path, Dir $dir) {
	my $next = @path[*-1] ⋗ $dir;
	return @path if $next eqv @path[0];

	my $dir2 = at(@map, $next) ∖ ↺$dir;
	die "Looking at $next from $dir, can only continue to {", $dir2, "}"
		if $dir2.elems != 1;

	search(@map, (|@path, $next), $dir2.pick);
}

sub directions(@map, $p) {
	gather for (North, East, South, West) -> $dir {
		take $dir if is-connected(@map, $p, $p ⋗ $dir);
	}
}

sub find-path(@map, $s) {
	for directions(@map, $s) -> $direction {
		if my @path = search(@map, [$s], $direction) {
			return @path;
		}
	}
}

our sub part1(IO::Handle $in) {
	my ($start, @map) := read-map($in);
	floor(find-path(@map, $start) / 2)
}

sub hash-path(@path) {
	my %tiles = Hash.new;

	for @path -> $p {
		%tiles{$p.y}{$p.x} = True;
	}

	return %tiles;
}

sub count-tiles(@map, @path, $rx, $ry) {
	my %is-path = hash-path(@path);
	my $enclosed = 0;

	for |$ry -> $y {
		my %state = North => False, South => False;

		for |$rx -> $x {
			my $tile = at(@map, Pt.new($x, $y));

			if %is-path{$y}{$x} {
				for North, South -> $d {
					%state{$d} = !%state{$d} if $d ∈ $tile;
				}
			} else {
				$enclosed++ if %state{North};
				# die "Inconsistent state" if %state{North} xor %state{South};
			}
		}
	}

	return $enclosed;
}

sub fix-start(@map, $s, @neigh) {
	at(@map, $s) = (@neigh.map: $s ↦ *).Set;
}

our sub part2(IO::Handle $in) {
	my ($start, @map) := read-map($in);
	my @path = find-path(@map, $start);

	fix-start(@map, @path[0], @path[1, *-1]);
	count-tiles(@map, @path, minmax(@path>>.x), minmax(@path>>.y))
}
