[![Actions Status](https://github.com/lizmat/Array-Sorted-Util/workflows/test/badge.svg)](https://github.com/lizmat/Array-Sorted-Util/actions)

NAME
====

Array::Sorted::Util - Raku utilities for (native) sorted arrays

SYNOPSIS
========

```raku
use Array::Sorted::Util;  # imports finds, inserts, deletes

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

Array::Sorted::Util exports a set of subroutines that create and manipulate sorted arrays.

SUBROUTINES
===========

inserts
-------

```raku
my @a;
my $pos = inserts(@a, "foo", :cmp(&[coll]));

inserts(@a, "foo");  # use &infix:<cmp> by default

my @b;
my @c;
inserts(@b, 'foo', @c, 'bar');  # multiple associated lists

my @d = <a c e g i>;
my $pos = finds(@d,"d");
if $pos {
    say "Found at $pos";
}
else {
    inserts(@d,"d",:$pos);
}
say @d;  # (a c d e g i)
```

Insert the given object (the second argument) into the correct location in the given array (the first argument). Takes a named argument `cmp` to indicate the logic that should be used to determine order (defaults to `&infix:<cmp>`). Additionally takes array, object arguments to insert the given object in the associated array at the same location. Returns the position at which the object(s) were actually inserted.

Can also take an optional named argument `pos` from a previously unsuccessful call to `finds` as a shortcut to prevent needing to search for the object again.

finds
-----

```raku
my @a = <a b c d e f g h i j>;
.say with finds(@a, "h");   # 7, use &infix:<cmp> by default
say "could not be found" without finds(@a, "z", :cmp(&[coll]));
```

Attempt to find the given object (the second argument) in the given sorted array (the first argument). Takes a named argument `cmp` to indicate the logic that should be used to determine order (defaults to `&infix:<cmp>`). Returns a special **undefined** value if the object could not be found.

deletes
-------

```raku
my @a = <a b c d e f g h i j>;
say deletes(@a, "e");                 # e, use &infix:<cmp> by default
say deletes(@a, "z", :cmp(&[coll]));  # Nil
```

Attempt to remove the given object (the second argument) from the given sorted array (the first argument). Takes a named argument `cmp` to indicate the logic that should be used to determine order (defaults to `&infix:<cmp>`). Additionally takes array arguments to delete elements in the associated array at the same location. Returns the value of the primary removed object.

INSPIRATION
===========

The inspiration for these names is from the TUTOR Programming Language, which had `finds`, `inserts` and `deletes` commands.

See https://files.eric.ed.gov/fulltext/ED208879.pdf for more information (pages C16 and C17).

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Array-Sorted-Util . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

