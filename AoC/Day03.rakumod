unit module AoC::Day03;

use AoC::Ext::Pt;


# Day 03: Gear Ratios
# -------------------

class Engine::Part {
	has Int $.id;
	has Pt @.position[2];

	multi method Str(::?CLASS:D:) {
		"<" ~ $.id ~ " at " ~ @.position[0].gist ~ "--" ~ @.position[1].gist ~ ">"
	}

	multi method gist(::?CLASS:D:) { self.Str }
}

class Engine::Symbol {
	has Str $.s;
	has Pt $.position;

	multi method Str(::?CLASS:D:) {
		"<" ~ $.s ~ " at " ~ $.position.gist ~ ">"
	}

	multi method gist(::?CLASS:D:) { self.Str }
}

sub is-adjacent(Engine::Part $e, Pt$p --> Bool) {
	$e.position[0].x - 1 <= $p.x <= $e.position[1].x + 1
		&& $e.position[0].y - 1 <= $p.y <= $e.position[1].y + 1;
}

sub split-input(IO::Handle $in) {
	my @parts;
	my @symbols;

	for $in.lines.kv -> $y, $line {
		for ($line ~~ m:g{ \d+ }) -> $m {
			@parts.push(Engine::Part.new(
				id => +$m,
				position => [pt($m.from, $y), pt($m.to - 1, $y)])
			);
		}

		for ($line ~~ m:g{ <-[0 .. 9, .]> }) -> $m {
			@symbols.push: Engine::Symbol.new(s => ~$m, position => pt($m.from, $y));
		}
	}

	return (@parts, @symbols);
}

sub filter-parts(@parts, @symbols) {
	gather for @parts -> $part {
		take $part if is-adjacent($part, @symbols.any.position)
	}
}

our sub part1(IO::Handle $in) {
	my (@parts, @symbols) := split-input($in);
	sum filter-parts(@parts, @symbols).map: *.id
}

sub gear-ratios(@parts, @gears) {
	gather for @gears -> $gear {
		my @ids = @parts.grep: -> $p { is-adjacent($p, $gear.position) }
		next unless @ids == 2;
		take [*] @ids>>.id
	}
}

our sub part2(IO::Handle $in) {
	my (@parts, @symbols) := split-input($in);
	[+] gear-ratios(@parts, @symbols.grep: *.s eq '*')
}
