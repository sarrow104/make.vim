# 广度优先，遍历所有文件
# 说明：
# $(1)
# 	函数的第一个参数
# $(wildcard $(1)/*) 中的 *
#   枚举的条件。这里会匹配所有文件（各种后缀、无后缀）；另外，这里不能去其他的值——你只能先枚举出所有文件……
# $(call walk, .)
#   从当前文件夹开始枚举
# $(filter-out ., ...)
#   $(call walk, .)得到的结果，会多出一个 . 的文件。这里用 filter-out 剔除掉。
# $(patsubst ./%,%, ...)
#   去掉多余的 ./ 前缀

define walk
$(wildcard $(1)) $(foreach e, $(wildcard $(1)/*), $(call walk, $(e)))
endef

ALLFILES := $(patsubst ./%,%,$(filter-out .,$(call walk, .)))

SRCFILES := $(filter %.cpp,$(ALLFILES))
HEAFILES := $(filter %.hpp,$(ALLFILES))

#dirs := $(shell find . -maxdepth 1 -type d)
dirs := $(shell find . -type d)
dirs := $(basename $(patsubst ./%,%,$(dirs)))
dirs := $(filter-out $(exclude_dirs),$(dirs))

OUT_DIR := ../../lib

OBJFILES := $(addprefix $(OUT_DIR)/,$(patsubst %.cpp,%.o,$(SRCFILES)))

TARGET_NAME := libsss

TARGET  := $(OUT_DIR)/$(TARGET_NAME).a

CC		 := gcc
CXX		 := g++
CXXFLAGS := -Wall -O2
RC		 := windres -O COFF

.PHONY: all

all: $(TARGET)
#	@echo OBJFILES=$(OBJFILES)

$(OUT_DIR)/%.o: %.cpp
	$(CXX) -o $@ -c $< $(CXXFLAGS) $(CPPFLAGS)

$(TARGET): $(OBJFILES)
	$(AR) $(ARFLAGS) $@ $?
