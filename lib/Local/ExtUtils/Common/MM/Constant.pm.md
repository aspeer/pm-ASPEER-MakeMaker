# Local::ExtUtils::Common::Constant

## Name

Local::ExtUtils::Common::Constant - exported constants and Makefile macro data

## Synopsis

```perl
use Local::ExtUtils::Common::Constant qw(
    $EXTUTILS_COMMON_PM
    $TEMPLATE_POSTAMBLE_FN
    $UPDATE_SOURCE_UTIL_FN
    $UPDATE_SOURCE_IMPORT_FN
    $EXTUTILS_COMMON_PM_ARGV
);
```

```perl
use Local::ExtUtils::Common::Constant qw(:all);
```

## Description

`Local::ExtUtils::Common::Constant` defines the constants used by the
MakeMaker hook layer and generated postamble targets.

The constants are stored in `%Constant`, exported as scalar package variables,
and later copied into the MakeMaker macro table by
`Local::ExtUtils::Common::MM::const_config`.

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
lib/Local/ExtUtils/Common/Constant/postamble.inc
```

### UPDATE_SOURCE_UTIL_FN

Path to this distribution's source `Util.pm`. The `utilsync` target uses this
as the source file for utility synchronization.

### UPDATE_SOURCE_IMPORT_FN

Path to this distribution's source `Import.pm`. The `utilsync` target uses this
as the source file for import helper synchronization.

### EXTUTILS_COMMON_PM_ARGV

A comma-separated Makefile macro expression that expands to the fixed argument
block passed into generated target methods.

The argument order matches `Local::ExtUtils::Common::Util::arg`:

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

1. A `.local` file beside `Constant.pm`.
2. `~/.Local::ExtUtils::Common::Constant.local`.

Later values override earlier values.

This is the intended mechanism for supplying destination-specific macros such
as `UPDATE_DEST_UTIL_FN` and `UPDATE_DEST_IMPORT_FN`.

## Export Behavior

All constants are exported by default as scalar variables. They are also
available through the `:all` export tag.

The module also aliases `$_` to `%Constant` by assigning:

```perl
$_ = \%Constant;
```

This allows callers that load the module to access the full constant hash
through the package's default scalar context convention used by the existing
code.

## See Also

- `Local::ExtUtils::Common::MM`
- `Local::ExtUtils::Common::Util`

