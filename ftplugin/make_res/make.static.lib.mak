.PHONY: Create_Out_Dir all release debug depends

define mkdir-if-not-exist
	$(if $(wildcard $1),@echo dir $1 already exist,@echo make dir `$1` && $(MKDIR) $1)
endef

ifeq "$(firstword $(MAKECMDGOALS))" "all"
CFG=release
endif
ifeq "$(firstword $(MAKECMDGOALS))" ""
CFG=release
endif
ifeq "$(firstword $(MAKECMDGOALS))" "release"
CFG=release
endif
ifeq "$(firstword $(MAKECMDGOALS))" "debug"
CFG=debug
endif

# NOTE: user defined variable
DEBUG_DIR	:=debug
RELEASE_DIR :=.

# if $(CFG) undefined, then give default value 'release' to it
# CFG ?= release

# the Main target to build!
TARGET_NAME := lib$DIRNAME$
TARGET		= $(if $(OUT_DIR),$(OUT_DIR)/,)$(TARGET_NAME).a

# MingW32 tool Chain setting
CC		:= gcc
CFLAGS	:= -Wall
CXX		:= g++
CXXFLAGS:= $(CFLAGS)
RC		:= windres -O COFF

# Dos shell tool Setting
RM		:= rm -f
MKDIR	:= mkdir

ifeq "$(CFG)"  "release"
CFLAGS+=-W -fexceptions -O2 -DNDEBUG -D_LIB -D_MBCS -DWIN32
AR=ar
ARFLAGS=rus
OUT_DIR=$(RELEASE_DIR)
release: Create_Out_Dir depends $(TARGET)
endif
ifeq "$(CFG)"  "debug"
CFLAGS+=-W -fexceptions -g -O0 -D_DEBUG -D_LIB -D_MBCS -DWIN32
AR=ar
ARFLAGS=rus
OUT_DIR=$(DEBUG_DIR)
debug: Create_Out_Dir depends $(TARGET)
endif

all: release

Create_Out_Dir:
	$(call mkdir-if-not-exist,$(OUT_DIR))

$(OUT_DIR)/$(notdir %.o): %.c
	$(CC) -o $@ -c $< $(CFLAGS) $(CPPFLAGS)

$(OUT_DIR)/%.o: %.cc
	$(CXX) -o $@ -c $< $(CXXFLAGS) $(CPPFLAGS)

$(OUT_DIR)/$(notdir %.o): %.cpp
	$(CXX) -o $@ -c $< $(CXXFLAGS) $(CPPFLAGS)

$(OUT_DIR)/%.o: %.cxx
	$(CXX) -o $@ -c $< $(CXXFLAGS) $(CPPFLAGS)

$(OUT_DIR)/%.res: %.rc
	$(RC) -o $@ -i $< $(CPPFLAGS)

#----------------------------------------------------

SOURCE_FILES= \
	$SRC$

HEADER_FILES= \
	$HH$

RESOURCE_FILES=

SRCS=$(SOURCE_FILES) $(HEADER_FILES) $(RESOURCE_FILES) 

OBJS_CUR=$(patsubst %.rc,%.res,$(patsubst %.cxx,%.o,$(patsubst %.cpp,%.o,$(patsubst %.cc,%.o,$(patsubst %.c,%.o,$(filter %.c %.cc %.cpp %.cxx %.rc,$(SRCS)))))))

OBJS=$(addprefix $(OUT_DIR)/,$(OBJS_CUR))

# "$?"仅重新打包更新了的obj文件
$(TARGET): $(OBJS)
	$(AR) $(ARFLAGS) $@ $?

clean:
	-$(RM) $(TARGET_NAME).dep
	-$(RM) $(addprefix $(RELEASE_DIR)/,$(OBJS_CUR)) $(RELEASE_DIR)/$(TARGET)
	-$(RM) $(addprefix $(DEBUG_DIR)/,$(OBJS_CUR)) $(DEBUG_DIR)/$(TARGET)

depends: $(TARGET_NAME).dep

$(TARGET_NAME).dep:
	-$(CXX) $(CXXFLAGS) $(CPPFLAGS) -MM $(filter %.c %.cc %.cpp %.cxx,$(SRCS)) > $(TARGET_NAME).dep

-include $(TARGET_NAME).dep

