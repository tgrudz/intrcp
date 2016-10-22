PROGS = intrcp.4ge

OBJS = main.o rcp_glob.o rcp.o abs_count.o abs_rates.o

CC = c4gl

C4GL = c4gl

all :

build : intrcp 

intrcp : $(OBJS) 
	@echo "Konsolidacja $(PROGS) ..."
	@c4gl -o $(PROGS) $(OBJS) -L../../lib -lforest -lenv -ldod -lcsilp

%.o : %.4gl 

	$(C4GL) -c -D`uname` $<

inst : 
	@[ -d ../INST/main-app/silp-dir/app-dir/bin ] || mkdir -p ../INST/main-app/silp-dir/app-dir/bin
	@cp *.4ge ../INST/main-app/silp-dir/app-dir/bin

clean : 
	rm -f *.o
	rm -f *.4ge
	rm -f *.frm
	rm -f core

