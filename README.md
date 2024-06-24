[![Actions Status](https://github.com/lizmat/Array-Sorted-Util/workflows/test/badge.svg)](https://github.com/lizmat/Array-Sorted-Util/actions)

NAME
====

Array::Sorted::Util - Raku utilities for (native) sorted arrays

SYNOPSIS
========

```raku
use Array::Sorted::Util;  # imports finds, inserts, deletes, nexts, prevs

my @a;
inserts(@a,$_) for <d c f e g h a b j i>;
say @a;               # [a b c d e f g h i j]

.say with finds(@a,"h");    # 7
.say with finds(@a,"z");    # (no output)

say deletes(@a,"e");  # e
say @a;               # [a b c d f g h i j]
```

DESCRIPTION
===========

Array::Sorted::Util exports a collection of subroutines that create, introspect and manipulate sorted arrays and optionally associated arrays.

SUBROUTINES
===========

inserts
-------

```raku
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
```

Insert the given object (the second argument) into the correct location in the given array (the first argument). Takes a named argument `cmp` to indicate the logic that should be used to determine order (defaults to `infix:<cmp>`). Additionally takes array, object arguments to insert the given object in the associated array at the same location. Returns the position at which the object(s) were actually inserted.

Can also take an optional named argument `pos` from a previously unsuccessful call to `finds` as a shortcut to prevent needing to search for the object again.

finds
-----

```raku
my @a = <a b c d e f g h i j>;
.say with finds(@a, "h");   # 7, use infix:<cmp> by default
say "could not be found" without finds(@a, "z", :cmp(&[coll]));
```

Attempt to find the given object (the second argument) in the given sorted array (the first argument). Takes a named argument `cmp` to indicate the logic that should be used to determine order (defaults to `infix:<cmp>`). Returns a special **undefined** value if the object could not be found.

nexts
-----

```raku
my @a = <a b c d e f g h i j>;
say nexts(@a, "g");  # h
say nexts(@a, "j");  # Nil
```

Return the object **after** the given object (the second argument) in the given sorted array (the first argument). Takes a named argument `cmp` to indicate the logic that should be used to determine order (defaults to `infix:<cmp>`). Returns `Nil` if no object could be found.

prevs
-----

```raku
my @a = <a b c d e f g h i j>;
say prevs(@a, "g");  # f
say prevs(@a, "a");  # Nil
```

Return the object **before** the given object (the second argument) in the given sorted array (the first argument). Takes a named argument `cmp` to indicate the logic that should be used to determine order (defaults to `infix:<cmp>`). Returns `Nil` if no object could be found.

deletes
-------

```raku
my @a = <a b c d e f g h i j>;
say deletes(@a, "e");                 # e, use &infix:<cmp> by default
say deletes(@a, "z", :cmp(&[coll]));  # Nil
```

Attempt to remove the given object (the second argument) from the given sorted array (the first argument). Takes a named argument `cmp` to indicate the logic that should be used to determine order (defaults to `infix:<cmp>`). Additionally takes array arguments to delete elements in the associated array at the same location. Returns the value of the primary removed object.

INSPIRATION
===========

The inspiration for the names of these subroutines came from the [TUTOR Programming Language](https://en.wikipedia.org/wiki/TUTOR), which had `finds`, `inserts` and `deletes` commands, where the postfix `s` indicated the **sorted** version of these commands.

The [original manual](https://files.eric.ed.gov/fulltext/ED208879.pdf) contains more information, specifically pages C16 and C17.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Array-Sorted-Util . Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2021, 2024 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

