# This modules is prepared to be incorporated into the Rakudo core,
# so it set up to be as performant as possible already using nqp ops.
use nqp;

# An empty list for nqp::splice to delete stuff
my $empty-list := nqp::list;

my class NotFound is Int {  # is implementation-detail
    method defined(--> False) { }
    method Int() { nqp::box_i(self,Int) }
}

my proto sub finds(|)   is export {*}
my proto sub inserts(|) is export {*}
my proto sub deletes(|) is export {*}

my proto sub insert(|) {*}
my proto sub delete(|) {*}

my sub nexts(\haystack, \needle, :&cmp) is export {
    my $pos = &cmp
      ?? finds(haystack, needle, :&cmp)
      !! finds(haystack, needle);
    ++$pos if $pos.defined;
    $pos < haystack.elems ?? haystack.AT-POS($pos) !! Nil
}

my sub prevs(\haystack, \needle, :&cmp) is export {
    my $pos = &cmp
      ?? finds(haystack, needle, :&cmp)
      !! finds(haystack, needle);
    $pos > 0 ?? haystack.AT-POS($pos - 1) !! Nil
}

#-------------------------------------------------------------------------------
# Publicly visible opaque candidates

my multi sub finds(\haystack, $needle, :&cmp = &[cmp]) {
    my int $start;
    my int $elems = haystack.elems;   # reifies
    my int $end   = nqp::sub_i($elems,1);
    my int $i     = nqp::div_i($elems,2);

    nqp::while(
      nqp::isge_i($i,$start) && nqp::isle_i($i,$end),  # not done yet
      nqp::if(
        nqp::eqaddr(
          (my $cmp := cmp($needle,haystack.AT-POS($i))),
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
            (return nqp::box_i(nqp::add_i($end,1),NotFound))
          ),
          nqp::stmts(                                  # found needle
            nqp::while(                                # find first occurrence
              nqp::isge_i(($i = nqp::sub_i($i,1)),0)
                && nqp::eqaddr(cmp($needle,haystack.AT-POS($i)),Order::Same),
              nqp::null
            ),
            (return nqp::add_i($i,1))
          )
        )
      )
    );

    # before or after the array
    nqp::box_i($i,NotFound)
}

my multi sub inserts(\haystack, $needle, NotFound :$pos!) {
    insert(haystack, $pos, $needle)
}

my multi sub inserts(\haystack, $needle, :&cmp = &[cmp], :$force) {
    nqp::if(
      nqp::istype((my $i := finds(haystack, $needle, :&cmp)),NotFound),
      nqp::stmts(                                       # not found
        insert(haystack, $i, $needle),
        nqp::box_i($i,Int)
      ),
      nqp::if(                                          # found
        $force,
        nqp::stmts(                                     # force insertion
          (my int $j = $i),
          (my int $elems = haystack.elems),
          nqp::while(                                   # insert after last
            nqp::islt_i(($j = nqp::add_i($j,1)),$elems)
              && nqp::eqaddr(cmp($needle,haystack.AT-POS($j)),Order::Same),
            nqp::null
          ),
          insert(haystack, $j, $needle),
          $j
        ),
        Nil
      )
    )
}

my multi sub inserts(\haystack, $needle, **@also, NotFound :$pos!) {
    insert(haystack, $pos, $needle);
    insert-also($pos, @also)
}

my multi sub inserts(\haystack, $needle, **@also, :&cmp = &[cmp], :$force) {
    nqp::eqaddr((my $i := inserts(haystack, $needle, :&cmp, :$force)),Nil)
      ?? $i
      !! insert-also($i, @also)
}

my multi sub deletes(\haystack, $needle, :&cmp = &[cmp]) {
    nqp::if(
      nqp::istype((my $i := finds(haystack, $needle, :&cmp)),NotFound),
      Nil,
      nqp::stmts(
        delete(haystack, $i),
        $needle
      )
    )
}

