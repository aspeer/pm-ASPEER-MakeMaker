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
package Local::ExtUtils::Common::MM::Constant;


#  Pragma
#
use strict qw(vars);
use warnings;
use vars qw($VERSION @ISA %EXPORT_TAGS @EXPORT_OK @EXPORT %Constant);


#  Modules we need
#
use File::Spec;
use File::Basename qw(dirname);


#  Version information
#
$VERSION='1.005';


#  Get module file name and path, derive name of file to store local constants
#
use Cwd qw(abs_path);
my $local_fn=abs_path(__FILE__) . '.local';


#  Hash of constants
#
%Constant=(


    MM_PREFIX => 'EXTUTILS_COMMON',

    EXTUTILS_COMMON_PM => 'Local::ExtUtils::Common',
    
    TEMPLATE_POSTAMBLE_FN =>
        File::Spec->catfile(dirname(__FILE__), 'postamble.inc'),
        
    UPDATE_SOURCE_UTIL_FN =>
        File::Spec->catfile(dirname(__FILE__), 'Util.pm'),
        
    UPDATE_SOURCE_IMPORT_FN =>
        File::Spec->catfile(dirname(__FILE__), 'Import.pm'),

    EXTUTILS_COMMON_PM_ARGV => join(',', qw[
        "$(NAME)"
        "$(NAME_SYM)"
        "$(DISTNAME)"
        "$(DISTVNAME)"
        "$(VERSION)"
        "$(VERSION_SYM)"
        "$(VERSION_FROM)"
        "$(LICENSE)"
        "$(AUTHOR)"
        "$(TO_INST_PM)"
        "$(EXE_FILES)"
        "$(DIST_DEFAULT_TARGET)"
        "$(SUFFIX)"
        "$(ABSTRACT_FROM)"
    ]),


    #  Local constants override anything above
    #
    %{do($local_fn) || {}},
    %{do(my($fn)=glob(sprintf('~/.%s.local', __PACKAGE__))) || {}}    # || {} avoids warning

);


#  Export constants to namespace, place in export tags
#
require Exporter;
@ISA=qw(Exporter);
foreach (keys %Constant) {${$_}=$Constant{$_}}
@EXPORT=map {'$' . $_} keys %Constant;
@EXPORT_OK=@EXPORT;
%EXPORT_TAGS=(all => [@EXPORT_OK]);
$_=\%Constant;
__END__

=begin markdown

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

### MM_PREFIX

Private prefix used when constructing this extension's Makefile macro names.
It is consumed by the hook implementation and is not emitted as the generic
Makefile macro `MM_PREFIX`. When omitted, the importing class name is
uppercased and `::` is replaced with `_`.

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

Path to this distribution's source `MM/Util.pm`. The `util_sync` target can use
this as the source file for utility synchronization.

### UPDATE_SOURCE_IMPORT_FN

Path to this distribution's source `MM/Import.pm`. The `util_sync` target can
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

=end markdown


=head1 Local::ExtUtils::Common::MM::Constant


=head2 Name

Local::ExtUtils::Common::MM::Constant - exported constants and Makefile macro data


=head2 Synopsis


 use Local::ExtUtils::Common::MM::Constant qw(
     $EXTUTILS_COMMON_PM
     $TEMPLATE_POSTAMBLE_FN
     $UPDATE_SOURCE_UTIL_FN
     $UPDATE_SOURCE_IMPORT_FN
     $UPDATE_SOURCE_CONSTANT_FN
     $EXTUTILS_COMMON_PM_ARGV
 );

 use Local::ExtUtils::Common::MM::Constant qw(:all);

=head2 Description

C<Local::ExtUtils::Common::MM::Constant> defines constants used by the
MakeMaker hook layer and generated postamble targets.

The constants are stored in C<%Constant>, exported as scalar package variables,
and copied into the Makefile macro table by
C<Local::ExtUtils::Common::MM::Import::const_config>.


=head2 Constants


=head3 MM_PREFIX

Private prefix used when constructing this extension's Makefile macro names.
It is consumed by the hook implementation and is not emitted as the generic
Makefile macro C<MM_PREFIX>. When omitted, the importing class name is
uppercased and C<::> is replaced with C<_>.


=head3 EXTUTILS_COMMON_PM

The module name used by generated make targets when dispatching back into this
helper distribution.

Default:


 Local::ExtUtils::Common

=head3 TEMPLATE_POSTAMBLE_FN

Path to the bundled postamble template:


 lib/Local/ExtUtils/Common/MM/postamble.inc

=head3 UPDATE_SOURCE_UTIL_FN

Path to this distribution's source C<MM/Util.pm>. The C<util_sync> target can use
this as the source file for utility synchronization.


=head3 UPDATE_SOURCE_IMPORT_FN

Path to this distribution's source C<MM/Import.pm>. The C<util_sync> target can
use this as the source file for import helper synchronization.


=head3 UPDATE_SOURCE_CONSTANT_FN

Path to this distribution's source C<MM/Constant.pm>.


=head3 EXTUTILS_COMMON_PM_ARGV

A comma-separated Makefile macro expression that expands to the fixed argument
block passed into generated target methods.

The argument order matches C<Local::ExtUtils::Common::MM::Util::arg>:

=over

=item -

C<$(NAME)>


=item -

C<$(NAME_SYM)>


=item -

C<$(DISTNAME)>


=item -

C<$(DISTVNAME)>


=item -

C<$(VERSION)>


=item -

C<$(VERSION_SYM)>


=item -

C<$(VERSION_FROM)>


=item -

C<$(LICENSE)>


=item -

C<$(AUTHOR)>


=item -

C<$(TO_INST_PM)>


=item -

C<$(EXE_FILES)>


=item -

C<$(DIST_DEFAULT_TARGET)>


=item -

C<$(SUFFIX)>


=item -

C<$(ABSTRACT_FROM)>


=back


=head2 Local Overrides

After defining built-in defaults, the module applies optional local overrides.
The override files must evaluate to a hash reference.

The files are loaded in this order:

=over

=item 1.

A C<.local> file beside C<MM/Constant.pm>.


=item 2.

C<~/.Local::ExtUtils::Common::MM::Constant.local>.


=back

Later values override earlier values.


=head2 Export Behavior

All constants are exported by default as scalar variables. They are also
available through the C<:all> export tag.

The module also aliases C<$_> to C<%Constant> by assigning:


 $_ = \%Constant;

=head2 See Also

=over

=item -

C<Local::ExtUtils::Common>


=item -

C<Local::ExtUtils::Common::MM::Import>


=item -

C<Local::ExtUtils::Common::MM::Util>


=back

=cut
