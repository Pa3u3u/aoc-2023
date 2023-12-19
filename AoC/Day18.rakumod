unit module AoC::Day18;

use AoC::Ext::Pt;


# Day 18: Lavaduct Lagoon
# -----------------------

sub read-dig-plan(Str $line) {
	if $line ~~ m/$<o> = <[UDLR]> <.ws> $<n> = \d+ <.ws> '(' '#' $<rgb> = [<.xdigit> ** 6] ')' / {
		return { o => ~$<o>, n => +$<n>, rgb => ~$<rgb> };
	}

	die "Cannot parse '$line'"
}

sub get-points($start, @plan) {
	my $point = $start;
	gather for @plan -> $i {
		my $v = do given $i<o> {
			when 'R' { pt(+$i<n>, 0) }
			when 'L' { pt(-$i<n>, 0) }
			when 'U' { pt(0, -$i<n>) }
			when 'D' { pt(0, +$i<n>) }
			default { die "Unknown orientation" }
		};

		take $point += $v;
	}
}

sub trapezoid(Pt $a, Pt $b) {
	($a.y + $b.y) * ($a.x - $b.x)
}

# https://en.wikipedia.org/wiki/Shoelace_formula
sub polygon-area(@points) {
	# Triangles
	(([+] (@points Z[&trapezoid] @points[1 .. *-1, 0].flat))
		# Borders take up space too; each line creates ½-block.
		+ [+] (@points Z- @points[1 .. *-1, 0].flat).map(-> $p { abs($p.x + $p.y) })) / 2
		# And in addition, corners create “positive” and “negative”
		# ¼-blocks, which eventually annihilate, leaving one full
		# block (imagine four corners of a rectangle) behind.
		+ 1
}

our sub part1(IO::Handle $in) {
	my @plan = $in.lines.map: &read-dig-plan;
	my @points = get-points(pt(0, 0), @plan);
	abs(polygon-area(@points))
}
