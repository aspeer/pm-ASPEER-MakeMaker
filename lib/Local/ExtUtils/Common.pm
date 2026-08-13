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

use 5.038002;
use strict;
use warnings;

use Local::ExtUtils::Common::MM ();
use Local::ExtUtils::Common::Util;
use File::Basename qw(dirname);
use File::Copy qw(copy);
use File::Spec;
use File::Temp qw(tempfile);
use Data::Dumper;
local $Data::Dumper::Sortkeys=1;

sub import {

    push (@_, qw(const_config postamble)) unless $_[1];
    #die Dumper(\@_);
    goto &Local::ExtUtils::Common::Import::import;
    
}

#==============================================================================

sub foobar {

    my ($self, $param_hr)=(shift(), arg(@_));

    print Dumper($param_hr);

}

sub utilsync {

    my ($self, $param_hr)=(shift(), arg(@_));
    my ($source_fn, $dest_fn)=@{$param_hr->{'ARGV_AR'}};
    #die (Dumper([$source_fn, $dest_fn]));

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

__END__

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Local::ExtUtils::Common ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';


# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Local::ExtUtils::Common - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Local::ExtUtils::Common;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Local::ExtUtils::Common, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Andrew Speer, E<lt>aspeer@localdomainE<gt>

=head1 LICENSE and COPYRIGHT

This file is part of Local::ExtUtils::Common.

This software is copyright (c) 2026 by Andrew Speer L<mailto:aspeer@localdomain>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

Full license text is available at:

L<http://dev.perl.org/licenses/>

=cut
