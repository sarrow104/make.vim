PROJECT_ROOT_DIR = .
TARGET_NAME = $DIRNAME$
# outputdir
DEBUG = Debug
RELEASE = Release
CC=g++
SRC_EXT=cpp

#final target
EXT =#.exe
DEBUG_TARGET=$(TARGET_NAME)D$(EXT)
RELEASE_TARGET=$(TARGET_NAME)$(EXT)

# compile flags
CXX_BASE_FLAGS=-Wall -Wextra #-Werror -DLINUX
CXXFLAGS = $(CXX_BASE_FLAGS)
CXX_DEBUG_FLAGS=-g3 -DDEBUG_ALL
CXX_RELEASE_FLAGS=-O2

# linke flags
LD_BASE_FLAGS = #-mwindows -mconsole
LDFLAGS = $(LD_BASE_FLAGS)
LD_DEBUG_FLAGS =
LD_RELEASE_FLAGS =

SOURCES = $(wildcard *.$(SRC_EXT))
RC_FILE = $(wildcard *.rc)

.PHONY: all
all: release

.PHONY: debug
# 关于目标变量的作用域：它只能用在其依赖树上所有节点的生成规则(rule)
# 上……。
# 一行只能有一个目标变量；多个目标变量只能多行写；
# 至于目标的依赖关系，有且只能有一个。
debug: O_DIR=$(DEBUG)
debug: CXXFLAGS+=$(CXX_DEBUG_FLAGS)
debug: LDFLAGS+=$(LD_DEBUG_FLAGS)
debug: $(DEBUG_TARGET)

.PHONY: release
release: O_DIR=$(RELEASE)
release: CXXFLAGS+=$(CXX_RELEASE_FLAGS)
release: LDFLAGS+=$(LD_RELEASE_FLAGS)
release: $(RELEASE_TARGET)

.PHONY: clean
clean:
	rm -f $(DEBUG_TARGET) $(DEBUG_OBJECTS)
	rm -f $(RELEASE_TARGET) $(RELEASE_OBJECTS)

# 这两组目标变量，能不能挪到目标变量规则里面呢？
# 像这样：
# debug  : build
# release: build
# 
# .PHONY: build
# build: TARGET_NAME=HelloWorld$(MODULE_BLD_TYPE)
# build: TARGET_BUILD_DIR=$(PROJECT_ROOT_DIR)/$(OUT_DIR)
# build: TARGET_BUILD_OBJS=$(addprefix $(TARGET_BUILD_DIR)/,$(SOURCES:.$(SRC_EXT)=.o))
# build: $(TARGET_NAME)
# 见：
# http://stackoverflow.com/questions/4035013/using-gnu-make-to-build-both-debug-and-release-targets-at-the-same-time
DEBUG_OBJECTS = $(addprefix $(PROJECT_ROOT_DIR)/$(DEBUG)/,$(SOURCES:.$(SRC_EXT)=.o))
DEBUG_RC      = $(addprefix $(PROJECT_ROOT_DIR)/$(DEBUG)/,$(RC_FILE:.rc=.res))

RELEASE_OBJECTS = $(addprefix $(PROJECT_ROOT_DIR)/$(RELEASE)/,$(SOURCES:.$(SRC_EXT)=.o))
RELEASE_RC      = $(addprefix $(PROJECT_ROOT_DIR)/$(RELEASE)/,$(RC_FILE:.rc=.res))

$(DEBUG_TARGET): $(DEBUG_OBJECTS) $(DEBUG_RC)
$(RELEASE_TARGET): $(RELEASE_OBJECTS) $(RELEASE_RC)

$(DEBUG_TARGET):
	$(CC) -o $@ $^ $(LDFLAGS)

$(RELEASE_TARGET):
	$(CC) -o $@ $^ $(LDFLAGS)
	strip $@

$(DEBUG_OBJECTS): $(PROJECT_ROOT_DIR)/$(DEBUG)/%.o: %.$(SRC_EXT)
$(DEBUG_RC): $(PROJECT_ROOT_DIR)/$(DEBUG)/%.res: %.rc
$(RELEASE_OBJECTS): $(PROJECT_ROOT_DIR)/$(RELEASE)/%.o: %.$(SRC_EXT)
$(RELEASE_RC): $(PROJECT_ROOT_DIR)/$(RELEASE)/%.res: %.rc

%.o:
	@mkdir -p $(O_DIR) && echo mkdir $(O_DIR)
	$(CC) -o $@ -c $< $(CXXFLAGS)

%.res:
	windres -O COFF -i $< -o $@

# And let's add three lines just to ensure that the flags will be correct in case
# someone tries to make an object without going through "debug" or "release":

#$(DEBUG_OBJECTS): CXXFLAGS=$(CXX_BASE_FLAGS) $(CXX_DEBUG_FLAGS)
#$(DEBUG_OBJECTS): O_DIR=$(DEBUG)
#$(RELEASE_OBJECTS): CXXFLAGS=$(CXX_BASE_FLAGS) $(CXX_RELEASE_FLAGS)
#$(RELEASE_OBJECTS): O_DIR=$(RELEASE)

