#
#  This file is part of Local::ExtUtils::Common.
#
#  This software is copyright (c) 2026 by Andrew Speer <aspeer@localdomain>.
#
#  This is free software; you can redistribute it and/or modify it under
#  the same terms as the Perl 5 programming language system itself.
#
#  Full license text is available at:
#
#  <http://dev.perl.org/licenses/>
#
package Local::ExtUtils::Common::MM;


#  Compiler Pragma
#
use strict qw(vars);
use vars   qw($VERSION @ISA $IMPORTED);
use warnings;
no warnings qw(uninitialized);
sub BEGIN {local $^W=0}


#  External Packages
#
use Local::ExtUtils::Common::MM::Import();
use Local::ExtUtils::Common::MM::Util;
use Local::ExtUtils::Common::MM::Constant;
@ISA=qw(Local::ExtUtils::Common::MM::Import);


#  Version information in a formate suitable for CPAN etc. Must be
#  all on one line
#
$VERSION='0.010';


#  All done, init finished
#
1;


#======================================================================================================================


#  ExtUtils::MakeMaker sections in this block
#
sub const_config0 {


    #  Get self ref
    #
    my ($self, $mm_or, @param)=@_;
    (my $section = (caller(0))[3]) =~ s/^.*:://;
    msg("generating %s $section", ref($self));
    

    #  Get original const_config ready for append
    #
    my $const_config=$self->{$section}($mm_or, @param);


    #  Import Constants into macros
    #
    #while (my ($key, $value)=each %{sprintf('%s::Constant::Constant', __PACKAGE__)}) {
    while (my ($key, $value)=each %{sprintf('%s::Constant::Constant', ref($self))}) {

        #  Update macros with our config
        #
        msg("add macro: $key, value: $value");
        $mm_or->{'macro'}{$key}=$value;

    }


    #  Now construct final PERLRUN string
    #
    my $perlrun=&perlrun($self);
    $mm_or->{'PERLRUN'}=$perlrun;

    
    #  Macros all set, return whatever master const_config does
    #
    return $const_config;

}


sub postamble {


    #  Get self ref
    #
    my ($self, $mm_or, @param)=@_;
    (my $section = (caller(0))[3]) =~ s/^.*:://;
    msg("generating %s $section", ref($self));
    

    #  Get original const_config ready for append
    #
    my $postamble=$self->{$section}($mm_or, @param);
    
    
    #  Get patch dir and file name
    #
    my $patch_fn=$TEMPLATE_POSTAMBLE_FN;


    #  Open it and slurp in
    #
    $postamble.=slurp($patch_fn);

}

__END__

=begin markdown

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


=end markdown


=head1 Local::ExtUtils::Common::MM


=head2 Name

Local::ExtUtils::Common::MM - MakeMaker section implementations


=head2 Synopsis


 use Local::ExtUtils::Common qw(const_config postamble);
The methods in this module are called by wrappers installed into
C<ExtUtils::MM>. They are not usually called directly.


=head2 Description

C<Local::ExtUtils::Common::MM> contains replacement or augmenting
implementations for selected C<ExtUtils::MakeMaker> sections.

Each method receives an internal hook object, the MakeMaker object, and the
original MakeMaker arguments. The hook object contains the saved original
MakeMaker implementation for that section.


=head2 Methods


=head3 const_config


 Local::ExtUtils::Common::MM::const_config($hook, $mm, @args);
Calls the original MakeMaker C<const_config> method, then imports constants from
C<Local::ExtUtils::Common::Constant> into the Makefile macro table.

The method also replaces the MakeMaker object's C<PERLRUN> value with a command
constructed by C<Local::ExtUtils::Common::Util::perlrun>. That command preserves
useful local include paths and loaded C<ExtUtils::*> modules when generated make
targets invoke Perl.


=head3 postamble


 Local::ExtUtils::Common::MM::postamble($hook, $mm, @args);
Calls the original MakeMaker C<postamble> method, then appends the contents of
the bundled postamble template:


 lib/Local/ExtUtils/Common/Constant/postamble.inc
The template defines common make targets and the method-dispatch helper used by
those targets.


=head2 Generated Postamble Convention

The postamble defines an C<EXTUTILS_COMMON_PM_TARGET> macro that calls a module
method selected from the first target argument:


 $(EXTUTILS_COMMON_PM_TARGET) utilsync ...
The generated Perl call passes the fixed MakeMaker macro argument block first,
then passes any remaining target arguments:


 $(EXTUTILS_COMMON_PM)->$method($(EXTUTILS_COMMON_PM_ARGV), @ARGV)
Methods intended for postamble dispatch should therefore parse their arguments
with C<Local::ExtUtils::Common::Util::arg>.


=head2 Usage Conventions

Add new MakeMaker section customizations here when they are meant to be
installed by C<Local::ExtUtils::Common::Import>.

Each section method should call the saved original implementation unless it is
intentionally replacing MakeMaker behavior outright.


=head2 See Also

=over

=item -

C<Local::ExtUtils::Common::Import>


=item -

C<Local::ExtUtils::Common::Constant>


=item -

C<Local::ExtUtils::Common::Util>


=back

=cut
