Target := $DIRNAME$
all: $(Target).exe
OBJs	:= $(patsubst %.rc,%.res,$(wildcard *.rc)) $(patsubst %.cpp,%.o,$(wildcard *.cpp))
$(Target).exe: $(OBJs)
clean:
	rm $(Target).exe $(OBJs)

RC		:= windres -O COFF
CPPFLAGS:= -O2 -Wall
LD_FLAGS:= `fltk-config --ldflags`

%.exe:
	g++ -o $@ $^ $(LD_FLAGS)

%.o: %.cpp
	g++ -o $@ -c $< $(CPPFLAGS)

%.res: %.rc
	$(RC) -o $@ -i $<
