unit module Array::Sorted::Util:ver<0.0.1>:auth<cpan:ELIZABETH>;

use nqp;

proto sub finds(|)   is export {*}
proto sub inserts(|) is export {*}
proto sub deletes(|) is export {*}

#-------------------------------------------------------------------------------
# Publicly visible opaque candidates

my multi sub finds(@a, $needle) {
    nqp::islt_i((my int $i = finds_o_cmp(@a, $needle, &[cmp])),0)
      ?? Nil
      !! $i
}
my multi sub finds(@a, $needle, :&cmp!) {
    nqp::islt_i((my int $i = finds_o_cmp(@a, $needle, &cmp)),0)
      ?? Nil
      !! $i
}

my multi sub inserts(@a, $needle, :$force) {
    inserts_o_cmp(
      @a, $needle, finds_o_cmp(@a, $needle, &[cmp]), &[cmp], $force.Bool
    )
}
my multi sub inserts(@a, $needle, :&cmp!, :$force) {
    inserts_o_cmp(
      @a, $needle, finds_o_cmp(@a, $needle, &cmp), &cmp, $force.Bool
    )
}

my multi sub deletes(@a, $needle) {
    nqp::if(
      nqp::islt_i((my int $i = finds_o_cmp(@a, $needle, &[cmp])),0),
      Nil,
      nqp::stmts(
        @a.splice($i,1),
        $needle
      )
    )
}
my multi sub deletes(@a, $needle, :&cmp!) {
    nqp::if(
      nqp::islt_i((my int $i = finds_o_cmp(@a, $needle, &cmp)),0),
      Nil,
      nqp::stmts(
        @a.splice($i,1),
        $needle
      )
    )
}

#-------------------------------------------------------------------------------
# Actual opaque workhorses

my sub finds_o_cmp(@a, $needle, &cmp) {
    my int $start;
    my int $elems = @a.elems;   # reifies
    my int $end   = nqp::sub_i($elems,1);
    my int $i     = nqp::div_i($elems,2);

    nqp::while(
      nqp::isge_i($i,$start) && nqp::isle_i($i,$end),  # not done yet
      nqp::if(
        nqp::eqaddr(
          (my $cmp := cmp($needle,@a.AT-POS($i))),
          Order::Less
        ),
        nqp::stmts(                                    # needle is less
          ($end = nqp::sub_i($i,1)),
          ($i = nqp::div_i(
            nqp::add_i($start,nqp::add_i($end,1)),
            2
          ))
        ),
        nqp::if(
          nqp::eqaddr($cmp,Order::More),
          nqp::if(                                     # needle is more
            nqp::islt_i($i,$end),
            nqp::stmts(                                # still before end
              ($start = nqp::add_i($i,1)),
              ($i = nqp::div_i(
                nqp::add_i($start,nqp::add_i($end,1)),
                2
              ))
            ),
            (return nqp::neg_i(nqp::add_i($end,2)))    # at end
          ),
          nqp::stmts(                                  # found needle
            nqp::while(                                # find first occurrence
              nqp::isge_i(($i = nqp::sub_i($i,1)),0)
                && nqp::eqaddr(cmp($needle,@a.AT-POS($i)),Order::Same),
              nqp::null
            ),
            (return nqp::add_i($i,1))
          )
        )
      )
    );

    # before or after the list
    nqp::neg_i(nqp::add_i($i,1))
}

my sub inserts_o_cmp(@a, $needle, int $i, &cmp, int $force) {
    nqp::if(
      nqp::islt_i($i,0),
      @a.splice(nqp::abs_i(nqp::add_i($i,1)),0,$needle),# not found
      nqp::if(                                          # found
        $force,
        nqp::stmts(                                     # force insertion
          (my int $j = $i),
          (my int $elems = @a.elems),
          nqp::while(                                   # insert after last
            nqp::islt_i(($j = nqp::add_i($j,1)),$elems)
              && nqp::eqaddr(cmp($needle,@a.AT-POS($j)),Order::Same),
            nqp::null
          ),
          @a.splice($j,0,$needle)
        )
      )
    );

    @a
}

