######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################
#

globals "globals.4gl"

define
   absen_dor_prep   char(1)

######################################################################
function abs_dor(a_abs_num, a_addr_nr, a_date_from, a_date_to)
######################################################################
#
define
   a_abs_num     integer, 
   a_addr_nr     integer, 
   a_date_from   date,
   a_date_to     date,
   dorhead_rec   record
                    dor_num     integer,
                    addr_nr     integer,
                    dor_year    smallint,
                    dor_month   smallint
                 end record

   whenever error call error_handler

   if absen_dor_prep is null
   then
      let absen_dor_prep = "Y"

      # 'pn_dor_head' table
      let scratch = "select pn_dor_head.dor_num,",
                    " pn_dor_head.addr_nr,",
                    " pn_dor_head.dor_year,",
                    " pn_dor_head.dor_month",
                   " from pn_dor_head",
                   " where pn_dor_head.addr_nr = ? ",
                     " and ( ? between pn_dor_head.date_from",
                             " and pn_dor_head.date_to",
                          " or ? between pn_dor_head.date_from",
                               " and pn_dor_head.date_to",
                          " or (pn_dor_head.date_from between ? and ? ",
                              " and pn_dor_head.date_to between ? and ? ))",
                   " order by pn_dor_head.dor_num"
      prepare get_dorhead_s from scratch
      declare get_dorhead_c cursor for get_dorhead_s

   end if

   if get_yes_no("Otworzyæ ponownie istniej±ce ju¿ DOR-y?")
   then
   else
      return false
   end if 

   open get_dorhead_c using a_addr_nr, a_date_from, a_date_to,
                            a_date_from, a_date_to,
                            a_date_from, a_date_to
   while true

      fetch get_dorhead_c into dorhead_rec.*
      if sqlca.sqlcode = notfound
      then
         exit while
      end if

      let scratch = dorhead_rec.addr_nr
      let scratch = "pn_dor_head.addr_nr = ", scratch clipped
      if dor_open(dorhead_rec.dor_year, dorhead_rec.dor_month,
                  scratch clipped, false, "NYYNNNN")
      then end if

   end while
   close get_dorhead_c

   return true

end function
# abs_dor()
