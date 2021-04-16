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

say finds(@a,"h");    # 7
say finds(@a,"z");    # Nil

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
inserts(@a, "foo");  # use &infix:<cmp> by default

inserts(@a, "foo", :cmp(&[coll]));
```

Insert the given object (the second argument) into the correct location in the given array (the first argument). Takes a named argument `cmp` to indicate the logic that should be used to determine order (defaults to &infix:<cmp>).

finds
-----

```raku
my @a = <a b c d e f g h i j>;
say finds(@a, "h");                 # 7, use &infix:<cmp> by default
say finds(@a, "z", :cmp(&[coll]));  # Nil
```

Attempt to find the given object (the second argument) in the given sorted array (the first argument). Takes a named argument `cmp` to indicate the logic that should be used to determine order (defaults to &infix:<cmp>).

deletes
-------

```raku
my @a = <a b c d e f g h i j>;
say deletes(@a, "e");                 # e, use &infix:<cmp> by default
say deletes(@a, "z", :cmp(&[coll]));  # Nil
```

Attempt to remove the given object (the second argument) from the given sorted array (the first argument). Takes a named argument `cmp` to indicate the logic that should be used to determine order (defaults to &infix:<cmp>).

INSPIRATION
===========

The inspiration for these names is from the TUTOR Programming Language, which had `finds`, `inserts` and `deletes` commands.

See https://files.eric.ed.gov/fulltext/ED208879.pdf for more information (pages C16 and C17).

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/List-Sorted-Util . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