#- start of generated part of str candidates ----------------------------------
#- Generated on 2021-04-15T22:43:01+02:00 by ./makeNATIVES.raku
#- PLEASE DON'T CHANGE ANYTHING BELOW THIS LINE
my str @insert_s;
my str @delete_s;

#-------------------------------------------------------------------------------
# Publicly visible str candidates

my multi sub finds(str @a, Str:D $needle) {
    nqp::islt_i((my int $i = finds_s(@a, $needle)),0)
      ?? Nil
      !! $i
}
my multi sub finds(str @a, Str:D $needle, :&cmp!) {
    nqp::islt_i((my int $i = finds_s_cmp(@a, $needle, &cmp)),0)
      ?? Nil
      !! $i
}

my multi sub inserts(str @a, Str:D $needle, :$force) {
    inserts_s(@a, $needle, finds_s(@a, $needle), $force.Bool)
}
my multi sub inserts(str @a, Str:D $needle, :&cmp!, :$force) {
    inserts_s(@a, $needle, finds_s_cmp(@a, $needle, &cmp), $force.Bool)
}

my multi sub deletes(str @a, Str:D $needle) {
    nqp::if(
      nqp::islt_i((my int $i = finds_s(@a, $needle)),0),
      Nil,
      nqp::stmts(
        nqp::splice(@a,@delete_s,$i,1),
        $needle
      )
    )
}
my multi sub deletes(str @a, Str:D $needle, :&cmp!) {
    nqp::if(
      nqp::islt_i((my int $i = finds_s_cmp(@a, $needle, &cmp)),0),
      Nil,
      nqp::stmts(
        nqp::splice(@a,@delete_s,$i,1),
        $needle
      )
    )
}

#-------------------------------------------------------------------------------
# Actual str workhorses

my sub finds_s(str @a, str $needle) {
    my int $start;
    my int $end = nqp::sub_i(nqp::elems(@a),1);
    my int $i   = nqp::div_i(nqp::elems(@a),2);

    nqp::while(
      nqp::isge_i($i,$start) && nqp::isle_i($i,$end),  # not done yet
      nqp::if(
        (my int $cmp = nqp::cmp_s($needle,nqp::atpos_s(@a,$i))),
        nqp::if(                                       # not same
          nqp::islt_i($cmp,0),
          nqp::stmts(                                  # needle is less
            ($end = nqp::sub_i($i,1)),
            ($i = nqp::div_i(
              nqp::add_i($start,nqp::add_i($end,1)),
              2
            ))
          ),
          nqp::if(                                     # needle is more
            nqp::islt_i($i,$end),
            nqp::stmts(                                # still before end
              ($start = nqp::add_i($i,1)),
              ($i = nqp::div_i(
                nqp::add_i($start,nqp::add_i($end,1)),
                2
              ))
            ),
            (return nqp::neg_i(nqp::add_i($end,2)))    # at end
          )
        ),
        nqp::stmts(                                    # needle found
          nqp::while(                                  # find first occurrence
            nqp::isge_i(($i = nqp::sub_i($i,1)),0)
              && nqp::iseq_s($needle,nqp::atpos_s(@a,$i)),
            nqp::null
          ),
          (return nqp::add_i($i,1))
        )
      )
    );

    # before or after the list
    nqp::neg_i(nqp::add_i($i,1))
}

