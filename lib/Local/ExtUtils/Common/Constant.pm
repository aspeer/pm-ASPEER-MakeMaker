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

#


#  Pragma
#
package Local::ExtUtils::Common::Constant;
use strict qw(vars);
use warnings;
use vars qw($VERSION @ISA %EXPORT_TAGS @EXPORT_OK @EXPORT %Constant);


#  Modules we need
#
use File::Spec;
use File::Basename qw(dirname);


#  Version information
#
$VERSION='0.010';


#  Get module file name and path, derive name of file to store local constants
#
use Cwd qw(abs_path);
my $local_fn=abs_path(__FILE__) . '.local';


#  Hash of constants
#
%Constant=(


    EXTUTILS_COMMON_PM => 'Local::ExtUtils::Common',
    
    TEMPLATE_POSTAMBLE_FN =>
        File::Spec->catfile(dirname(__FILE__), 'Constant', 'postamble.inc'),
        
    UPDATE_SOURCE_UTIL_FN =>
        File::Spec->catfile(dirname(__FILE__), 'Util.pm'),
        
    UPDATE_SOURCE_IMPORT_FN =>
        File::Spec->catfile(dirname(__FILE__), 'Import.pm'),
        
    EXTUTILS_COMMON_PM_ARGV => join(',', qw[
        "$(NAME)"
        "$(NAME_SYM)"
        "$(DISTNAME)"
        "$(DISTVNAME)"
        "$(VERSION)"
        "$(VERSION_SYM)"
        "$(VERSION_FROM)"
        "$(LICENSE)"
        "$(AUTHOR)"
        "$(TO_INST_PM)"
        "$(EXE_FILES)"
        "$(DIST_DEFAULT_TARGET)"
        "$(SUFFIX)"
        "$(ABSTRACT_FROM)"
    ]),


    #  Local constants override anything above
    #
    %{do($local_fn) || {}},
    %{do(my($fn)=glob(sprintf('~/.%s.local', __PACKAGE__))) || {}}    # || {} avoids warning

);


#  Export constants to namespace, place in export tags
#
require Exporter;
@ISA=qw(Exporter);
foreach (keys %Constant) {${$_}=$Constant{$_}}
@EXPORT=map {'$' . $_} keys %Constant;
@EXPORT_OK=@EXPORT;
%EXPORT_TAGS=(all => [@EXPORT_OK]);
$_=\%Constant;
