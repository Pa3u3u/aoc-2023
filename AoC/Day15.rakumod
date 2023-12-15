unit module AoC::Day15;


# Day 15: Lens Library
# --------------------

sub hash(Str $s) {
	(0, |$s.comb.map(*.ord)).reduce({ (17 * ($^a + $^b)) % 256 })
}

our sub part1(IO::Handle $in) {
	[+] $in.lines».split(',').flat.map(&hash)
}
