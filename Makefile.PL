use 5.038002;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Local::ExtUtils::Common',
    VERSION_FROM      => 'lib/Local/ExtUtils/Common.pm', # finds $VERSION, requires EU::MM from perl >= 5.5
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/Local/ExtUtils/Common.pm', # retrieve abstract from module
    AUTHOR            => 'Andrew Speer <aspeer@localdomain>',
    LICENSE           => 'perl',
    #Value must be from legacy list of licenses here
    #https://metacpan.org/pod/Module::Build::API
);


#  Example postable section if using this module
#
sub MY::postamble {

    my $postamble=shift()->MY::SUPER::postamble;
    $postamble.=<<'END'
    
hello:
	@echo world
	
END
;
	return $postamble;
	
}
