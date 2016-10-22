######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################
#

globals "rcp_glob.4gl"

define
   abs_rates_prep   char(1)

######################################################################
function abs_rates_count(a_abs_num, a_addr_nr, a_abs_code, a_date_from,
                         a_date_to, a_first_abs_num)
######################################################################
#
define
   a_abs_num            like pn_absence.abs_num,
   a_addr_nr            like pn_absence.addr_nr,
   a_abs_code           like pn_absence.abs_code,
   a_date_from          like pn_absence.date_from,
   a_date_to            like pn_absence.date_to,
   a_first_abs_num      like pn_absence.first_abs_num,
   ar_type_rec          record
                           pri_perc          like pn_abs_type.pri_perc,
                           sec_perc_fl       like pn_abs_type.sec_perc_fl,
                           sec_perc          like pn_abs_type.sec_perc,
                           sec_perc_limit    like pn_abs_type.sec_perc_limit,
                           base_kind_dc      like pn_abs_type.base_kind_dc,
                           base_upgrade_dc   like pn_abs_type.base_upgrade_dc,
                           upgrade_limit     like pn_dict_pos.feature,
                           upgrade_factor    like pn_dict_pos.value_dec
                        end record,
   ar_rates_rec         record like pn_absen_rates.*,
   ar_block_rec         record
                           date_from        like pn_absen_block.date_from,
                           date_to          like pn_absen_block.date_to,
                           block_cause_dc   like pn_absen_block.block_cause_dc
                        end record,
   ar_bases_rec         record like pn_absba_pos.*,
   ar_ratbas_rec        record like pn_absen_rates.*,
   ar_absbas_rec        record like pn_absen_bases.*,
# NKP KO 2005.07.20
   tmp_work_factor      decimal(8,6),
# end NKP KO 2005.07.20
   stat                 integer,
   tmp_int              integer,
   tmp_date_from        date,
   tmp_date_to          date,
   per_abs_from         date,
   is_first             smallint,
   is_std_base          smallint,
   tmp_base1            like pn_absba_pos.base_value1,
   tmp_base1_cnt        smallint,
   tmp_base2            like pn_absba_pos.base_value2,
   tmp_base2_cnt        smallint,
   abs_per_new          smallint,
   abs_base_months      smallint,
   abs_new_base         smallint,

   st_year_from         smallint,
   st_month_from        smallint,
   st_year_to           smallint,
   st_month_to          smallint,
   amount               decimal(8,2),
   wsk_pocz             integer,
   wsk_kon              integer