my multi sub deletes(\haystack, $needle, **@also, :&cmp = &[cmp]) {
    nqp::if(
      nqp::istype((my $i := finds(haystack, $needle, :&cmp)),NotFound),
      Nil,
      nqp::stmts(
        delete(haystack, $i),
        delete-also($i, @also),
        $needle
      )
    )
}

#------------------------------------------------------------------------------
# Actual opaque workhorses

my sub insert-also(Int:D $i, @also) {
    my int $elems = @also.elems;  # reifies
    my     $also := nqp::getattr(@also,List,'$!reified');

    nqp::while(
      nqp::elems($also),
      insert(nqp::decont(nqp::shift($also)), $i, nqp::shift($also))
    );

    $i
}

my sub delete-also(Int:D $i, @also) {
    my int $elems = @also.elems;  # reifies
    my     $also := nqp::getattr(@also,List,'$!reified');

    nqp::while(
      nqp::elems($also),
      delete(nqp::decont(nqp::shift($also)), $i)
    );

    $i
}

my multi sub insert(@a, $pos, \value) {
    @a.splice($pos, 0, value);
    $pos
}
my multi sub insert(IterationBuffer:D $buffer, $pos, \value) {
    nqp::splice($buffer,nqp::list(value),$pos,0);
    $pos
}
my multi sub delete(@a, $pos) {
    @a.splice($pos, 1)
}
my multi sub delete(IterationBuffer:D $buffer, $pos) {
    nqp::splice($buffer, $empty-list, $pos, 1)
}

#- start of generated part of str candidates -----------------------------------
#- Generated on 2021-05-06T12:15:03+02:00 by ./makeNATIVES.raku
#- PLEASE DON'T CHANGE ANYTHING BELOW THIS LINE
my str @delete_s;

#-------------------------------------------------------------------------------
# Publicly visible str candidates

my multi sub finds(array[str] \a, Str:D $needle) {
    finds_s(a, $needle)
}
my multi sub finds(array[str] \a, Str:D $needle, :&cmp!) {
    finds_s_cmp(a, $needle, &cmp)
}

my multi sub inserts(array[str] \a, Str:D $needle, NotFound :$pos!) {
    inserts_s(a, $needle, $pos, True)
}
my multi sub inserts(array[str] \a, Str:D $needle, :$force) {
    inserts_s(a, $needle, finds_s(a, $needle), $force.Bool)
}

my multi sub inserts(array[str] \a, Str:D $needle, **@also, NotFound :$pos!) {
    inserts_s(a, $needle, $pos, True);
    insert-also($pos, @also)
}
my multi sub inserts(array[str] \a, Str:D $needle, **@also, :$force) {
    nqp::eqaddr((my $i := inserts(a, $needle, :$force)),Nil)
      ?? $i
      !! insert-also($i, @also)
}

my multi sub inserts(array[str] \a, Str:D $needle, :&cmp!, :$force) {
    inserts_s(a, $needle, finds_s_cmp(a, $needle, &cmp), $force.Bool)
}
my multi sub inserts(array[str] \a, Str:D $needle, **@also, :&cmp = &[cmp], :$force) {
    nqp::eqaddr((my $i := inserts_s(a, $needle, :&cmp, :$force)),Nil)
      ?? $i
      !! insert-also($i, @also)
}

my multi sub deletes(array[str] \a, Str:D $needle) {
    nqp::if(
      nqp::istype((my $i := finds_s(a, $needle)),NotFound),
      Nil,
      nqp::stmts(
        nqp::splice(a,@delete_s,$i,1),
        $needle
      )
    )
}
my multi sub deletes(array[str] \a, Str:D $needle, **@also) {
    nqp::if(
      nqp::istype((my $i := finds_s(a, $needle)),NotFound),
      Nil,
      nqp::stmts(
        nqp::splice(a,@delete_s,$i,1),
        delete-also($i, @also),
        $needle
      )
    )
}
my multi sub deletes(array[str] \a, Str:D $needle, :&cmp!) {
    nqp::if(
      nqp::istype(
        (my $i := finds_s_cmp(a, $needle, &cmp)),
        NotFound
      ),
      Nil,
      nqp::stmts(
        nqp::splice(a,@delete_s,$i,1),
        $needle
      )
    )
}
my multi sub deletes(array[str] \a, Str:D $needle, **@also, :&cmp!) {
    nqp::if(
      nqp::istype((my $i := finds_s_cmp(a, $needle, &cmp)),NotFound),
      Nil,
      nqp::stmts(
        nqp::splice(a,@delete_s,$i,1),
        delete-also($i, @also),
        $needle
      )
    )
}

