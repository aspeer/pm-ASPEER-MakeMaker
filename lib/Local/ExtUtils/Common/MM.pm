#
#  This file is part of Local::ExtUtils::Common.
#
#  This software is copyright (c) 2026 by Andrew Speer <andrew.speer.com.au>.
#
#  This is free software; you can redistribute it and/or modify it under
#  the same terms as the Perl 5 programming language system itself.
#
#  Full license text is available at:
#
#  <http://dev.perl.org/licenses/>
#
package Local::ExtUtils::Common::MM;


#  Compiler Pragma
#
use strict qw(vars);
use warnings;
use vars qw($VERSION);


#  External Packages
#
use Local::ExtUtils::Common::MM::Util;
use Local::ExtUtils::Common::MM::Constant;


#  Version information in a formate suitable for CPAN etc. Must be
#  all on one line
#
$VERSION='1.005';


#  All done, init finished
#
1;


__END__

=begin markdown

# Local::ExtUtils::Common::MM

## Name

Local::ExtUtils::Common::MM - namespace module for MakeMaker helper support

## Synopsis

```perl
use Local::ExtUtils::Common::MM;
```

This module is normally loaded indirectly by `Local::ExtUtils::Common` and
`Local::ExtUtils::Common::MM::Import`.

## Description

`Local::ExtUtils::Common::MM` currently acts as a namespace and dependency
anchor for the MakeMaker helper implementation. It loads:

- `Local::ExtUtils::Common::MM::Util`
- `Local::ExtUtils::Common::MM::Constant`

The active MakeMaker section wrappers and replacement methods are implemented
in `Local::ExtUtils::Common::MM::Import`.

## Methods

### const_config0

```perl
Local::ExtUtils::Common::MM::const_config0($hook, $mm, @args);
```

Legacy or parked implementation of a `const_config` wrapper. It calls the
saved original MakeMaker section, copies constants into the Makefile macro
table, and updates `PERLRUN`.

The active implementation is currently
`Local::ExtUtils::Common::MM::Import::const_config`.

### postamble0

```perl
Local::ExtUtils::Common::MM::postamble0($hook, $mm, @args);
```

Legacy or parked implementation of a `postamble` wrapper. It calls the saved
original MakeMaker section and appends the configured postamble template.

The active implementation is currently
`Local::ExtUtils::Common::MM::Import::postamble`.

## Usage Conventions

Do not call this module's methods directly from a `Makefile.PL`. Use the
top-level entry point:

```perl
use Local::ExtUtils::Common;
```

New active MakeMaker hook behavior should generally be documented against
`Local::ExtUtils::Common::MM::Import`, since that module installs and provides
the current hook implementations.

## See Also

- `Local::ExtUtils::Common`
- `Local::ExtUtils::Common::MM::Import`
- `Local::ExtUtils::Common::MM::Util`
- `Local::ExtUtils::Common::MM::Constant`


=end markdown


=head1 Local::ExtUtils::Common::MM


=head2 Name

Local::ExtUtils::Common::MM - namespace module for MakeMaker helper support


=head2 Synopsis


 use Local::ExtUtils::Common::MM;
This module is normally loaded indirectly by C<Local::ExtUtils::Common> and
C<Local::ExtUtils::Common::MM::Import>.


=head2 Description

C<Local::ExtUtils::Common::MM> currently acts as a namespace and dependency
anchor for the MakeMaker helper implementation. It loads:

=over

=item -

C<Local::ExtUtils::Common::MM::Util>


=item -

C<Local::ExtUtils::Common::MM::Constant>


=back

The active MakeMaker section wrappers and replacement methods are implemented
in C<Local::ExtUtils::Common::MM::Import>.


=head2 Methods


=head3 const_config0


 Local::ExtUtils::Common::MM::const_config0($hook, $mm, @args);
Legacy or parked implementation of a C<const_config> wrapper. It calls the
saved original MakeMaker section, copies constants into the Makefile macro
table, and updates C<PERLRUN>.

The active implementation is currently
C<Local::ExtUtils::Common::MM::Import::const_config>.


=head3 postamble0


 Local::ExtUtils::Common::MM::postamble0($hook, $mm, @args);
Legacy or parked implementation of a C<postamble> wrapper. It calls the saved
original MakeMaker section and appends the configured postamble template.

The active implementation is currently
C<Local::ExtUtils::Common::MM::Import::postamble>.


=head2 Usage Conventions

Do not call this module's methods directly from a C<Makefile.PL>. Use the
top-level entry point:


 use Local::ExtUtils::Common;
New active MakeMaker hook behavior should generally be documented against
C<Local::ExtUtils::Common::MM::Import>, since that module installs and provides
the current hook implementations.


=head2 See Also

=over

=item -

C<Local::ExtUtils::Common>


=item -

C<Local::ExtUtils::Common::MM::Import>


=item -

C<Local::ExtUtils::Common::MM::Util>


=item -

C<Local::ExtUtils::Common::MM::Constant>


=back

=cut
