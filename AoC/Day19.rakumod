unit module AoC::Day19;


# Day 19: Aplenty
# ---------------

class Branch {
	has $.attr;
	has $.value;
	has $.op;
	has $.target;

	method Str(::?CLASS:D:) {
		($.attr, { Less => '<', More => '>' }{$.op}, $.value).join(' ') ~ " => $.target"
	}

	method eval($i) {
		($i{$.attr} <=> $.value) eqv $.op ?? $.target !! Nil
	}
}

class Workflow {
	has $.name;
	has @.branches;
	has $.default;

	method eval($i) {
		for @.branches -> $b {
			if my $name = $b.eval($i) {
				return $name;
			}
		}
	
		return $.default;
	}

	method Str(::?CLASS:D:) {
		"[($.name) " ~ (@.branches.join('; ')) ~ ";; Ø -> " ~ $.default ~ "]"
	}
}
	
grammar Workflow::Grammar {
	rule TOP { <name=.id> '{' [[<branch>+ % ','] ',' <default=.id>] '}' }
	rule branch { <attr=.id> <rel-op> <value> ':' <target=.id> }

	token id { \w+ }
	token value { \d+ }

	proto token rel-op {*}
	token rel-op:sym<less> { '<' }
	token rel-op:sym<more> { '>' }
}

class Workflow::Actions {
	method TOP($/) {
		make Workflow.new(
			name => ~$/<name>,
			default => ~$/<default>,
			branches => $/<branch>».made,
		)
	}

	method branch($/) {
		make Branch.new(
			attr => ~$/<attr>,
			value => +$/<value>,
			op => $/<rel-op>.made,
			target => ~$/<target>,
		)
	}

	method rel-op:sym<less>($/) { make Less }
	method rel-op:sym<more>($/) { make More }
}

grammar Item::Grammar {
	rule TOP { '{' [ <pair> ]+ % ',' '}' }
	rule pair { <attr> '=' <value> }
	token attr { \w+ }
	token value { \d+ }
}

class Item::Actions {
	method TOP($/) {
		make %($/<pair>».made)
	}

	method pair($/) {
		make (~$/<attr> => +$/<value>)
	}
}

sub parse-workflows(IO::Handle $in) {
	gather while my $line = $in.get {
		if my $m = Workflow::Grammar.parse($line, actions => Workflow::Actions) {
			take $m.made;
		} else {
			die "$line: Cannot parse workflow";
		}
	}
}

sub parse-items(IO::Handle $in) {
	gather while (my $line = $in.get) {
		if my $i = Item::Grammar.parse($line, actions => Item::Actions) {
			take $i.made;
		} else {
			die "$line: Cannot parse item";
		}
	}
}

sub parse(IO::Handle $in) {
	%(parse-workflows($in).map({ $^a.name, $^a }).flat), [parse-items($in)]
}

sub filter-item(%workflows, $item) {
	my $chain = 'in';

	while $chain ne 'A'|'R' {
		$chain = %workflows{$chain}.eval($item);
	}

	return $chain eq 'A';
}

sub filter-items(%workflows, @items) {
	gather for @items -> $item {
		take $item if filter-item(%workflows, $item);
	}
}

our sub part1(IO::Handle $in) {
	my (%workflows, @items) := parse($in);
	[+] filter-items(%workflows, @items).map(*.values).flat
}
