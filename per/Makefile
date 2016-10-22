
CC = c4gl

C4GL = c4gl

all : 

build : intrcp_forms

inst :
	@[ -d ../INST/main-app/silp-dir/app-dir/bin ] || mkdir -p ../INST/main-app/silp-dir/app-dir/bin
	@cp *.frm ../INST/main-app/silp-dir/app-dir/bin

clean : 
	rm -f *.frm
	rm -f core

FC = form4gl

INTRCP_FORMS = rcp_okres.frm rcp_addr.frm rcp_adm.frm

intrcp_forms : $(INTRCP_FORMS) 

%.frm : %.per 
	@$(FC) $< 

