# Local::ExtUtils::Common::Import

## Name

Local::ExtUtils::Common::Import - import-time MakeMaker section hook manager

## Synopsis

```perl
use Local::ExtUtils::Common qw(const_config postamble);
```

Usually this module is not used directly. It is invoked by
`Local::ExtUtils::Common`.

## Description

`Local::ExtUtils::Common::Import` installs the MakeMaker hooks requested by the
caller. For each requested MakeMaker section, it finds and stores the original
implementation, then replaces the corresponding `ExtUtils::MM::*` method with
a wrapper that calls this distribution's implementation.

For example, requesting `postamble` causes calls to
`ExtUtils::MM::postamble` to be routed to:

```perl
Local::ExtUtils::Common::MM::postamble(...)
```

The original MakeMaker method is saved in the hook object's internal hash so
the replacement can call it and append or modify the result.

## Import Behavior

```perl
Local::ExtUtils::Common::Import->import(@sections);
```

The import process:

1. Requires `ExtUtils::MakeMaker`.
2. Builds a list of active `ExtUtils::MM::*` classes from `@ExtUtils::MM::ISA`.
3. For each requested section, locates the original implementation.
4. Stores the original code reference.
5. Replaces `ExtUtils::MM::$section` with a wrapper method.

The wrapper dispatches to:

```perl
<importing class>::MM::<section>
```

For this distribution, that normally means `Local::ExtUtils::Common::MM`.

## Usage Conventions

This module is part of the import mechanism and is normally loaded indirectly.
Callers should prefer:

```perl
use Local::ExtUtils::Common;
```

or:

```perl
use Local::ExtUtils::Common qw(const_config postamble);
```

Because it modifies `ExtUtils::MM` symbol table entries, it should be used only
during Makefile generation.

## Diagnostics

The module emits formatted status messages through
`Local::ExtUtils::Common::Util::msg`. It dies if no `ExtUtils::MM` inheritance
chain can be found.

## See Also

- `Local::ExtUtils::Common`
- `Local::ExtUtils::Common::MM`
- `ExtUtils::MakeMaker`

