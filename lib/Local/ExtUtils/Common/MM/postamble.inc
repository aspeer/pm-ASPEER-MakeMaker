#  Call module method
#
EXTUTILS_COMMON_PM_TARGET=@$(PERLRUN) \
	-e 'my $$method=shift(@ARGV) || $@; $(EXTUTILS_COMMON_PM)->$$method($(EXTUTILS_COMMON_PM_ARGV), @ARGV)'


#  Same method with arg
# 
utilsync :: 
	$(EXTUTILS_COMMON_PM_TARGET) $@ $(UPDATE_SOURCE_UTIL_FN)
	$(EXTUTILS_COMMON_PM_TARGET) $@ $(UPDATE_SOURCE_IMPORT_FN)


#  Different method
# 
#utilsync :: 
#	$(EXTUTILS_COMMON_PM_TARGET) foobar


#  Different method and arg
#	
gherkin ::
	$(EXTUTILS_COMMON_PM_TARGET) foobar car dar
	

gherkin ::
	$(EXTUTILS_COMMON_PM_TARGET) serfin lar far


#  No arguments
#
EXTUTILS_COMMON_PM_DEFAULT=dump_param
$(EXTUTILS_COMMON_PM_DEFAULT) :
	$(EXTUTILS_COMMON_PM_TARGET)
