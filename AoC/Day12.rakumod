unit module AoC::Day12;


# Day 12: Hot Springs
# -------------------

sub parse(Str $line) {
	if $line ~~ /^^ ( <[ # . ? ]>+ ) \s+ ( \d+ | ',' )+ $$/ {
		return ($/[0].comb, $/[1].split(',')>>.Int);
	}

	die "Cannot parse '$line' as input instance";
}

# (x₁, x₂, …, xₙ) ⪽ (y₁, ₂₂, …, yₙ, …, yₘ) iff
#   (∀k < n)(xₖ = yₖ) ∧ (xₙ ≤ yₙ)
multi infix:<⪽>(@a, @b --> Bool) {
	return False if @a.elems > @b.elems;

	for (@a Z @b).kv -> $i, ($an, $bn) {
		return False if $i < (@a.elems - 1) && $an != $bn;
		return False if $i == (@a.elems - 1) && $an > $bn;
	}

	return True;
}

# (x₁, x₂, …, xₙ) ⫘ (y₁, ₂₂, …, yₙ, …, yₘ) iff
#   (∀k ≤ n)(xₖ = yₖ) ∧ (n = m)
multi infix:<⫘>(@a, @b) {
	@a eqv @b
}

sub set-ok($index, @template, @fixed, @control, @count) {
	search-space(@template, (|@fixed, '.'), @control, @count)
}

sub set-failed($index, @template, @fixed, @control, @count) {
	search-space(@template, (|@fixed, '#'), @control,
		@fixed.elems == 0 || @fixed[*-1] eq '.' ?? (|@count, 1) !! (|@count[0 .. *-2], @count[*-1] + 1)
	)
}

sub is-solution(@template, @fixed, @control, @count) {
	@template.elems == @fixed.elems
		&& @count ⫘  @control

}

sub search-space(@template, @fixed, @control, @count) {
	return 1 if is-solution(@template, @fixed, @control, @count);
	return 0 if !(@count ⪽  @control);

	my $index = @fixed.elems;
	given @template[$index] {
		when '#' {
			set-failed($index, @template, @fixed, @control, @count)
		}

		when '.' {
			set-ok($index, @template, @fixed, @control, @count)
		}

		when '?' {
			set-failed($index, @template, @fixed, @control, @count)
				+ set-ok($index, @template, @fixed, @control, @count)
		}
	}
}

sub solve(@template, @control) {
	[+] search-space(@template, @(), @control, @());
}

our sub part1(IO::Handle $in) {
	[+] $in.lines.map({ parse($^a) }).map({ solve($^a[0], $^a[1]) })
}