my sub finds_s_cmp(str @a, str $needle, &cmp) {
    my int $start;
    my int $end = nqp::sub_i(nqp::elems(@a),1);
    my int $i   = nqp::div_i(nqp::elems(@a),2);

    nqp::while(
      nqp::isge_i($i,$start) && nqp::isle_i($i,$end),  # not done yet
      nqp::if(
        nqp::eqaddr(
          (my $cmp := cmp($needle,nqp::atpos_s(@a,$i))),
          Order::Less
        ),
        nqp::stmts(                                    # needle is less
          ($end = nqp::sub_i($i,1)),
          ($i = nqp::div_i(
            nqp::add_i($start,nqp::add_i($end,1)),
            2
          ))
        ),
        nqp::if(
          nqp::eqaddr($cmp,Order::More),
          nqp::if(                                     # needle is more
            nqp::islt_i($i,$end),
            nqp::stmts(                                # still before end
              ($start = nqp::add_i($i,1)),
              ($i = nqp::div_i(
                nqp::add_i($start,nqp::add_i($end,1)),
                2
              ))
            ),
            (return nqp::neg_i(nqp::add_i($end,2)))    # at end
          ),
          nqp::stmts(                                  # found needle
            nqp::while(                                # find first occurrence
              nqp::isge_i(($i = nqp::sub_i($i,1)),0)
                && nqp::iseq_s($needle,nqp::atpos_s(@a,$i)),
              nqp::null
            ),
            (return nqp::add_i($i,1))
          )
        )
      )
    );

    # before or after the list
    nqp::neg_i(nqp::add_i($i,1))
}

my sub inserts_s(str @a, str $needle, int $i, int $force) {
    nqp::bindpos_s(@insert_s,0,$needle);
    nqp::if(
      nqp::islt_i($i,0),
      nqp::splice(                                      # not found
        @a,@insert_s,nqp::abs_i(nqp::add_i($i,1)),0
      ),
      nqp::if(                                          # found
        $force,
        nqp::stmts(                                     # force insertion
          (my int $j = $i),
          nqp::while(                                   # insert after last
            nqp::islt_i(($j = nqp::add_i($j,1)),nqp::elems(@a))
              && nqp::iseq_s($needle,nqp::atpos_s(@a,$j)),
            nqp::null
          ),
          nqp::splice(@a,@insert_s,$j,0)
        )
      )
    );

    @a
}
#- PLEASE DON'T CHANGE ANYTHING ABOVE THIS LINE
#- end of generated part of str candidates ------------------------------------

#- start of generated part of int candidates ----------------------------------
#- Generated on 2021-04-15T22:43:01+02:00 by ./makeNATIVES.raku
#- PLEASE DON'T CHANGE ANYTHING BELOW THIS LINE
my int @insert_i;
my int @delete_i;

#-------------------------------------------------------------------------------
# Publicly visible int candidates

my multi sub finds(int @a, Int:D $needle) {
    nqp::islt_i((my int $i = finds_i(@a, $needle)),0)
      ?? Nil
      !! $i
}
my multi sub finds(int @a, Int:D $needle, :&cmp!) {
    nqp::islt_i((my int $i = finds_i_cmp(@a, $needle, &cmp)),0)
      ?? Nil
      !! $i
}

my multi sub inserts(int @a, Int:D $needle, :$force) {
    inserts_i(@a, $needle, finds_i(@a, $needle), $force.Bool)
}
my multi sub inserts(int @a, Int:D $needle, :&cmp!, :$force) {
    inserts_i(@a, $needle, finds_i_cmp(@a, $needle, &cmp), $force.Bool)
}

my multi sub deletes(int @a, Int:D $needle) {
    nqp::if(
      nqp::islt_i((my int $i = finds_i(@a, $needle)),0),
      Nil,
      nqp::stmts(
        nqp::splice(@a,@delete_i,$i,1),
        $needle
      )
    )
}
my multi sub deletes(int @a, Int:D $needle, :&cmp!) {
    nqp::if(
      nqp::islt_i((my int $i = finds_i_cmp(@a, $needle, &cmp)),0),
      Nil,
      nqp::stmts(
        nqp::splice(@a,@delete_i,$i,1),
        $needle
      )
    )
}

#-------------------------------------------------------------------------------
# Actual int workhorses

