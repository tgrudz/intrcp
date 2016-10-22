######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################
#

globals "globals.4gl"

define
   ok_update_prep   char(1),
   upd_dor_prep     char(1),
   del_ref_prep     char(1),
   abs_type_prep    char(1),
   abs_limit_prep   char(1),
   abs_param_prep   char(1),
   chk_plan_prep    char(1),
   chk_curs_prep    char(1),
   pay_rates_prep   char(1),
   upd_limit_prep   char(1),
   s_cnt_payrates   smallint,
   cur_abs_code     like pn_abs_type.abs_code,
   abs_type_rec     record
                       abs_period_dc  like pn_abs_type.abs_period_dc,
                       abs_limit      like pn_abs_type.abs_limit,
                       is_plan_fl     like pn_abs_type.is_plan_fl,
                       is_hours_fl    like pn_abs_type.is_hours_fl,
                       day_hours      like pn_abs_type.day_hours
                    end record


######################################################################
function show_browse()
######################################################################
#

   whenever error call error_handler

   return true

end function
# show_browse()


######################################################################
function ok_add()
######################################################################
#

   if cnt_pay_rates(-1) then end if

   return true

end function
# ok_add()


######################################################################
function ok_update()
######################################################################
#

   if q_bsence.addr_actual_fl != "T"
   then
      call fg_er("Zmiana zabroniona. Pracownik nieaktualny !!!")
      return false
   end if

   if q_bsence.addr_type_fl != "P"
   then
      call fg_er("Zmiana zabroniona. Pracownik obcy !!!")
      return false
   end if

   if cnt_pay_rates(q_bsence.abs_num)
   then
      call fg_er("UWAGA !!! Dane przekazane na listê p³ac.")
   end if

   return true

end function
# ok_update()


######################################################################
function ok_delete()
######################################################################
#

   if cnt_pay_rates(q_bsence.abs_num)
   #if get_pay_rates()
   then
      call fg_er("Usuwanie zabronione. Dane przekazane na listê p³ac !!!")
      return false
   end if

   return true

end function
# ok_delete()


######################################################################
function delete_ref(a_abs_num)
######################################################################
#
define
   a_abs_num   like pn_absence.abs_num

   if del_ref_prep is null
   then
      let del_ref_prep = "Y"
      let scratch = "delete from pn_absen_rates",
                   " where pn_absen_rates.abs_num = ? "
      prepare del_rates_stmt from scratch
      let scratch = "delete from pn_absen_bases",
                   " where pn_absen_bases.abs_num = ? "
      prepare del_bases_stmt from scratch
      let scratch = "delete from pn_absen_hours",
                   " where pn_absen_hours.abs_num = ? "
      prepare del_hours_stmt from scratch
   end if

   execute del_rates_stmt using a_abs_num
   execute del_bases_stmt using a_abs_num
   execute del_hours_stmt using a_abs_num

end function
# delete_ref()


######################################################################
function update_dor(a_abs_num)
######################################################################
#
define
   a_abs_num   like pn_absence.abs_num,
   dorpl_rec   record
                  dor_num    integer,
                  dor_date   date
               end record

   if upd_dor_prep is null
   then
      let upd_dor_prep = "Y"

      # 'pn_dor_plans' table
      let scratch = "select pn_dor_plans.dor_num,",
                    " pn_dor_plans.dor_date",
                   " from pn_dor_plans",
                   " where pn_dor_plans.abs_num = ? "
      prepare get_dorpl_s from scratch
      declare get_dorpl_c cursor for get_dorpl_s

      let scratch = "delete from pn_dor_plans",
                   " where pn_dor_plans.dor_num = ? ",
                     " and pn_dor_plans.dor_date = ? ",
                     " and pn_dor_plans.is_auto_fl = 'Y'"
      prepare del_dorpl_stmt from scratch

      # 'pn_dor_pos' table
      let scratch = "update pn_dor_pos",
                   " set",
                      " pn_dor_pos.abs_code = null,",
                      " pn_dor_pos.abs_num = null,",
                      " pn_dor_pos.abs_rate_num = null",
                   " where pn_dor_pos.abs_num = ? "
      prepare upd_dorpos_stmt from scratch

   end if

   open get_dorpl_c using a_abs_num
   while true

      fetch get_dorpl_c into dorpl_rec.*
      if sqlca.sqlcode = notfound
      then
         exit while
      end if

      execute del_dorpl_stmt using dorpl_rec.*

   end while
   close get_dorpl_c

   execute upd_dorpos_stmt using a_abs_num

   call fg_er("Wpisy o absencji zosta³y usuniête z istniej±cych DOR-ów !!!")

