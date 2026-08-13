# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Local-ExtUtils-Common.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 6;
use File::Spec;
use File::Temp qw(tempdir);

BEGIN { use_ok('Local::ExtUtils::Common') };
use Local::ExtUtils::Common::Constant qw($UPDATE_SOURCE_UTIL_FN);

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $tmp_dir=tempdir(CLEANUP => 1);
my $dest_fn=File::Spec->catfile($tmp_dir, 'Util.pm.0');

ok(
    Local::ExtUtils::Common->utilsync(qw(dummy args), $UPDATE_SOURCE_UTIL_FN, $dest_fn),
    'utilsync copies utility file to trial destination'
);

ok(-e $dest_fn, 'trial destination exists');

my $source_size=-s $UPDATE_SOURCE_UTIL_FN;
my $dest_size=-s $dest_fn;
is($dest_size, $source_size, 'trial destination has source size');

my $source_mtime=(stat($UPDATE_SOURCE_UTIL_FN))[9];
utime($source_mtime + 100, $source_mtime + 100, $dest_fn)
    or die "utime failed for $dest_fn: $!";

like(
    do {
        local $@;
        eval { Local::ExtUtils::Common->utilsync(qw(dummy args), $UPDATE_SOURCE_UTIL_FN, $dest_fn) };
        $@;
    },
    qr/destination is newer than source/,
    'utilsync refuses to overwrite newer destination'
);

like(
    do {
        local $@;
        eval { Local::ExtUtils::Common->utilsync(qw(dummy args), $UPDATE_SOURCE_UTIL_FN, $UPDATE_SOURCE_UTIL_FN) };
        $@;
    },
    qr/source and destination are the same/,
    'utilsync refuses same source and destination'
);
