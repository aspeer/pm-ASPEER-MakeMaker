# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Local-ExtUtils-Common.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 13;
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

is(
    Local::ExtUtils::Common::MM::Import::mm_prefix('ExtUtils::Markdown::Pod'),
    'EXTUTILS_MARKDOWN_POD',
    'default Makefile prefix is derived from the extension class'
);

my $tmp_dir=tempdir(CLEANUP => 1);
my $dest_dir=File::Spec->catdir($tmp_dir, qw(Local ExtUtils Common MM));
make_path($dest_dir);
my $dest_fn=File::Spec->catfile($dest_dir, 'Util.pm');
my $version_from_fn=File::Spec->catfile($tmp_dir, 'Version.pm');
open(my $version_from_fh, '>', $version_from_fn) ||
    die "unable to open $version_from_fn, $!";
print $version_from_fh "package Version;\nour \$VERSION='0.777';\n1;\n";
close($version_from_fh) || die "unable to close $version_from_fn, $!";

my @makemaker_args=(
    'Local::ExtUtils::Common',
    'Local_ExtUtils_Common',
    'Local-ExtUtils-Common',
    'Local-ExtUtils-Common-0.010',
    '0.010',
    '0_010',
    $version_from_fn,
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

unlike(
    $postamble,
    qr/^EXTUTILS_COMMON_PM_TARGET=/m,
    'postamble leaves platform command generation to MakeMaker'
);

like(
    $postamble,
    qr/\$\(EXTUTILS_COMMON_PM_TARGET\) util_sync \$\(UPDATE_SOURCE_UTIL_FN\)/,
    'postamble passes util_sync method and utility source explicitly'
);

unlike(
    $postamble,
    qr/(?:gherkin|foobar|serfin)/,
    'postamble contains no demonstration targets or missing methods'
);

is(
    scalar split(/,/, $EXTUTILS_COMMON_PM_ARGV),
    scalar @makemaker_args,
    'test MakeMaker argument list matches postamble macro arity'
);

ok(
    Local::ExtUtils::Common->util_sync(target_args($dest_fn, $UPDATE_SOURCE_UTIL_FN)),
    'util_sync copies utility file to trial destination'
);

ok(-e $dest_fn, 'trial destination exists');

like(
    Local::ExtUtils::Common::MM::Util::slurp($dest_fn),
    qr/\$VERSION='0\.777'/,
    'util_sync applies the version parsed from VERSION_FROM'
);

my $source_size=-s $UPDATE_SOURCE_UTIL_FN;
my $dest_size=-s $dest_fn;
is($dest_size, $source_size, 'trial destination has source size');

my $source_mtime=(stat($UPDATE_SOURCE_UTIL_FN))[9];
utime($source_mtime + 100, $source_mtime + 100, $dest_fn)
    or die "utime failed for $dest_fn: $!";

ok(
    Local::ExtUtils::Common->util_sync(target_args($dest_fn, $UPDATE_SOURCE_UTIL_FN)),
    'util_sync overwrites existing destination'
);

is((stat($dest_fn))[9], $source_mtime, 'util_sync preserves the source timestamp');

like(
    do {
        local $@;
        eval { Local::ExtUtils::Common->util_sync(target_args($UPDATE_SOURCE_UTIL_FN, $UPDATE_SOURCE_UTIL_FN)) };
        $@;
    },
    qr/source and destination are the same/,
    'util_sync refuses same source and destination'
);
