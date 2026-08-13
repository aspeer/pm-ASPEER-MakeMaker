# Local::ExtUtils::Common::Util

## Name

Local::ExtUtils::Common::Util - shared utility functions for MakeMaker helpers

## Synopsis

```perl
use Local::ExtUtils::Common::Util;

msg('building %s', $name);
my $text = slurp($file);
blurp($file, $text);

my $param = arg(@make_target_args);
my $perlrun = perlrun($hook_object);
```

## Description

`Local::ExtUtils::Common::Util` exports support functions used by the rest of
the distribution. The helpers cover formatted messages, debugging, simple file
I/O, MakeMaker target argument parsing, and construction of a Perl command for
generated make targets.

All listed functions are exported by default.

## Functions

### quiet_enable

```perl
quiet_enable();
quiet_enable($value);
```

Enables quiet mode. When quiet mode is active, `msg` and `verbose` output is
suppressed.

### verbose_enable

```perl
verbose_enable();
verbose_enable($value);
```

Enables verbose output for `verbose`.

### debug_enable

```perl
debug_enable($value);
```

Sets the debug flag used by `debug`.

The module also enables debug mode at load time if an environment variable
named after the current script plus `_DEBUG` is set.

### msg

```perl
msg('message %s', $value);
```

Prints a formatted message to standard error unless quiet mode is enabled.

### verbose

```perl
verbose('message %s', $value);
```

Prints a formatted message to standard error only when verbose mode is enabled
and quiet mode is not enabled.

### debug

```perl
debug('message %s', $value);
```

Prints a debug message to standard error when debug mode is enabled. The output
includes caller package, method, and line information.

### err

```perl
err('unable to process %s', $file);
```

Prints a formatted error message and croaks.

### slurp

```perl
my $text = slurp($file);
```

Reads and returns the full contents of a file. On failure, calls `err`.

### blurp

```perl
blurp($file, $text);
```

Writes text to a file, replacing any existing content. On failure, calls `err`.

### touch

```perl
touch($file);
```

Ensures a file exists. If the file is missing, creates it as an empty file.

### arg

```perl
my $param = arg(@args);
```

Parses the fixed argument sequence passed by generated make targets into a hash
reference. The recognized fields are:

- `NAME`
- `NAME_SYM`
- `DISTNAME`
- `DISTVNAME`
- `VERSION`
- `VERSION_SYM`
- `VERSION_FROM`
- `LICENSE`
- `AUTHOR`
- `TO_INST_PM`
- `EXE_FILES`
- `DIST_DEFAULT_TARGET`
- `SUFFIX`
- `ABSTRACT_FROM`

Any remaining values are stored in `ARGV_AR`.

The helper also derives:

- `TO_INST_PM_AR` from whitespace-splitting `TO_INST_PM`
- `EXE_FILES_AR` from whitespace-splitting `EXE_FILES`

### perlrun

```perl
my $command = perlrun($hook_object);
```

Builds a Makefile command string beginning with `$(PERL)`. It includes
non-default local `@INC` directories as `-I` options, loaded `ExtUtils::*`
modules as `-M` options, and the hook object's class as the final module to
load.

This value is installed into MakeMaker's `PERLRUN` macro by
`Local::ExtUtils::Common::MM::const_config`.

## Usage Conventions

Functions in this module are intended for build-time helper code and generated
make target methods. New make target methods should use `arg` to decode their
calling arguments instead of reading positional values directly.

## See Also

- `Local::ExtUtils::Common`
- `Local::ExtUtils::Common::MM`

