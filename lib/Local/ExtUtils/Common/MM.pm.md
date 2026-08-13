# Local::ExtUtils::Common::MM

## Name

Local::ExtUtils::Common::MM - MakeMaker section implementations

## Synopsis

```perl
use Local::ExtUtils::Common qw(const_config postamble);
```

The methods in this module are called by wrappers installed into
`ExtUtils::MM`. They are not usually called directly.

## Description

`Local::ExtUtils::Common::MM` contains replacement or augmenting
implementations for selected `ExtUtils::MakeMaker` sections.

Each method receives an internal hook object, the MakeMaker object, and the
original MakeMaker arguments. The hook object contains the saved original
MakeMaker implementation for that section.

## Methods

### const_config

```perl
Local::ExtUtils::Common::MM::const_config($hook, $mm, @args);
```

Calls the original MakeMaker `const_config` method, then imports constants from
`Local::ExtUtils::Common::Constant` into the Makefile macro table.

The method also replaces the MakeMaker object's `PERLRUN` value with a command
constructed by `Local::ExtUtils::Common::Util::perlrun`. That command preserves
useful local include paths and loaded `ExtUtils::*` modules when generated make
targets invoke Perl.

### postamble

```perl
Local::ExtUtils::Common::MM::postamble($hook, $mm, @args);
```

Calls the original MakeMaker `postamble` method, then appends the contents of
the bundled postamble template:

```text
lib/Local/ExtUtils/Common/Constant/postamble.inc
```

The template defines common make targets and the method-dispatch helper used by
those targets.

## Generated Postamble Convention

The postamble defines an `EXTUTILS_COMMON_PM_TARGET` macro that calls a module
method selected from the first target argument:

```make
$(EXTUTILS_COMMON_PM_TARGET) utilsync ...
```

The generated Perl call passes the fixed MakeMaker macro argument block first,
then passes any remaining target arguments:

```perl
$(EXTUTILS_COMMON_PM)->$method($(EXTUTILS_COMMON_PM_ARGV), @ARGV)
```

Methods intended for postamble dispatch should therefore parse their arguments
with `Local::ExtUtils::Common::Util::arg`.

## Usage Conventions

Add new MakeMaker section customizations here when they are meant to be
installed by `Local::ExtUtils::Common::Import`.

Each section method should call the saved original implementation unless it is
intentionally replacing MakeMaker behavior outright.

## See Also

- `Local::ExtUtils::Common::Import`
- `Local::ExtUtils::Common::Constant`
- `Local::ExtUtils::Common::Util`

