# Local::ExtUtils::Common

`Local::ExtUtils::Common` is a local helper distribution for sharing
`ExtUtils::MakeMaker` customizations across Perl modules.

The module is designed to be loaded from a `Makefile.PL`. On import it can
wrap selected `ExtUtils::MakeMaker` sections, add project-specific Makefile
macros, and append a reusable postamble containing common make targets.

## Purpose

This distribution centralizes build-time conventions that would otherwise be
copied between local Perl distributions. In particular it provides:

- MakeMaker import hooks for selected Makefile generation sections.
- A `const_config` extension that publishes shared constants as Makefile
  macros.
- A `postamble` extension that appends common make targets from a template.
- A `post_initialize` extension that controls the install map and records the
  Git revision beside `VERSION_FROM`.
- A `util_sync` target and method for copying this module's utility files into
  another distribution.
- Shared logging, file, argument-parsing, and Perl runtime construction helpers.

## Basic Usage

In a consuming `Makefile.PL`, load the module before calling `WriteMakefile`:

```perl
use Local::ExtUtils::Common;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Some::Module',
    VERSION_FROM => 'lib/Some/Module.pm',
);
```

With no import arguments, `Local::ExtUtils::Common` enables the `const_config`,
`depend`, `postamble`, and `post_initialize` hooks. A caller may also request
additional sections explicitly:

```perl
use Local::ExtUtils::Common qw(const_config postamble);
```

The generated postamble dispatches make targets back into the module through a
MakeMaker-generated command using the global `PERLRUN` value. Local include
paths are quoted for the platform shell. The target method receives a fixed
MakeMaker argument block first, followed by any target-specific arguments.

The Makefile retains any existing dependencies and also depends on
`VERSION_FROM`. License metadata is enriched when both `LICENSE` and `AUTHOR`
are supplied, but neither field is mandatory.

During post-initialization, documentation and temporary source files are
removed from the install map. If Git and `VERSION_FROM` are available, a
matching `.sha` provenance file is updated only when its content changes and is
installed beside the module or script. Executable filenames are always kept as
declared in `EXE_FILES`.

## Generated Targets

The bundled postamble currently defines `util_sync`. That target calls the
module's `util_sync` method twice:

- once to copy `Util.pm` to `$(UPDATE_DEST_UTIL_FN)`
- once to copy `Import.pm` to `$(UPDATE_DEST_IMPORT_FN)`

After each copy, the target rewrites occurrences of `Local::ExtUtils::Common`
in the destination file to the consuming distribution's `$(NAME)`.

The destination macro values are expected to be supplied by the consuming
distribution, usually through local constant overrides.

## Local Overrides

`Local::ExtUtils::Common::Constant` loads default constants from the module and
then applies optional local overrides from:

- a `.local` file next to `Constant.pm`
- `~/.Local::ExtUtils::Common::Constant.local`

Each override file is expected to evaluate to a hash reference.

## Documentation Map

The module-level sidecar documents describe the individual pieces:

- `lib/Local/ExtUtils/Common.pm.md`
- `lib/Local/ExtUtils/Common/MM/Import.pm.md`
- `lib/Local/ExtUtils/Common/MM.pm.md`
- `lib/Local/ExtUtils/Common/MM/Util.pm.md`
- `lib/Local/ExtUtils/Common/MM/Constant.pm.md`

## Notes

This module modifies `ExtUtils::MakeMaker` behavior by replacing selected
`ExtUtils::MM::*` methods at import time. It should therefore be loaded as part
of Makefile generation, not as a general runtime dependency.

The distribution requires Perl 5.8 or later.
