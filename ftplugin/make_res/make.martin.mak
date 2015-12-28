###############################################################################
# Martin�汾Դ���� - from msys-cn
# ͨ��������ϵ���� MAKEFILE for MSYS
#
# ��ǰ֧�ֵĴ����ʽ:
#  *.s, *.c, *.cpp, *.f, *.rc, *.m, *.go
#
# PROVIDED WITH NO WARRANTY OF ANY KIND, AND NO COPYRIGHT RESTRICTIONS
###############################################################################
# ���������ã������޸ģ����� C ���� LD=gcc��C++ ���� LD=g++ �ȵ�
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
# ���������ã������������Ҫ�޸ģ���Ϥ����������û����������޸ģ�
INCLUDE=
ASFLAGS=$(INCLUDE) -g
CCFLAGS=$(INCLUDE) -g
CXFLAGS=$(INCLUDE) -g
FCFLAGS=$(INCLUDE) -g
8GFLAGS=$(INCLUDE) -g
8LFLAGS=$(INCLUDE) -g
RCFLAGS=
LDFLAGS=
# �ļ����󣨴�����Ŀֻ��Ҫ�޸���������Ǿ�����
OBJECT=Main.o     # ��дԴ����Main.cpp��Ӧ���ɵ�.o�ļ�����������Լ�����ӣ��� \ ����
TARGET=App.exe    # ��д��������.o�ļ����������ɵ�exe�ļ���
DEPEND=$(OBJECT:.o=.dep)
# ������������ṩ�˱�׼�������Ϥ���û�����������ӣ�
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
# ��׼������̣���������Ϊ�ڲ����ƣ��û������޸ģ�
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