end function
# update_dor()


######################################################################
function extra_menu_items(i)
######################################################################
#

define
   i   smallint

   case i
      when 0
         return "0-Absencje", "Wprowadzanie dokumenów absencji."
      when 1
         return "1-Okresy", "Okresy absencji."
      when 2
         return "2-Podstawy", "Podstawy wchodz±ce do wyliczenia stawki."
      when 3
         return "3-Godziny", "Godziny w poszczególnych dniach absencji."
      otherwise
         return "", ""
   end case

   return "", ""

end function
# extra_menu_items()


######################################################################
function do_scr_funct(cur_funct)
######################################################################
#

define
   cur_funct       char(20),
   cur_scr         char(64),
   save_scr_funct  char(20)             # save current screen function


   let save_scr_funct = scr_funct             # save screen function
   let scr_funct = cur_funct                  # set new screen function
   let cur_scr = get_cur_screen()             # get current screen name

   case
      when cur_scr = "pn_absen"
         if cur_funct = "init"
         then
            call init_main()
         end if
         let scr_funct = save_scr_funct     # restore screen function
         return false
      when cur_scr = "pn_absra"
         call S_pnabsra()
         let scr_funct = save_scr_funct     # restore screen function
         return true
      when cur_scr = "pn_absba"
         call S_pnabsba()
         let scr_funct = save_scr_funct     # restore screen function
         return true
      when cur_scr = "pn_absho"
         call S_pnabsho()
         let scr_funct = save_scr_funct     # restore screen function
         return true
      otherwise
         let scr_funct = save_scr_funct     # restore screen function
  end case

  return false

end function
# do_scr_funct()


######################################################################
function init_main()
######################################################################
#


  let scr1_max = 5
  let rec1_max = 50
  let rec1_cnt = rec1_max

end function
# init_main()

######################################################################
function get_abs_type()
######################################################################
#
define
   stat   integer

   if abs_type_prep is null
   then
      let abs_type_prep = "Y"
      let scratch = "select pn_abs_type.abs_period_dc,",
                    " pn_abs_type.abs_limit,",
                    " pn_abs_type.is_plan_fl,",
                    " pn_abs_type.is_hours_fl,",
                    " pn_abs_type.day_hours",
                   " from pn_abs_type",
                   " where pn_abs_type.abs_code = ? "
      prepare abs_type_stmt from scratch
      declare abs_type_curs cursor for abs_type_stmt
   end if

   # get absence definition
   if cur_abs_code = p_bsence.abs_code
   then
      return true
   else
      open abs_type_curs using p_bsence.abs_code
      fetch abs_type_curs into abs_type_rec.*
      let stat = sqlca.sqlcode
      close abs_type_curs
      if stat = notfound
      then
         call fg_er("Brak definicji kodu absencji !!!")
         return false
      end if
   end if

   if abs_type_rec.abs_period_dc is null
   then
      call fg_er("B³êdna definicja okresu zliczania absencji !!!")
      return false
   end if

   return true

end function
# get_abs_type()


