unit module AoC::Ext::Math;

sub circumfix:<⌊ ⌋>(Real $n) is export { $n.floor }
sub circumfix:<⌈ ⌉>(Real $n) is export { $n.ceiling }
