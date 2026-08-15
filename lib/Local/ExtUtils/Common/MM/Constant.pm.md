# Local::ExtUtils::Common::MM::Constant

## Name

Local::ExtUtils::Common::MM::Constant - exported constants and Makefile macro data

## Synopsis

```perl
use Local::ExtUtils::Common::MM::Constant qw(
    $EXTUTILS_COMMON_PM
    $TEMPLATE_POSTAMBLE_FN
    $UPDATE_SOURCE_UTIL_FN
    $UPDATE_SOURCE_IMPORT_FN
    $UPDATE_SOURCE_CONSTANT_FN
    $EXTUTILS_COMMON_PM_ARGV
);
```

```perl
use Local::ExtUtils::Common::MM::Constant qw(:all);
```

## Description

`Local::ExtUtils::Common::MM::Constant` defines constants used by the
MakeMaker hook layer and generated postamble targets.

The constants are stored in `%Constant`, exported as scalar package variables,
and copied into the Makefile macro table by
`Local::ExtUtils::Common::MM::Import::const_config`.

## Constants

### EXTUTILS_COMMON_PM

The module name used by generated make targets when dispatching back into this
helper distribution.

Default:

```perl
Local::ExtUtils::Common
```

### TEMPLATE_POSTAMBLE_FN

Path to the bundled postamble template:

```text
lib/Local/ExtUtils/Common/MM/postamble.inc
```

### UPDATE_SOURCE_UTIL_FN

Path to this distribution's source `MM/Util.pm`. The `utilsync` target can use
this as the source file for utility synchronization.

### UPDATE_SOURCE_IMPORT_FN

Path to this distribution's source `MM/Import.pm`. The `utilsync` target can
use this as the source file for import helper synchronization.

### UPDATE_SOURCE_CONSTANT_FN

Path to this distribution's source `MM/Constant.pm`.

### EXTUTILS_COMMON_PM_ARGV

A comma-separated Makefile macro expression that expands to the fixed argument
block passed into generated target methods.

The argument order matches `Local::ExtUtils::Common::MM::Util::arg`:

- `$(NAME)`
- `$(NAME_SYM)`
- `$(DISTNAME)`
- `$(DISTVNAME)`
- `$(VERSION)`
- `$(VERSION_SYM)`
- `$(VERSION_FROM)`
- `$(LICENSE)`
- `$(AUTHOR)`
- `$(TO_INST_PM)`
- `$(EXE_FILES)`
- `$(DIST_DEFAULT_TARGET)`
- `$(SUFFIX)`
- `$(ABSTRACT_FROM)`

## Local Overrides

After defining built-in defaults, the module applies optional local overrides.
The override files must evaluate to a hash reference.

The files are loaded in this order:

1. A `.local` file beside `MM/Constant.pm`.
2. `~/.Local::ExtUtils::Common::MM::Constant.local`.

Later values override earlier values.

## Export Behavior

All constants are exported by default as scalar variables. They are also
available through the `:all` export tag.

The module also aliases `$_` to `%Constant` by assigning:

```perl
$_ = \%Constant;
```

## See Also

- `Local::ExtUtils::Common`
- `Local::ExtUtils::Common::MM::Import`
- `Local::ExtUtils::Common::MM::Util`

