.PHONY: all release debug depends Create_Out_Dir

# the Main target to build!
TARGET_NAME := $DIRNAME$
TARGET		= $(if $(OUT_DIR),$(OUT_DIR)/,)$(TARGET_NAME).exe

# MingW32 tool Chain setting
CC		:= gcc
CFLAGS	+= -Wall
CXX		:= g++
CXXFLAGS = $(CFLAGS)
RC		:= windres -O COFF
LDFLAGS  = -mwindows -wl

# Dos shell tool Setting
RM		:= rm -f
MKDIR	:= mkdir

release: obj_dir=Release Target=$(Target).exe CFLAGS+=-W CFLAGS+=-fexceptions CFLAGS+=-O2 CFLAGS+=-DNDEBUG CFLAGS+=-D_MBCS
debug  : obj_dir=Debug Target=$(Target)_debug.exe CFLAGS+=-W CFLAGS+=-fexceptions CFLAGS+=-g CFLAGS+=-O0 CFLAGS+=-D_DEBUG CFLAGS+=-D_MBCS

define mkdir-if-not-exist
	$(if $(wildcard $1),@echo dir $1 already exist,@echo make dir `$1` && $(MKDIR) $1)
endef

all: release

Create_Out_Dir:
	$(call mkdir-if-not-exist,$(obj_dir))

$(obj_dir)/%.o: %.c
	$(CC) -o $@ -c $< $(CFLAGS)

$(obj_dir)/%.o: %.cc
	$(CXX) -o $@ -c $< $(CXXFLAGS)

%(obj_dir)/%.o: %.cpp
	$(CXX) -o $@ -c $< $(CXXFLAGS)

$(obj_dir)/%.o: %.cxx
	$(CXX) -o $@ -c $< $(CXXFLAGS)

$(obj_dir)/%.res: %.rc
	$(RC) -o $@ -i $< $(CFLAGS)

#----------------------------------------------------

SOURCE_FILES= \
	$SRC$

HEADER_FILES= \
	$HH$

RESOURCE_FILES=

SRCS=$(SOURCE_FILES) $(HEADER_FILES) $(RESOURCE_FILES) 

OBJS_CUR=$(patsubst %.rc,%.res,$(patsubst %.cxx,%.o,$(patsubst %.cpp,%.o,$(patsubst %.cc,%.o,$(patsubst %.c,%.o,$(filter %.c %.cc %.cpp %.cxx %.rc,$(SRCS)))))))

OBJS=$(addprefix $(OUT_DIR)/,$(OBJS_CUR))

$(TARGET): $(OBJS)
	$(LD) -o $@ $(OBJS) $(LDFLAGS) $(LIBS)

clean:
	-$(RM) (.depends)
	-$(RM) $(addprefix $(RELEASE_DIR)/,$(OBJS_CUR)) $(RELEASE_DIR)/$(TARGET)
	-$(RM) $(addprefix $(DEBUG_DIR)/,$(OBJS_CUR)) $(DEBUG_DIR)/$(TARGET)

#depends: $(TARGET_NAME).dep

# 生成以各个实现文件为名，后缀为.d的依赖文件
# 形如：
# main.o: main.cpp fun.hpp
(.depends):
	-$(CXX) $(CXXFLAGS) $(CPPFLAGS) -MMD $(filter %.c %.cc %.cpp %.cxx,$(SRCS))

-include $(TARGET_NAME).dep

