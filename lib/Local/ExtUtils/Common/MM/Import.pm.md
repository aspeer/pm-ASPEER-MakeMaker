# Local::ExtUtils::Common::MM::Import

## Name

Local::ExtUtils::Common::MM::Import - MakeMaker hook installer and active section implementations

## Synopsis

```perl
use Local::ExtUtils::Common;
```

```perl
use Local::ExtUtils::Common qw(const_config postamble);
```

Usually this module is not used directly. It is loaded by
`Local::ExtUtils::Common::import`.

## Description

`Local::ExtUtils::Common::MM::Import` installs and implements the current
`ExtUtils::MakeMaker` hooks for this distribution.

It only performs hook installation while running under a `Makefile.PL` process.
If imported outside that context, it returns without modifying `ExtUtils::MM`.

The module always considers `const_config`, `depend`, and `postamble`, and also
honors any additional section names passed by the caller. For each section, it
saves the original MakeMaker implementation and then replaces
`ExtUtils::MM::$section` with a wrapper.

If a method named `<importing class>::MM::<section>` exists, the wrapper calls
that method. Otherwise it calls the section method implemented in this module.

## Import Behavior

```perl
Local::ExtUtils::Common::MM::Import->import(@sections);
```

The import process:

1. Returns immediately if this class has already been loaded.
2. Returns immediately unless the current process name matches `Makefile.PL`.
3. Builds a list of active `ExtUtils::MM::*` classes from `@ExtUtils::MM::ISA`.
4. Saves the original implementation for each requested section.
5. Replaces the matching `ExtUtils::MM::*` symbol with a wrapper.

The original method is stored in the hook object's internal hash and is called
by the replacement section methods before augmenting the result.

## Section Methods

### const_config

```perl
Local::ExtUtils::Common::MM::Import::const_config($hook, $mm, @args);
```

Calls the original MakeMaker `const_config`, then copies constants from
`Local::ExtUtils::Common::MM::Constant` into the Makefile macro table.

It also validates and expands license metadata:

- requires `LICENSE` in the MakeMaker object
- requires `AUTHOR`
- uses `Software::LicenseUtils` to resolve the license key
- writes the license URL into `META_MERGE.resources.license`
- copies normalized `LICENSE` and first `AUTHOR` into the macro table

The method then installs a generated `PERLRUN` command and stores
`DIST_DEFAULT` in the `DIST_DEFAULT_TARGET` macro.

### depend

```perl
Local::ExtUtils::Common::MM::Import::depend($hook, $mm, @args);
```

Calls the original MakeMaker `depend` section. If the original section returns
no dependency text and `VERSION_FROM` is set, it supplies:

```make
Makefile : $(VERSION_FROM)
```

### postamble

```perl
Local::ExtUtils::Common::MM::Import::postamble($hook, $mm, @args);
```

Calls the original MakeMaker `postamble`, then appends the configured template
when `TEMPLATE_POSTAMBLE_FN` is available in this module's namespace.

The current bundled template is:

```text
lib/Local/ExtUtils/Common/MM/postamble.inc
```

## Usage Conventions

Callers should normally use `Local::ExtUtils::Common`, not this module
directly.

Because the module modifies `ExtUtils::MM` symbol table entries, it should be
used only during Makefile generation.

## Diagnostics

The module emits formatted status messages through
`Local::ExtUtils::Common::MM::Util::msg`. It dies if no `ExtUtils::MM`
inheritance chain can be found, if required license/author metadata is missing,
or if the configured license string cannot be resolved unambiguously.

## See Also

- `Local::ExtUtils::Common`
- `Local::ExtUtils::Common::MM`
- `Local::ExtUtils::Common::MM::Constant`
- `Local::ExtUtils::Common::MM::Util`
- `ExtUtils::MakeMaker`

