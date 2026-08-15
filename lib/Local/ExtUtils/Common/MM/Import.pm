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
package Local::ExtUtils::Common::MM::Import;


#  Compiler Pragma
#
use strict qw(vars);
use vars   qw($VERSION @ISA $IMPORTED);
use warnings;
no warnings qw(uninitialized);
sub BEGIN {local $^W=0}


#  Base Packages
#
use Local::ExtUtils::Common::MM;
use Local::ExtUtils::Common::MM::Util;
use Local::ExtUtils::Common::MM::Constant;


#  External Packages
#
use Software::LicenseUtils;


#  Version information in a formate suitable for CPAN etc. Must be
#  all on one line
#
$VERSION='0.010';


#  All done, init finished
#
1;


#======================================================================================================================


sub import {


    #  Manage activation of various ExtUtils::Makemaker sections for this class.
    #
    #  use ExtUtils::<This Package> qw(const_config) to just replace the macros section of the Makefile
    #  .. qw(dist_ci) to replace standard MakeMaker targets with our own
    #  .. qw(:all) or no tag (i.e defaults) to all targers
    #  
    #
    my ($class, @section)=@_;
    return if $_{$class}{'loaded'}++;
    require ExtUtils::MakeMaker;
    msg("initializing $class import");


    #  Get params, bless self ref and remember import tags spec'd for later
    #  re-use
    #
    my $self=bless (\my %self, $class);
    
    
    #  Build chain of MM modules loaded for this OS so we can search for
    #  code ref's associated with various ExtUtils::MakeMaker sections;
    #
    my @mm_isa=grep {/^ExtUtils::MM/} @ExtUtils::MM::ISA;
    push @mm_isa, map { @{"${_}::ISA"} } @mm_isa;
    die('no ExtUtils::MM inheritance found in @ISA') unless @mm_isa;
    

    #  Sections to augment with additional targets
    #
    {   no warnings qw(redefine once);
        foreach my $section (qw(const_config depend), @section) {
            next if $self{$section};
            $self{$section} =*{"ExtUtils::MM::${section}"}{CODE}; # unless (*{"ExtUtils::MM::${section}"}{CODE} eq \&{$section});
            $self{$section} ||= do {
                my ($cr)=grep {$_} (map { $_->can($section) } @mm_isa);
                $cr || sub {''};
            };
            $self{$section} ||= ExtUtils::MM_Unix->can($section) || sub {''};
            my $sub=sprintf('%s::MM::%s', ref($self), $section);
            if (my $cr=*{$sub}{CODE}) {
                msg("import $section from $sub");
                *{"ExtUtils::MM::${section}"}=sub { $cr->($self, @_) };
            }
            else {
                msg("import $section from %s", __PACKAGE__);
                *{"ExtUtils::MM::${section}"}=sub { &{$section}($self, @_) };
            }
            #*{"ExtUtils::MM::${section}"}=sub {&{sprintf('%s::MM::%s', ref($self), $section)}($self, @_)};
        }
    }
    msg("initializing $class import complete");

}


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

sub const_config {


    #  Get self ref
    #
    #
    my ($self, $mm_or, @param)=@_;
    (my $section = (caller(0))[3]) =~ s/^.*:://;
    msg("generating %s $section", ref($self));
    

    #  Get original const_config ready for append
    #
    my $const_config=$self->{$section}($mm_or, @param);


    #  Import Constants into macros
    #
    while (my ($key, $value)=each %{sprintf('%s::MM::Constant::Constant', ref($self))}) {

        #  Update macros with our config
        #
        msg("add macro: $key, value: $value");
        $mm_or->{'macro'}{$key}=$value;

    }


    #   Update license data. Get license type and author
    #
    my $license=$mm_or->{'LICENSE'} ||
        return err('no license specified in Makefile');
    my @author=@{
        $mm_or->{'AUTHOR'}
            ||
            return err('no author specified in Makefile')};
    my $author=shift(@author);


    #  Choose appropriate module
    #
    my @license_module=Software::LicenseUtils->guess_license_from_meta_key($license);
    @license_module ||
        return err("unable to determine correct license module from string: $license");
    (@license_module > 1) &&
        return err("ambiguous license string: $license, resolves to %s", join(',', @license_module));
    my $license_or=(shift @license_module)->new({holder => $author});


    #  Generate data later used in META files
    #
    @{$mm_or->{'macro'}}{qw(LICENSE AUTHOR)}=($license, $author);
    $mm_or->{'META_MERGE'}{'resources'}{'license'}=$license_or->url();


    #  Now construct final PERLRUN string
    #
    my $perlrun=&perlrun($self);
    $mm_or->{'PERLRUN'}=$perlrun;


    #  Keep copy of DIST_DEFAULT
    #
    $mm_or->{'macro'}{'DIST_DEFAULT_TARGET'}=$mm_or->{'DIST_DEFAULT'};


    #  Return whatever our parent does
    #
    return $const_config;


}