#-------------------------------------------------------------------------------
# Actual str workhorses

my sub finds_s(array[str] \a, str $needle) {
    my int $start;
    my int $end = nqp::sub_i(nqp::elems(a),1);
    my int $i   = nqp::div_i(nqp::elems(a),2);

    nqp::while(
      nqp::isge_i($i,$start) && nqp::isle_i($i,$end),  # not done yet
      nqp::if(
        (my int $cmp = nqp::cmp_s($needle,nqp::atpos_s(a,$i))),
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
            (return nqp::box_i(nqp::add_i($end,1),NotFound))
          )
        ),
        nqp::stmts(                                    # needle found
          nqp::while(                                  # find first occurrence
            nqp::isge_i(($i = nqp::sub_i($i,1)),0)
              && nqp::iseq_s($needle,nqp::atpos_s(a,$i)),
            nqp::null
          ),
          (return nqp::add_i($i,1))
        )
      )
    );

    # before or after the array
    nqp::box_i($i,NotFound)
}

my sub finds_s_cmp(array[str] \a, str $needle, &cmp) {
    my int $start;
    my int $end = nqp::sub_i(nqp::elems(a),1);
    my int $i   = nqp::div_i(nqp::elems(a),2);

    nqp::while(
      nqp::isge_i($i,$start) && nqp::isle_i($i,$end),  # not done yet
      nqp::if(
        nqp::eqaddr(
          (my $cmp := cmp($needle,nqp::atpos_s(a,$i))),
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
            (return nqp::box_i(nqp::add_i($end,1),NotFound))
          ),
          nqp::stmts(                                  # found needle
            nqp::while(                                # find first occurrence
              nqp::isge_i(($i = nqp::sub_i($i,1)),0)
                && nqp::iseq_s($needle,nqp::atpos_s(a,$i)),
              nqp::null
            ),
            (return nqp::add_i($i,1))
          )
        )
      )
    );

    # before or after the array
    nqp::box_i($i,NotFound)
}

my sub inserts_s(array[str] \a, str $needle, Int:D $i, int $force) {
    my str @insert = $needle;
    nqp::if(
      nqp::istype($i,NotFound),
      nqp::stmts(                                       # not found
        nqp::splice(a,@insert,$i,0),
        nqp::box_i($i,Int)
      ),
      nqp::if(                                          # found
        $force,
        nqp::stmts(                                     # force insertion
          (my int $j = $i),
          nqp::while(                                   # insert after last
            nqp::islt_i(($j = nqp::add_i($j,1)),nqp::elems(a))
              && nqp::iseq_s($needle,nqp::atpos_s(a,$j)),
            nqp::null
          ),
          nqp::splice(a,@insert,$j,0),
          $j
        )
      )
    )
}

#- PLEASE DON'T CHANGE ANYTHING ABOVE THIS LINE
#- end of generated part of str candidates -------------------------------------

#- start of generated part of int candidates -----------------------------------
#- Generated on 2021-05-06T12:15:03+02:00 by ./makeNATIVES.raku
#- PLEASE DON'T CHANGE ANYTHING BELOW THIS LINE
my int @delete_i;

#-------------------------------------------------------------------------------
# Publicly visible int candidates

