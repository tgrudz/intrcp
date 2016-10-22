######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################
#

#  Makefile for an Informix-4GL program

#_name - program name
NAME = pn_absen.4ge

#_objfiles - program files
OBJFILES = abs_count.o abs_dor.o abs_rates.o browse.o custom.o detail.o globals.o header.o main.o menuhead.o midlevel.o mlh_curs.o options.o pnabsba.o pnabsho.o pnabsra.o r_delete.o r_find.o r_lladd.o r_llupdate.o ver.o

FORMS = br_absen.frm pn_absba.frm pn_absho.frm pn_absen.frm pn_absra.frm

#_libfiles - library list
LIBFILES = ../lib.a ../../../lib/tlib.a

#_globals - globals file
GLOBAL = globals.4gl

#-----------------------------------------------------------------------

.SUFFIXES:   .4gl .c .o .4ge .per .frm

$(NAME):$(FORMS) $(OBJFILES)
	@echo "Linking 1"
	c4gl $(OBJFILES) $(LIBFILES) -o $(NAME);

.4gl.o:
	c4gl -c $*.4gl

$(OBJFILES):$(GLOBAL)

.per.frm:
	form4gl $*

clean :
	@rm -f *.4gi *.4go *.RDS *.idb
	@rm -f *.o
	@rm -f *.frm
	@rm -f *.4ge
	@rm -f core

build:$(NAME)

include ../../makefile.prg



include ../../makefile.rdsp
