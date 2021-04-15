#!/usr/bin/env raku

# This script reads the lib/List/Sorted/Util.rakumod file, and
# generates the necessary code for the native versions of the
# utility functions, and writes them back to the file.

# always use highest version of Raku
use v6.*;

my $generator = $*PROGRAM-NAME;
my $generated = DateTime.now.gist.subst(/\.\d+/,'');
my $start     = '#- start of generated part of ';
my $idpos     = $start.chars;
my $idchars   = 3;
my $end       = '#- end of generated part of ';

# slurp the whole file and set up writing to it
my $filename = "lib/List/Sorted/Util.rakumod";
my @lines = $filename.IO.lines;
$*OUT = $filename.IO.open(:w);

# for all the lines in the source that don't need special handling
while @lines {
    my $line := @lines.shift;

    # nothing to do yet
    unless $line.starts-with($start) {
        say $line;
        next;
    }

    # found shaped header, ignore
    my $type = $line.substr($idpos,$idchars);
    if $type eq 'sha' {
        say $line;
        next;
    }

    # found header
    die "Don't know how to handle $type" unless $type eq "int" | "num" | "str";
    say $start ~ $type ~ " candidates ----------------------------------";
    say "#- Generated on $generated by $generator";
    say "#- PLEASE DON'T CHANGE ANYTHING BELOW THIS LINE";

    # skip the old version of the code
    while @lines {
        last if @lines.shift.starts-with($end);
    }

    # set up template values
    my %mapper =
      postfix => $type.substr(0,1),
      type    => $type,
      Type    => $type.tclc,
      nullval => $type eq 'str' ?? '""' !! $type eq 'num' ?? '0e0' !! '0'
    ;

    # spurt the role
    say Q:to/SOURCE/.subst(/ '#' (\w+) '#' /, -> $/ { %mapper{$0} }, :g).chomp;
#-------------------------------------------------------------------------------
# Publicly visible #type# candidates

multi sub finds(#type# @a, #Type#:D $needle) {
    nqp::islt_i((my int $i = finds_#postfix#(@a, $needle)),0)
      ?? Nil
      !! $i
}
multi sub finds(#type# @a, #Type#:D $needle, :&cmp!) {
    nqp::islt_i((my int $i = finds_#postfix#_cmp(@a, $needle, &cmp)),0)
      ?? Nil
      !! $i
}

multi sub inserts(#type# @a, #Type#:D $needle, :$force) {
    inserts_#postfix#(@a, $needle, finds_#postfix#(@a, $needle), $force.Bool)
}
multi sub inserts(#type# @a, #Type#:D $needle, :&cmp!, :$force) {
    inserts_#postfix#(@a, $needle, finds_#postfix#_cmp(@a, $needle, &cmp), $force.Bool)
}

#-------------------------------------------------------------------------------
# Actual #type# workhorses

my sub finds_#postfix#(#type# @a, #type# $needle) {
    my int $start;
    my int $end = nqp::sub_i(nqp::elems(@a),1);
    my int $i   = nqp::div_i(nqp::elems(@a),2);

    nqp::while(
      nqp::isge_i($i,$start) && nqp::isle_i($i,$end),  # not done yet
      nqp::if(
        (my int $cmp = nqp::cmp_#postfix#($needle,nqp::atpos_#postfix#(@a,$i))),
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
              && nqp::iseq_s($needle,nqp::atpos_#postfix#(@a,$i)),
            nqp::null
          ),
          (return nqp::add_i($i,1))
        )
      )
    );

    # before or after the list
    nqp::neg_i(nqp::add_i($i,1))
}

my sub finds_#postfix#_cmp(#type# @a, #type# $needle, &cmp) {
    my int $start;
    my int $end = nqp::sub_i(nqp::elems(@a),1);
    my int $i   = nqp::div_i(nqp::elems(@a),2);

    nqp::while(
      nqp::isge_i($i,$start) && nqp::isle_i($i,$end),  # not done yet
      nqp::if(
        nqp::eqaddr(
          (my $cmp := cmp($needle,nqp::atpos_#postfix#(@a,$i))),
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
                && nqp::iseq_s($needle,nqp::atpos_#postfix#(@a,$i)),
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

my sub inserts_#postfix#(#type# @a, #type# $needle, int $i, int $force) {
    nqp::if(
      nqp::islt_i($i,0),
      nqp::splice(                                      # not found
        @a,
        nqp::list_#postfix#($needle),
        nqp::abs_i(nqp::add_i($i,1)),
        0
      ),
      nqp::if(                                          # found
        $force,
        nqp::stmts(                                     # force insertion
          (my int $j = $i),
          nqp::while(                                   # insert after last
            nqp::islt_i(($j = nqp::add_i($j,1)),nqp::elems(@a))
              && nqp::iseq_s($needle,nqp::atpos_#postfix#(@a,$j)),
            nqp::null
          ),
          nqp::splice(@a,nqp::list_#postfix#($needle),$j,1)
        )
      )
    );

    @a
}
SOURCE

    # we're done for this role
    say "#- PLEASE DON'T CHANGE ANYTHING ABOVE THIS LINE";
    say $end ~ $type ~ " candidates ------------------------------------";
}

# close the file properly
$*OUT.close;

# vim: expandtab shiftwidth=4