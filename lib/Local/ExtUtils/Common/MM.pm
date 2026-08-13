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
#use ExtUtils::MakeMaker;
#use ExtUtils::Markdown::Pod::MM::Constant;
#use ExtUtils::Markdown::Pod::Constant;
#use ExtUtils::Markdown::Pod::Util;
#use Digest::MD5 qw(md5_hex);
#use Config;
#use File::Spec;
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


sub import0 {


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
    #die Dumper(\@section);


    #  Get params, bless self ref and remember import tags spec'd for later
    #  re-use
    #
    my $self=bless (\my %self, $class);
    #my %import_tag=map {$_ => 1} @{$self{'import_tag'}=\@import};
    #$import_tag{':all'}++ unless keys %import_tag;
    
    
    #  Build chain of MM modules loaded for this OS so we can search for
    #  code ref's associated with various ExtUtils::MakeMaker sections;
    #
    my @mm_isa=grep {/^ExtUtils::MM/} @ExtUtils::MM::ISA;
    push @mm_isa, map { @{"${_}::ISA"} } @mm_isa;
    die('no ExtUtils::MM inheritance found in @ISA') unless @mm_isa;


    #  Sections to augment with additional targets
    #
    #my @section=qw(
    #    const_config
    #    postamble
    #);
    {   no warnings 'redefine';
        #foreach my $section (grep {$import_tag{$_} || $import_tag{':all'}} @section) {
        foreach my $section (@section) {
            $self{$section}=*{"ExtUtils::MM::${section}"}{CODE} unless (*{"ExtUtils::MM::${section}"}{CODE} eq \&{$section});
            $self{$section} ||= do {
                #msg('code map: %s', Dumper(\@mm_isa));
                my ($cr)=grep {$_} (map { $_->can($section) } @mm_isa);
                $cr || sub {''};
            };
            $self{$section} ||= ExtUtils::MM_Unix->can($section) || sub {''};
            msg("import $section: %s", $self{$section} || '');
            *{"ExtUtils::MM::${section}"}= sub {&{$section}($self, @_)};
        }
    }
    msg("initializing $class import complete");

}


#======================================================================================================================

#  ExtUtils::MakeMaker sections in this block
#
sub const_config {


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