#   whenever error call error_handler

   if abs_rates_prep is null
   then
      let abs_rates_prep = "Y"

      select * from pn_absen_rates
      where 1=0
      into temp tmp_abs_rates with no log

      let scratch = "delete from tmp_abs_rates",
                   " where 1=1"
      prepare ar_tmpdel_stmt from scratch

      let scratch = "insert into tmp_abs_rates",
                   " values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?,",
                           " ?, ?, ?, ?, ?, ?, ?, ?, ?)"
      prepare ar_tmpins_stmt from scratch

      let scratch = "update tmp_abs_rates",
                   " set",
                      " tmp_abs_rates.date_from = ? ,",
                      " tmp_abs_rates.date_to = ? ,",
                      " tmp_abs_rates.block_cause_dc = ? ,",
                      " tmp_abs_rates.abs_days = ? ,",
                      " tmp_abs_rates.abs_cnt_days = ? ,",
                      " tmp_abs_rates.abs_per_days = ? ,",
                      " tmp_abs_rates.abs_cnt_fl = ? ,",
                      " tmp_abs_rates.abs_per_fl = ? ",
                   " where tmp_abs_rates.abs_rate_num = ? "
      prepare ar_tmpupd_stmt from scratch

      let scratch = "update tmp_abs_rates",
                   " set",
                      " tmp_abs_rates.abs_base = ? ,",
                      " tmp_abs_rates.abs_rate1 = ? ,",
                      " tmp_abs_rates.abs_rate2 = ? ,",
                      " tmp_abs_rates.abs_rate3 = ? ",
                   " where tmp_abs_rates.abs_rate_num = ? "
      prepare ar_tupdba_stmt from scratch

      let scratch = "select tmp_abs_rates.*",
                   " from tmp_abs_rates",
                   " order by tmp_abs_rates.date_from"
      prepare ar_tmpall_stmt from scratch
      declare ar_tmpall_curs cursor for ar_tmpall_stmt

      let scratch = "select tmp_abs_rates.*",
                   " from tmp_abs_rates",
                   " where ? between tmp_abs_rates.date_from",
                           " and tmp_abs_rates.date_to",
                   " order by tmp_abs_rates.date_from"
      prepare ar_tmpget_stmt from scratch
      declare ar_tmpget_curs cursor for ar_tmpget_stmt

      let scratch = "select pn_absen_rates.*",
                   " from pn_absen_rates",
                   " where abs_num = ?"
      prepare ar_ratall_stmt from scratch
      declare ar_ratall_curs cursor for ar_ratall_stmt

      let scratch = "delete from pn_absen_rates",
                   " where pn_absen_rates.abs_num = ? "
      prepare ar_ratdel_stmt from scratch

      let scratch = "insert into pn_absen_rates",
                    " select 0,",
                     " tmp_abs_rates.abs_num,",
                     " tmp_abs_rates.dor_num,",
                     " tmp_abs_rates.earn_no,",
                     " tmp_abs_rates.date_from,",
                     " tmp_abs_rates.date_to,",
                     " tmp_abs_rates.block_cause_dc,",
                     " tmp_abs_rates.abs_days,",
                     " tmp_abs_rates.abs_cnt_days,",
                     " tmp_abs_rates.abs_per_days,",
                     " tmp_abs_rates.abs_cnt_fl,",
                     " tmp_abs_rates.abs_per_fl,",
                     " tmp_abs_rates.abs_base,",
                     " tmp_abs_rates.abs_rate1,",
                     " tmp_abs_rates.abs_rate2,",
                     " tmp_abs_rates.abs_rate3,",
                     " tmp_abs_rates.abs_perc,",
                     " tmp_abs_rates.pay_month,",
                     " tmp_abs_rates.pay_amount",
                    " from tmp_abs_rates"
      prepare ar_ratins_stmt from scratch

      let scratch = "select pn_abs_type.pri_perc,",
                    " pn_abs_type.sec_perc_fl,",
                    " pn_abs_type.sec_perc,",
                    " pn_abs_type.sec_perc_limit,",
                    " pn_abs_type.base_kind_dc,",
                    " pn_abs_type.base_upgrade_dc,",
                    " pn_dict_pos.feature,",
                    " pn_dict_pos.value_dec",
                   " from pn_abs_type, outer pn_dict_pos",
                   " where pn_abs_type.abs_code = ? ",
                     " and pn_dict_pos.type = 'base_upgrade'",
                     " and pn_dict_pos.code = pn_abs_type.base_upgrade_dc"
      prepare ar_type_stmt from scratch
      declare ar_type_curs cursor for ar_type_stmt

      let scratch = "select pn_absence.date_from",
                   " from pn_absence",
                   " where pn_absence.abs_num = ? "
      prepare ar_first_stmt from scratch
      declare ar_first_curs cursor for ar_first_stmt

      let scratch = "select pn_absence.date_from",
                   " from pn_absence, pn_abs_type",
                   " where pn_absence.addr_nr = ? ",
                     " and pn_absence.abs_num != ? ",
                     " and pn_absence.date_from < ? ",
                     " and ( ? - pn_absence.date_to - 1) < ?", 
                     " and pn_abs_type.abs_code = pn_absence.abs_code",
                     " and pn_abs_type.base_kind_dc = ? ",
                   " order by 1 desc"
      prepare ar_perabs_stmt from scratch
      declare ar_perabs_curs cursor for ar_perabs_stmt

      let scratch = "select pn_absen_block.date_from,",
                    " pn_absen_block.date_to,",
                    " pn_absen_block.block_cause_dc",
                   " from pn_absen_block",
                   " where pn_absen_block.abs_num = ? "
      prepare ar_blkabs_stmt from scratch
      declare ar_blkabs_curs cursor for ar_blkabs_stmt

      let scratch = "delete from pn_absen_bases",
                   " where pn_absen_bases.abs_num = ? "
      prepare ar_basdel_stmt from scratch

      let scratch = "insert into pn_absen_bases",
                   " values( ?, ?, ?, ?, ?, ?, ? )"
      prepare ar_basins_stmt from scratch

      let scratch = "select pn_absen_bases.abs_num,",
                    " pn_absen_bases.base_year,",
                    " pn_absen_bases.base_month,",
                    " pn_absen_bases.base_value1,",
                    " pn_absen_bases.base_value2,",
                    " pn_absen_bases.nom_days,",
                    " pn_absen_bases.work_days",
                   " from pn_absen_bases",
                   " where pn_absen_bases.abs_num = ? "
      prepare ar_basget_s from scratch
      declare ar_basget_c cursor for ar_basget_s

