unit module AoC::Day07;


# Day 06: Camel Cards
# -------------------

class Card {
	has Str $.label;

	method Str() {
		"⁅" ~ $.label ~ "⁆"
	}

	method gist() { self.Str }}

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
	method cmp-cards(Card $a, Card $b) {
		self.card-value($a) <=> self.card-value($b)
	}

	method cmp-hands(Hand $a, Hand $b) {
		return Less if $a.rank < $b.rank;
		return More if $a.rank > $b.rank;

		(($a.cards Z $b.cards).flat.map({ self.cmp-cards($^b, $^a) }).grep: * != Same)[0] // Same
	}

	method select(@cards, $n) {
		my $bag = @cards.map(-> $c { self.card-value($c) }).Bag;
		my @sorted = @cards.sort: * Rcmp *;
		my $key = $bag.pairs.grep(-> $k { $k.value == $n }).map(*.key).sort(&infix:<Rcmp>)[0];

		return () if !$key;
		return |@sorted.grep({ self.card-value($^a) == $key }), |@sorted.grep({ self.card-value($^a) != $key });
	}

	method !two-pair(@cards) {
		?my @p1 = self.select(@cards, 2)
				and my @p2 = self.select(@p1[2 .. *], 2)
	}

	method !full-house(@cards) {
		?my @p1 = self.select(@cards, 3)
				and my @p2 = self.select(@p1[3 .. *], 2)
	}

	method evaluate(@cards) {
		return FiveOfAKind if self.select(@cards, 5);
		return FourOfAKind if self.select(@cards, 4);
		return FullHouse if self!full-house(@cards);
		return ThreeOfAKind if self.select(@cards, 3);
		return TwoPair if self!two-pair(@cards);
		return OnePair if self.select(@cards, 2);
		return HighCard;
	}

	method card-value(Card $c) {
		given $c.label {
			when '2' .. '9' { return $c.label.Int }
			when 'T' { return 10 }
			when 'J' { return 11 }
			when 'Q' { return 12 }
			when 'K' { return 13 }
			when 'A' { return 14 }
			default { die "Bug: Unknown label $c.label" }
		}
	}
}

class Hand::Actions {
	has $.ranking;

	method TOP($/) {
		my $rank = $.ranking.evaluate($/<cards>.made);
		make Hand.new(cards => $/<cards>.made, rank => $rank, bid => +$/<number>)
	}

	method cards($/) {
		make [|$/<card>.map(-> $c { Card.new(label => ~$c) })]
	}
}

sub get-hands($in, $ranking = Ranking) {
	gather for $in.lines -> $line {
		if my $p = Hand::Grammar.parse($line, actions => Hand::Actions.new(:$ranking)) {
			take $p.made;
		} else {
			die "Cannot parse input '$line'";
		}
	}
}

our sub part1(IO::Handle $in) {
	my @hands = get-hands($in);
	my @ranked = @hands.sort(-> $a, $b { Ranking.cmp-hands($b, $a) });

	[+] @ranked.pairs.map(-> $p { ($p.key + 1) * $p.value.bid });
}

sub partition(&criterion, @list) {
	my (@t, @f);
	for @list -> $e {
		push (&criterion($e) ?? @t !! @f), $e;
	}

	return (@t, @f);
}

class WildRanking is Ranking {
	method card-value(Card $c) {
		return 1 if $c.label eq 'J';
		nextsame;
	}

	method select(@cards, $n) {
		my (@jokers, @rest) := partition({ $^a.label eq 'J' }, @cards);
		my $bag = @rest.map(-> $c { self.card-value($c) }).Bag;

		my @sorted = @rest.sort: * Rcmp *;
		my $jokers = +@jokers;

		my $key = $bag.pairs.grep(-> $k { $k.value + $jokers >= $n }).map(*.key).sort(&infix:<Rcmp>)[0];
		my $borrowed = $n - $bag{$key};

		nextsame if !$key;

		return |@sorted.grep({ self.card-value($^a) == $key }),
			|@jokers[0 ..^ $borrowed],
			|@sorted.grep({ self.card-value($^a) != $key }),
			|@jokers[$borrowed .. *];
	}
}

our sub part2(IO::Handle $in) {
	my @hands = get-hands($in, WildRanking);
	my @ranked = @hands.sort(-> $a, $b { WildRanking.cmp-hands($b, $a) });

	[+] @ranked.pairs.map(-> $p { ($p.key + 1) * $p.value.bid });
}