######################################################################
function get_abs_param(a_param_code)
######################################################################
#
define
   a_param_code    smallint,
   tmp_feature     smallint,
   tmp_value_dec   decimal(7,3)

   if abs_param_prep is null
   then
      let abs_param_prep = "Y"
      let scratch = "select pn_dict_pos.feature, pn_dict_pos.value_dec",
                   " from pn_dict_pos",
                   " where pn_dict_pos.type = 'abs_params'",
                     " and pn_dict_pos.code = ? "
      prepare get_param_stmt from scratch
      declare get_param_curs cursor for get_param_stmt
   end if

   open get_param_curs using a_param_code
   fetch get_param_curs into tmp_feature, tmp_value_dec
   if sqlca.sqlcode = notfound
   then
      let tmp_feature = null
      let tmp_value_dec = null
   end if
   close get_param_curs

   case a_param_code
      when 1
         if tmp_feature is null
         then
            let tmp_feature = 60
         end if
      when 2
         if tmp_feature is null
         then
            let tmp_feature = 180
         end if
      when 3
         if tmp_feature is null
         then
            let tmp_feature = 12
         end if
   end case

   return tmp_feature

end function
# get_abs_param()


######################################################################
function chk_plan()
######################################################################
#
define
   tmp_wage_code   char(5),
   tmp_abs_year    smallint,
   tmp_year        smallint,
   ret_value       smallint,
   stat            integer

   if chk_plan_prep is null
   then
      let chk_plan_prep = "Y"
      let scratch = "select pn_employ.wage_code",
                   " from pn_employ",
                   " where pn_employ.addr_nr = ? ",
                     " and pn_employ.date_from <= ? ",
                     " and pn_employ.date_to >= ? ",
                   " order by 1"
      prepare get_empl_stmt from scratch
      declare get_empl_curs cursor for get_empl_stmt
      let scratch = "select pn_abspl_pos.abs_year",
                   " from pn_abspl_pos",
                   " where pn_abspl_pos.abs_code = ? ",
                     " and pn_abspl_pos.wage_code = ? ",
                     " and pn_abspl_pos.abs_year = ? "
      prepare get_plan_stmt from scratch
      declare get_plan_curs cursor for get_plan_stmt
   end if

   let ret_value = true

   if p_bsence.addr_nr is null
      or length(p_bsence.abs_code) = 0
      or p_bsence.date_from is null
      or p_bsence.date_to is null
   then
      return ret_value
   end if

   let tmp_abs_year = year(p_bsence.date_from)

   open get_empl_curs using p_bsence.addr_nr,
                            p_bsence.date_to,
                            p_bsence.date_from
   while true
      fetch get_empl_curs into tmp_wage_code
      if sqlca.sqlcode = notfound
      then
         exit while
      end if
      open get_plan_curs using p_bsence.abs_code, tmp_wage_code, tmp_abs_year
      fetch get_plan_curs into tmp_year
      let stat = sqlca.sqlcode
      close get_plan_curs
      if stat = notfound
      then
         let ret_value = false
         exit while
      end if
   end while
   close get_empl_curs

   return ret_value

end function
# chk_plan()


######################################################################
function get_abs_limit()
######################################################################
#
define
   tmp_abs_hours     decimal(6,2),
   tmp_absgrp_code   char(5),
   stat              integer

   if length(p_bsence.abs_code) = 0
      or get_cur_screen() != "pn_absen"
   then
      return
   end if
   if get_abs_type()
   then
      call abs_limit_check(p_bsence.abs_code, abs_type_rec.abs_period_dc,
                           abs_type_rec.abs_limit, abs_type_rec.is_hours_fl,
                           abs_type_rec.day_hours, -1,
                           p_bsence.addr_nr, p_bsence.date_from,
                           p_bsence.date_to, 0, 0, 1)
           returning stat, p_bsence.days_avail_limit, p_bsence.days_used_limit,
                     p_bsence.hours_avail_limit, p_bsence.hours_used_limit,
                     tmp_abs_hours, tmp_absgrp_code
   end if

end function
# get_abs_limit()