# NKP KO 2005.07.20
      let scratch = "select pn_absba_pos.work_days / pn_absba_pos.nom_days,",
                    " pn_absba_pos.*",
                   " from pn_absba_head, pn_absba_pos",
                   " where pn_absba_head.addr_nr = ? ",
                     " and pn_absba_head.base_kind_dc = ? ",
                     " and pn_absba_pos.base_num = pn_absba_head.base_num",
                     " and extend(mdy(pn_absba_pos.base_month, 1,",
                                " pn_absba_pos.base_year), year to month)",
                         " between extend( ? , year to month) - ? units month",
                         " and extend( ? , year to month) - 1 units month",
                     " and pn_absba_pos.nom_days != 0",
                   " order by 1"
                   #" order by pn_absba_pos.work_days"
# end NKP KO 2005.07.20
      prepare ar_bases_stmt from scratch
      declare ar_bases_curs cursor for ar_bases_stmt

      let scratch = "select pn_absen_rates.*",
                   " from pn_abs_type, pn_absence, pn_absen_rates",
                   " where pn_abs_type.base_kind_dc = ? ",
                     " and pn_absence.abs_code = pn_abs_type.abs_code",
                     " and pn_absence.addr_nr = ? ",
                     " and pn_absence.abs_num != ? ",
                     # KO 2005.03.10
                     #" and pn_absence.date_from < ? ",
                     " and pn_abs_type.pri_perc > 0",
                     " and pn_absence.date_to between ",
                         " (mdy(month( ? ), 1 , year( ? )) - ? units month)",
                         " and (mdy(month( ? ), 1 , year( ? )) - 1 units day)",
                     # end KO 2005.03.10
                     " and pn_absen_rates.abs_num = pn_absence.abs_num",
                   " order by pn_absen_rates.date_from desc"
      prepare ar_ratget_stmt from scratch
      declare ar_ratget_curs cursor for ar_ratget_stmt
   end if

   # check if rates exists for specified absence
   open ar_ratall_curs using a_abs_num
   fetch ar_ratall_curs into ar_rates_rec.*
   let stat = sqlca.sqlcode
   close ar_ratall_curs
   if stat != notfound
   then
      let scratch = "Wygenerowæ nowe stawki dla dokumentu absencji ?"
      if not get_no_yes(scratch clipped)
      then
         return
      end if
   end if

   # delete all rows from "pn_absen_rates"
   execute ar_ratdel_stmt using a_abs_num

   # initialize variables
   initialize ar_type_rec.* to null
   initialize ar_rates_rec.* to null
   initialize tmp_date_from to null

   # clear temp table
   execute ar_tmpdel_stmt

   # set defaults and constants
   let ar_rates_rec.abs_rate_num = 0
   let ar_rates_rec.abs_num = a_abs_num
   let ar_rates_rec.date_from = a_date_from
   let ar_rates_rec.date_to = a_date_to
   let ar_rates_rec.abs_days = a_date_to - a_date_from + 1
   let ar_rates_rec.abs_cnt_days = a_date_to - a_date_from + 1
   let ar_rates_rec.abs_per_days = a_date_to - a_date_from + 1
   let ar_rates_rec.abs_cnt_fl = "N"
   let ar_rates_rec.abs_per_fl = "N"

   # get global parameters
   let abs_per_new = get_abs_param(1)
   let abs_base_months = get_abs_param(3)
   let abs_new_base = get_abs_param(4)

   # get absence definition
   open ar_type_curs using a_abs_code
   fetch ar_type_curs into ar_type_rec.*
   close ar_type_curs

   # check if absence is valid for rates count
   if ar_type_rec.base_kind_dc is null
   then
      return
   end if

   # check continuous absence
   if ar_type_rec.sec_perc_fl = "T"
   then
      if a_first_abs_num is not null
      then
         open ar_first_curs using a_first_abs_num
         fetch ar_first_curs into tmp_date_from
         close ar_first_curs
      end if
      if tmp_date_from is null
      then
         let tmp_date_from = a_date_from
      end if
      let ar_rates_rec.abs_cnt_days = a_date_to - tmp_date_from + 1
      if ar_rates_rec.abs_cnt_days > ar_type_rec.sec_perc_limit
      then
         let ar_rates_rec.abs_cnt_days = a_date_to - tmp_date_from + 1
         let ar_rates_rec.abs_cnt_fl = "T"
         let ar_rates_rec.abs_perc = ar_type_rec.sec_perc
         if (a_date_from - tmp_date_from) >= ar_type_rec.sec_perc_limit
         then
            execute ar_tmpins_stmt using ar_rates_rec.*
         else
            let ar_rates_rec.date_from = tmp_date_from +
                                         ar_type_rec.sec_perc_limit
            let ar_rates_rec.abs_days = ar_rates_rec.date_to -
                                        ar_rates_rec.date_from + 1
            execute ar_tmpins_stmt using ar_rates_rec.*

            let ar_rates_rec.date_to = ar_rates_rec.date_from - 1
            let ar_rates_rec.date_from = a_date_from
            let ar_rates_rec.abs_days = ar_rates_rec.date_to -
                                        ar_rates_rec.date_from + 1
            let ar_rates_rec.abs_cnt_days = ar_type_rec.sec_perc_limit
            let ar_rates_rec.abs_cnt_fl = "N"
            let ar_rates_rec.abs_perc = ar_type_rec.pri_perc
            execute ar_tmpins_stmt using ar_rates_rec.*
         end if
      else
         let ar_rates_rec.abs_perc = ar_type_rec.pri_perc
         execute ar_tmpins_stmt using ar_rates_rec.*
      end if
   else
      let ar_rates_rec.abs_perc = ar_type_rec.pri_perc
      execute ar_tmpins_stmt using ar_rates_rec.*
   end if

   # check base upgrade
   if ar_type_rec.base_upgrade_dc is not null
      and ar_type_rec.upgrade_limit > 0
   then
      let tmp_date_from = a_date_from
      while true
         open ar_perabs_curs using a_addr_nr, a_abs_num,
                                   tmp_date_from, tmp_date_from,
                                   abs_per_new, ar_type_rec.base_kind_dc
         fetch ar_perabs_curs into per_abs_from
         let stat = sqlca.sqlcode
         close ar_perabs_curs
         if stat = notfound
         then
            exit while
         end if
         let tmp_date_from = per_abs_from
      end while
      let per_abs_from = tmp_date_from
      if per_abs_from != a_date_from
      then
         open ar_tmpall_curs
         while true
            fetch ar_tmpall_curs into ar_rates_rec.*
            if sqlca.sqlcode = notfound
            then
               exit while
            end if
            let ar_rates_rec.abs_per_days = ar_rates_rec.date_to -
                                            per_abs_from + 1
            execute ar_tmpupd_stmt using ar_rates_rec.date_from,
                                         ar_rates_rec.date_to,
                                         ar_rates_rec.block_cause_dc,
                                         ar_rates_rec.abs_days,
                                         ar_rates_rec.abs_cnt_days,
                                         ar_rates_rec.abs_per_days,
                                         ar_rates_rec.abs_cnt_fl,
                                         ar_rates_rec.abs_per_fl,
                                         ar_rates_rec.abs_rate_num
         end while
         close ar_tmpall_curs
      end if
      if (a_date_to - per_abs_from + 1) > ar_type_rec.upgrade_limit
      then
         if (a_date_from - per_abs_from) >= ar_type_rec.upgrade_limit
         then
            let ar_rates_rec.abs_per_fl = "T"
            open ar_tmpall_curs
            while true
               fetch ar_tmpall_curs into ar_rates_rec.*
               if sqlca.sqlcode = notfound
               then
                  exit while
               end if
               let ar_rates_rec.abs_per_days = ar_rates_rec.date_to -
                                               per_abs_from + 1
               execute ar_tmpupd_stmt using ar_rates_rec.date_from,
                                            ar_rates_rec.date_to,
                                            ar_rates_rec.block_cause_dc,
                                            ar_rates_rec.abs_days,
                                            ar_rates_rec.abs_cnt_days,
                                            ar_rates_rec.abs_per_days,
                                            ar_rates_rec.abs_cnt_fl,
                                            ar_rates_rec.abs_per_fl,
                                            ar_rates_rec.abs_rate_num
            end while
            close ar_tmpall_curs
         else
            let tmp_date_from = per_abs_from + ar_type_rec.upgrade_limit
            open ar_tmpget_curs using tmp_date_from
            fetch ar_tmpget_curs into ar_rates_rec.*
            close ar_tmpget_curs
            let tmp_int = ar_rates_rec.date_to - tmp_date_from + 1
            let tmp_date_to = tmp_date_from - 1
            let ar_rates_rec.abs_days = ar_rates_rec.abs_days - tmp_int
            let ar_rates_rec.abs_cnt_days = ar_rates_rec.abs_cnt_days - tmp_int
            let ar_rates_rec.abs_per_days = tmp_date_to - per_abs_from + 1
            execute ar_tmpupd_stmt using ar_rates_rec.date_from,
                                         tmp_date_to,
                                         ar_rates_rec.block_cause_dc,
                                         ar_rates_rec.abs_days,
                                         ar_rates_rec.abs_cnt_days,
                                         ar_rates_rec.abs_per_days,
                                         ar_rates_rec.abs_cnt_fl,
                                         ar_rates_rec.abs_per_fl,
                                         ar_rates_rec.abs_rate_num

            let ar_rates_rec.abs_rate_num = 0
            let ar_rates_rec.date_from = tmp_date_from
            let ar_rates_rec.abs_days = ar_rates_rec.date_to -
                                        ar_rates_rec.date_from + 1
            let ar_rates_rec.abs_cnt_days = ar_rates_rec.abs_cnt_days +
                                            ar_rates_rec.abs_days
            let ar_rates_rec.abs_per_days = ar_rates_rec.abs_per_days +
                                            ar_rates_rec.abs_days
            let ar_rates_rec.abs_per_fl = "T"
            execute ar_tmpins_stmt using ar_rates_rec.*
         end if
      end if
   end if

   # check blocked documents
   open ar_blkabs_curs using a_abs_num
   while true
      fetch ar_blkabs_curs into ar_block_rec.*
      if sqlca.sqlcode = notfound
      then
         exit while
      end if
      open ar_tmpall_curs
      while true
         fetch ar_tmpall_curs into ar_rates_rec.*
         if sqlca.sqlcode = notfound
         then
            exit while
         end if
         if ar_rates_rec.date_to < ar_block_rec.date_from
         then
            continue while
         end if
         if ar_rates_rec.date_from > ar_block_rec.date_to
         then
            exit while
         end if
         if ar_rates_rec.date_from < ar_block_rec.date_from
         then
            let tmp_date_to = ar_block_rec.date_from - 1
            let tmp_int = ar_rates_rec.date_to - ar_block_rec.date_from + 1
            let ar_rates_rec.abs_days = ar_rates_rec.abs_days - tmp_int
            let ar_rates_rec.abs_cnt_days = ar_rates_rec.abs_cnt_days - tmp_int
            let ar_rates_rec.abs_per_days = ar_rates_rec.abs_per_days - tmp_int
            execute ar_tmpupd_stmt using ar_rates_rec.date_from,
                                         tmp_date_to,
                                         ar_rates_rec.block_cause_dc,
                                         ar_rates_rec.abs_days,
                                         ar_rates_rec.abs_cnt_days,
                                         ar_rates_rec.abs_per_days,
                                         ar_rates_rec.abs_cnt_fl,
                                         ar_rates_rec.abs_per_fl,
                                         ar_rates_rec.abs_rate_num

            let ar_rates_rec.abs_rate_num = 0
            let ar_rates_rec.date_from = ar_block_rec.date_from
            let ar_rates_rec.abs_days = ar_rates_rec.date_to -
                                        ar_rates_rec.date_from + 1
            let ar_rates_rec.abs_cnt_days = ar_rates_rec.abs_cnt_days +
                                            ar_rates_rec.abs_days
            let ar_rates_rec.abs_per_days = ar_rates_rec.abs_per_days +
                                            ar_rates_rec.abs_days
            let ar_rates_rec.block_cause_dc = ar_block_rec.block_cause_dc
            execute ar_tmpins_stmt using ar_rates_rec.*
            let ar_rates_rec.abs_rate_num = sqlca.sqlerrd[2]
            let ar_rates_rec.block_cause_dc = null
         end if
         if ar_rates_rec.date_to > ar_block_rec.date_to
         then
            let tmp_date_to = ar_block_rec.date_to
            let tmp_int = ar_rates_rec.date_to - ar_block_rec.date_to
            let ar_rates_rec.abs_days = ar_rates_rec.abs_days - tmp_int
            let ar_rates_rec.abs_cnt_days = ar_rates_rec.abs_cnt_days - tmp_int
            let ar_rates_rec.abs_per_days = ar_rates_rec.abs_per_days - tmp_int
            execute ar_tmpupd_stmt using ar_rates_rec.date_from,
                                         tmp_date_to,
                                         ar_block_rec.block_cause_dc,
                                         ar_rates_rec.abs_days,
                                         ar_rates_rec.abs_cnt_days,
                                         ar_rates_rec.abs_per_days,
                                         ar_rates_rec.abs_cnt_fl,
                                         ar_rates_rec.abs_per_fl,
                                         ar_rates_rec.abs_rate_num

            let ar_rates_rec.abs_rate_num = 0
            let ar_rates_rec.date_from = ar_block_rec.date_to + 1
            let ar_rates_rec.abs_days = ar_rates_rec.date_to -
                                        ar_rates_rec.date_from + 1
            let ar_rates_rec.abs_cnt_days = ar_rates_rec.abs_cnt_days +
                                            ar_rates_rec.abs_days
            let ar_rates_rec.abs_per_days = ar_rates_rec.abs_per_days +
                                            ar_rates_rec.abs_days
            execute ar_tmpins_stmt using ar_rates_rec.*
         end if
         if ar_rates_rec.date_from >= ar_block_rec.date_from
            and ar_rates_rec.date_to <= ar_block_rec.date_to
         then
            execute ar_tmpupd_stmt using ar_rates_rec.date_from,
                                         ar_rates_rec.date_to,
                                         ar_block_rec.block_cause_dc,
                                         ar_rates_rec.abs_days,
                                         ar_rates_rec.abs_cnt_days,
                                         ar_rates_rec.abs_per_days,
                                         ar_rates_rec.abs_cnt_fl,
                                         ar_rates_rec.abs_per_fl,
                                         ar_rates_rec.abs_rate_num
         end if
      end while
      close ar_tmpall_curs
   end while
   close ar_blkabs_curs

   # check months
   open ar_tmpall_curs
   while true
      fetch ar_tmpall_curs into ar_rates_rec.*
      if sqlca.sqlcode = notfound
      then
         exit while
      end if
      if month(ar_rates_rec.date_from) != month(ar_rates_rec.date_to)
      then
         # update first period
         let tmp_date_from = mdy(month(ar_rates_rec.date_from), 1,
                                 year(ar_rates_rec.date_from))
         let tmp_date_to = tmp_date_from + 1 units month - 1 units day
         let tmp_int = ar_rates_rec.date_to - tmp_date_to
         let ar_rates_rec.abs_days = ar_rates_rec.abs_days - tmp_int
         let ar_rates_rec.abs_cnt_days = ar_rates_rec.abs_cnt_days - tmp_int
         let ar_rates_rec.abs_per_days = ar_rates_rec.abs_per_days - tmp_int
         execute ar_tmpupd_stmt using ar_rates_rec.date_from,
                                      tmp_date_to,
                                      ar_rates_rec.block_cause_dc,
                                      ar_rates_rec.abs_days,
                                      ar_rates_rec.abs_cnt_days,
                                      ar_rates_rec.abs_per_days,
                                      ar_rates_rec.abs_cnt_fl,
                                      ar_rates_rec.abs_per_fl,
                                      ar_rates_rec.abs_rate_num

         # insert new periods
         let tmp_int = month(ar_rates_rec.date_to) -
                       month(ar_rates_rec.date_from)
         let tmp_date_from = tmp_date_to
         let tmp_date_to = ar_rates_rec.date_to
         let ar_rates_rec.date_to = tmp_date_from
         while tmp_int > 0
            let tmp_int = tmp_int - 1

            let ar_rates_rec.abs_rate_num = 0
            let ar_rates_rec.date_from = ar_rates_rec.date_to + 1
            let ar_rates_rec.date_to = ar_rates_rec.date_from + 1 units month
                                       - 1 units day
            if ar_rates_rec.date_to > tmp_date_to
            then
               let ar_rates_rec.date_to = tmp_date_to
            end if
            let ar_rates_rec.abs_days = ar_rates_rec.date_to -
                                        ar_rates_rec.date_from + 1
            let ar_rates_rec.abs_cnt_days = ar_rates_rec.abs_cnt_days +
                                            ar_rates_rec.abs_days
            let ar_rates_rec.abs_per_days = ar_rates_rec.abs_per_days +
                                            ar_rates_rec.abs_days
            execute ar_tmpins_stmt using ar_rates_rec.*
             
         end while
      end if
   end while
   close ar_tmpall_curs

   # get or count base and rate
   # ++++ Pro-Holding(LJ) 2008.07.22 zg-7135:B³±d naliczenia podst.chor.(inicjacja zmiennej is_std_base
 
   let is_std_base = false
   #++++ 

   let is_first = true
   open ar_tmpall_curs
   while true
      fetch ar_tmpall_curs into ar_rates_rec.*
      if sqlca.sqlcode = notfound
      then
         exit while
      end if

      if is_first
      then
         # delete all bases for absence document
         execute ar_basdel_stmt using a_abs_num

         # check if base count is needed

         # KO 2005.03.10
         open ar_ratget_curs using ar_type_rec.base_kind_dc, a_addr_nr,
                                   a_abs_num, a_date_from, a_date_from,
                                   abs_new_base, a_date_from, a_date_from
         fetch ar_ratget_curs into ar_ratbas_rec.*
         let stat = sqlca.sqlcode
         close ar_ratget_curs

         #if ar_rates_rec.abs_days != ar_rates_rec.abs_per_days
         if stat != notfound
         then

            # no new base is needed

            #open ar_ratget_curs using ar_type_rec.base_kind_dc, a_addr_nr,
            #                          a_abs_num, a_date_from
            #fetch ar_ratget_curs into ar_ratbas_rec.*
            #close ar_ratget_curs

            if ar_ratbas_rec.abs_cnt_fl = "T"
               and ar_rates_rec.abs_cnt_fl = "N"
            then
               let ar_ratbas_rec.abs_rate3 = ar_ratbas_rec.abs_rate3 /
                                             ar_ratbas_rec.abs_perc *
                                             ar_rates_rec.abs_perc
            end if
         # end KO 2005.03.10

