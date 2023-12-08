unit module AoC::Day08;


# Day 08: Haunted Wasteland
# -------------------------

grammar Node::Grammar {
	rule TOP { <instr> <node-rule>+ }
	rule node-rule { <from=.node> '=' '(' <left=.node> ',' <right=.node> ')' }
	token instr { <[ R L ]>+ }
	token node { \w+ }
}

class Node::Actions {
	method TOP($/) {
		make [ (~$/<instr>).comb, ($/<node-rule>».made).Map ]
	}

	method node-rule($/) {
		make ~$/<from> => { L => ~$/<left>, R => ~$/<right> };
	}
}

sub transit(@cmd, $rules, $start, $cond) {
	my $step = 0;
	my $node = $start;

	while $node !~~ $cond {
		my $direction = @cmd[$step % @cmd.elems];
		$node = $rules{$node}{$direction};
		$step++;
	}

	$step;
}


our sub part1(IO::Handle $in) {
	if !(my $p = Node::Grammar.parse($in.slurp, actions => Node::Actions)) {
		die "Cannot parse input"
	}

	my (@cmd, $rules) := $p.made;
	transit(@cmd, $rules, 'AAA', rx/^ZZZ$/)
}

our sub part2(IO::Handle $in) {
	if !(my $p = Node::Grammar.parse($in.slurp, actions => Node::Actions)) {
		die "Cannot parse input"
	}

	my (@cmd, $rules) := $p.made;
	[lcm] $rules.keys.grep(* ~~ /A $$/).map({transit(@cmd, $rules, $^a, rx/Z $$/)});
}