my sub finds_i(int @a, int $needle) {
    my int $start;
    my int $end = nqp::sub_i(nqp::elems(@a),1);
    my int $i   = nqp::div_i(nqp::elems(@a),2);

    nqp::while(
      nqp::isge_i($i,$start) && nqp::isle_i($i,$end),  # not done yet
      nqp::if(
        (my int $cmp = nqp::cmp_i($needle,nqp::atpos_i(@a,$i))),
        nqp::if(                                       # not same
          nqp::islt_i($cmp,0),
          nqp::stmts(                                  # needle is less
            ($end = nqp::sub_i($i,1)),
            ($i = nqp::div_i(
              nqp::add_i($start,nqp::add_i($end,1)),
              2
            ))
          ),
          nqp::if(                                     # needle is more
            nqp::islt_i($i,$end),
            nqp::stmts(                                # still before end
              ($start = nqp::add_i($i,1)),
              ($i = nqp::div_i(
                nqp::add_i($start,nqp::add_i($end,1)),
                2
              ))
            ),
            (return nqp::neg_i(nqp::add_i($end,2)))    # at end
          )
        ),
        nqp::stmts(                                    # needle found
          nqp::while(                                  # find first occurrence
            nqp::isge_i(($i = nqp::sub_i($i,1)),0)
              && nqp::iseq_s($needle,nqp::atpos_i(@a,$i)),
            nqp::null
          ),
          (return nqp::add_i($i,1))
        )
      )
    );

    # before or after the list
    nqp::neg_i(nqp::add_i($i,1))
}

my sub finds_i_cmp(int @a, int $needle, &cmp) {
    my int $start;
    my int $end = nqp::sub_i(nqp::elems(@a),1);
    my int $i   = nqp::div_i(nqp::elems(@a),2);

    nqp::while(
      nqp::isge_i($i,$start) && nqp::isle_i($i,$end),  # not done yet
      nqp::if(
        nqp::eqaddr(
          (my $cmp := cmp($needle,nqp::atpos_i(@a,$i))),
          Order::Less
        ),
        nqp::stmts(                                    # needle is less
          ($end = nqp::sub_i($i,1)),
          ($i = nqp::div_i(
            nqp::add_i($start,nqp::add_i($end,1)),
            2
          ))
        ),
        nqp::if(
          nqp::eqaddr($cmp,Order::More),
          nqp::if(                                     # needle is more
            nqp::islt_i($i,$end),
            nqp::stmts(                                # still before end
              ($start = nqp::add_i($i,1)),
              ($i = nqp::div_i(
                nqp::add_i($start,nqp::add_i($end,1)),
                2
              ))
            ),
            (return nqp::neg_i(nqp::add_i($end,2)))    # at end
          ),
          nqp::stmts(                                  # found needle
            nqp::while(                                # find first occurrence
              nqp::isge_i(($i = nqp::sub_i($i,1)),0)
                && nqp::iseq_s($needle,nqp::atpos_i(@a,$i)),
              nqp::null
            ),
            (return nqp::add_i($i,1))
          )
        )
      )
    );

    # before or after the list
    nqp::neg_i(nqp::add_i($i,1))
}

my sub inserts_i(int @a, int $needle, int $i, int $force) {
    nqp::bindpos_i(@insert_i,0,$needle);
    nqp::if(
      nqp::islt_i($i,0),
      nqp::splice(                                      # not found
        @a,@insert_i,nqp::abs_i(nqp::add_i($i,1)),0
      ),
      nqp::if(                                          # found
        $force,
        nqp::stmts(                                     # force insertion
          (my int $j = $i),
          nqp::while(                                   # insert after last
            nqp::islt_i(($j = nqp::add_i($j,1)),nqp::elems(@a))
              && nqp::iseq_s($needle,nqp::atpos_i(@a,$j)),
            nqp::null
          ),
          nqp::splice(@a,@insert_i,$j,0)
        )
      )
    );

    @a
}
#- PLEASE DON'T CHANGE ANYTHING ABOVE THIS LINE
#- end of generated part of int candidates ------------------------------------

