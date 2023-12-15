unit module AoC::Day15;


# Day 15: Lens Library
# --------------------

sub hash(Str $s) {
	(0, |$s.comb.map(*.ord)).reduce({ (17 * ($^a + $^b)) % 256 })
}

our sub part1(IO::Handle $in) {
	[+] $in.lines».split(',').flat.map(&hash)
}

sub interpret(@boxes, $command) {
	if $command !~~ / $<label>=(\w+) $<symbol>=<[=-]> [ $<focus>=(\d+) ]? / {
		die "$command: Invalid command"
	}

	my $box = hash(~$<label>);
	for @boxes[$box].kv -> $i, $lens {
		next unless $lens<label> eq $<label>;
		
		if ($<symbol> eq '-') {
			@boxes[$box].splice($i, 1);
		} else {
			$lens<f> = +$<focus>;
		}

		return;
	}

	@boxes[$box].push({ label => ~$<label>, f => +$<focus> })
		if $<symbol> eq '=';
}

sub power(@boxes) {
	[+] gather for @boxes.kv -> $bi, $box {
		next if !$box;
		for $box.kv -> $li, $lens {
			take ($bi + 1) * ($li + 1) * $lens<f>;
		}
	}
}

our sub part2(IO::Handle $in) {
	my @boxes;

	for $in.lines».split(',').flat -> $command {
		interpret(@boxes, $command);
	}

	power(@boxes);
}