my multi sub finds(array[int] \a, Int:D $needle) {
    finds_i(a, $needle)
}
my multi sub finds(array[int] \a, Int:D $needle, :&cmp!) {
    finds_i_cmp(a, $needle, &cmp)
}

my multi sub inserts(array[int] \a, Int:D $needle, NotFound :$pos!) {
    inserts_i(a, $needle, $pos, True)
}
my multi sub inserts(array[int] \a, Int:D $needle, :$force) {
    inserts_i(a, $needle, finds_i(a, $needle), $force.Bool)
}

my multi sub inserts(array[int] \a, Int:D $needle, **@also, NotFound :$pos!) {
    inserts_i(a, $needle, $pos, True);
    insert-also($pos, @also)
}
my multi sub inserts(array[int] \a, Int:D $needle, **@also, :$force) {
    nqp::eqaddr((my $i := inserts(a, $needle, :$force)),Nil)
      ?? $i
      !! insert-also($i, @also)
}

my multi sub inserts(array[int] \a, Int:D $needle, :&cmp!, :$force) {
    inserts_i(a, $needle, finds_i_cmp(a, $needle, &cmp), $force.Bool)
}
my multi sub inserts(array[int] \a, Int:D $needle, **@also, :&cmp = &[cmp], :$force) {
    nqp::eqaddr((my $i := inserts_i(a, $needle, :&cmp, :$force)),Nil)
      ?? $i
      !! insert-also($i, @also)
}

my multi sub deletes(array[int] \a, Int:D $needle) {
    nqp::if(
      nqp::istype((my $i := finds_i(a, $needle)),NotFound),
      Nil,
      nqp::stmts(
        nqp::splice(a,@delete_i,$i,1),
        $needle
      )
    )
}
my multi sub deletes(array[int] \a, Int:D $needle, **@also) {
    nqp::if(
      nqp::istype((my $i := finds_i(a, $needle)),NotFound),
      Nil,
      nqp::stmts(
        nqp::splice(a,@delete_i,$i,1),
        delete-also($i, @also),
        $needle
      )
    )
}
my multi sub deletes(array[int] \a, Int:D $needle, :&cmp!) {
    nqp::if(
      nqp::istype(
        (my $i := finds_i_cmp(a, $needle, &cmp)),
        NotFound
      ),
      Nil,
      nqp::stmts(
        nqp::splice(a,@delete_i,$i,1),
        $needle
      )
    )
}
my multi sub deletes(array[int] \a, Int:D $needle, **@also, :&cmp!) {
    nqp::if(
      nqp::istype((my $i := finds_i_cmp(a, $needle, &cmp)),NotFound),
      Nil,
      nqp::stmts(
        nqp::splice(a,@delete_i,$i,1),
        delete-also($i, @also),
        $needle
      )
    )
}

#-------------------------------------------------------------------------------
# Actual int workhorses

my sub finds_i(array[int] \a, int $needle) {
    my int $start;
    my int $end = nqp::sub_i(nqp::elems(a),1);
    my int $i   = nqp::div_i(nqp::elems(a),2);

    nqp::while(
      nqp::isge_i($i,$start) && nqp::isle_i($i,$end),  # not done yet
      nqp::if(
        (my int $cmp = nqp::cmp_i($needle,nqp::atpos_i(a,$i))),
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
            (return nqp::box_i(nqp::add_i($end,1),NotFound))
          )
        ),
        nqp::stmts(                                    # needle found
          nqp::while(                                  # find first occurrence
            nqp::isge_i(($i = nqp::sub_i($i,1)),0)
              && nqp::iseq_i($needle,nqp::atpos_i(a,$i)),
            nqp::null
          ),
          (return nqp::add_i($i,1))
        )
      )
    );

    # before or after the array
    nqp::box_i($i,NotFound)
}

