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
package Local::ExtUtils::Common;


#  Pragma
#
use strict;
use warnings;
use vars qw($VERSION $VERSION_GIT_SHA $AUTHORITY);


#  Base packages
#
use Local::ExtUtils::Common::MM::Util;


#  Other modules
#
use File::Basename qw(dirname basename);
use File::Copy qw(copy);
use File::Spec;
use File::Temp qw(tempfile);
local $Data::Dumper::Sortkeys=1;


#  Version information
#
$AUTHORITY='cpan:ASPEER';
$VERSION='0.011';
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

    push (@_, qw(const_config postamble)) unless $_[1];
    require Local::ExtUtils::Common::MM::Import;
    goto &Local::ExtUtils::Common::MM::Import::import;
    
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
    msg('utilsync start');
    my $srce_fn=basename($srce_pn) ||
        return err("unable to get basebane from path: $srce_pn");
    my $to_inst_pm_ar=$param_hr->{'TO_INST_PM_AR'} ||
        return err('unable to get TO_INST_PM_AR Makefile param');
    my ($dest_pn)=(grep { /MM\/${srce_fn}$/ } @{$to_inst_pm_ar});
    $dest_pn ||
        return err("unable to get destination for $srce_fn from TO_INST_PM_AR: %s, dest file must exist !", Dumper($to_inst_pm_ar));
    

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

    msg("updated $dest_pn");
}

__END__

=begin markdown

# Local::ExtUtils::Common

## Name

Local::ExtUtils::Common - top-level entry point for local MakeMaker helpers

## Synopsis

```perl
use Local::ExtUtils::Common;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Some::Module',
    VERSION_FROM => 'lib/Some/Module.pm',
);
```

```perl
use Local::ExtUtils::Common qw(const_config postamble);
```

## Description

`Local::ExtUtils::Common` is the public entry point for the distribution. It
loads the MakeMaker hook implementation and delegates import handling to
`Local::ExtUtils::Common::Import`.

When imported without arguments, it defaults to enabling the `const_config` and
`postamble` MakeMaker sections. These hooks add shared Makefile macros and
append the common postamble template.

The module also contains methods that are intended to be invoked by generated
make targets.

## Methods

### import

```perl
use Local::ExtUtils::Common;
use Local::ExtUtils::Common qw(const_config postamble);
```

Enables MakeMaker section hooks. If no sections are supplied, `const_config`
and `postamble` are enabled.

The implementation forwards to `Local::ExtUtils::Common::Import::import`.

### utilsync

```perl
Local::ExtUtils::Common->utilsync(
    @makemaker_args,
    $source_file,
    $destination_file,
);
```

Copies a source utility file to a destination path. The method expects the
fixed MakeMaker argument block first, followed by the source and destination
file names. This matches the call shape generated by the bundled postamble:

```perl
$(EXTUTILS_COMMON_PM)->$method($(EXTUTILS_COMMON_PM_ARGV), @ARGV)
```

The method validates that:

- source and destination arguments are present
- the source exists, is a regular file, and is readable
- the destination directory exists
- the source and destination are not the same path or same file

It copies via a temporary file in the destination directory, preserves mode and
timestamps from the source, then renames the temporary file into place.

Current behavior allows overwriting an existing destination file.

### foobar

```perl
Local::ExtUtils::Common->foobar(@makemaker_args, @args);
```

Debugging/demo method. It parses the MakeMaker-style argument list with `arg`
and prints the resulting hash using `Data::Dumper`.

## Usage Conventions

Load this module from `Makefile.PL` before MakeMaker generates the Makefile.
It is build-time infrastructure and is not intended to be part of normal module
runtime behavior.

Target methods should accept the fixed MakeMaker argument block first and use
`Local::ExtUtils::Common::Util::arg` to separate MakeMaker fields from
target-specific arguments.

## See Also

- `Local::ExtUtils::Common::Import`
- `Local::ExtUtils::Common::MM`
- `Local::ExtUtils::Common::Util`
- `Local::ExtUtils::Common::Constant`


=end markdown


=head1 Local::ExtUtils::Common


=head2 Name

Local::ExtUtils::Common - top-level entry point for local MakeMaker helpers


=head2 Synopsis


 use Local::ExtUtils::Common;
 use ExtUtils::MakeMaker;
 
 WriteMakefile(
     NAME         => 'Some::Module',
     VERSION_FROM => 'lib/Some/Module.pm',
 );

 use Local::ExtUtils::Common qw(const_config postamble);

=head2 Description

C<Local::ExtUtils::Common> is the public entry point for the distribution. It
loads the MakeMaker hook implementation and delegates import handling to
C<Local::ExtUtils::Common::Import>.

When imported without arguments, it defaults to enabling the C<const_config> and
C<postamble> MakeMaker sections. These hooks add shared Makefile macros and
append the common postamble template.

The module also contains methods that are intended to be invoked by generated
make targets.


=head2 Methods


=head3 import


 use Local::ExtUtils::Common;
 use Local::ExtUtils::Common qw(const_config postamble);
Enables MakeMaker section hooks. If no sections are supplied, C<const_config>
and C<postamble> are enabled.

The implementation forwards to C<Local::ExtUtils::Common::Import::import>.


=head3 utilsync


 Local::ExtUtils::Common->utilsync(
     @makemaker_args,
     $source_file,
     $destination_file,
 );
Copies a source utility file to a destination path. The method expects the
fixed MakeMaker argument block first, followed by the source and destination
file names. This matches the call shape generated by the bundled postamble:


 $(EXTUTILS_COMMON_PM)->$method($(EXTUTILS_COMMON_PM_ARGV), @ARGV)
The method validates that:

=over

=item -

source and destination arguments are present


=item -

the source exists, is a regular file, and is readable


=item -

the destination directory exists


=item -

the source and destination are not the same path or same file


=back

It copies via a temporary file in the destination directory, preserves mode and
timestamps from the source, then renames the temporary file into place.

Current behavior allows overwriting an existing destination file.


=head3 foobar


 Local::ExtUtils::Common->foobar(@makemaker_args, @args);
Debugging/demo method. It parses the MakeMaker-style argument list with C<arg>
and prints the resulting hash using C<Data::Dumper>.


=head2 Usage Conventions

Load this module from C<Makefile.PL> before MakeMaker generates the Makefile.
It is build-time infrastructure and is not intended to be part of normal module
runtime behavior.

Target methods should accept the fixed MakeMaker argument block first and use
C<Local::ExtUtils::Common::Util::arg> to separate MakeMaker fields from
target-specific arguments.


=head2 See Also

=over

=item -

C<Local::ExtUtils::Common::Import>


=item -

C<Local::ExtUtils::Common::MM>


=item -

C<Local::ExtUtils::Common::Util>


=item -

C<Local::ExtUtils::Common::Constant>


=back

=cut
