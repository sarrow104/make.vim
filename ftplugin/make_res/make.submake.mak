#
# Reference http://www.gnu.org/software/make/manual/make.html
#

# 需要排除的目录
exclude_dirs := include bin

# 取得当前子目录深度为1的所有目录名称
dirs := $(shell find . -maxdepth 1 -type d)
dirs := $(basename $(patsubst ./%,%,$(dirs)))
dirs := $(filter-out $(exclude_dirs),$(dirs))

# 避免clean子目录操作同名，加上_clean_前缀
SUBDIRS := $(dirs)

clean_dirs := $(addprefix _clean_,$(SUBDIRS) )
#

.PHONY: subdirs $(SUBDIRS) clean

# 执行默认make target
$(SUBDIRS):    
	$(MAKE) -C $@

subdirs: $(SUBDIRS)

# 执行clean
$(clean_dirs):    
	$(MAKE) -C $(patsubst _clean_%,%,$@) clean

clean: $(clean_dirs)    
@find . \        
	\( -name '*.[oas]' -o -name '*.ko' -o -name '.*.cmd' \
	-o -name '.*.d' -o -name '.*.tmp' -o -name '*.mod.c' \
	-o -name '*.symtypes' \) \
	-type f -print | xargs rm -f