my sub finds_i_cmp(array[int] \a, int $needle, &cmp) {
    my int $start;
    my int $end = nqp::sub_i(nqp::elems(a),1);
    my int $i   = nqp::div_i(nqp::elems(a),2);

    nqp::while(
      nqp::isge_i($i,$start) && nqp::isle_i($i,$end),  # not done yet
      nqp::if(
        nqp::eqaddr(
          (my $cmp := cmp($needle,nqp::atpos_i(a,$i))),
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
            (return nqp::box_i(nqp::add_i($end,1),NotFound))
          ),
          nqp::stmts(                                  # found needle
            nqp::while(                                # find first occurrence
              nqp::isge_i(($i = nqp::sub_i($i,1)),0)
                && nqp::iseq_i($needle,nqp::atpos_i(a,$i)),
              nqp::null
            ),
            (return nqp::add_i($i,1))
          )
        )
      )
    );

    # before or after the array
    nqp::box_i($i,NotFound)
}

my sub inserts_i(array[int] \a, int $needle, Int:D $i, int $force) {
    my int @insert = $needle;
    nqp::if(
      nqp::istype($i,NotFound),
      nqp::stmts(                                       # not found
        nqp::splice(a,@insert,$i,0),
        nqp::box_i($i,Int)
      ),
      nqp::if(                                          # found
        $force,
        nqp::stmts(                                     # force insertion
          (my int $j = $i),
          nqp::while(                                   # insert after last
            nqp::islt_i(($j = nqp::add_i($j,1)),nqp::elems(a))
              && nqp::iseq_i($needle,nqp::atpos_i(a,$j)),
            nqp::null
          ),
          nqp::splice(a,@insert,$j,0),
          $j
        )
      )
    )
}

#- PLEASE DON'T CHANGE ANYTHING ABOVE THIS LINE
#- end of generated part of int candidates -------------------------------------

#- start of generated part of num candidates -----------------------------------
#- Generated on 2021-05-06T12:15:03+02:00 by ./makeNATIVES.raku
#- PLEASE DON'T CHANGE ANYTHING BELOW THIS LINE
my num @delete_n;

#-------------------------------------------------------------------------------
# Publicly visible num candidates

my multi sub finds(array[num] \a, Num:D $needle) {
    finds_n(a, $needle)
}
my multi sub finds(array[num] \a, Num:D $needle, :&cmp!) {
    finds_n_cmp(a, $needle, &cmp)
}

my multi sub inserts(array[num] \a, Num:D $needle, NotFound :$pos!) {
    inserts_n(a, $needle, $pos, True)
}
my multi sub inserts(array[num] \a, Num:D $needle, :$force) {
    inserts_n(a, $needle, finds_n(a, $needle), $force.Bool)
}

my multi sub inserts(array[num] \a, Num:D $needle, **@also, NotFound :$pos!) {
    inserts_n(a, $needle, $pos, True);
    insert-also($pos, @also)
}
my multi sub inserts(array[num] \a, Num:D $needle, **@also, :$force) {
    nqp::eqaddr((my $i := inserts(a, $needle, :$force)),Nil)
      ?? $i
      !! insert-also($i, @also)
}

my multi sub inserts(array[num] \a, Num:D $needle, :&cmp!, :$force) {
    inserts_n(a, $needle, finds_n_cmp(a, $needle, &cmp), $force.Bool)
}
my multi sub inserts(array[num] \a, Num:D $needle, **@also, :&cmp = &[cmp], :$force) {
    nqp::eqaddr((my $i := inserts_n(a, $needle, :&cmp, :$force)),Nil)
      ?? $i
      !! insert-also($i, @also)
}

