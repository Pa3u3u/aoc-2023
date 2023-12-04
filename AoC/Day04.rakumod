unit module AoC::Day04;


# Day 04: Scratchcards
# --------------------

class Card {
	has $.id;
	has @.win;
	has @.bet;

	method wins(Card:D:) {
		@.win ∩ @.bet
	}
}

grammar Card::Grammar {
	rule TOP { 'Card' <id> ':' <win=.numbers> '|' <bet=.numbers> }
	rule numbers { [ (\d+) ]+ }
	token id { \d+ }
}

class Card::Actions {
	method TOP($/) {
		make Card.new(
			id => +$<id>,
			win => $<win>.made.flat,
			bet => $<bet>.made.flat,
		)
	}

	method numbers($/) {
		make $/.map({ $^a>>.Int })
	}
}

sub get-cards($in) {
	gather for $in.lines -> $line {
		if my $r = Card::Grammar.parse($line, actions => Card::Actions) {
			take $r.made;
		} else {
			warn "Could not parse input «$line»";
		}
	}
}

sub evaluate-card(Card $card) {
	my $won = $card.wins;
	$won ?? 2 ** (+$won - 1) !! 0
}

our sub part1(IO::Handle $in) {
	my @cards = get-cards($in);
	[+] @cards.map: { evaluate-card($^a) }
}

our sub part2(IO::Handle $in) {
	my @cards = get-cards($in);
	my @wins = (1) xx @cards;

	for @wins.kv -> $ix, $count {
		my $n = +@cards[$ix].wins;
		@wins[$ix + $_] += $count for 1 .. min($n, +@cards - $ix - 1);
	}

	[+] @wins;
}
