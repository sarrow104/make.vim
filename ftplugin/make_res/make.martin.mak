###############################################################################
# Martin版本源代码 - from msys-cn
# 通用依赖关系驱动 MAKEFILE for MSYS
#
# 当前支持的代码格式:
#  *.s, *.c, *.cpp, *.f, *.rc, *.m, *.go
#
# PROVIDED WITH NO WARRANTY OF ANY KIND, AND NO COPYRIGHT RESTRICTIONS
###############################################################################
# 工具链配置（可以修改，比如 C 语言 LD=gcc，C++ 语言 LD=g++ 等等
PP=cpp
AS=as
CC=gcc
CX=g++
FC=gfortran
RC=windres
MC=windmc
8G=8g
8L=8l
LD=gcc
DB=insight
# 编译器配置（这里基本不需要修改，熟悉编译参数的用户可以酌情修改）
INCLUDE=
ASFLAGS=$(INCLUDE) -g
CCFLAGS=$(INCLUDE) -g
CXFLAGS=$(INCLUDE) -g
FCFLAGS=$(INCLUDE) -g
8GFLAGS=$(INCLUDE) -g
8LFLAGS=$(INCLUDE) -g
RCFLAGS=
LDFLAGS=
# 文件对象（创建项目只需要修改这里，下面是举例）
OBJECT=Main.o     # 填写源代码Main.cpp对应生成的.o文件名，后面可以继续添加，用 \ 换行
TARGET=App.exe    # 填写链接所有.o文件后最终生成的exe文件名
DEPEND=$(OBJECT:.o=.dep)
# 编译命令（这里提供了标准的命令，熟悉的用户可以自行添加）
all : $(TARGET)
	@$(RM) $(DEPEND)
$(TARGET) : $(OBJECT)
	$(LD) -o $@ $^ $(LDFLAGS)
debug: all
	@$(DB) $(TARGET)
run: all
	@$(TARGET)
clean:
	@$(RM) $(OBJECT) $(DEPEND) $(TARGET)
# 标准处理过程（以下内容为内部机制，用户请勿修改）
%.dep : %.s
	@$(PP) $(INCLUDE) -MM -MT $(@:.dep=.o) -o $@ $<
%.dep : %.c
	@$(PP) $(INCLUDE) -MM -MT $(@:.dep=.o) -o $@ $<
%.dep : %.m
	@$(PP) $(INCLUDE) -MM -MT $(@:.dep=.o) -o $@ $<
%.dep : %.cpp
	@$(PP) $(INCLUDE) -MM -MT $(@:.dep=.o) -o $@ $<
%.dep : %.f
	@$(PP) $(INCLUDE) -MM -MT $(@:.dep=.o) -o $@ $<
%.dep : %.rc
	@$(PP) $(INCLUDE) -MM -MT $(@:.dep=.o) -o $@ $<
%.o : %.s
	$(AS) $(ASFLAGS) -o $@ $<
%.o : %.c
	$(CC) $(CCFLAGS) -c -o $@ $<
%.o : %.m
	$(CC) $(CCFLAGS) -c -o $@ $<
%.o : %.cpp
	$(CX) $(CXFLAGS) -c -o $@ $<
%.o : %.f
	$(FC) $(FCFLAGS) -c -o $@ $<
%.o : %.rc
	$(RC) $(RCFLAGS) $< $@
%.8 : %.go
	$(8G) $(8GFLAGS) -o $@ $<
%.exe : %.8
	$(8L) $(8LFLAGS) -o $@ $<
-include $(DEPEND)
