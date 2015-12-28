# 生成文件列表；但是文件夹的枚举，有问题。
# http://blog.codingnow.com/2009/06/make_recursion_directory.html
.PHONY : all

# arg1 dir
define EXPAND_temp
  FILES := $(wildcard $(1)*)
  DIRS := $$(foreach e, $$(FILES), $$(if $$(wildcard $$(e)/*), $$(eval DIRS := $$(DIRS) $$(e))))
  FILES := $$(filter-out $$(DIRS),$$(FILES))
  ALLFILES := $$(ALLFILES) $$(FILES) $$(foreach e,$$(DIRS),$$(eval $$(call EXPAND_temp,$$(e)/)))
endef

$(eval $(call EXPAND_temp))

all :
	@echo FILES: $(FILES)
	@echo ALLFILES: $(ALLFILES)

