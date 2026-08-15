# Local::ExtUtils::Common

## Name

Local::ExtUtils::Common - top-level entry point and make-target methods for local MakeMaker helpers

## Synopsis

```perl
use Local::ExtUtils::Common;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Some::Module',
    VERSION_FROM => 'lib/Some/Module.pm',
);
```

```perl
use Local::ExtUtils::Common qw(const_config postamble);
```

## Description

`Local::ExtUtils::Common` is the public entry point for the distribution. It
sets version metadata, imports shared utility functions from
`Local::ExtUtils::Common::MM::Util`, and forwards import handling to
`Local::ExtUtils::Common::MM::Import`.

When imported without arguments, it defaults to enabling the `const_config` and
`postamble` MakeMaker sections. Import handling is lazy-loaded and then
delegated to `Local::ExtUtils::Common::MM::Import`.

The module also contains methods intended to be invoked by generated make
targets.

## Methods

### import

```perl
use Local::ExtUtils::Common;
use Local::ExtUtils::Common qw(const_config postamble);
```

Enables MakeMaker section hooks. If no sections are supplied, `const_config`
and `postamble` are requested.

The implementation loads `Local::ExtUtils::Common::MM::Import` and forwards to
its `import` method.

### dump_param

```perl
Local::ExtUtils::Common->dump_param(@makemaker_args, @args);
```

Debugging method. It parses the MakeMaker-style argument list with `arg` and
prints the resulting hash using `Dumper`.

### utilsync

```perl
Local::ExtUtils::Common->utilsync(
    @makemaker_args,
    $source_file,
);
```

Copies one of this distribution's helper files into the consuming
distribution. The method expects the fixed MakeMaker argument block first,
followed by the source file path. The destination is not passed directly.
Instead, `utilsync` derives it from the parsed `TO_INST_PM` MakeMaker value.

The destination lookup uses the source basename and selects an installed module
path ending in:

```text
MM/<source basename>
```

For example, a source named `Util.pm` is matched against a target path ending
in `MM/Util.pm`.

The method validates that:

- a source argument is present
- `TO_INST_PM` can be parsed into `TO_INST_PM_AR`
- the destination can be found in `TO_INST_PM_AR`
- the source exists, is a regular file, and is readable
- the destination directory exists
- the source and destination are not the same path or same file

It copies via a temporary file in the destination directory, preserves mode and
timestamps from the source, then renames the temporary file into place.

After copying, it runs an in-place Perl substitution over the destination file,
replacing the helper package name with the consuming distribution's `NAME`
value.

Current behavior allows overwriting an existing destination file.

## Usage Conventions

Load this module from `Makefile.PL` before MakeMaker generates the Makefile.
It is build-time infrastructure and is not intended to be part of normal module
runtime behavior.

Target methods should accept the fixed MakeMaker argument block first and use
`Local::ExtUtils::Common::MM::Util::arg` to separate MakeMaker fields from
target-specific arguments.

## See Also

- `Local::ExtUtils::Common::MM`
- `Local::ExtUtils::Common::MM::Import`
- `Local::ExtUtils::Common::MM::Util`
- `Local::ExtUtils::Common::MM::Constant`

