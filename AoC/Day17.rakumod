unit module AoC::Day17;

use AoC::Ext::Pt;


# Day 17: Clumsy Crucible
# -----------------------

# Priority Queue 2, because the previous version was shit.
class PQ2 {
	has @!queue;
	has $.elems = 0;

	method insert($prio, $data) {
		@!queue[$prio].push($data);
		$!elems++;
	}

	method fetch() {
		return if $.elems == 0;

		for @!queue.values -> $l {
			next if $l === Any || $l.elems == 0;
			$!elems--;
			return $l.shift;
		}
	}

	method new(*@init) {
		my $q = self.bless;
		for @init -> $p {
			$q.insert($p.key, $p.value);
		}

		return $q;
	}
}

sub read-map(IO::Handle $in) {
	my @pattern;

	for $in.lines.kv -> $y, $line {
		last if $line.chars == 0;
		@pattern[$y; (0 ..^ $line.chars)] = $line.comb.map(+*);
	}

	return @pattern;
}

sub infix:<∈>(Pt $p, @map) {
	0 <= $p.y <= @map.end && 0 <= $p.x <= @map[0].end
}

use experimental :cached;

sub dir($n) is cached {
	given $n % 4 {
		when 0 { pt( 0, +1) }
		when 1 { pt(+1,  0) }
		when 2 { pt( 0, -1) }
		when 3 { pt(-1,  0) }
	}
}

sub shortest-path(@map, $start, $end, $steps) {
	my %visited;

	my $Q = PQ2.new:
		0 => ($start, 1, 0, 0),
		0 => ($start, 0, 0, 0);

	while $Q.elems {
		my ($N, $N-ι, $N-step, $N-dist) = $Q.fetch;
		next if (%visited{$($N.y, $N.x)}{$($N-ι, $N-step)} //= 0)++;
		return $N-dist if $N eqv $end && $N-step >= $steps.min;

		for $N-ι, ($N-ι + 1) % 4, ($N-ι - 1) % 4 -> $X-ι {
			next if $N-ι != $X-ι && $N-step <  $steps.min;
			next if $N-ι == $X-ι && $N-step >= $steps.max;

			my $X = $N + dir($X-ι);
			next if !($X ∈ @map);

			my $X-step = $N-ι == $X-ι ?? $N-step + 1 !! 1;
			my $X-dist = $N-dist + @map[$X.y; $X.x];

			$Q.insert($X-dist, ($X, $X-ι, $X-step, $X-dist))
				unless %visited{$($X.y, $X.x)}{$($X-ι, $X-step)};
		}
	}

	die "No solution found";
}

our sub part1(IO::Handle $in) {
	my @map = read-map($in);
	shortest-path(@map, pt(0, 0), pt(@map[0].end, @map.end), 0 .. 3)
}

our sub part2(IO::Handle $in) {
	my @map = read-map($in);
	shortest-path(@map, pt(0, 0), pt(@map[0].end, @map.end), 4 .. 10)
}
