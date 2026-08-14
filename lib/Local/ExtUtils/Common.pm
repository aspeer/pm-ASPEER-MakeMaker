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
use Local::ExtUtils::Common::Util;


#  Other modules
#
use File::Basename qw(dirname);
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
        goto &Local::ExtUtils::Common::Import::import;
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
    my ($source_fn, $dest_fn)=@{$param_hr->{'ARGV_AR'}};

    die "usage: $self->utilsync(..., UPDATE_SOURCE_UTIL_FN, UPDATE_DEST_UTIL_FN)\n"
        unless $source_fn && $dest_fn;

    die "source file not found: $source_fn\n"
        unless -e $source_fn;
    die "source is not a regular file: $source_fn\n"
        unless -f _;
    die "source is not readable: $source_fn\n"
        unless -r _;

    my $dest_dir=dirname($dest_fn);
    die "destination directory not found: $dest_dir\n"
        unless -d $dest_dir;

    my $source_abs=File::Spec->rel2abs($source_fn);
    my $dest_abs=File::Spec->rel2abs($dest_fn);
    die "source and destination are the same path: $source_abs\n"
        if $source_abs eq $dest_abs;

    my @source_stat=stat($source_fn)
        or die "stat failed for source $source_fn: $!\n";

    if (-e $dest_fn) {

        my @dest_stat=stat($dest_fn)
            or die "stat failed for destination $dest_fn: $!\n";

        die "source and destination are the same file: $source_fn -> $dest_fn\n"
            if $source_stat[0] == $dest_stat[0] && $source_stat[1] == $dest_stat[1];

        #die "destination is newer than source, refusing to overwrite: $dest_fn\n"
        #    if $dest_stat[9] > $source_stat[9];

    }

    my ($tmp_fh, $tmp_fn)=tempfile('.utilsync.XXXXXXXX', DIR => $dest_dir);
    close($tmp_fh)
        or die "close failed for temporary file $tmp_fn: $!\n";

    eval {
        copy($source_fn, $tmp_fn)
            or die "copy failed from $source_fn to $tmp_fn: $!\n";
        chmod($source_stat[2] & 07777, $tmp_fn)
            or die "chmod failed for temporary file $tmp_fn: $!\n";
        utime($source_stat[8], $source_stat[9], $tmp_fn)
            or die "utime failed for temporary file $tmp_fn: $!\n";
        rename($tmp_fn, $dest_fn)
            or die "rename failed from $tmp_fn to $dest_fn: $!\n";
        1;
    } or do {
        my $err=$@ || 'unknown error';
        unlink($tmp_fn) if -e $tmp_fn;
        die $err;
    };

    print "updated $dest_fn from $source_fn\n";
}

