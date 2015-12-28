# 枚举，并进入各个子文件夹；然后调用命令
# http://blog.codingnow.com/2009/06/make_recursion_directory.html
.PHONY : all

all: 
	echo I\'m in $(CURRENT_DIR)

CURRENT_DIR ?= .
FILES = $(wildcard $(CURRENT_DIR)/*)

define DIR_temp
.PHONY : $(1)
all: $(1)
$(1) :
	$$(MAKE) CURRENT_DIR=$$(CURRENT_DIR)/$(strip $(1))
endef

$(foreach e, $(FILES), \
  $(if $(wildcard $(e)/*), \
    $(eval $(call DIR_temp, $(notdir $(e))))))