my multi sub deletes(array[num] \a, Num:D $needle) {
    nqp::if(
      nqp::istype((my $i := finds_n(a, $needle)),NotFound),
      Nil,
      nqp::stmts(
        nqp::splice(a,@delete_n,$i,1),
        $needle
      )
    )
}
my multi sub deletes(array[num] \a, Num:D $needle, **@also) {
    nqp::if(
      nqp::istype((my $i := finds_n(a, $needle)),NotFound),
      Nil,
      nqp::stmts(
        nqp::splice(a,@delete_n,$i,1),
        delete-also($i, @also),
        $needle
      )
    )
}
my multi sub deletes(array[num] \a, Num:D $needle, :&cmp!) {
    nqp::if(
      nqp::istype(
        (my $i := finds_n_cmp(a, $needle, &cmp)),
        NotFound
      ),
      Nil,
      nqp::stmts(
        nqp::splice(a,@delete_n,$i,1),
        $needle
      )
    )
}
my multi sub deletes(array[num] \a, Num:D $needle, **@also, :&cmp!) {
    nqp::if(
      nqp::istype((my $i := finds_n_cmp(a, $needle, &cmp)),NotFound),
      Nil,
      nqp::stmts(
        nqp::splice(a,@delete_n,$i,1),
        delete-also($i, @also),
        $needle
      )
    )
}

#-------------------------------------------------------------------------------
# Actual num workhorses

my sub finds_n(array[num] \a, num $needle) {
    my int $start;
    my int $end = nqp::sub_i(nqp::elems(a),1);
    my int $i   = nqp::div_i(nqp::elems(a),2);

    nqp::while(
      nqp::isge_i($i,$start) && nqp::isle_i($i,$end),  # not done yet
      nqp::if(
        (my int $cmp = nqp::cmp_n($needle,nqp::atpos_n(a,$i))),
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
            (return nqp::box_i(nqp::add_i($end,1),NotFound))
          )
        ),
        nqp::stmts(                                    # needle found
          nqp::while(                                  # find first occurrence
            nqp::isge_i(($i = nqp::sub_i($i,1)),0)
              && nqp::iseq_n($needle,nqp::atpos_n(a,$i)),
            nqp::null
          ),
          (return nqp::add_i($i,1))
        )
      )
    );

    # before or after the array
    nqp::box_i($i,NotFound)
}

my sub finds_n_cmp(array[num] \a, num $needle, &cmp) {
    my int $start;
    my int $end = nqp::sub_i(nqp::elems(a),1);
    my int $i   = nqp::div_i(nqp::elems(a),2);

    nqp::while(
      nqp::isge_i($i,$start) && nqp::isle_i($i,$end),  # not done yet
      nqp::if(
        nqp::eqaddr(
          (my $cmp := cmp($needle,nqp::atpos_n(a,$i))),
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
            (return nqp::box_i(nqp::add_i($end,1),NotFound))
          ),
          nqp::stmts(                                  # found needle
            nqp::while(                                # find first occurrence
              nqp::isge_i(($i = nqp::sub_i($i,1)),0)
                && nqp::iseq_n($needle,nqp::atpos_n(a,$i)),
              nqp::null
            ),
            (return nqp::add_i($i,1))
          )
        )
      )
    );

    # before or after the array
    nqp::box_i($i,NotFound)
}

my sub inserts_n(array[num] \a, num $needle, Int:D $i, int $force) {
    my num @insert = $needle;
    nqp::if(
      nqp::istype($i,NotFound),
      nqp::stmts(                                       # not found
        nqp::splice(a,@insert,$i,0),
        nqp::box_i($i,Int)
      ),
      nqp::if(                                          # found
        $force,
        nqp::stmts(                                     # force insertion
          (my int $j = $i),
          nqp::while(                                   # insert after last
            nqp::islt_i(($j = nqp::add_i($j,1)),nqp::elems(a))
              && nqp::iseq_n($needle,nqp::atpos_n(a,$j)),
            nqp::null
          ),
          nqp::splice(a,@insert,$j,0),
          $j
        )
      )
    )
}

#- PLEASE DON'T CHANGE ANYTHING ABOVE THIS LINE
#- end of generated part of num candidates -------------------------------------


=begin pod

=head1 NAME

Array::Sorted::Util - Raku utilities for (native) sorted arrays

=head1 SYNOPSIS

=begin code :lang<raku>

