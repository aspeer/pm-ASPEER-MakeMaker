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

