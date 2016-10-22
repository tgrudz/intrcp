######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################
#

globals "globals.4gl"

define
   abs_count_prep      char(1),
   abs_limit_prep      char(1),
   ins_hours_prep      char(1),
   create_limit_prep   char(1)


######################################################################
function abs_count(a_addr_nr, a_abs_code, a_date_from, a_date_to)
######################################################################
#
define
   a_addr_nr         like pn_absence.addr_nr,
   a_abs_code        like pn_absence.abs_code,
   a_date_from       like pn_absence.date_from,
   a_date_to         like pn_absence.date_to,
   get_empl_found    smallint,
   get_empl_rec      record
                        pos_num         like pn_employ.pos_num,
                        date_from       like pn_employ.date_from,
                        date_to         like pn_employ.date_to,
                        calen_type_ds   like pn_employ.calen_type_ds,
                        calen_feature   like pn_dict_pos.feature
                     end record,
   abs_count_found   smallint,
   abs_count_rec     record
                        abs_days         like pn_absence.abs_days,
                        abs_hours        like pn_absence.abs_hours,
                        abs_work_days    like pn_absence.abs_days,
                        abs_work_hours   like pn_absence.abs_hours,
                        last_day_hours   like pn_absence.abs_hours
                     end record,
   stat              integer,
   all_abs_days      like pn_absence.abs_days,
   tmp_abs_days      like pn_absence.abs_days,
   tmp_abs_hours     like pn_absence.abs_hours,
   tmp_work_days     like pn_absence.abs_days,
   tmp_work_hours    like pn_absence.abs_hours,
   tmp_int           integer,
   tmp_date_from     date,
   tmp_date_to       date,
   tmp_l_day         date,
   tmp_l_day_hours   like pn_calen_pos.day_hours

   whenever error call error_handler

   if abs_count_prep is null
   then
      let abs_count_prep = "Y"

      let scratch = "select pn_employ.pos_num,",
                    " pn_employ.date_from,",
                    " pn_employ.date_to,",
                    " pn_employ.calen_type_ds,",
                    " pn_dict_pos.feature",
                   " from pn_employ, pn_dict_pos",
                   " where pn_employ.addr_nr = ? ",
                     " and pn_employ.date_from <= ? ",
                     " and pn_employ.date_to >= ? ",
                     " and pn_dict_pos.symbol = pn_employ.calen_type_ds",
                     " and pn_dict_pos.type = 'calen_type'",
                   " order by 1"
      prepare get_empl_stmt from scratch
      declare get_empl_curs cursor for get_empl_stmt

      let scratch = "select count(*)",
                   " from pn_calen_head, pn_calen_pos",
                   " where pn_calen_head.calen_type_ds = ? ",
                     " and pn_calen_pos.calen_num = pn_calen_head.calen_num",
                     " and pn_calen_pos.day_date between ? and ? "
      prepare get_calen_stmt from scratch
      declare get_calen_curs cursor for get_calen_stmt

      let scratch = "select count(*), sum(pn_calen_pos.day_hours)",
                   " from pn_calen_head, pn_calen_pos, pn_abs_days",
                   " where pn_calen_head.calen_type_ds = ? ",
                     " and pn_calen_pos.calen_num = pn_calen_head.calen_num",
                     " and pn_calen_pos.day_date between ? and ? ",
                     " and pn_abs_days.day_type_ds = pn_calen_pos.day_type_ds",
                     " and pn_abs_days.abs_code = ? "
      prepare abs_calen_stmt from scratch
      declare abs_calen_curs cursor for abs_calen_stmt

      let scratch = "select count(*), sum(pn_calen_pos.day_hours)",
                   " from pn_calen_head, pn_calen_pos, pn_abs_days",
                   " where pn_calen_head.calen_type_ds = ? ",
                     " and pn_calen_pos.calen_num = pn_calen_head.calen_num",
                     " and pn_calen_pos.day_feature = 1",
                     " and pn_calen_pos.day_date between ? and ? ",
                     " and pn_abs_days.day_type_ds = pn_calen_pos.day_type_ds",
                     " and pn_abs_days.abs_code = ? "
      prepare abs_work_stmt from scratch
      declare abs_work_curs cursor for abs_work_stmt

      let scratch = "select count(*)",
                   " from pn_dor_head, pn_dor_pos",
                   " where pn_dor_head.pos_num = ? ",
                     " and pn_dor_pos.dor_num = pn_dor_head.dor_num",
                     " and pn_dor_pos.dor_date between ? and ? "
      prepare get_dor_stmt from scratch
      declare get_dor_curs cursor for get_dor_stmt

      let scratch = "select count(*), sum(pn_dor_pos.day_hours)",
                   " from pn_dor_head, pn_dor_pos, pn_abs_days",
                   " where pn_dor_head.pos_num = ? ",
                     " and pn_dor_pos.dor_num = pn_dor_head.dor_num",
                     " and pn_dor_pos.dor_date between ? and ? ",
                     " and pn_abs_days.day_type_ds = pn_dor_pos.day_type_ds",
                     " and pn_abs_days.abs_code = ? "
      prepare abs_dor_stmt from scratch
      declare abs_dor_curs cursor for abs_dor_stmt

      let scratch = "select pn_calen_pos.day_date,",
                    " pn_calen_pos.day_hours",
                   " from pn_calen_head, pn_calen_pos, pn_abs_days",
                   " where pn_calen_head.calen_type_ds = ? ",
                     " and pn_calen_pos.calen_num = pn_calen_head.calen_num",
                     " and pn_calen_pos.day_date between ? and ? ",
                     " and pn_abs_days.day_type_ds = pn_calen_pos.day_type_ds",
                     " and pn_abs_days.abs_code = ? ",
                   " order by 1 desc"
      prepare abs_l_day_stmt from scratch
      declare abs_l_day_curs cursor for abs_l_day_stmt
   end if

   initialize get_empl_rec.* to null
   let abs_count_rec.abs_days = 0
   let abs_count_rec.abs_hours = 0
   let abs_count_rec.last_day_hours = null
   let abs_count_rec.abs_work_days = 0
   let abs_count_rec.abs_work_hours = 0
   let all_abs_days = 0

   # count absence days and hours
   let get_empl_found = 0
   open get_empl_curs using a_addr_nr, a_date_to, a_date_from
   while true
      fetch get_empl_curs into get_empl_rec.*
      if sqlca.sqlcode = notfound
      then
         exit while
      end if
      if get_empl_rec.date_from <= a_date_from
      then
         let get_empl_found = get_empl_found + 1
         let tmp_date_from = a_date_from
      else
         let tmp_date_from = get_empl_rec.date_from
      end if
      if get_empl_rec.date_to >= a_date_to
      then
         let get_empl_found = get_empl_found + 1
         let tmp_date_to = a_date_to
      else
         let tmp_date_to = get_empl_rec.date_to
      end if

      # initialize data found flag
      let abs_count_found = 0

      # check 'pn_dor_head' table
      if get_empl_rec.calen_feature = 100
      then
         # check all absence days
         open get_dor_curs using get_empl_rec.pos_num,
                                 tmp_date_from,
                                 tmp_date_to
         fetch get_dor_curs into tmp_int
         close get_dor_curs

         if tmp_int = 0
         then
         else
            # count absence days
            let all_abs_days = all_abs_days + tmp_int
            let abs_count_found = abs_count_found + 1
            open abs_dor_curs using get_empl_rec.pos_num,
                                    tmp_date_from,
                                    tmp_date_to,
                                    a_abs_code
            fetch abs_dor_curs into tmp_abs_days, tmp_abs_hours
            close abs_dor_curs
         end if
      end if

      # check 'pn_calen_pos' table if no data found in 'pn_dor_pos' table
      # or table 'pn_dor_pos' not used
      if not abs_count_found
      then
         # check all absence days
         open get_calen_curs using get_empl_rec.calen_type_ds,
                                   tmp_date_from,
                                   tmp_date_to
         fetch get_calen_curs into tmp_int
         close get_calen_curs

         if tmp_int = 0
         then
         else
            # count absence days
            let all_abs_days = all_abs_days + tmp_int
            let abs_count_found = abs_count_found + 1

            open abs_calen_curs using get_empl_rec.calen_type_ds,
                                      tmp_date_from,
                                      tmp_date_to,
                                      a_abs_code
            fetch abs_calen_curs into tmp_abs_days, tmp_abs_hours
            close abs_calen_curs

            open abs_work_curs using get_empl_rec.calen_type_ds,
                                      tmp_date_from,
                                      tmp_date_to,
                                      a_abs_code
            fetch abs_work_curs into tmp_work_days, tmp_work_hours
            close abs_work_curs

            open abs_l_day_curs using get_empl_rec.calen_type_ds,
                                      tmp_date_from,
                                      tmp_date_to,
                                      a_abs_code
            fetch abs_l_day_curs into tmp_l_day, tmp_l_day_hours
            if sqlca.sqlcode != notfound
            then
               let abs_count_rec.last_day_hours = tmp_l_day_hours
            end if
            close abs_l_day_curs
         end if
      end if
      if not abs_count_found
      then
         exit while
      end if
      if tmp_abs_days is not null
      then
         let abs_count_rec.abs_days = abs_count_rec.abs_days + tmp_abs_days
      end if
      if tmp_abs_hours is not null
      then
         let abs_count_rec.abs_hours = abs_count_rec.abs_hours + tmp_abs_hours
      end if
      if tmp_work_days is not null
      then
         let abs_count_rec.abs_work_days = abs_count_rec.abs_work_days +
                                           tmp_work_days
      end if
      if tmp_work_hours is not null
      then
         let abs_count_rec.abs_work_hours = abs_count_rec.abs_work_hours +
                                            tmp_work_hours
      end if
   end while
   close get_empl_curs

   case get_empl_found
      # no records in 'pn_employ' table for specified absence period
      when 0
         initialize abs_count_rec.* to null
         return -1, abs_count_rec.*
      # records in 'pn_employ' table do not cover all specified absence period
      when 1
         initialize abs_count_rec.* to null
         return -2, abs_count_rec.*
   end case
   
   if not abs_count_found
   then
      if get_empl_rec.calen_feature = 100
      then
         # no rows in 'pn_dor_pos' and 'pn_calen_pos' tables
         initialize abs_count_rec.* to null
         return -3, abs_count_rec.*
      else
         # no rows in 'pn_calen_pos' table
         initialize abs_count_rec.* to null
         return -4, abs_count_rec.*
      end if
   end if

   if all_abs_days < (a_date_to - a_date_from + 1)
   then
      if get_empl_rec.calen_feature = 100
      then
         # not all absence days is defined in 'pn_dor_pos'
         # and 'pn_calen_pos' tables
         initialize abs_count_rec.* to null
         return -5, abs_count_rec.*
      else
         # not all absence days is defined in 'pn_calen_pos' table
         initialize abs_count_rec.* to null
         return -6, abs_count_rec.*
      end if
   end if

   return 0, abs_count_rec.*

