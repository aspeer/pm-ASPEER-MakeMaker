use 5.008;
use strict;
use warnings;
use version;
use ExtUtils::MakeMaker;


#  Optional MakeMaker helpers, give helper targets
#
eval {
    require ExtUtils::Markdown::Pod; ExtUtils::Markdown::Pod->import(); 1
};


#  Main Makefile.PL section
#
my $mm_ver = $ExtUtils::MakeMaker::VERSION;
if ($mm_ver =~ /_/) { # dev version
    $mm_ver = eval $mm_ver;
    die $@ if $@;
}
my %WriteMakefile=(
    NAME                => 'Local::ExtUtils::Common',
    DISTNAME            => 'Local-ExtUtils-Common',
    VERSION_FROM        => 'lib/Local/ExtUtils/Common.pm',
    ABSTRACT_FROM       => 'lib/Local/ExtUtils/Common.pm',
    EXE_FILES           => [],
    LICENSE             => 'perl',
    AUTHOR              => 'Andrew Speer <andrew.speer@isolutions.com.au>',
    MIN_PERL_VERSION    => '5.008',
    PREREQ_PM           => {
        'Carp'                  =>  0,
        'Cwd'                   =>  0,
        'Data::Dumper'          =>  0,
        'Exporter'              =>  0,
        'ExtUtils::MM'          =>  0,
        'ExtUtils::MakeMaker'   =>  0,
        'File::Basename'        =>  0,
        'File::Copy'            =>  0,
        'File::Spec'            =>  0,
        'File::Temp'            =>  0,
        'FindBin'               =>  0,
        'IO::File'              =>  0,
        'Software::LicenseUtils'=>  0,
        'Tie::File'             =>  0,
        'base'                  =>  0,
        'strict'                =>  0,
        'vars'                  =>  0,
        'warnings'              =>  0,
    },
    CONFIGURE_REQUIRES  =>  {
        'ExtUtils::MakeMaker'   =>  0,
        'Tie::File'             =>  0,
        'version'               =>  0,
    },
    TEST_REQUIRES       =>  {
        'File::Path'            =>  0,
        'File::Temp'            =>  0,
        'Test::More'            =>  0,
    },
    META_MERGE => { 
        'meta-spec'     => {
            version     => 2
        },
        resources       => {
            homepage    => 'https://github.com/aspeer/pm-Local-ExtUtils-Common',
            repository  => {
                type    => 'git',
                url     => 'https://github.com/aspeer/pm-Local-ExtUtils-Common.git',
                web     => 'https://github.com/aspeer/pm-Local-ExtUtils-Common'
            }
        }
    },
    'depend'            => {
        Makefile        => '$(VERSION_FROM)',
    },
    'dist'		        => {
	    COMPRESS        =>  'gzip -9f',
	    SUFFIX		    =>  '.gz'
    },
);
my %MM_Compat=(
    '5.46'		        => [q(PM_FILTER)],
    '6.31'              => [q(LICENSE)],
    '6.46'              => [q(META_MERGE)],
    '6.48'              => [q(MIN_PERL_VERSION)],
    '6.52'              => [q(CONFIGURE_REQUIRES)],
    '6.5503'            => [q(BUILD_REQUIRES)],
    '6.64'              => [q(TEST_REQUIRES)],
);
while (my($mm_ver_test, $ar)=each %MM_Compat) {
    if (version->parse($mm_ver) < version->parse($mm_ver_test)) {
        delete @WriteMakefile{@{$ar}};
    }
}
WriteMakefile(%WriteMakefile);