######################################################################
function chk_absence()
######################################################################
#
define
   tmp_abs_num       integer,
   tmp_int           integer,
   tmp_absgrp_code   char(5),
   tmp_l_day_hours   like pn_calen_pos.day_hours,
   stat              integer

   if chk_curs_prep is null
   then
      let chk_curs_prep = "Y"
      let scratch = "select pn_absence.abs_num",
                   " from pn_absence",
                   " where pn_absence.abs_num != ? ",
                     " and pn_absence.addr_nr = ? ",
                     " and ? between pn_absence.date_from",
                           " and pn_absence.date_to"
      prepare abs_chk1_stmt from scratch
      declare abs_chk1_curs cursor for abs_chk1_stmt
      let scratch = "select pn_absence.abs_num",
                   " from pn_absence",
                   " where pn_absence.abs_num != ? ",
                     " and pn_absence.addr_nr = ? ",
                     " and pn_absence.date_from between ? and ? "
      prepare abs_chk2_stmt from scratch
      declare abs_chk2_curs cursor for abs_chk2_stmt
   end if

   # check absence dates
   if p_bsence.addr_nr is null
   then
      return
   end if
   if p_bsence.date_from > p_bsence.date_to
   then
      call fg_er("Data pocz±tku nie mo¿e byæ wiêksza od daty koñca absencji !!!")
      let nxt_fld = scr_fld
      return
   end if

   # set temporary absence number
   if q_bsence.abs_num is null
   then
      let tmp_abs_num = -1
   else
      let tmp_abs_num = q_bsence.abs_num
   end if

   if p_bsence.date_from is not null
   then
      open abs_chk1_curs using tmp_abs_num, p_bsence.addr_nr,
                               p_bsence.date_from
      fetch abs_chk1_curs into tmp_int
      let stat = sqlca.sqlcode
      close abs_chk1_curs
      if stat != notfound
      then
         call fg_er("Istnieje dokument absencji na ten okres !!!")
         let nxt_fld = scr_fld
         return
      end if
   end if

   if p_bsence.date_to is not null
   then
      open abs_chk1_curs using tmp_abs_num, p_bsence.addr_nr,
                               p_bsence.date_to
      fetch abs_chk1_curs into tmp_int
      let stat = sqlca.sqlcode
      close abs_chk1_curs
      if stat != notfound
      then
         call fg_er("Istnieje dokument absencji na ten okres !!!")
         let nxt_fld = scr_fld
         return
      end if
   end if

   if p_bsence.date_from is not null
      and p_bsence.date_to is not null
   then
      open abs_chk2_curs using tmp_abs_num, p_bsence.addr_nr,
                               p_bsence.date_from, p_bsence.date_to
      fetch abs_chk2_curs into tmp_int
      let stat = sqlca.sqlcode
      close abs_chk2_curs
      if stat != notfound
      then
         call fg_er("Istnieje dokument absencji na ten okres !!!")
         let nxt_fld = scr_fld
         return
      end if
   end if

   # check absence period
   if length(p_bsence.abs_code) = 0
   then
      return
   end if
   if abs_type_rec.abs_period_dc = 2
   then
      if year(p_bsence.date_from) != year(p_bsence.date_to)
      then
         call fg_er("Niedozwolona operacja - rejestracja na prze³omie roku !!!")
         let nxt_fld = scr_fld
         return
      end if
   end if

   # check absence plans
   if abs_type_rec.is_plan_fl = "T"
   then
      if not chk_plan()
      then
         call fg_er("Brak przypisanej pozycji planu na okres absencji !!!")
         let nxt_fld = scr_fld
         return
      end if
   end if

   # count absence days and hours
   if p_bsence.date_from is null
      or p_bsence.date_to is null
   then
      return
   end if

   call abs_count(p_bsence.addr_nr, p_bsence.abs_code,
                  p_bsence.date_from, p_bsence.date_to)
        returning stat, p_bsence.abs_days, p_bsence.abs_hours,
                  p_bsence.abs_work_days, p_bsence.abs_work_hours,
                  tmp_l_day_hours

   case stat
      when -1
         call fg_er("Brak pozycji w przebiegu zatrudnienia na okres absencji !!!")
         let nxt_fld = scr_fld
         return
      when -2
         call fg_er("Przebieg zatrudnienia nie pokrywa ca³ego okresu absencji !!!")
         let nxt_fld = scr_fld
         return
      when -3
         call fg_er("Brak danych w DOR i kalendarzu dla okresu absencji !!!")
         let nxt_fld = scr_fld
         return
      when -4
         call fg_er("Brak danych w kalendarzu dla okresu absencji !!!")
         let nxt_fld = scr_fld
         return
      when -5
         call fg_er("Brak definicji wszystkich dni absencji w DOR i kalendarzu !!!")
         let nxt_fld = scr_fld
         return
      when -6
         call fg_er("Brak definicji wszystkich dni absencji w kalendarzu !!!")
         let nxt_fld = scr_fld
         return
   end case

   display by name p_bsence.abs_days, p_bsence.abs_hours,
                   p_bsence.abs_work_days, p_bsence.abs_work_hours
    attribute(red)

   call abs_limit_check(p_bsence.abs_code, abs_type_rec.abs_period_dc,
                        abs_type_rec.abs_limit, abs_type_rec.is_hours_fl,
                        abs_type_rec.day_hours, tmp_abs_num,
                        p_bsence.addr_nr, p_bsence.date_from,
                        p_bsence.date_to, p_bsence.abs_days,
                        p_bsence.abs_hours, 0)
        returning stat, p_bsence.days_avail_limit, p_bsence.days_used_limit,
                  p_bsence.hours_avail_limit, p_bsence.hours_used_limit,
                  p_bsence.abs_hours, tmp_absgrp_code

   if p_bsence.abs_work_hours > p_bsence.abs_hours
   then
      let p_bsence.abs_work_hours = p_bsence.abs_hours
   end if


   display by name p_bsence.days_avail_limit, p_bsence.days_used_limit,
                   p_bsence.hours_avail_limit, p_bsence.hours_used_limit,
                   p_bsence.abs_hours, p_bsence.abs_work_hours
    attribute(red)

   case stat
      when -1
         call fg_er("Przekroczony limit dla kodu absencji !!!")
         let nxt_fld = scr_fld
         return
      when -2
         call fg_er("UWAGA - niepe³ny ostatni dzieñ absencji !!!")
      when -3
         call fg_er("Przekroczony indywidualny limit dla kodu absencji !!!")
         let nxt_fld = scr_fld
         return
      when -11
         let scratch = "Przekroczony limit dla grupy absencji '",
                       tmp_absgrp_code clipped, "' !!!"
         call fg_er(scratch clipped)
         let nxt_fld = scr_fld
         return
      when -12
         let scratch = "Przekroczony indywidualny limit dla grupy absencji '",
                       tmp_absgrp_code clipped, "' !!!"
         call fg_er(scratch clipped)
         let nxt_fld = scr_fld
         return
   end case

