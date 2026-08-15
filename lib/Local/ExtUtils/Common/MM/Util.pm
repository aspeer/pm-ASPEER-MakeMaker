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
package Local::ExtUtils::Common::MM::Util;


#  Pragma
#
use strict;
use vars qw($VERSION $DEBUG $QUIET $VERBOSE @EXPORT);
use warnings;


#  External modules
#
use FindBin qw($RealBin $Script);
FindBin::again();
use Data::Dumper;
use IO::File;
local $Data::Dumper::Indent=1;
local $Data::Dumper::Terse=1;
local $Data::Dumper::SortKeys=1;


#  Export functions
#
use base 'Exporter';
@EXPORT=qw(err msg verbose debug quiet_enable verbose_enable debug_enable Dumper slurp blurp touch arg perlrun);


#  Version information in a format suitable for CPAN etc. Must be
#  all on one line
#
$VERSION='0.010';


#  Debugging on ?
#
$Script=~s/\.pl$//;
($Carp::Verbose=++$DEBUG) if $ENV{uc("${Script}_DEBUG")};


#  Done
#
1;

#==================================================================================================


sub quiet_enable {


    #  Turn on quiet flag
    #
    $QUIET=shift() || 1;
    

}


sub verbose {

    #  Print verbose message
    #
    return if $QUIET || !$VERBOSE;
    return CORE::print STDERR &fmt(@_), $/;

}


sub verbose_enable {

    #  Turn on verbose flag
    #
    $VERBOSE=shift() || 1;

}


sub debug_enable {

    #  Turn on debugging flag
    #
    $DEBUG=shift();
    
}


sub debug {

    #  Debug
    #
    $DEBUG || return;
    my $debug=sprintf(shift(), @_);
    chomp($debug);
    my ($package, undef, $line, $method) = caller(1);  # '1' for caller of the function
    print STDERR sprintf("[%s:%d] %s$/", 
        join('::', grep {$_} ($package, $method)),
        $line,
        $debug
    );

}


sub err {

    #  Quit on errors
    #
    my $msg=&fmt('error: %s', @_);
    CORE::print STDERR $msg, "\n";
    eval {require Carp; 1};
    Carp::croak;

}


sub fmt {


    #  Format message nicely. Always called by err or msg so caller=2
    #
    my $message=sprintf(shift(), @_);
    chomp($message);
    my @caller=(caller(2));
    my $caller=$caller[3] || $caller[0];
    my ($class, $method)=($caller=~/^(.*)::([^:]+)$/);
    $method ||=$caller[0]; 
    $caller=~s/^_?!(_)//;
    my $format=' @<<<<<<<<<<<<<<<<<< @*';
    local $^A='';
    formline $format, "[$method]", $message;
    return $^A;

}


sub msg {

    #  Print message
    #
    return (CORE::print STDERR &fmt(@_), $/) unless $QUIET;

}


sub slurp {

    #  Slurp in file content
    #
    my ($fn)=@_;
    my $fh=IO::File->new($fn, 'r') ||
        return err("unable to open file $fn, $!");
    local $/=undef;
    my $text=<$fh>;
    $fh->close();
    return $text || '';

}


sub blurp {

    #  Save file content
    #
    my ($fn, $text)=@_;
    my $fh=IO::File->new($fn, 'w') ||
        return err("unable to open $fn for write, $!");
    print $fh $text;
    $fh->close();
    return 1;

}


sub touch {

    my ($fn)=@_;
    return 1 if -e $fn;
    return blurp($fn, '');

}


sub perlrun {

    
    #  Get self ref
    #
    my $self=shift();


    #  Construct PERL runtime
    #
    my $perl_inc_ar=&perl_inc;
    
    
    #  And modules
    #
    my $perl_mod_ar=&perl_mod;


    #  Now construct final PERLRUN string
    #
    my $perlrun;
    my $perlrun_inc=join(' ', map {"-I$_"} @{$perl_inc_ar});
    my $perlrun_mod=join(' ', map {"-M$_"} @{$perl_mod_ar});
    my $class=ref($self);
    if (my $import_tag_ar=$MY::->{__PACKAGE__}{'import_tag'}) {
        $perlrun=sprintf("\$(PERL) $perlrun_inc $perlrun_mod -M${class}=%s", join(',', @{$import_tag_ar}));
    }
    else {
        $perlrun="\$(PERL) $perlrun_inc $perlrun_mod -M${class}";
    }
    
    
    #  And return
    #
    return $perlrun
    
}


sub perl_mod {

    my %seen=(
        __PACKAGE__ => 1
    );
    my @m=sort 
        grep { !$seen{$_}++ } 
        map {(my $m = $_) =~ s{\.pm$}{}; $m =~ s{/}{::}g; $m;}
        grep { m{^ExtUtils/} }
        keys %INC;
    return \@m;
}


sub perl_inc {

    #  Return array ref of any additional libraries specified via command line (-I)
    #
    my %default_inc=map { $_ => 1 } @{ perl_inc_default() || [] };
    my %seen;
    my @lib=grep {
        !$default_inc{$_} && !$seen{$_}++
    } map {
        File::Spec->rel2abs($_)
    } grep {
        defined($_) && !ref($_) && length($_) && -d $_
    } @INC;

    return \@lib;
}


sub perl_inc_default {

    my @default_inc;
    if (open(my $perl_fh, '-|', $^X, '-e', 'print join qq(\0), grep { defined && !ref && length && -d } @INC')) {
        local $/;
        my $inc=<$perl_fh>;
        close($perl_fh);
        @default_inc=map {
            File::Spec->rel2abs($_)
        } split(/\0/, ($inc || ''));
    }
    return \@default_inc;
}


sub arg {

    #  Convert MakeMaker target args to a named parameter hash.
    #
    my (%param, @argv);
    (@param{qw(
        NAME
        NAME_SYM
        DISTNAME
        DISTVNAME
        VERSION
        VERSION_SYM
        VERSION_FROM
        LICENSE AUTHOR
        TO_INST_PM
        EXE_FILES
        DIST_DEFAULT_TARGET
        SUFFIX
        ABSTRACT_FROM
    )}, @argv)=@_;
    $param{'TO_INST_PM_AR'}=[split /\s+/, $param{'TO_INST_PM'}];
    $param{'EXE_FILES_AR'}=[split /\s+/, $param{'EXE_FILES'}];
    $param{'ARGV_AR'}=\@argv;
    return \%param

}