#  MakeMaker::MY replacement depend section
#
sub depend {


    #  Get self ref
    #
    my ($self, $mm_or, @param)=@_;
    (my $section = (caller(0))[3]) =~ s/^.*:://;
    msg("generating %s $section", ref($self));


    #  Get original and modify
    #
    my $depend=$self->{$section}($mm_or, @param);


    #  If nothing generate default
    #
    if (!$depend && $mm_or->{'VERSION_FROM'}) {
        $depend='Makefile : $(VERSION_FROM)';
    }
    return $depend;

}

__END__

=begin markdown

# Local::ExtUtils::Common::Import

## Name

Local::ExtUtils::Common::Import - import-time MakeMaker section hook manager

## Synopsis

```perl
use Local::ExtUtils::Common qw(const_config postamble);
```

Usually this module is not used directly. It is invoked by
`Local::ExtUtils::Common`.

## Description

`Local::ExtUtils::Common::Import` installs the MakeMaker hooks requested by the
caller. For each requested MakeMaker section, it finds and stores the original
implementation, then replaces the corresponding `ExtUtils::MM::*` method with
a wrapper that calls this distribution's implementation.

For example, requesting `postamble` causes calls to
`ExtUtils::MM::postamble` to be routed to:

```perl
Local::ExtUtils::Common::MM::postamble(...)
```

The original MakeMaker method is saved in the hook object's internal hash so
the replacement can call it and append or modify the result.

## Import Behavior

```perl
Local::ExtUtils::Common::Import->import(@sections);
```

The import process:

1. Requires `ExtUtils::MakeMaker`.
2. Builds a list of active `ExtUtils::MM::*` classes from `@ExtUtils::MM::ISA`.
3. For each requested section, locates the original implementation.
4. Stores the original code reference.
5. Replaces `ExtUtils::MM::$section` with a wrapper method.

The wrapper dispatches to:

```perl
<importing class>::MM::<section>
```

For this distribution, that normally means `Local::ExtUtils::Common::MM`.

## Usage Conventions

This module is part of the import mechanism and is normally loaded indirectly.
Callers should prefer:

```perl
use Local::ExtUtils::Common;
```

or:

```perl
use Local::ExtUtils::Common qw(const_config postamble);
```

Because it modifies `ExtUtils::MM` symbol table entries, it should be used only
during Makefile generation.

## Diagnostics

The module emits formatted status messages through
`Local::ExtUtils::Common::Util::msg`. It dies if no `ExtUtils::MM` inheritance
chain can be found.

## See Also

- `Local::ExtUtils::Common`
- `Local::ExtUtils::Common::MM`
- `ExtUtils::MakeMaker`


=end markdown


=head1 Local::ExtUtils::Common::Import


=head2 Name

Local::ExtUtils::Common::Import - import-time MakeMaker section hook manager


=head2 Synopsis


 use Local::ExtUtils::Common qw(const_config postamble);
Usually this module is not used directly. It is invoked by
C<Local::ExtUtils::Common>.


=head2 Description

C<Local::ExtUtils::Common::Import> installs the MakeMaker hooks requested by the
caller. For each requested MakeMaker section, it finds and stores the original
implementation, then replaces the corresponding C<ExtUtils::MM::*> method with
a wrapper that calls this distribution's implementation.

For example, requesting C<postamble> causes calls to
C<ExtUtils::MM::postamble> to be routed to:


 Local::ExtUtils::Common::MM::postamble(...)
The original MakeMaker method is saved in the hook object's internal hash so
the replacement can call it and append or modify the result.


=head2 Import Behavior


 Local::ExtUtils::Common::Import->import(@sections);
The import process:

=over

=item 1.

Requires C<ExtUtils::MakeMaker>.


=item 2.

Builds a list of active C<ExtUtils::MM::*> classes from C<@ExtUtils::MM::ISA>.


=item 3.

For each requested section, locates the original implementation.


=item 4.

Stores the original code reference.


=item 5.

Replaces C<ExtUtils::MM::$section> with a wrapper method.


=back

The wrapper dispatches to:


 <importing class>::MM::<section>
For this distribution, that normally means C<Local::ExtUtils::Common::MM>.


=head2 Usage Conventions

This module is part of the import mechanism and is normally loaded indirectly.
Callers should prefer:


 use Local::ExtUtils::Common;
or:


 use Local::ExtUtils::Common qw(const_config postamble);
Because it modifies C<ExtUtils::MM> symbol table entries, it should be used only
during Makefile generation.


=head2 Diagnostics

The module emits formatted status messages through
C<Local::ExtUtils::Common::Util::msg>. It dies if no C<ExtUtils::MM> inheritance
chain can be found.


=head2 See Also

=over

=item -

C<Local::ExtUtils::Common>


=item -

C<Local::ExtUtils::Common::MM>


=item -

C<ExtUtils::MakeMaker>


=back

=cut