end function
# chk_absence()


######################################################################
function cnt_pay_rates(a_abs_num)
######################################################################
#
define
   a_abs_num   integer

   if pay_rates_prep is null
   then
      let pay_rates_prep = "Y"

      let scratch = "select count(*) from pn_absen_rates",
                   " where pn_absen_rates.abs_num = ? ",
                     " and (pn_absen_rates.pay_month is not null",
                          " or pn_absen_rates.pay_amount is not null)"
      prepare cnt_payrates_s from scratch
      declare cnt_payrates_c cursor for cnt_payrates_s
   end if

   open cnt_payrates_c using a_abs_num
   fetch cnt_payrates_c into s_cnt_payrates
   close cnt_payrates_c

   return s_cnt_payrates

end function
# cnt_pay_rates()


######################################################################
function get_pay_rates()
######################################################################
#

   return 0
   #return s_cnt_payrates

end function
# get_pay_rates()


######################################################################
function update_limit(a_addr_nr, a_abs_code, a_abs_year)
######################################################################
#
define
   a_addr_nr         like pn_absence.addr_nr,
   a_abs_code        like pn_absence.abs_code,
   a_abs_year        smallint,
   l_abs_period_dc   like pn_abs_type.abs_period_dc,
   l_limchk_rec      record
                        abs_code like pn_absence.abs_code,
                        abs_period_dc like pn_abs_type.abs_period_dc,
                        abs_limit like pn_abs_type.abs_limit,
                        is_hours_fl like pn_abs_type.is_hours_fl,
                        day_hours like pn_abs_type.day_hours,
                        abs_num like pn_absence.abs_num,
                        addr_nr like pn_absence.addr_nr,
                        date_from like pn_absence.date_from,
                        date_to like pn_absence.date_to,
                        abs_days like pn_absence.abs_days,
                        abs_hours like pn_absence.abs_hours
                     end record,
   l_absgrp_code     like pn_absgrp_pos.abs_code,
   stat              integer,
   l_limit_type_fl   char(1),
   l_abs_found_fl    smallint

   if upd_limit_prep is null
   then
      let upd_limit_prep = "Y"

      let scratch = "select pn_absence.abs_code,",
                    " pn_abs_type.abs_period_dc,",
                    " pn_abs_type.abs_limit,",
                    " pn_abs_type.is_hours_fl,",
                    " pn_abs_type.day_hours,",
                    " pn_absence.abs_num,",
                    " pn_absence.addr_nr,",
                    " pn_absence.date_from,",
                    " pn_absence.date_to,",
                    " pn_absence.abs_days,",
                    " pn_absence.abs_hours",
                   " from pn_absence, pn_abs_type",
                   " where pn_absence.addr_nr = ? ",
                     " and pn_absence.abs_code = ? ",
