# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Local-ExtUtils-Common.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 9;
use File::Path qw(make_path);
use File::Spec;
use File::Temp qw(tempdir);

BEGIN { use_ok('Local::ExtUtils::Common') };
use Local::ExtUtils::Common::MM::Constant qw(
    $EXTUTILS_COMMON_PM_ARGV
    $TEMPLATE_POSTAMBLE_FN
    $UPDATE_SOURCE_UTIL_FN
);

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $tmp_dir=tempdir(CLEANUP => 1);
my $dest_dir=File::Spec->catdir($tmp_dir, qw(Local ExtUtils Common MM));
make_path($dest_dir);
my $dest_fn=File::Spec->catfile($dest_dir, 'Util.pm');

my @makemaker_args=(
    'Local::ExtUtils::Common',
    'Local_ExtUtils_Common',
    'Local-ExtUtils-Common',
    'Local-ExtUtils-Common-0.010',
    '0.010',
    '0_010',
    'lib/Local/ExtUtils/Common.pm',
    'perl',
    'Andrew Speer <aspeer@localdomain>',
    $dest_fn,
    '',
    'all',
    '.pm',
    'lib/Local/ExtUtils/Common.pm',
);

sub target_args {
    my ($to_inst_pm, @argv)=@_;
    my @args=@makemaker_args;
    $args[9]=$to_inst_pm;
    return (@args, @argv);
}

my $postamble=do {
    open(my $fh, '<', $TEMPLATE_POSTAMBLE_FN)
        or die "unable to open $TEMPLATE_POSTAMBLE_FN: $!";
    local $/;
    <$fh>;
};

like(
    $postamble,
    qr/EXTUTILS_COMMON_PM_TARGET=\@\$\(PERLRUN\) \\\n\t-e 'my \$\$method=shift\(\@ARGV\)/,
    'postamble defines quiet method-dispatch target syntax'
);

like(
    $postamble,
    qr/\$\(EXTUTILS_COMMON_PM\)->\$\$method\(\$\(EXTUTILS_COMMON_PM_ARGV\), \@ARGV\)/,
    'postamble passes MakeMaker args before target args'
);

is(
    scalar split(/,/, $EXTUTILS_COMMON_PM_ARGV),
    scalar @makemaker_args,
    'test MakeMaker argument list matches postamble macro arity'
);

ok(
    Local::ExtUtils::Common->utilsync(target_args($dest_fn, $UPDATE_SOURCE_UTIL_FN)),
    'utilsync copies utility file to trial destination'
);

ok(-e $dest_fn, 'trial destination exists');

my $source_size=-s $UPDATE_SOURCE_UTIL_FN;
my $dest_size=-s $dest_fn;
is($dest_size, $source_size, 'trial destination has source size');

my $source_mtime=(stat($UPDATE_SOURCE_UTIL_FN))[9];
utime($source_mtime + 100, $source_mtime + 100, $dest_fn)
    or die "utime failed for $dest_fn: $!";

ok(
    Local::ExtUtils::Common->utilsync(target_args($dest_fn, $UPDATE_SOURCE_UTIL_FN)),
    'utilsync overwrites existing destination'
);

like(
    do {
        local $@;
        eval { Local::ExtUtils::Common->utilsync(target_args($UPDATE_SOURCE_UTIL_FN, $UPDATE_SOURCE_UTIL_FN)) };
        $@;
    },
    qr/source and destination are the same/,
    'utilsync refuses same source and destination'
);
