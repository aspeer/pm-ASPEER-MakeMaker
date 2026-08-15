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
package Local::ExtUtils::Common;


#  Pragma
#
use strict;
use warnings;
use vars qw($VERSION $VERSION_GIT_SHA $AUTHORITY);


#  Base packages
#
use Local::ExtUtils::Common::MM ();
use Local::ExtUtils::Common::MM::Util;


#  Other modules
#
use File::Basename qw(dirname basename);
use File::Copy qw(copy);
use File::Spec;
use File::Temp qw(tempfile);
use Data::Dumper;
local $Data::Dumper::Sortkeys=1;


#  Version information
#
$AUTHORITY='cpan:ASPEER';
$VERSION='0.010';
$VERSION_GIT_SHA=do { local (@ARGV, $/) = ($_=__FILE__.'.sha'); <> if -f $_ };
chomp($VERSION_GIT_SHA) if defined $VERSION_GIT_SHA;


#  Init Done
#
1;
#==============================================================================
#
#  Forward import on to dedicated module
#
sub import {

    if ($0=~/Makefile\.PL$/) {
        push (@_, qw(const_config postamble)) unless $_[1];
        goto &Local::ExtUtils::Common::MM::Import::import;
    }
    
}



#==============================================================================
#
#  Methods to support Makefile targets from here on
#
sub dump_param {

    my ($self, $param_hr)=(shift(), arg(@_));
    print Dumper($param_hr);

}



#  Copy template files from this module to target
#
sub utilsync {

    my ($self, $param_hr)=(shift(), arg(@_));
    my ($srce_pn)=@{$param_hr->{'ARGV_AR'}};
    
    
    #  Get dest 
    # 
    msg('utilsync start %s', Dumper($param_hr));
    my $srce_fn=basename($srce_pn) ||
        return err("unable to get basebane from path: $srce_pn");
    my $to_inst_pm_ar=$param_hr->{'TO_INST_PM_AR'} ||
        return err('unable to get TO_INST_PM_AR Makefile param');
    my ($dest_pn)=(grep { /MM\/${srce_fn}$/ } @{$to_inst_pm_ar});
    $dest_pn ||
        return err("unable to get destination for $srce_fn from TO_INST_PM_AR: %s, dest file must exist !", Dumper($to_inst_pm_ar));
    print ("srce: $srce_pn, dest: $dest_pn\n");
    #printf('%s -pi -e s/%s/%s/ %s'."\n", $^X, $self, $param_hr->{'NAME'}, $dest_pn);
    #msg('utilsync end');
    #return;
    #my $dest_fn;
    

    die "usage: $self->utilsync(..., UPDATE_SOURCE_UTIL_FN, UPDATE_DEST_UTIL_FN)\n"
        unless $srce_pn && $dest_pn;

    die "source file not found: $srce_pn\n"
        unless -e $srce_pn;
    die "source is not a regular file: $srce_pn\n"
        unless -f _;
    die "source is not readable: $srce_pn\n"
        unless -r _;

    my $dest_dir=dirname($dest_pn);
    die "destination directory not found: $dest_dir\n"
        unless -d $dest_dir;

    my $srce_abs=File::Spec->rel2abs($srce_pn);
    my $dest_abs=File::Spec->rel2abs($dest_pn);
    die "source and destination are the same path: $srce_abs\n"
        if $srce_abs eq $dest_abs;

    my @srce_stat=stat($srce_pn)
        or die "stat failed for source $srce_pn: $!\n";

    if (-e $dest_pn) {

        my @dest_stat=stat($dest_pn)
            or die "stat failed for destination $dest_pn: $!\n";

        die "source and destination are the same file: $srce_pn -> $dest_pn\n"
            if $srce_stat[0] == $dest_stat[0] && $srce_stat[1] == $dest_stat[1];

        #die "destination is newer than source, refusing to overwrite: $dest_pn\n"
        #    if $dest_stat[9] > $srce_stat[9];

    }

    my ($tmp_fh, $tmp_fn)=tempfile('.utilsync.XXXXXXXX', DIR => $dest_dir);
    close($tmp_fh)
        or die "close failed for temporary file $tmp_fn: $!\n";

    eval {
        copy($srce_pn, $tmp_fn)
            or die "copy failed from $srce_pn to $tmp_fn: $!\n";
        chmod($srce_stat[2] & 07777, $tmp_fn)
            or die "chmod failed for temporary file $tmp_fn: $!\n";
        utime($srce_stat[8], $srce_stat[9], $tmp_fn)
            or die "utime failed for temporary file $tmp_fn: $!\n";
        rename($tmp_fn, $dest_pn)
            or die "rename failed from $tmp_fn to $dest_pn: $!\n";
        1;
    } or do {
        my $err=$@ || 'unknown error';
        unlink($tmp_fn) if -e $tmp_fn;
        die $err;
    };
    
    
    my $qx=sprintf('%s -pi -e s/%s/%s/ %s'."\n", $^X, $self, $param_hr->{'NAME'}, $dest_pn);
    if (my $err=qx{$qx}) {
        return err("unexpected stdout on '$qx', $err");
    }
    if ($? != 0) {
        return err("qx command: '$qx' failed: $?");
    }

    print "updated $dest_pn from $srce_pn\n";
}