#- start of generated part of num candidates ----------------------------------
#- Generated on 2021-04-15T22:43:01+02:00 by ./makeNATIVES.raku
#- PLEASE DON'T CHANGE ANYTHING BELOW THIS LINE
my num @insert_n;
my num @delete_n;

#-------------------------------------------------------------------------------
# Publicly visible num candidates

my multi sub finds(num @a, Num:D $needle) {
    nqp::islt_i((my int $i = finds_n(@a, $needle)),0)
      ?? Nil
      !! $i
}
my multi sub finds(num @a, Num:D $needle, :&cmp!) {
    nqp::islt_i((my int $i = finds_n_cmp(@a, $needle, &cmp)),0)
      ?? Nil
      !! $i
}

my multi sub inserts(num @a, Num:D $needle, :$force) {
    inserts_n(@a, $needle, finds_n(@a, $needle), $force.Bool)
}
my multi sub inserts(num @a, Num:D $needle, :&cmp!, :$force) {
    inserts_n(@a, $needle, finds_n_cmp(@a, $needle, &cmp), $force.Bool)
}

my multi sub deletes(num @a, Num:D $needle) {
    nqp::if(
      nqp::islt_i((my int $i = finds_n(@a, $needle)),0),
      Nil,
      nqp::stmts(
        nqp::splice(@a,@delete_n,$i,1),
        $needle
      )
    )
}
my multi sub deletes(num @a, Num:D $needle, :&cmp!) {
    nqp::if(
      nqp::islt_i((my int $i = finds_n_cmp(@a, $needle, &cmp)),0),
      Nil,
      nqp::stmts(
        nqp::splice(@a,@delete_n,$i,1),
        $needle
      )
    )
}

#-------------------------------------------------------------------------------
# Actual num workhorses

my sub finds_n(num @a, num $needle) {
    my int $start;
    my int $end = nqp::sub_i(nqp::elems(@a),1);
    my int $i   = nqp::div_i(nqp::elems(@a),2);

    nqp::while(
      nqp::isge_i($i,$start) && nqp::isle_i($i,$end),  # not done yet
      nqp::if(
        (my int $cmp = nqp::cmp_n($needle,nqp::atpos_n(@a,$i))),
        nqp::if(                                       # not same
          nqp::islt_i($cmp,0),
          nqp::stmts(                                  # needle is less
            ($end = nqp::sub_i($i,1)),
            ($i = nqp::div_i(
              nqp::add_i($start,nqp::add_i($end,1)),
              2
            ))
          ),
          nqp::if(                                     # needle is more
            nqp::islt_i($i,$end),
            nqp::stmts(                                # still before end
              ($start = nqp::add_i($i,1)),
              ($i = nqp::div_i(
                nqp::add_i($start,nqp::add_i($end,1)),
                2
              ))
            ),
            (return nqp::neg_i(nqp::add_i($end,2)))    # at end
          )
        ),
        nqp::stmts(                                    # needle found
          nqp::while(                                  # find first occurrence
            nqp::isge_i(($i = nqp::sub_i($i,1)),0)
              && nqp::iseq_s($needle,nqp::atpos_n(@a,$i)),
            nqp::null
          ),
          (return nqp::add_i($i,1))
        )
      )
    );

    # before or after the list
    nqp::neg_i(nqp::add_i($i,1))
}

