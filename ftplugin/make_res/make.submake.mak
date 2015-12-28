#
# Reference http://www.gnu.org/software/make/manual/make.html
#

# ��Ҫ�ų���Ŀ¼
exclude_dirs := include bin

# ȡ�õ�ǰ��Ŀ¼���Ϊ1������Ŀ¼����
dirs := $(shell find . -maxdepth 1 -type d)
dirs := $(basename $(patsubst ./%,%,$(dirs)))
dirs := $(filter-out $(exclude_dirs),$(dirs))

# ����clean��Ŀ¼����ͬ��������_clean_ǰ׺
SUBDIRS := $(dirs)

clean_dirs := $(addprefix _clean_,$(SUBDIRS) )
#

.PHONY: subdirs $(SUBDIRS) clean

# ִ��Ĭ��make target
$(SUBDIRS):    
	$(MAKE) -C $@

subdirs: $(SUBDIRS)

# ִ��clean
$(clean_dirs):    
	$(MAKE) -C $(patsubst _clean_%,%,$@) clean

clean: $(clean_dirs)    
@find . \        
	\( -name '*.[oas]' -o -name '*.ko' -o -name '.*.cmd' \
	-o -name '.*.d' -o -name '.*.tmp' -o -name '*.mod.c' \
	-o -name '*.symtypes' \) \
	-type f -print | xargs rm -f