# NKP KO 2006.01.16
                     " and year(pn_absence.date_to) <= ? ",
# end NKP KO 2006.01.16
                     " and pn_abs_type.abs_code = pn_absence.abs_code",
                   " order by pn_absence.date_from desc"
      prepare g_absence_s from scratch
      declare g_absence_c cursor for g_absence_s

      let scratch = "select pn_absgrp_pos.absgrp_code",
                   " from pn_absgrp_pos",
                   " where pn_absgrp_pos.abs_code = ? "
      prepare g_absgrp_s from scratch
      declare g_absgrp_c cursor for g_absgrp_s

      let scratch = "select pn_absence.abs_code,",
                    " pn_abs_type.abs_period_dc,",
                    " pn_abs_type.abs_limit,",
                    " pn_abs_type.is_hours_fl,",
                    " pn_abs_type.day_hours,",
                    " pn_absence.abs_num,",
                    " pn_absence.addr_nr,",
                    " pn_absence.date_from,",
                    " pn_absence.date_to,",
                    " pn_absence.abs_days,",
                    " pn_absence.abs_hours",
                   " from pn_absgrp_pos, pn_absence, pn_abs_type",
                   " where pn_absgrp_pos.absgrp_code = ? ",
                     " and pn_absence.abs_code = pn_absgrp_pos.abs_code",
                     " and pn_absence.addr_nr = ? ",
# NKP KO 2006.01.16
                     " and year(pn_absence.date_to) <= ? ",
