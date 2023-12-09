unit module AoC::Day09;


# Day 09: Mirage Maintenance
# --------------------------

sub next-value(@measurement) {
	return 0 if @measurement.all == 0;

	my @Δ = (0 .. (@measurement.elems - 2)).map({ [-] @measurement[$^a + 1, $^a] });
	return @measurement[*-1] + next-value(@Δ);
}

our sub part1(IO::Handle $in) {
	[+] $in.lines.map(*.split(/\s/)>>.Int).map(&next-value)
}

sub prev-value(@measurement) {
	return 0 if @measurement.all == 0;

	my @Δ = (0 .. (@measurement.elems - 2)).map({ [-] @measurement[$^a + 1, $^a] });
	return @measurement[0] - prev-value(@Δ);
}

our sub part2(IO::Handle $in) {
	[+] $in.lines.map(*.split(/\s/)>>.Int).map(&prev-value)
}