# NKP KO 2005.06.14
         # insert bases from previosu document
         open ar_basget_c using ar_ratbas_rec.abs_num
         while true
            fetch ar_basget_c into ar_absbas_rec.*
            if sqlca.sqlcode = notfound
            then
               exit while
            end if
            let ar_absbas_rec.abs_num = a_abs_num
            execute ar_basins_stmt using ar_absbas_rec.*
         end while
         close ar_basget_c
# end NKP KO 2005.06.14

         else

            # count new base
            let tmp_base1 = 0
            let tmp_base1_cnt = 0
            let tmp_base2 = 0
            let tmp_base2_cnt = 0
            let is_std_base = false
            open ar_bases_curs using a_addr_nr, ar_type_rec.base_kind_dc,
                                     a_date_from, abs_base_months, a_date_from
            while true
# NKP KO 2005.07.20
               #fetch ar_bases_curs into ar_bases_rec.*
               fetch ar_bases_curs into tmp_work_factor, ar_bases_rec.*
# end NKP KO 2005.07.20
               if sqlca.sqlcode = notfound
               then
                  exit while
               end if
               if ar_bases_rec.work_days is null
                  or ar_bases_rec.work_days = 0
                  or ar_bases_rec.nom_days is null
                  or ar_bases_rec.nom_days = 0
               then
                  continue while
               end if
               if ar_bases_rec.work_days >= (ar_bases_rec.nom_days / 2)
               then
                  if not is_std_base
                  then
                     let is_std_base = true
