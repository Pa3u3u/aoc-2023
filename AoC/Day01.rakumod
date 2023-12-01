unit module AoC::Day01;


# Day 01: Trebuchet?!
# -------------------

sub value(Int $a, Int $b --> Int) {
	10 * $a + $b
}

sub extract(Str $line --> Int) {
	($line ~~ m:g { \d }).map({ .Int }).[0, *-1].map(&value).[0]
}

our sub part1(IO::Handle $in) {
	sum $in.lines.map: &extract
}

sub extract2(Str $line --> Int) {
	state %nums = :1one, :2two, :3three, :4four, :5five, :6six, :7seven, :8eight, :9nine;
	state $names = %nums.keys.join: '||';
	($line ~~ m:ex:g { <$names> || \d }).map(-> $x { %nums{$x} // +$x }).[0, *-1].map(&value).[0]
}

our sub part2(IO::Handle $in) {
	sum $in.lines.map: &extract2
}
