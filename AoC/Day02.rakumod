unit module AoC::Day02;


# Day 02: Cube Conundrum
# ----------------------

class Game::Turn {
	has $.balls;

	method new(@items) {
		self.bless(balls => BagHash.new-from-pairs: @items);
	}

	method is-possible(%config) {
		$.balls.map({
			.pairs.map(-> (:key($c), :value($n)) { say ":$c-$n"; %config{$c} >= $n })
		}).flat.all.Bool;
	}
}

class Game {
	has Int $.id;
	has Game::Turn @.turns;

	method add-turn(Game::Turn $turn) {
		@.turns.push($turn);
	}

	method is-possible(%config --> Bool) {
		@.turns.all.is-possible(%config).Bool;
	}

	method !minimum() {
		say reduce { %^a{$^b.key} max= $^b.value },
			(|(%()), @.turns.map({ .balls.map: { .pairs } }).flat);
	}

	method power() {
		[*] self!minimum.values
	}
}

grammar Game::Grammar {
	rule TOP { <game-id> [ <turn> ]+ % ';' }
	rule game-id { 'Game' <id> ':' }
	rule turn { [ <turn-spec> ]+ % ',' }
	rule turn-spec { <count> <colour> }

	token count { \d+ }
	token colour { \w+ }
	token id { \d+ }
}

class Game::Actions {
	method TOP($/) {
		make Game.new(
			id => $/<game-id>.made,
			turns => $/<turn>».made,
		)
	}

	method game-id($/) { make $/<id>.made }

	method turn($/) {
		make Game::Turn.new(
			$/<turn-spec>».made
		)
	}

	method turn-spec($/) {
		make $<colour>.made => $<count>.made
	}

	method id($/) { make +$/ }
	method count($/) { make +$/ }
	method colour($/) { make $/ }
}

sub get-games(IO::Handle $in) {
	gather {
		for $in.lines -> $line {
			if my $result = Game::Grammar.parse($line, :actions(Game::Actions)) {
				take $result.made;
			} else {
				warn "Could not parse input «$line»";
			}
		}
	}
}

my %config = :red(12), :green(13), :blue(14);

our sub part1(IO::Handle $in) {
	sum get-games($in).grep({ .is-possible(%config) }).map: { .id }
}

our sub part2(IO::Handle $in) {
	sum get-games($in).map({ .power })
}