end function
# abs_count()


######################################################################
function abs_limit_check(a_abs_code, a_abs_period_dc, a_abs_limit,
                         a_is_hours_fl, a_day_hours,
                         a_abs_num, a_addr_nr, a_date_from,
                         a_date_to,
                         a_abs_days, a_abs_hours, a_check_fl)
######################################################################
#
define
   a_abs_code         like pn_absence.abs_code,
   a_abs_period_dc    like pn_abs_type.abs_period_dc,
   a_abs_limit        like pn_abs_type.abs_limit,
   a_is_hours_fl      like pn_abs_type.is_hours_fl,
   a_day_hours        like pn_abs_type.day_hours,
   a_abs_num          like pn_absence.abs_num,
   a_addr_nr          like pn_absence.addr_nr,
   a_date_from        like pn_absence.date_from,
   a_date_to          like pn_absence.date_to,
   a_abs_days         like pn_absence.abs_days,
   a_abs_hours        like pn_absence.abs_hours,
   a_check_fl         smallint,
   abs_year           smallint,
   abs_days_sum       smallint,
   abs_hours_sum      smallint,
   abs_limit_rec      record
                         days_avail_limit    smallint,
                         days_used_limit     smallint,
                         hours_avail_limit   decimal(6,2),
                         hours_used_limit    decimal(6,2),
                         abs_hours           decimal(6,2),
                         absgrp_code         char(5)
                      end record,
   is_indiv_fl        smallint,
   abs_limit_num      integer,
   tmp_abs_limit      smallint,
   tmp_abs_hours      decimal(6,2),
   tmp_limit_fl       char(1),
   tmp_absgrp_code    char(5),
   grp_limit_num      integer,
   absgrp_limit       smallint,
   tmp_absgrp_limit   smallint,
   tmp_absgrp_days    smallint,
   tmp_absgrp_hours   decimal(6,2),
   tmp_day_date       date,
   tmp_day_hours      decimal(4,2),
   tmp_avail_hours    decimal(6,2),
   tmp_hours          decimal(6,2),
   tmp_date_to        date,
   ret_stat           integer,
   grp_stat           integer,
   stat               integer

   if abs_limit_prep is null
   then
      let abs_limit_prep = "Y"

      let scratch = "select sum(pn_absence.abs_days),",
                    " sum(pn_absence.abs_hours)",
                   " from pn_absence",
                   " where pn_absence.abs_num != ? ",
                     " and pn_absence.addr_nr = ? ",
                     " and pn_absence.abs_code = ? "
      prepare sum_abs1_stmt from scratch
      declare sum_abs1_curs cursor for sum_abs1_stmt

      let scratch = "select sum(pn_absence.abs_days),",
                    " sum(pn_absence.abs_hours)",
                   " from pn_absence",
                   " where pn_absence.abs_num != ? ",
                     " and pn_absence.addr_nr = ? ",
                     " and pn_absence.abs_code = ? ",
                     " and year(pn_absence.date_from) = ? ",
                     " and year(pn_absence.date_to) = ? "
      prepare sum_abs2_stmt from scratch
      declare sum_abs2_curs cursor for sum_abs2_stmt

      let scratch = "select pn_absli_head.limit_num,",
                    " pn_absli_pos.avail_limit",
                   " from pn_absli_head, pn_absli_pos",
                   " where pn_absli_head.addr_nr = ? ",
                     " and pn_absli_head.limit_type_fl = ? ",
                     " and pn_absli_head.limit_code = ? ",
                     " and pn_absli_pos.limit_num = pn_absli_head.limit_num",
                     " and pn_absli_pos.limit_year is null"
      prepare get_lim1_stmt from scratch
      declare get_lim1_curs cursor for get_lim1_stmt

      let scratch = "select pn_absli_head.limit_num,",
                    " pn_absli_pos.avail_limit",
                   " from pn_absli_head, pn_absli_pos",
                   " where pn_absli_head.addr_nr = ? ",
                     " and pn_absli_head.limit_type_fl = ? ",
                     " and pn_absli_head.limit_code = ? ",
                     " and pn_absli_pos.limit_num = pn_absli_head.limit_num",
                     " and pn_absli_pos.limit_year = ? "
      prepare get_lim2_stmt from scratch
      declare get_lim2_curs cursor for get_lim2_stmt

      let scratch = "update pn_absli_pos",
                   " set",
                      " pn_absli_pos.used_limit = ? ",
                   " where pn_absli_pos.limit_num = ? ",
                     " and pn_absli_pos.limit_year is null"
      prepare upd_lim1_stmt from scratch

      let scratch = "update pn_absli_pos",
                   " set",
                      " pn_absli_pos.used_limit = ? ",
                   " where pn_absli_pos.limit_num = ? ",
                     " and pn_absli_pos.limit_year = ? "
      prepare upd_lim2_stmt from scratch

      let scratch = "select pn_absgrp_head.absgrp_code,",
                    " pn_absgrp_head.absgrp_limit",
                   " from pn_absgrp_pos, pn_absgrp_head",
                   " where pn_absgrp_pos.abs_code = ? ",
                     " and pn_absgrp_head.absgrp_code =",
                         " pn_absgrp_pos.absgrp_code",
                     " and pn_absgrp_head.absgrp_limit >= 0"
      prepare get_grp_stmt from scratch
      declare get_grp_curs cursor for get_grp_stmt

      let scratch = "select sum(pn_absence.abs_days),",
                    " sum(pn_absence.abs_hours)",
                   " from pn_absgrp_head, pn_absgrp_pos, pn_absence",
                   " where pn_absgrp_head.absgrp_code = ? ",
                     " and pn_absgrp_pos.absgrp_code =",
                         " pn_absgrp_head.absgrp_code",
                     " and pn_absence.abs_code = pn_absgrp_pos.abs_code",
                     " and pn_absence.addr_nr = ? ",
                     " and pn_absence.abs_num != ? "
      prepare sum_grp1_stmt from scratch
      declare sum_grp1_curs cursor for sum_grp1_stmt

      let scratch = "select sum(pn_absence.abs_days),",
                    " sum(pn_absence.abs_hours)",
                   " from pn_absgrp_head, pn_absgrp_pos, pn_absence",
                   " where pn_absgrp_head.absgrp_code = ? ",
                     " and pn_absgrp_pos.absgrp_code =",
                         " pn_absgrp_head.absgrp_code",
                     " and pn_absence.abs_code = pn_absgrp_pos.abs_code",
                     " and pn_absence.addr_nr = ? ",
                     " and pn_absence.abs_num != ? ",
                     " and year(pn_absence.date_from) = ? ",
                     " and year(pn_absence.date_to) = ? "
      prepare sum_grp2_stmt from scratch
      declare sum_grp2_curs cursor for sum_grp2_stmt

      select * from pn_absen_hours
      where 1=0
      into temp tmp_abs_hours with no log

      let scratch = "delete from tmp_abs_hours where 1=1"
      prepare ah_tmpdel_stmt from scratch

      let scratch = "select pn_calen_pos.day_date,",
                    " pn_calen_pos.day_hours",
                   " from pn_employ, pn_calen_head, pn_calen_pos, pn_abs_days",
                   " where pn_employ.addr_nr = ? ",
                     " and pn_employ.date_from <= ? ",
                     " and pn_employ.date_to >= ? ",
                     " and pn_calen_head.calen_type_ds = pn_employ.calen_type_ds",
                     " and pn_calen_pos.calen_num = pn_calen_head.calen_num",
                     " and pn_calen_pos.day_date between ? and ? ",
                     " and pn_calen_pos.day_date between pn_employ.date_from",
                                               " and pn_employ.date_to",
                     " and pn_abs_days.abs_code = ? ",
                     " and pn_abs_days.day_type_ds = pn_calen_pos.day_type_ds",
                   " order by pn_calen_pos.day_date"
      prepare get_dhours_stmt from scratch
      declare get_adays_curs cursor for get_dhours_stmt

      let scratch = "insert into tmp_abs_hours values (?, ?, ?)"
      prepare ah_tmpins_stmt from scratch

      let scratch = "select tmp_abs_hours.abs_day,",
                    " tmp_abs_hours.abs_hours",
                   " from tmp_abs_hours",
                   " order by tmp_abs_hours.abs_day"
      prepare ah_tmpall_stmt from scratch
      declare ah_tmpall_curs cursor for ah_tmpall_stmt

      let scratch = "update tmp_abs_hours",
                   " set",
                      " tmp_abs_hours.abs_hours = tmp_abs_hours.abs_hours - ? ",
                   " where tmp_abs_hours.abs_day = ? "
      prepare ah_tmpupd_stmt from scratch
   end if

   # initialize variables
   let abs_year = year(a_date_from)
   let abs_days_sum = null
   let abs_hours_sum = null
   initialize abs_limit_rec.* to null
   let is_indiv_fl = 0
   let tmp_limit_fl = "A"
   let ret_stat = 0
   let grp_stat = 0
   let stat = null

   # check if absence is limited
   if a_abs_period_dc = 0
   then
      let abs_limit_rec.abs_hours = a_abs_hours
      return 0, abs_limit_rec.*
   end if 

   # get absence sums
   if a_abs_period_dc = 1
   then
      open sum_abs1_curs using a_abs_num, a_addr_nr, a_abs_code
      fetch sum_abs1_curs into abs_days_sum, abs_hours_sum
      close sum_abs1_curs 

      open get_lim1_curs using a_addr_nr, tmp_limit_fl, a_abs_code
      fetch get_lim1_curs into abs_limit_num, tmp_abs_limit
      if sqlca.sqlcode = notfound
      then
         let abs_year = null
         let abs_limit_num = create_limit(a_addr_nr, tmp_limit_fl,
                                          a_abs_code, abs_year,
                                          a_abs_limit)
         let abs_year = year(a_date_from)
         let tmp_abs_limit = a_abs_limit
         let is_indiv_fl = 1
      else
         let is_indiv_fl = 1
      end if
      close get_lim1_curs
   end if

   if a_abs_period_dc = 2
   then
      open sum_abs2_curs using a_abs_num, a_addr_nr, a_abs_code,
                               abs_year, abs_year
      fetch sum_abs2_curs into abs_days_sum, abs_hours_sum
      close sum_abs2_curs 

      open get_lim2_curs using a_addr_nr, tmp_limit_fl, a_abs_code,
                               abs_year
      fetch get_lim2_curs into abs_limit_num, tmp_abs_limit
      if sqlca.sqlcode = notfound
      then
         let abs_limit_num = create_limit(a_addr_nr, tmp_limit_fl,
                                          a_abs_code, abs_year,
                                          a_abs_limit)
         let tmp_abs_limit = a_abs_limit
         let is_indiv_fl = 2
      else
         let is_indiv_fl = 2
      end if
      close get_lim2_curs
   end if

   if abs_days_sum is null
   then
      let abs_days_sum = 0
   end if
   if abs_hours_sum is null
   then
      let abs_hours_sum = 0
   end if

   let abs_limit_rec.days_avail_limit = tmp_abs_limit
   let abs_limit_rec.days_used_limit = abs_days_sum + a_abs_days
   let abs_limit_rec.abs_hours = a_abs_hours
   if a_is_hours_fl = "T"
   then
      let abs_limit_rec.hours_avail_limit = tmp_abs_limit * a_day_hours
      let abs_limit_rec.hours_used_limit = abs_hours_sum
      let abs_limit_rec.days_used_limit = abs_limit_rec.hours_used_limit /
                                          a_day_hours
   end if

   # get only sums
   if a_check_fl
   then
      return 0, abs_limit_rec.*
   end if

   # clear temporary table
   execute ah_tmpdel_stmt

   # get abs days and hours 
   if a_is_hours_fl = "T"
   then
      open get_adays_curs using a_addr_nr, a_date_to, a_date_from,
                                a_date_from, a_date_to, a_abs_code
      while true
          fetch get_adays_curs into tmp_day_date, tmp_day_hours
          if sqlca.sqlcode = notfound
          then
             exit while
          end if
          execute ah_tmpins_stmt using a_abs_num, tmp_day_date, tmp_day_hours
      end while
      close get_adays_curs
   end if

   # check limit for absence code
   if a_is_hours_fl = "T"
   then
      # initialize variables
      let abs_limit_rec.hours_used_limit = abs_hours_sum
      let tmp_day_date = a_date_from
      let tmp_avail_hours = tmp_abs_limit * a_day_hours
      let tmp_date_to = a_date_to

      # check used limit
      if abs_limit_rec.hours_used_limit >= tmp_avail_hours
      then
         # limit exceeded
         let abs_limit_rec.days_used_limit = null
         let abs_limit_rec.hours_used_limit = null
         if is_indiv_fl
         then
            return -3, abs_limit_rec.*
         else
            return -1, abs_limit_rec.*
         end if
      end if

      # check absence days
      open ah_tmpall_curs
      while true
         fetch ah_tmpall_curs into tmp_day_date, tmp_day_hours
         if sqlca.sqlcode = notfound
         then
            let tmp_date_to = tmp_day_date
            exit while
         end if
         let abs_limit_rec.hours_used_limit = abs_limit_rec.hours_used_limit +
                                              tmp_day_hours
         if abs_limit_rec.hours_used_limit >= tmp_avail_hours
         then
            exit while
         end if
      end while

      # check last absence day
      if tmp_date_to != tmp_day_date
      then
         fetch ah_tmpall_curs into scratch, tmp_day_hours
         if sqlca.sqlcode = notfound
         then
            let tmp_date_to = tmp_day_date
         end if
      end if

      close ah_tmpall_curs

      let abs_limit_rec.days_used_limit = abs_limit_rec.hours_used_limit /
                                          a_day_hours

      #if tmp_day_date != a_date_to
      if tmp_day_date != tmp_date_to
      then
         if abs_limit_rec.hours_used_limit >= tmp_avail_hours
         then
            # limit exceeded
            let abs_limit_rec.days_used_limit = null
            let abs_limit_rec.hours_used_limit = null
            if is_indiv_fl
            then
               return -3, abs_limit_rec.*
            else
               return -1, abs_limit_rec.*
            end if
         end if
      else
         if abs_limit_rec.hours_used_limit > tmp_avail_hours
         then
            # not whole last day
            let tmp_abs_hours = abs_limit_rec.hours_used_limit mod a_day_hours
            let abs_limit_rec.abs_hours = a_abs_hours - tmp_abs_hours
            let abs_limit_rec.hours_used_limit = abs_hours_sum + 
                                                 abs_limit_rec.abs_hours
            execute ah_tmpupd_stmt using tmp_abs_hours, tmp_day_date
            let ret_stat = -2
         end if
      end if
   else
      if abs_days_sum + a_abs_days > tmp_abs_limit
      then
         # limit exceeded
         if is_indiv_fl
         then
            return -3, abs_limit_rec.*
         else
            return -1, abs_limit_rec.*
         end if
      end if
   end if

   # update individual limits for absence type
   case is_indiv_fl
      when 1
         execute upd_lim1_stmt using abs_limit_rec.days_used_limit,
                                     abs_limit_num
      when 2
         execute upd_lim2_stmt using abs_limit_rec.days_used_limit,
                                     abs_limit_num, abs_year
   end case

   # check limits for absence groups
   let tmp_limit_fl = "G"
   open get_grp_curs using a_abs_code
   while true
      fetch get_grp_curs into tmp_absgrp_code, absgrp_limit
      if sqlca.sqlcode = notfound
         or absgrp_limit is null
         or absgrp_limit < 0
      then
         exit while
      end if
      close get_lim2_curs

      let is_indiv_fl = 0
      let tmp_absgrp_days = 0
      let tmp_absgrp_hours = 0

      if a_abs_period_dc = 1
      then
         open get_lim1_curs using a_addr_nr, tmp_limit_fl, tmp_absgrp_code
         fetch get_lim1_curs into grp_limit_num, tmp_absgrp_limit
         if sqlca.sqlcode = notfound
         then
            let abs_year = null
            let grp_limit_num = create_limit(a_addr_nr, tmp_limit_fl,
                                             tmp_absgrp_code, abs_year,
                                             absgrp_limit)
            let abs_year = year(a_date_from)
            let tmp_absgrp_limit = absgrp_limit
            let is_indiv_fl = 11
         else
            let is_indiv_fl = 11
         end if

         open sum_grp1_curs using tmp_absgrp_code, a_addr_nr, a_abs_num
         fetch sum_grp1_curs into tmp_absgrp_days, tmp_absgrp_hours 
         close sum_grp1_curs
      end if

      if a_abs_period_dc = 2
      then
         open get_lim2_curs using a_addr_nr, tmp_limit_fl, tmp_absgrp_code,
                                  abs_year
         fetch get_lim2_curs into grp_limit_num, tmp_absgrp_limit
         if sqlca.sqlcode = notfound
         then
            let grp_limit_num = create_limit(a_addr_nr, tmp_limit_fl,
                                             tmp_absgrp_code, abs_year,
                                             absgrp_limit)
            let tmp_absgrp_limit = absgrp_limit
            let is_indiv_fl = 12
         else
            let is_indiv_fl = 12
         end if

         open sum_grp2_curs using tmp_absgrp_code, a_addr_nr, a_abs_num,
                                  abs_year, abs_year
         fetch sum_grp2_curs into tmp_absgrp_days, tmp_absgrp_hours 
         close sum_grp2_curs
      end if

      if tmp_absgrp_days is null
      then
         let tmp_absgrp_days = 0
      end if
      if tmp_absgrp_hours is null
      then
         let tmp_absgrp_hours = 0
      end if

      if a_is_hours_fl = "T"
      then
         let tmp_hours = tmp_absgrp_hours
         let tmp_day_date = a_date_from
         let tmp_avail_hours = tmp_absgrp_limit * a_day_hours
         let tmp_date_to = a_date_to

         # check absence days
         open ah_tmpall_curs
         while true
            fetch ah_tmpall_curs into tmp_day_date, tmp_day_hours
            if sqlca.sqlcode = notfound
            then
               let tmp_date_to = tmp_day_date
               exit while
            end if
            let tmp_hours = tmp_hours + tmp_day_hours
            if tmp_hours >= tmp_avail_hours
            then
               exit while
            end if
         end while

         # check last absence day
         if tmp_date_to != tmp_day_date
         then
            fetch ah_tmpall_curs into scratch, tmp_day_hours
            if sqlca.sqlcode = notfound
            then
               let tmp_date_to = tmp_day_date
            end if
         end if

         close ah_tmpall_curs

         #if tmp_day_date != a_date_to
         if tmp_day_date != tmp_date_to
         then
            if tmp_hours >= tmp_avail_hours
            then
               # limit exceeded
               let grp_stat = -1
               let abs_limit_rec.absgrp_code = tmp_absgrp_code
               exit while
            end if
         else
            if tmp_hours > tmp_avail_hours
            then
               # not whole last day
               let tmp_abs_hours = tmp_hours mod a_day_hours
               let abs_limit_rec.abs_hours = a_abs_hours - tmp_abs_hours
               let abs_limit_rec.hours_used_limit = tmp_absgrp_hours + 
                                                    abs_limit_rec.abs_hours
               execute ah_tmpupd_stmt using tmp_abs_hours, tmp_day_date
               let ret_stat = -2
            end if
         end if

         let tmp_absgrp_days =  (tmp_absgrp_hours + a_abs_hours) / a_day_hours
      else
         if tmp_absgrp_days + a_abs_days > tmp_absgrp_limit
         then
            # limit exceeded
            let grp_stat = -1
            let abs_limit_rec.absgrp_code = tmp_absgrp_code
            exit while
         end if
         let tmp_absgrp_days =  tmp_absgrp_days + a_abs_days
      end if

      # update individual limits for absence group
      case is_indiv_fl
         when 11
            execute upd_lim1_stmt using tmp_absgrp_days,
                                        grp_limit_num
         when 12
            execute upd_lim2_stmt using tmp_absgrp_days,
                                        grp_limit_num, abs_year
      end case
   end while
   close get_grp_curs

   # limit exceeded for absence group
   if grp_stat < 0
   then
      let abs_limit_rec.days_used_limit = null
      let abs_limit_rec.hours_used_limit = null
      if is_indiv_fl
      then
         return -12, abs_limit_rec.*
      else
         return -11, abs_limit_rec.*
      end if
   end if

   # limit not exceeded -> insert absence hours
   call abs_ins_hours(a_abs_num)

   return ret_stat, abs_limit_rec.*

