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
use Local::ExtUtils::Common::Import();
use Local::ExtUtils::Common::Util;
use Local::ExtUtils::Common::Constant;
@ISA=qw(Local::ExtUtils::Common::Import);


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