# end NKP KO 2006.01.16
                     " and pn_abs_type.abs_code = pn_absence.abs_code",
                   " order by pn_absence.date_from desc"
      prepare g_grpabsen_s from scratch
      declare g_grpabsen_c cursor for g_grpabsen_s

      let scratch = "update pn_absli_pos",
                   " set",
                     " pn_absli_pos.used_limit = 0 ",
                   " where pn_absli_pos.limit_num = ",
                         " (select pn_absli_head.limit_num",
                          " from pn_absli_head",
                          " where pn_absli_head.addr_nr = ? ",
                            " and pn_absli_head.limit_type_fl = ? ",
                            " and pn_absli_head.limit_code = ? )",
                     " and pn_absli_pos.limit_year is null"
      prepare u_absli_pos1_s from scratch

      let scratch = "update pn_absli_pos",
                   " set",
                     " pn_absli_pos.used_limit = 0 ",
                   " where pn_absli_pos.limit_num = ",
                         " (select pn_absli_head.limit_num",
                          " from pn_absli_head",
                          " where pn_absli_head.addr_nr = ? ",
                            " and pn_absli_head.limit_type_fl = ? ",
                            " and pn_absli_head.limit_code = ? )",
                     " and pn_absli_pos.limit_year = ? "
      prepare u_absli_pos2_s from scratch
   end if

   let l_abs_period_dc = 0
   select pn_abs_type.abs_period_dc
   into l_abs_period_dc
   from pn_abs_type
   where pn_abs_type.abs_code = a_abs_code

   let l_limit_type_fl = "G"
   let l_abs_found_fl = false

   open g_absgrp_c using a_abs_code
   while true
      fetch g_absgrp_c into l_absgrp_code
      if sqlca.sqlcode = notfound
      then
         exit while
      end if

      open g_grpabsen_c using l_absgrp_code, a_addr_nr, a_abs_year
      fetch g_grpabsen_c into l_limchk_rec.*
      let stat = sqlca.sqlcode
      close g_grpabsen_c

      if stat != notfound
# NKP KO 2006.01.16
         and (l_abs_period_dc != 2
              or year(l_limchk_rec.date_from) = a_abs_year)
# end NKP KO 2006.01.16
      then
         call abs_limit_check(l_limchk_rec.*, 0)
          returning scratch, scratch, scratch, scratch,
                    scratch, scratch, scratch
      else
		 # NKP KO 2006.01.16
		          #if not l_abs_found_fl
		          #   and l_limchk_rec.abs_code = a_abs_code
		          #then
		          #   let l_abs_found_fl = true
		          #end if
		 # end NKP KO 2006.01.16
         case l_abs_period_dc
            when 1
               execute u_absli_pos1_s using a_addr_nr, l_limit_type_fl,
                                            l_absgrp_code
            when 2
               execute u_absli_pos2_s using a_addr_nr, l_limit_type_fl,
                                            l_absgrp_code, a_abs_year
         end case
      end if

   end while
   close g_absgrp_c

   if not l_abs_found_fl
   then
      let l_limit_type_fl = "A"

      open g_absence_c using a_addr_nr, a_abs_code, a_abs_year
      fetch g_absence_c into l_limchk_rec.*
      let stat = sqlca.sqlcode
      close g_absence_c

      if stat != notfound
# NKP KO 2006.01.16
         and (l_abs_period_dc != 2
              or year(l_limchk_rec.date_from) = a_abs_year)
# end NKP KO 2006.01.16
      then
         call abs_limit_check(l_limchk_rec.*, 0)
          returning scratch, scratch, scratch, scratch,
                    scratch, scratch, scratch
      else
         case l_abs_period_dc
            when 1
               execute u_absli_pos1_s using a_addr_nr, l_limit_type_fl,
                                            a_abs_code
            when 2
               execute u_absli_pos2_s using a_addr_nr, l_limit_type_fl,
                                            a_abs_code, a_abs_year
         end case
      end if
   end if

end function
# update_limit()


######################################################################
function dline_browse(line_no)
######################################################################
define
    line_no     smallint,
    ring_rowid  integer,
    ret_str     char(76)

if line_no = 0
then
    return 0,
" Numer      Nazwisko                   Kod absencji  Absencja od-do"
end if
#  Numer      Nazwisko                   Kod absencji  Absencja od-do
# [A1     ] [A2                       ] [A3   ]     [A4        ]-[A5        ]


call ring_fetch(line_no) returning ring_rowid

let ret_str =" ",
            p_bsence.addr_nr using "#######", "   ",
            p_bsence.name_1[1,25], "   ",
            p_bsence.abs_code, "       ",
            p_bsence.date_from, " - ",
            p_bsence.date_to

return ring_rowid, ret_str

end function
# dline_browse()