end function
# abs_limit_check()

######################################################################
function abs_ins_hours(a_abs_num)
######################################################################
#
define
   a_abs_num   integer

   if ins_hours_prep is null
   then
      let ins_hours_prep = "Y"

      let scratch = "delete from pn_absen_hours",
                   " where pn_absen_hours.abs_num = ? "
      prepare del_hours_stmt from scratch

      let scratch = "update tmp_abs_hours",
                   " set",
                      " tmp_abs_hours.abs_num = ? ",
                   " where 1=1"
      prepare ah_updnum_stmt from scratch

      let scratch = "insert into pn_absen_hours select * from tmp_abs_hours"
      prepare ins_hours_stmt from scratch
   end if

   if a_abs_num is not null
      and a_abs_num != -1
   then
      execute ah_updnum_stmt using a_abs_num
      execute del_hours_stmt using a_abs_num
      execute ins_hours_stmt
   end if

end function
# abs_ins_hours()


######################################################################
function create_limit(a_addr_nr, a_limit_fl, a_limit_code,
                      a_limit_year, a_abs_limit)
######################################################################
#
define
   a_addr_nr      integer,
   a_limit_fl     char(1),
   a_limit_code   char(5),
   a_limit_year   smallint,
   a_abs_limit    smallint,
   abslihe_rec    record like pn_absli_head.*,
   abslipo_rec    record like pn_absli_pos.*,
   stat           integer

   if create_limit_prep is null
   then
      let create_limit_prep = "Y"

      let scratch = "select pn_absli_head.limit_num",
                   " from pn_absli_head",
                   " where pn_absli_head.addr_nr = ? ",
                     " and pn_absli_head.limit_type_fl = ? ",
                     " and pn_absli_head.limit_code = ? "
      prepare get_abslihe_s from scratch
      declare get_abslihe_c cursor for get_abslihe_s

      let scratch = "insert into pn_absli_head",
                    " values (0, ?, ?, ?)"
      prepare ins_abslihe_s from scratch

      let scratch = "insert into pn_absli_pos",
                    " values (?, ?, ?, 0, ?, 0)"
      prepare ins_abslipo_s from scratch

   end if

   # check arguments
   if a_abs_limit is null
   then
      return -1
   end if

   # check if limit header exists
   open get_abslihe_c using a_addr_nr, a_limit_fl, a_limit_code
   fetch get_abslihe_c into abslihe_rec.limit_num
   let stat = sqlca.sqlcode
   close get_abslihe_c

   if stat = notfound
   then
      # insert limit header
      execute ins_abslihe_s using a_addr_nr, a_limit_fl, a_limit_code
      let abslihe_rec.limit_num = sqlca.sqlerrd[2]
   end if

   # insert limit position
   execute ins_abslipo_s using abslihe_rec.limit_num, a_limit_year,
                               a_abs_limit, a_abs_limit

   return abslihe_rec.limit_num

end function
# create_limit()