use Array::Sorted::Util;  # imports finds, inserts, deletes, nexts, prevs

my @a;
inserts(@a,$_) for <d c f e g h a b j i>;
say @a;               # [a b c d e f g h i j]

.say with finds(@a,"h");    # 7
.say with finds(@a,"z");    # (no output)

say deletes(@a,"e");  # e
say @a;               # [a b c d f g h i j]

=end code

=head1 DESCRIPTION

Array::Sorted::Util exports a collection of subroutines that create,
introspect and manipulate sorted arrays and optionally associated arrays.

=head1 SUBROUTINES

=head2 inserts

=begin code :lang<raku>

my @a;
my $pos = inserts(@a, "foo", :cmp(&[coll]));

inserts(@a, "foo");  # use infix:<cmp> by default

my @b;
my @c;
inserts(@b, 'foo', @c, 'bar');  # multiple associated lists

my @d = <a c e g i>;
my $pos = finds(@d,"d");
with $pos {
    say "Found at $pos";
}
else {
    inserts(@d,"d",:$pos);
}
say @d;  # (a c d e g i)

=end code

Insert the given object (the second argument) into the correct location in
the given array (the first argument).  Takes a named argument C<cmp> to
indicate the logic that should be used to determine order (defaults
to C<infix:<cmp>>).  Additionally takes array, object arguments to insert
the given object in the associated array at the same location.  Returns the
position at which the object(s) were actually inserted.

Can also take an optional named argument C<pos> from a previously unsuccessful
call to C<finds> as a shortcut to prevent needing to search for the object
again.

=head2 finds

=begin code :lang<raku>

my @a = <a b c d e f g h i j>;
.say with finds(@a, "h");   # 7, use infix:<cmp> by default
say "could not be found" without finds(@a, "z", :cmp(&[coll]));

=end code

Attempt to find the given object (the second argument) in the given
sorted array (the first argument).  Takes a named argument C<cmp> to
indicate the logic that should be used to determine order (defaults
to C<infix:<cmp>>).  Returns a special B<undefined> value if the object
could not be found.

=head2 nexts

=begin code :lang<raku>

my @a = <a b c d e f g h i j>;
say nexts(@a, "g");  # h
say nexts(@a, "j");  # Nil

=end code

Return the object B<after> the given object (the second argument) in the
given sorted array (the first argument).  Takes a named argument C<cmp> to
indicate the logic that should be used to determine order (defaults to
C<infix:<cmp>>).  Returns C<Nil> if no object could be found.

=head2 prevs

=begin code :lang<raku>

my @a = <a b c d e f g h i j>;
say prevs(@a, "g");  # f
say prevs(@a, "a");  # Nil

=end code

Return the object B<before> the given object (the second argument) in the
given sorted array (the first argument).  Takes a named argument C<cmp> to
indicate the logic that should be used to determine order (defaults to
C<infix:<cmp>>).  Returns C<Nil> if no object could be found.

=head2 deletes

=begin code :lang<raku>

my @a = <a b c d e f g h i j>;
say deletes(@a, "e");                 # e, use &infix:<cmp> by default
say deletes(@a, "z", :cmp(&[coll]));  # Nil

=end code

Attempt to remove the given object (the second argument) from the given
sorted array (the first argument).  Takes a named argument C<cmp> to
indicate the logic that should be used to determine order (defaults
to C<infix:<cmp>>).  Additionally takes array arguments to delete elements
in the associated array at the same location.  Returns the value of
the primary removed object.

=head1 INSPIRATION

The inspiration for the names of these subroutines came from the
L<TUTOR Programming Language|https://en.wikipedia.org/wiki/TUTOR>, which
had C<finds>, C<inserts> and C<deletes> commands, where the postfix C<s>
indicated the B<sorted> version of these commands.

The L<original manual|https://files.eric.ed.gov/fulltext/ED208879.pdf>
contains more information, specifically pages C16 and C17.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Array-Sorted-Util .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2021 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