# NKP KO 2005.06.14
                     #execute ar_basdel_stmt using a_abs_num
                     update pn_absen_bases
                     set
                        pn_absen_bases.base_value1 = -1
                     where pn_absen_bases.abs_num = a_abs_num
                       and pn_absen_bases.base_value1 is null
                     update pn_absen_bases
                     set
                        pn_absen_bases.base_value2 = -1
                     where pn_absen_bases.abs_num = a_abs_num
                       and pn_absen_bases.base_value2 is null
# end NKP KO 2005.06.14
                  end if
                  let tmp_base2 = 0
                  if ar_bases_rec.base_value2 is not null
                  then
                     let tmp_base1_cnt = tmp_base1_cnt + 1
                     let tmp_base1 = tmp_base1 + ar_bases_rec.base_value2
                     let ar_bases_rec.base_value1 = null
                  else
                     if ar_bases_rec.base_value1 is not null
                     then
                        let tmp_base1_cnt = tmp_base1_cnt + 1
                        let tmp_base1 = tmp_base1 + ar_bases_rec.base_value1
                     end if
                  end if
                  if ar_bases_rec.base_value1 is not null
                     or ar_bases_rec.base_value2 is not null
                  then
                     execute ar_basins_stmt using a_abs_num,
                                                  ar_bases_rec.base_year,
                                                  ar_bases_rec.base_month,
                                                  ar_bases_rec.base_value1,
                                                  ar_bases_rec.base_value2,
                                                  ar_bases_rec.nom_days,
                                                  ar_bases_rec.work_days
                  end if
               else
                  if ar_bases_rec.work_days >= 1
                  then
                     if ar_bases_rec.base_value2 is not null
                     then
                        let tmp_base2_cnt = tmp_base2_cnt + 1
                        let tmp_base2 = tmp_base2 + ar_bases_rec.base_value2
                        let ar_bases_rec.base_value1 = null
                     else
                        if ar_bases_rec.base_value1 is not null
                        then
                           let tmp_base2_cnt = tmp_base2_cnt + 1
                           let tmp_base2 = tmp_base2 + ar_bases_rec.base_value1
                        end if
                     end if
                     if not is_std_base
                     then
                        if ar_bases_rec.base_value1 is not null
                           or ar_bases_rec.base_value2 is not null
                        then
                           execute ar_basins_stmt using a_abs_num,
                                                        ar_bases_rec.base_year,
                                                        ar_bases_rec.base_month,
                                                        ar_bases_rec.base_value1,
                                                        ar_bases_rec.base_value2,
                                                        ar_bases_rec.nom_days,
                                                        ar_bases_rec.work_days
                        end if
                     end if
                  end if
               end if
            end while
            close ar_bases_curs
            if is_std_base
            then
               if tmp_base1_cnt != 0
               then
                  let ar_ratbas_rec.abs_base = tmp_base1 / tmp_base1_cnt
               else
                  let ar_ratbas_rec.abs_base = tmp_base1
               end if
            else
               if tmp_base2_cnt != 0
               then
                  let ar_ratbas_rec.abs_base = tmp_base2 / tmp_base2_cnt
               else
                  let ar_ratbas_rec.abs_base = tmp_base2
               end if
            end if
            let ar_ratbas_rec.abs_rate1 = ar_ratbas_rec.abs_base / 30
            let ar_ratbas_rec.abs_perc = ar_rates_rec.abs_perc
            let ar_ratbas_rec.abs_rate3 = null

         end if
      end if

