unit module List::Sorted::Util:ver<0.0.1>:auth<cpan:ELIZABETH>;

use nqp;

proto sub finds(|)   is export {*}
proto sub inserts(|) is export {*}

#- start of generated part of str candidates ----------------------------------
#- Generated on 2021-04-15T15:44:10+02:00 by ./makeNATIVES.raku
#- PLEASE DON'T CHANGE ANYTHING BELOW THIS LINE
#-------------------------------------------------------------------------------
# Publicly visible str candidates

multi sub finds(str @a, Str:D $needle) {
    nqp::islt_i((my int $i = finds_s(@a, $needle)),0)
      ?? Nil
      !! $i
}
multi sub finds(str @a, Str:D $needle, :&cmp!) {
    nqp::islt_i((my int $i = finds_s_cmp(@a, $needle, &cmp)),0)
      ?? Nil
      !! $i
}

multi sub inserts(str @a, Str:D $needle, :$force) {
    inserts_s(@a, $needle, finds_s(@a, $needle), $force.Bool)
}
multi sub inserts(str @a, Str:D $needle, :&cmp!, :$force) {
    inserts_s(@a, $needle, finds_s_cmp(@a, $needle, &cmp), $force.Bool)
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
    nqp::if(
      nqp::islt_i($i,0),
      nqp::splice(                                      # not found
        @a,
        nqp::list_s($needle),
        nqp::abs_i(nqp::add_i($i,1)),
        0
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
          nqp::splice(@a,nqp::list_s($needle),$j,1)
        )
      )
    );

    @a
}
#- PLEASE DON'T CHANGE ANYTHING ABOVE THIS LINE
#- end of generated part of str candidates ------------------------------------

#- start of generated part of int candidates ----------------------------------
#- Generated on 2021-04-15T15:44:10+02:00 by ./makeNATIVES.raku
#- PLEASE DON'T CHANGE ANYTHING BELOW THIS LINE
#-------------------------------------------------------------------------------
# Publicly visible int candidates

multi sub finds(int @a, Int:D $needle) {
    nqp::islt_i((my int $i = finds_i(@a, $needle)),0)
      ?? Nil
      !! $i
}
multi sub finds(int @a, Int:D $needle, :&cmp!) {
    nqp::islt_i((my int $i = finds_i_cmp(@a, $needle, &cmp)),0)
      ?? Nil
      !! $i
}

multi sub inserts(int @a, Int:D $needle, :$force) {
    inserts_i(@a, $needle, finds_i(@a, $needle), $force.Bool)
}
multi sub inserts(int @a, Int:D $needle, :&cmp!, :$force) {
    inserts_i(@a, $needle, finds_i_cmp(@a, $needle, &cmp), $force.Bool)
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
    nqp::if(
      nqp::islt_i($i,0),
      nqp::splice(                                      # not found
        @a,
        nqp::list_i($needle),
        nqp::abs_i(nqp::add_i($i,1)),
        0
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
          nqp::splice(@a,nqp::list_i($needle),$j,1)
        )
      )
    );

    @a
}
#- PLEASE DON'T CHANGE ANYTHING ABOVE THIS LINE
#- end of generated part of int candidates ------------------------------------

#- start of generated part of num candidates ----------------------------------
#- Generated on 2021-04-15T15:44:10+02:00 by ./makeNATIVES.raku
#- PLEASE DON'T CHANGE ANYTHING BELOW THIS LINE
#-------------------------------------------------------------------------------
# Publicly visible num candidates

multi sub finds(num @a, Num:D $needle) {
    nqp::islt_i((my int $i = finds_n(@a, $needle)),0)
      ?? Nil
      !! $i
}
multi sub finds(num @a, Num:D $needle, :&cmp!) {
    nqp::islt_i((my int $i = finds_n_cmp(@a, $needle, &cmp)),0)
      ?? Nil
      !! $i
}

multi sub inserts(num @a, Num:D $needle, :$force) {
    inserts_n(@a, $needle, finds_n(@a, $needle), $force.Bool)
}
multi sub inserts(num @a, Num:D $needle, :&cmp!, :$force) {
    inserts_n(@a, $needle, finds_n_cmp(@a, $needle, &cmp), $force.Bool)
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
    nqp::if(
      nqp::islt_i($i,0),
      nqp::splice(                                      # not found
        @a,
        nqp::list_n($needle),
        nqp::abs_i(nqp::add_i($i,1)),
        0
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
          nqp::splice(@a,nqp::list_n($needle),$j,1)
        )
      )
    );

    @a
}
#- PLEASE DON'T CHANGE ANYTHING ABOVE THIS LINE
#- end of generated part of num candidates ------------------------------------

=begin pod

=head1 NAME

List::Sorted::Util - blah blah blah

=head1 SYNOPSIS

=begin code :lang<raku>

use List::Sorted::Util;

=end code

=head1 DESCRIPTION

List::Sorted::Util is ...

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/List-Sorted-Util . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2021 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
