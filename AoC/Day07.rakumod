unit module AoC::Day07;


# Day 06: Camel Cards
# -------------------

class Card {
	has Str $.label;

	method Str() {
		"⁅" ~ $.label ~ "⁆"
	}

	method gist() { self.Str }

	method value() {
		given $.label {
			when '2' .. '9' { return $.label.Int }
			when 'T' { return 10 }
			when 'J' { return 11 }
			when 'Q' { return 12 }
			when 'K' { return 13 }
			when 'A' { return 14 }
			default { die "Bug: Unknown label $.label" }
		}
	}
}

multi infix:<cmp>(Card $a, Card $b) {
	$a.value <=> $b.value
}

multi infix:<before>(Card $a, Card $b) { ($a cmp $b) == Less }
multi infix:<after>(Card $a, Card $b) { ($a cmp $b) == More }
multi infix:<eqv>(Card $a, Card $b) { ($a cmp $b) == Same }

enum Rank <FiveOfAKind FourOfAKind FullHouse ThreeOfAKind TwoPair OnePair HighCard>;

class Hand {
	has Card @.cards;
	has Rank $.rank;
	has Int $.bid;

	method Str() {
		"⟨" ~ @.cards ~ " $.rank : " ~ $.bid ~ "⟩"
	}

	method gist() { self.Str }
}

grammar Hand::Grammar {
	rule TOP { <cards> <number> }
	rule cards { <card>+ }
	token card { <[ 2 .. 9 T J Q K A ]> }
	token number { \d+ }
}

class Ranking {
	method !select(@cards, $n) {
		my $bag = @cards.map(*.value).Bag;
		my @sorted = @cards.sort: * Rcmp *;
		my $key = $bag.pairs.grep(-> $k { $k.value == $n }).map(*.key).sort(&infix:<Rcmp>)[0];

		return () if !$key;
		return |@sorted.grep(*.value == $key), |@sorted.grep(*.value != $key);
	}

	method !two-pair(@cards) {
		?my @p1 = self!select(@cards, 2)
				and my @p2 = self!select(@p1[2 .. *], 2);
	}

	method !full-house(@cards) {
		?my @p1 = self!select(@cards, 3)
				and my @p2 = self!select(@p1[3 .. *], 2)
	}

	method evaluate(@cards) {
		my @sorted;
		return FiveOfAKind if self!select(@cards, 5);
		return FourOfAKind if self!select(@cards, 4);
		return FullHouse if self!full-house(@cards);
		return ThreeOfAKind if self!select(@cards, 3);
		return TwoPair if self!two-pair(@cards);
		return OnePair if self!select(@cards, 2);
		return HighCard;
	}
}

class Hand::Actions {
	method TOP($/) {
		my $rank = Ranking.evaluate($/<cards>.made);
		make Hand.new(cards => $/<cards>.made, rank => $rank, bid => +$/<number>)
	}

	method cards($/) {
		make [|$/<card>.map(-> $c { Card.new(label => ~$c) })]
	}
}

multi infix:<cmp>(Hand $a, Hand $b) {
	return Less if $a.rank < $b.rank;
	return More if $a.rank > $b.rank;
	(($a.cards Z[Rcmp] $b.cards).grep: * != Same)[0] // Same
}

sub get-hands($in) {
	gather for $in.lines -> $line {
		if my $p = Hand::Grammar.parse($line, actions => Hand::Actions) {
			take $p.made;
		} else {
			die "Cannot parse input '$line'";
		}
	}
}

sub C($c) { Card.new(label => $c) }
sub CC($s) { $s.comb.map(-> $c { C($c) }) }

our sub part1(IO::Handle $in) {
	my @hands = get-hands($in);
	my @ranked = @hands.sort: * Rcmp *;

	[+] @ranked.pairs.map(-> $p { ($p.key + 1) * $p.value.bid });
}