##########################################################################
## 20071112 -> szukam odpowiedni okres w pn_absba13 i kwote (1/12 z 13-tki

      if is_first and is_std_base
        then

        let wsk_pocz = year(a_date_from)*100+month(a_date_from)
        let wsk_kon =  year(a_date_to)  *100+month(a_date_to)

        let scratch = "select year_from ,month_from , year_to, ",
            " month_to , amount",
            " from pn_absen13 ",
            "where pn_absen13.addr_nr= ?",
            " order by pn_absen13.year_from desc, pn_absen13.month_from desc"

        prepare  x_rates from scratch
        declare xx_rates cursor for x_rates

        open xx_rates using a_addr_nr

        while true

          fetch xx_rates into st_year_from,st_month_from, st_year_to, st_month_to, amount

          if sqlca.sqlcode = notfound or year(a_date_to) >st_year_to
          then

            let amount = 0
            let st_year_from  = null
            let st_month_from = null
            exit while

          end if

          if wsk_pocz < st_year_from*100+st_month_from
             then  ## dalej sprawdzaj
             else
               if wsk_pocz >= st_year_from*100+st_month_from and
                  wsk_pocz <= st_year_to*100+st_month_to
                  then  exit while
               else
                  let amount =0
                  exit while
               end if
          end if

        end while

        close xx_rates

        let ar_ratbas_rec.abs_base = ar_ratbas_rec.abs_base + amount
        let ar_ratbas_rec.abs_rate1 = ar_ratbas_rec.abs_base / 30
      end if


      # check if base upgrade is needed
      # abs_per_fl - > flaga przekroczenia progu waloryzacji

      if ar_rates_rec.abs_per_fl = "T"
         and ar_ratbas_rec.abs_per_fl = "N"
      then
         let ar_ratbas_rec.abs_per_fl = "T"
         let ar_ratbas_rec.abs_base = ar_ratbas_rec.abs_base *
                                      ar_type_rec.upgrade_factor
         let ar_ratbas_rec.abs_rate1 = ar_ratbas_rec.abs_base / 30
         let ar_ratbas_rec.abs_rate3 = ar_ratbas_rec.abs_rate3 *
                                       ar_type_rec.upgrade_factor
      end if

      let ar_ratbas_rec.abs_rate2 = ar_ratbas_rec.abs_rate1 *
                                    (ar_rates_rec.abs_perc / 100)

      # check if continuous absence limit was changed
      if ar_rates_rec.abs_cnt_fl = "T"
         and ar_ratbas_rec.abs_cnt_fl = "N"
      then
         let ar_ratbas_rec.abs_cnt_fl = "T"
         let ar_ratbas_rec.abs_rate3 = ar_ratbas_rec.abs_rate3 *
                                       (ar_rates_rec.abs_perc /
                                        ar_ratbas_rec.abs_perc)
      end if

      # update bases and rates
      execute ar_tupdba_stmt using ar_ratbas_rec.abs_base,
                                   ar_ratbas_rec.abs_rate1,
                                   ar_ratbas_rec.abs_rate2,
                                   ar_ratbas_rec.abs_rate3,
                                   ar_rates_rec.abs_rate_num

      # set first record flag
      let is_first = false

   end while 
   close ar_tmpall_curs

   # insert rows to "pn_absen_rates"
   execute ar_ratins_stmt

end function
# abs_rates_count()
