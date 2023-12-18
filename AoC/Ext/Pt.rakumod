unit module AoC::Ext::Pt;

class Pt is export {
	has Numeric $.x is rw;
	has Numeric $.y is rw;

	method Str(::?CLASS:D:) { "($.x, $.y)" }
	multi method gist(::?CLASS:D:) { self.Str }
}

sub pt(Numeric $x, Numeric $y) is export {
	Pt.new(:$x, :$y)
}

multi infix:<eqv>(Pt $a, Pt $b) is export {
	$a.x == $b.x && $a.y == $b.y
}

multi infix:<+>(Pt $a, Pt $b) is export {
	Pt.new(x => $a.x + $b.x, y => $a.y + $b.y)
}

multi infix:<->(Pt $a, Pt $b) is export {
	Pt.new(x => $a.x - $b.x, y => $a.y - $b.y)
}