my sub finds_n_cmp(num @a, num $needle, &cmp) {
    my int $start;
    my int $end = nqp::sub_i(nqp::elems(@a),1);
    my int $i   = nqp::div_i(nqp::elems(@a),2);

    nqp::while(
      nqp::isge_i($i,$start) && nqp::isle_i($i,$end),  # not done yet
      nqp::if(
        nqp::eqaddr(
          (my $cmp := cmp($needle,nqp::atpos_n(@a,$i))),
          Order::Less
        ),
        nqp::stmts(                                    # needle is less
          ($end = nqp::sub_i($i,1)),
          ($i = nqp::div_i(
            nqp::add_i($start,nqp::add_i($end,1)),
            2
          ))
        ),
        nqp::if(
          nqp::eqaddr($cmp,Order::More),
          nqp::if(                                     # needle is more
            nqp::islt_i($i,$end),
            nqp::stmts(                                # still before end
              ($start = nqp::add_i($i,1)),
              ($i = nqp::div_i(
                nqp::add_i($start,nqp::add_i($end,1)),
                2
              ))
            ),
            (return nqp::neg_i(nqp::add_i($end,2)))    # at end
          ),
          nqp::stmts(                                  # found needle
            nqp::while(                                # find first occurrence
              nqp::isge_i(($i = nqp::sub_i($i,1)),0)
                && nqp::iseq_s($needle,nqp::atpos_n(@a,$i)),
              nqp::null
            ),
            (return nqp::add_i($i,1))
          )
        )
      )
    );

    # before or after the list
    nqp::neg_i(nqp::add_i($i,1))
}

my sub inserts_n(num @a, num $needle, int $i, int $force) {
    nqp::bindpos_n(@insert_n,0,$needle);
    nqp::if(
      nqp::islt_i($i,0),
      nqp::splice(                                      # not found
        @a,@insert_n,nqp::abs_i(nqp::add_i($i,1)),0
      ),
      nqp::if(                                          # found
        $force,
        nqp::stmts(                                     # force insertion
          (my int $j = $i),
          nqp::while(                                   # insert after last
            nqp::islt_i(($j = nqp::add_i($j,1)),nqp::elems(@a))
              && nqp::iseq_s($needle,nqp::atpos_n(@a,$j)),
            nqp::null
          ),
          nqp::splice(@a,@insert_n,$j,0)
        )
      )
    );

    @a
}
#- PLEASE DON'T CHANGE ANYTHING ABOVE THIS LINE
#- end of generated part of num candidates ------------------------------------

=begin pod

=head1 NAME

Array::Sorted::Util - Raku utilities for (native) sorted arrays

=head1 SYNOPSIS

=begin code :lang<raku>

use Array::Sorted::Util;  # imports finds, inserts, deletes

my @a;
inserts(@a,$_) for <d c f e g h a b j i>;
say @a;               # [a b c d e f g h i j]

say finds(@a,"h");    # 7
say finds(@a,"z");    # Nil

say deletes(@a,"e");  # e
say @a;               # [a b c d f g h i j]

=end code

=head1 DESCRIPTION

Array::Sorted::Util exports a set of subroutines that create and manipulate
sorted arrays.

=head1 SUBROUTINES

=head2 inserts

=begin code :lang<raku>

my @a;
inserts(@a, "foo");  # use &infix:<cmp> by default

inserts(@a, "foo", :cmp(&[coll]));

=end code

Insert the given object (the second argument) into the correct location in
the given array (the first argument).  Takes a named argument C<cmp> to
indicate the logic that should be used to determine order (defaults
to &infix:<cmp>).

=head2 finds

=begin code :lang<raku>

my @a = <a b c d e f g h i j>;
say finds(@a, "h");                 # 7, use &infix:<cmp> by default
say finds(@a, "z", :cmp(&[coll]));  # Nil

=end code

Attempt to find the given object (the second argument) in the given
sorted array (the first argument).  Takes a named argument C<cmp> to
indicate the logic that should be used to determine order (defaults
to &infix:<cmp>).

=head2 deletes

=begin code :lang<raku>

my @a = <a b c d e f g h i j>;
say deletes(@a, "e");                 # e, use &infix:<cmp> by default
say deletes(@a, "z", :cmp(&[coll]));  # Nil

=end code

Attempt to remove the given object (the second argument) from the given
sorted array (the first argument).  Takes a named argument C<cmp> to
indicate the logic that should be used to determine order (defaults
to &infix:<cmp>).

=head1 INSPIRATION

The inspiration for these names is from the TUTOR Programming Language,
which had C<finds>, C<inserts> and C<deletes> commands.

See https://files.eric.ed.gov/fulltext/ED208879.pdf for more information
(pages C16 and C17).

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/List-Sorted-Util . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2021 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
