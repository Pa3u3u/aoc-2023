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

sub transit(@cmd, $rules, $start, $end) {
	my $n = 0;
	my $node = $start;

	while $node ne $end {
		$node = $rules{$node}{@cmd[$n % @cmd.elems]};
		$n++;
	}

	return $n;
}

our sub part1(IO::Handle $in) {
	if !(my $p = Node::Grammar.parse($in.slurp, actions => Node::Actions)) {
		die "Cannot parse input"
	}

	my (@cmd, $rules) := $p.made;
	transit(@cmd, $rules, 'AAA', 'ZZZ')
}
