######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################

# mlh_curs.4gl
# This file contains all of the logic for the browse cursor
# implimentation.
# The calls to these functions are designed to replace the local
# mlh_define/fetch/close_cur functions.

globals "globals.4gl"

define
    t_limit_prep    char(1),
    table_list      char(512),      # table list in 'from' clausule
    join_filter     char(2048),     # select join criteria
    sel_filter      char(2048),     # select criteria for current screen form
    pn_absen_cond   char(2048),     # filter for 'pn_absen' screen
    pn_absra_cond   char(2048),     # filter for 'pn_absra' screen
    pn_absba_cond   char(2048),     # filter for 'pn_absba' screen
    pn_absho_cond   char(2048),     # filter for 'pn_absho' screen
    cur_scr_id      smallint,       # current screen form id
    max_forms       smallint,       # number of screen forms
    form_tab        array[20] of
                       record
                          form_name   char(20),
                          table_list  char(128),
                          join_cond   char(512)
                       end record,
    fld_help_buff   char(80),       # Help     field buffer
    is_open char(1),                # (boolean) Is the browse table open?
    arr_mesgs array[3] of record    # Message text
        mssg_text char(132)
    end record,
    mssg_prep char(1)               # Y/null Message cursor prepared?


######################################################################
function mlh_define_cur(criteria)
######################################################################
# This function is called when a browse cursor needs to be defined.
# If it is present in local code (not library), then it uses the old
# method of cursor manipulation.  If it isn't present in local code
# then this function is loaded & the temp table method is used.
#

    define
        sel_str  char(16384),  # select statment string
        criteria char(512),    # user defined portion of filter
        tab_name char(18),     # header table name
        detl_tab char(18),     # detail tables to be employed in SELECT
        join_str char(200),    # join criteria
        qry_dtl char(1),       # Y/N, query including detail?
        hard_filter char(512), # hardcoded filter
        sel_column char(10),   # seq_no or rowid (based on turbo or SE)
        row_id integer,        # current rowid being processed
        seq_no integer,        # row sequence number
        tmp_str char(19),      # tmp string holds detl_tab and "."
        newcode char(1),       # num_vararg
        c char(1),             # entry character
        m integer,             # generic counter
        n integer,             # generic counter
        z smallint             # generic counter

    # Trap fatal errors
    whenever error call error_handler

    # Initialize the display messages
    if mssg_prep is null
    then
        let mssg_prep = "Y"
        let arr_mesgs[1].mssg_text = fg_message("lib_scr","mlhcur",1)
        let arr_mesgs[2].mssg_text = fg_message("lib_scr","mlhcur",2)
        let arr_mesgs[3].mssg_text = fg_message("lib_scr","mlhcur",3)
    end if

    # Set to no rows found (if early exit)
    let sqlca.sqlerrd[3] = 0

    call mlh_cursor()

    # num_vararg() is used for backward compatibilty.
    # it can be either 3 or greater than 3.
    # >3 -- code is genned by new version.
    # 3 -- code is genned by old version.
    if num_vararg() > 3
      then let newcode = "Y"
      else let newcode = "N" end if

    # get 1.header tables, 2.hard_filter (put perfile),
    # 3.order (in perfile), 4.detail table (if is # header/detail),
    # 5.construct sql filter, 6.join
    let tab_name = get_vararg()
    let hard_filter = get_vararg()
    if sql_order is null or sql_order = " "
      then let sql_order = get_vararg()
      else let tmp_str = get_vararg()
    end if

    let detl_tab = null
    let join_str = null

    # to make this function backward compatible, only when
    # qry_dtl is "Y" we make the following assignments.
    if newcode = "Y"
    then
        let detl_tab = get_vararg()
        let join_str = get_vararg()
    end if

    let sql_filter = criteria

    # if detail tab name appears in the sql_filter string,
    # then we need to query in detail, set the flag.
    # the join string will be put in the query.
    # otherwise, join string will not be part of the query,
    # the query is only performed in header table.
    if length(detl_tab) > 0
    then
        let tmp_str = "*", detl_tab clipped, ".*"
        if sql_filter matches tmp_str
          then let qry_dtl = "Y"
          else let qry_dtl = "N"
        end if
    else
        let qry_dtl = null
    end if

    # Default hard_filter to "1 = 1" if appropriate
    if hard_filter = " " or hard_filter is null
      then let hard_filter = "1 = 1" end if

    # Set the default sql_filter and sql_order
    call lib_filtord()

    # Build the SQL string
    #let scratch = "select unique ", tab_name clipped, ".rowid"
    if qry_dtl = "Y"
    then
        let scratch = "select unique ", tab_name clipped, ".rowid"
    else
        let scratch = "select ", tab_name clipped, ".rowid"
    end if

    # Add the ordering columns
    if length(sql_order) = 0 or get_scrlib("mlh_order") = "N"
    then
    else
        # We have to remove any 'desc' portion of the order by string.
        let scratch = scratch clipped, ", ", tab_name clipped, "."
        let n = length(scratch) + 1
        for m = 11 to length(sql_order)
            # Bump up 'm' if 'desc' is found.
            if sql_order[m, m + 4] = " desc"
            then
                # Don't get fooled by " description" or " desc_a"
                if (sql_order[m + 5] >= "a" and sql_order[m + 5] <= "z")
                   or (sql_order[m + 5] =  "_")
                  then  # ' desc' is part of a column (or table) name
                  else let m = m + 5  # skip over the ' desc' keyword
                end if
            end if
            # Transfer the character from sql_order into scratch
            let scratch[n] = sql_order[m]
            let n = n + 1
        end for
    end if

    # Continue with the 'from' and 'where' portions of the SQL string.
    if qry_dtl = "Y"
    then
        let scratch = scratch clipped, " from ", tab_name clipped,
          ", ", detl_tab clipped, " where ", join_str clipped,
          " and ", hard_filter clipped, " and ", sql_filter clipped,
          " "#, sql_order clipped
    else
        let scratch = scratch clipped, " from ", tab_name clipped,
          " where ", hard_filter clipped, " and ", sql_filter clipped,
          " "#, sql_order clipped
    end if
    if get_scrlib("mlh_order") = "N"
    then
    else
        let scratch = scratch clipped, " ", sql_order clipped
    end if

    call build_join_filter()

    let sel_str = "select unique pn_absence.rowid,",
                   " pn_absence.addr_nr,",
                   " pn_absence.date_from",
                 " from pn_absence", table_list clipped,
                 " where 1=1",
                   " and ", join_filter clipped,
                   " and ", sql_filter clipped,
                   " and ", pn_absen_cond clipped,
                   " and ", pn_absra_cond clipped,
                   " and ", pn_absba_cond clipped,
                 " order by 2, 3 desc"

    # Convert the string into an SQL cursor
    #prepare brw_specs from scratch
    prepare brw_specs from sel_str
    declare brw_cursor scroll cursor with hold for brw_specs
    open brw_cursor

    # Drop the old temp table
    if is_open is not null then drop table browse end if

    {
    # Build the temp table
    let scratch =
      "create temp table browse(row_id integer, seq_no integer)"

    # Don't log the temp table if using transactions
    # (this works on 4.0 engines and above only)
    if is_trx() and is_4_0()
        then let scratch = scratch clipped, " with no log"
    end if
    prepare bld_tmp from scratch
    execute bld_tmp
    let is_open = "Y"

    # Build cursors on the temp table:

    # Declare an insert cursor for maximum efficiency
    let scratch = "insert into browse values(?, ?)"
    prepare ins_prep from scratch
    declare ins_cursor cursor for ins_prep

    # Determine the column to select on based on turbo running
    if is_turbo()
      then let sel_column = "seq_no"
      else let sel_column = "rowid"
    end if
    let scratch = "select row_id from browse where ",
      sel_column, " = ?"
    prepare fetch_stmt from scratch
    declare fetch_cur cursor for fetch_stmt

    open ins_cursor
    }

    # Here we go:  For each element returned, insert the
    # data into the temp table.

    let seq_no = 0
    while true
    fetch brw_cursor into row_id
        if sqlca.sqlcode != 0 or int_flag != 0 then exit while end if
        let seq_no = seq_no + 1
        let m = seq_no / 100
        if (m * 100) = seq_no
        then
            let scratch = arr_mesgs[3].mssg_text clipped,
                          seq_no using "<<<<<<<<<", ")"
            # Don't clear bottom line on successive calls
            if m > 100
              then let scratch[100, 104] = "no cl"
            end if
            call lib_message("scr_bottom")
        end if
        #put ins_cursor from row_id, seq_no
    end while

    # flush the cursor
    #close ins_cursor
    #close brw_cursor

    # Return the number of elements in the cursor
    let int_flag = 0
    let sqlca.sqlerrd[3] = seq_no

    return

end function
# mlh_define_cur()

######################################################################
function mlh_fetch_cur(curno)
# returning rowid in sqlca.sqlerrd[6]
######################################################################
#
    define
        curno integer,    # absolute cursor number
        row_id integer    # rowid to fetch

    #open fetch_cur using curno
    #fetch fetch_cur into row_id
    fetch absolute curno brw_cursor into row_id
    #close fetch_cur
    let sqlca.sqlerrd[6] = row_id
end function
# mlh_fetch_cur()

######################################################################
function mlh_close_cur()
######################################################################
#

    return

end function
# mlh_close_cur()



######################################################################
function mlh_init_forms()
######################################################################
#

  let max_forms = 4   # number of forms

  let form_tab[1].form_name = "pn_absen"
  let form_tab[1].table_list = ""
  let form_tab[1].join_cond  = ""

  let form_tab[2].form_name = "pn_absra"
  let form_tab[2].table_list = ""
  let form_tab[2].join_cond  = ""

  let form_tab[3].form_name = "pn_absba"
  let form_tab[3].table_list = ""
  let form_tab[3].join_cond  = ""

  let form_tab[4].form_name = "pn_absho"
  let form_tab[4].table_list = ""
  let form_tab[4].join_cond  = ""

end function
# mlh_init_forms()


######################################################################
function mlh_init_filters()
######################################################################
#

   let pn_absen_cond = " 1=1"
   let pn_absra_cond = " 1=1"
   let pn_absba_cond = " 1=1"
   let pn_absho_cond = " 1=1"

end function
# mlh_init_filters()


#####################################################################
function mlh_define_joins()
#####################################################################
#

define
   cur_scr     char(64)

   call mlh_clear_joins()

   let cur_scr = get_cur_screen()

   case
      ##########################
      when cur_scr = "pn_absen"
      ##########################
         if pn_absen_cond matches "*v_address*"
         then
            call mlh_set_table("v_address")
            call mlh_set_join("v_address.addr_nr = pn_absence.addr_nr")
         end if
         if pn_absen_cond matches "*pn_abs_type*"
         then
            call mlh_set_table("pn_abs_type")
            call mlh_set_join("pn_abs_type.abs_code = pn_absence.abs_code")
         end if
         if pn_absen_cond matches "*first_abs*"
         then
            call mlh_set_table("pn_absence first_abs")
            call mlh_set_join("first_abs.abs_num = pn_absence.first_abs_num")
         end if
         if pn_absen_cond matches "*doc_dict*"
         then
            call mlh_set_table("pn_dict_pos doc_dict")
            call mlh_set_join("doc_dict.type = 'abs_doc_type' and doc_dict.code = pn_absence.abs_doc_type_dc")
         end if
         if pn_absen_cond matches "*pn_absen_block*"
         then
            call mlh_set_table("pn_absen_block")
            call mlh_set_join("pn_absen_block.abs_num = pn_absence.abs_num")
         end if
         if pn_absen_cond matches "*block_dict*"
         then
            if not mlh_is_table_set("pn_absen_block")
            then
               call mlh_set_table("pn_absen_block")
               call mlh_set_join("pn_absen_block.abs_num = pn_absence.abs_num")
            end if
            call mlh_set_table("pn_dict_pos block_dict")
            call mlh_set_join("block_dict.type = 'block_cause' and block_dict.code = pn_absen_block.block_cause_dc")
         end if
      ##########################
      when cur_scr = "pn_absra"
      ##########################
         if pn_absra_cond matches "*v_address*"
         then
            call mlh_set_table("v_address")
            call mlh_set_join("v_address.addr_nr = pn_absence.addr_nr")
         end if
         if pn_absra_cond matches "*pn_abs_type*"
         then
            call mlh_set_table("pn_abs_type")
            call mlh_set_join("pn_abs_type.abs_code = pn_absence.abs_code")
         end if
         if pn_absra_cond matches "*first_abs*"
         then
            call mlh_set_table("pn_absence first_abs")
            call mlh_set_join("first_abs.abs_num = pn_absence.first_abs_num")
         end if
         if pn_absra_cond matches "*pn_absen_rates*"
         then
            call mlh_set_table("pn_absen_rates")
            call mlh_set_join("pn_absen_rates.abs_num = pn_absence.abs_num")
         end if
      ##########################
      when cur_scr = "pn_absba"
      ##########################
         if pn_absba_cond matches "*v_address*"
         then
            call mlh_set_table("v_address")
            call mlh_set_join("v_address.addr_nr = pn_absence.addr_nr")
         end if
         if pn_absba_cond matches "*pn_abs_type*"
         then
            call mlh_set_table("pn_abs_type")
            call mlh_set_join("pn_abs_type.abs_code = pn_absence.abs_code")
         end if
         if pn_absba_cond matches "*first_abs*"
         then
            call mlh_set_table("pn_absence first_abs")
            call mlh_set_join("first_abs.abs_num = pn_absence.first_abs_num")
         end if
         if pn_absba_cond matches "*pn_absen_bases*"
         then
            call mlh_set_table("pn_absen_bases")
            call mlh_set_join("pn_absen_bases.abs_num = pn_absence.abs_num")
         end if
      ##########################
      when cur_scr = "pn_absho"
      ##########################
         if pn_absho_cond matches "*v_address*"
         then
            call mlh_set_table("v_address")
            call mlh_set_join("v_address.addr_nr = pn_absence.addr_nr")
         end if
         if pn_absho_cond matches "*pn_abs_type*"
         then
            call mlh_set_table("pn_abs_type")
            call mlh_set_join("pn_abs_type.abs_code = pn_absence.abs_code")
         end if
         if pn_absho_cond matches "*first_abs*"
         then
            call mlh_set_table("pn_absence first_abs")
            call mlh_set_join("first_abs.abs_num = pn_absence.first_abs_num")
         end if
         if pn_absho_cond matches "*pn_absen_hours*"
         then
            call mlh_set_table("pn_absen_hours")
            call mlh_set_join("pn_absen_hours.abs_num = pn_absence.abs_num")
         end if
      otherwise
         # nothing to do
   end case

end function
# mlh_define_joins()


######################################################################
function mlh_clear_joins()
######################################################################
#
  define
        i     smallint

  for i = 1 to max_forms
     let form_tab[i].table_list = ""
     let form_tab[i].join_cond  = ""
  end for

end function
# mlh_clear_joins()


######################################################################
function mlh_set_table(tab_name)
######################################################################
#
  define
        tab_name    char(64)


  let form_tab[cur_scr_id].table_list = form_tab[cur_scr_id].table_list clipped,
                                        ", ", tab_name

end function
# mlh_set_table()


######################################################################
function mlh_is_table_set(tab_name)
######################################################################
#
define
   tab_name   char(64),
   tmp_cond   char(66)

   let tmp_cond = "*", tab_name clipped, "*"

   if form_tab[cur_scr_id].table_list matches tmp_cond clipped
   then
      return true
   end if

   return false

end function
# mlh_is_table_set()


######################################################################
function mlh_set_join(join_cond)
######################################################################
#
  define
        join_cond    char(512)


  let form_tab[cur_scr_id].join_cond = form_tab[cur_scr_id].join_cond clipped,
                                       " and ", join_cond

end function
# mlh_set_join()


#####################################################################
function mlh_set_scr_id()
######################################################################
#

define
   cur_scr  char(64),
   i        smallint


   let cur_scr_id = 0
   let cur_scr = get_cur_screen()

   for i = 1 to max_forms
      if cur_scr = form_tab[i].form_name
      then
         let cur_scr_id = i
         exit for
      end if
   end for

end function
# mlh_set_scr_id()


######################################################################
function build_join_filter()
######################################################################
#
  define
        i     smallint


  let table_list  = ""
  let join_filter = "1=1"

  for i = 1 to max_forms
      if length(form_tab[i].table_list) <> 0 then
         let table_list  = table_list clipped, form_tab[i].table_list
         let join_filter = join_filter clipped, form_tab[i].join_cond
      end if
  end for

end function
# build_join_filter()


######################################################################
function mlh_construct()
######################################################################
#

define
   cur_scr   char(64)

   call mlh_set_scr_id()
   let cur_scr = get_cur_screen()

   case
      when cur_scr = "pn_absen"
         call Q_pn_absen()
      when cur_scr = "pn_absra"
         call Q_pn_absra()
      when cur_scr = "pn_absba"
         call Q_pn_absba()
      when cur_scr = "pn_absho"
         call Q_pn_absho()
      otherwise
         # nothing to do
   end case

   if not int_flag
   then
       call mlh_define_joins()
   end if

   return "1=1"

end function
# mlh_construct()


######################################################################
function Q_pn_absen()
######################################################################

   construct sel_filter
      on
        pn_absence.addr_nr, v_address.name_1,
        v_address.name_2, pn_absence.abs_code,
        pn_abs_type.abs_name, pn_absence.date_from,
        pn_absence.date_to, pn_absence.abs_days,
        pn_absence.abs_hours, pn_absence.abs_work_days,
        pn_absence.abs_work_hours, pn_absence.abs_absolute,
        pn_absence.abs_absol_days, pn_absence.first_abs_num,
        first_abs.abs_code, first_abs.date_from,
        first_abs.date_to, pn_absence.abs_doc_type_dc,
        doc_dict.descr, pn_absence.abs_stat_code,
        pn_absence.ins_ref_cd, pn_absence.ins_date,
        pn_absence.upd_ref_cd, pn_absence.upd_date,
        pn_absen_block.date_from, pn_absen_block.date_to,
        pn_absen_block.block_cause_dc, block_dict.descr
      from
        s_pnabsen.addr_nr, s_pnabsen.name_1,
        s_pnabsen.name_2, s_pnabsen.abs_code,
        s_pnabsen.abs_name, s_pnabsen.date_from,
        s_pnabsen.date_to, s_pnabsen.abs_days,
        s_pnabsen.abs_hours, s_pnabsen.abs_work_days,
        s_pnabsen.abs_work_hours, s_pnabsen.abs_absolute,
        s_pnabsen.abs_absol_days, s_pnabsen.first_abs_num,
        s_pnabsen.first_abs_code, s_pnabsen.first_date_from,
        s_pnabsen.first_date_to, s_pnabsen.abs_doc_type_dc,
        s_pnabsen.abs_doc_desc, s_pnabsen.abs_stat_code,
        s_pnabsen.ins_ref_cd, s_pnabsen.ins_date,
        s_pnabsen.upd_ref_cd, s_pnabsen.upd_date,
        s_dpnabsen.date_from, s_dpnabsen.date_to,
        s_dpnabsen.block_cause_dc, s_dpnabsen.block_cause_desc

      before field addr_nr
         call lib_message("zoom_on")

      after field addr_nr
         call lib_message("zoom_off")

      before field abs_code
         call lib_message("zoom_on")

      after field abs_code
         call lib_message("zoom_off")

      before field first_abs_num
         if length(get_fldbuf(s_pnabsen.addr_nr)) > 0
         then
            call lib_message("zoom_on")
         end if

      after field first_abs_num
         call lib_message("zoom_off")

      before field first_abs_code
         call lib_message("zoom_on")

      after field first_abs_code
         call lib_message("zoom_off")

      before field abs_doc_type_dc
         call lib_message("zoom_on")

      after field abs_doc_type_dc
         call lib_message("zoom_off")

      before field block_cause_dc
         call lib_message("zoom_on")

      after field block_cause_dc
         call lib_message("zoom_off")

      on key (f4)
         case
            when infield(addr_nr)
               if zoom("persz", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.addr_nr
               end if
            when infield(abs_code)
               call set_zoom_code_column("pn_abs_type.abs_code")
               call set_zoom_desc_column("pn_abs_type.abs_name")
               call set_zoom_sort_column("1 dummy")
               if f_std_zoom("pn_abs_type", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.abs_code
               end if
            when infield(first_abs_num)
                 and length(get_fldbuf(s_pnabsen.addr_nr)) > 0
               call set_zoom_code_column("pn_absence.abs_num")
               call set_zoom_desc_column("pn_absence.abs_code||' '||pn_absence.date_from||'-'||pn_absence.date_to")
               call set_zoom_sort_column("pn_absence.date_from desc")
               let scratch = get_fldbuf(s_pnabsen.addr_nr)
               let scratch = "pn_absence.addr_nr = ", scratch clipped
               call set_join_filter(scratch clipped)
               if f_std_zoom("pn_absence", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.first_abs_num
               end if
            when infield(first_abs_code)
               call set_zoom_code_column("pn_abs_type.abs_code")
               call set_zoom_desc_column("pn_abs_type.abs_name")
               call set_zoom_sort_column("1 dummy")
               if f_std_zoom("pn_abs_type", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.first_abs_code
               end if
            when infield(abs_doc_type_dc)
               call set_zoom_code_column("pn_dict_pos.code")
               call set_zoom_desc_column("pn_dict_pos.descr")
               call set_zoom_sort_column("1 dummy")
               call set_join_filter("pn_dict_pos.type = 'abs_doc_type'")
               if f_std_zoom("pn_dict_pos", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.abs_doc_type_dc
               end if
            when infield(block_cause_dc)
               call set_zoom_code_column("pn_dict_pos.code")
               call set_zoom_desc_column("pn_dict_pos.descr")
               call set_zoom_sort_column("1 dummy")
               call set_join_filter("pn_dict_pos.type = 'block_cause'")
               if f_std_zoom("pn_dict_pos", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_dpnabsen.block_cause_dc
               end if
         end case

   end construct

   if not int_flag
   then
      call mlh_init_filters()
      let pn_absen_cond = sel_filter
   end if

end function
# Q_pn_absen()


######################################################################
function Q_pn_absra()
######################################################################

   construct sel_filter
      on
        pn_absence.addr_nr, v_address.name_1,
        v_address.name_2, pn_absence.abs_code,
        pn_abs_type.abs_name, pn_absence.date_from,
        pn_absence.date_to, pn_absence.abs_days,
        pn_absence.abs_hours, pn_absence.first_abs_num,
        first_abs.abs_code, first_abs.date_from,
        first_abs.date_to, pn_absen_rates.date_from,
        pn_absen_rates.date_to, pn_absen_rates.block_cause_dc,
        pn_absen_rates.abs_days, pn_absen_rates.abs_cnt_days,
        pn_absen_rates.abs_cnt_fl, pn_absen_rates.abs_per_days,
        pn_absen_rates.abs_per_fl, pn_absen_rates.pay_amount,
        pn_absen_rates.pay_month, pn_absen_rates.abs_base,
        pn_absen_rates.abs_rate1, pn_absen_rates.abs_perc,
        pn_absen_rates.abs_rate2, pn_absen_rates.abs_rate3
      from
        s_pnabsen.addr_nr, s_pnabsen.name_1,
        s_pnabsen.name_2, s_pnabsen.abs_code,
        s_pnabsen.abs_name, s_pnabsen.date_from,
        s_pnabsen.date_to, s_pnabsen.abs_days,
        s_pnabsen.abs_hours, s_pnabsen.first_abs_num,
        s_pnabsen.first_abs_code, s_pnabsen.first_date_from,
        s_pnabsen.date_to, s_pnabsra.date_from,
        s_pnabsra.date_to, s_pnabsra.block_cause_dc,
        s_pnabsra.abs_days, s_pnabsra.abs_cnt_days,
        s_pnabsra.abs_cnt_fl, s_pnabsra.abs_per_days,
        s_pnabsra.abs_per_fl, s_pnabsra.pay_amount,
        s_pnabsra.pay_month, s_pnabsra.abs_base,
        s_pnabsra.abs_rate1, s_pnabsra.abs_perc,
        s_pnabsra.abs_rate2, s_pnabsra.abs_rate3


      before field addr_nr
         call lib_message("zoom_on")

      after field addr_nr
         call lib_message("zoom_off")

      before field abs_code
         call lib_message("zoom_on")

      after field abs_code
         call lib_message("zoom_off")

      before field first_abs_num
         if length(get_fldbuf(s_pnabsen.addr_nr)) > 0
         then
            call lib_message("zoom_on")
         end if

      after field first_abs_num
         call lib_message("zoom_off")

      before field first_abs_code
         call lib_message("zoom_on")

      after field first_abs_code
         call lib_message("zoom_off")

      before field block_cause_dc
         call lib_message("zoom_on")

      after field block_cause_dc
         call lib_message("zoom_off")

      on key (f4)
         case
            when infield(addr_nr)
               if zoom("persz", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.addr_nr
               end if
            when infield(abs_code)
               call set_zoom_code_column("pn_abs_type.abs_code")
               call set_zoom_desc_column("pn_abs_type.abs_name")
               call set_zoom_sort_column("1 dummy")
               if f_std_zoom("pn_abs_type", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.abs_code
               end if
            when infield(first_abs_num)
                 and length(get_fldbuf(s_pnabsen.addr_nr)) > 0
               call set_zoom_code_column("pn_absence.abs_num")
               call set_zoom_desc_column("pn_absence.abs_code||' '||pn_absence.date_from||'-'||pn_absence.date_to")
               call set_zoom_sort_column("pn_absence.date_from desc")
               let scratch = get_fldbuf(s_pnabsen.addr_nr)
               let scratch = "pn_absence.addr_nr = ", scratch clipped
               call set_join_filter(scratch clipped)
               if f_std_zoom("pn_absence", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.first_abs_num
               end if
            when infield(first_abs_code)
               call set_zoom_code_column("pn_abs_type.abs_code")
               call set_zoom_desc_column("pn_abs_type.abs_name")
               call set_zoom_sort_column("1 dummy")
               if f_std_zoom("pn_abs_type", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.first_abs_code
               end if
            when infield(block_cause_dc)
               call set_zoom_code_column("pn_dict_pos.code")
               call set_zoom_desc_column("pn_dict_pos.descr")
               call set_zoom_sort_column("1 dummy")
               call set_join_filter("pn_dict_pos.type = 'block_cause'")
               if f_std_zoom("pn_dict_pos", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsra.block_cause_dc
               end if
         end case

   end construct

   if not int_flag
   then
      call mlh_init_filters()
      let pn_absra_cond = sel_filter
   end if

end function
# Q_pn_absra()

######################################################################
function Q_pn_absba()
######################################################################

   construct sel_filter
      on
        pn_absence.addr_nr, v_address.name_1,
        v_address.name_2, pn_absence.abs_code,
        pn_abs_type.abs_name, pn_absence.date_from,
        pn_absence.date_to, pn_absence.abs_days,
        pn_absence.abs_hours, pn_absence.first_abs_num,
        first_abs.abs_code, first_abs.date_from,
        first_abs.date_to, pn_absen_bases.base_year,
        pn_absen_bases.base_month, pn_absen_bases.base_value1,
        pn_absen_bases.base_value2, pn_absen_bases.nom_days,
        pn_absen_bases.work_days
      from
        s_pnabsen.addr_nr, s_pnabsen.name_1,
        s_pnabsen.name_2, s_pnabsen.abs_code,
        s_pnabsen.abs_name, s_pnabsen.date_from,
        s_pnabsen.date_to, s_pnabsen.abs_days,
        s_pnabsen.abs_hours, s_pnabsen.first_abs_num,
        s_pnabsen.first_abs_code, s_pnabsen.first_date_from,
        s_pnabsen.date_to, s_pnabsba.base_year,
        s_pnabsba.base_month, s_pnabsba.base_value1,
        s_pnabsba.base_value2, s_pnabsba.nom_days,
        s_pnabsba.work_days
       
      before field addr_nr
         call lib_message("zoom_on")

      after field addr_nr
         call lib_message("zoom_off")

      before field abs_code
         call lib_message("zoom_on")

      after field abs_code
         call lib_message("zoom_off")

      before field first_abs_num
         if length(get_fldbuf(s_pnabsen.addr_nr)) > 0
         then
            call lib_message("zoom_on")
         end if

      after field first_abs_num
         call lib_message("zoom_off")

      before field first_abs_code
         call lib_message("zoom_on")

      after field first_abs_code
         call lib_message("zoom_off")

      on key (f4)
         case
            when infield(addr_nr)
               if zoom("persz", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.addr_nr
               end if
            when infield(abs_code)
               call set_zoom_code_column("pn_abs_type.abs_code")
               call set_zoom_desc_column("pn_abs_type.abs_name")
               call set_zoom_sort_column("1 dummy")
               if f_std_zoom("pn_abs_type", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.abs_code
               end if
            when infield(first_abs_num)
                 and length(get_fldbuf(s_pnabsen.addr_nr)) > 0
               call set_zoom_code_column("pn_absence.abs_num")
               call set_zoom_desc_column("pn_absence.abs_code||' '||pn_absence.date_from||'-'||pn_absence.date_to")
               call set_zoom_sort_column("pn_absence.date_from desc")
               let scratch = get_fldbuf(s_pnabsen.addr_nr)
               let scratch = "pn_absence.addr_nr = ", scratch clipped
               call set_join_filter(scratch clipped)
               if f_std_zoom("pn_absence", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.first_abs_num
               end if
            when infield(first_abs_code)
               call set_zoom_code_column("pn_abs_type.abs_code")
               call set_zoom_desc_column("pn_abs_type.abs_name")
               call set_zoom_sort_column("1 dummy")
               if f_std_zoom("pn_abs_type", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.first_abs_code
               end if
    
         end case

   end construct
    
   if not int_flag
   then
      call mlh_init_filters()
      let pn_absba_cond = sel_filter
   end if

end function
# Q_pn_absba()



######################################################################
function Q_pn_absho()
######################################################################

   construct sel_filter
      on
        pn_absence.addr_nr, v_address.name_1,
        v_address.name_2, pn_absence.abs_code,
        pn_abs_type.abs_name, pn_absence.date_from,
        pn_absence.date_to, pn_absence.abs_days,
        pn_absence.abs_hours, pn_absence.first_abs_num,
        first_abs.abs_code, first_abs.date_from,
        first_abs.date_to, pn_absen_hours.abs_day,
        pn_absen_hours.abs_hours
      from
        s_pnabsen.addr_nr, s_pnabsen.name_1,
        s_pnabsen.name_2, s_pnabsen.abs_code,
        s_pnabsen.abs_name, s_pnabsen.date_from,
        s_pnabsen.date_to, s_pnabsen.abs_days,
        s_pnabsen.abs_hours, s_pnabsen.first_abs_num,
        s_pnabsen.first_abs_code, s_pnabsen.first_date_from,
        s_pnabsen.date_to, s_pnabsho.abs_day,
        s_pnabsho.abs_hours
       
      before field addr_nr
         call lib_message("zoom_on")

      after field addr_nr
         call lib_message("zoom_off")

      before field abs_code
         call lib_message("zoom_on")

      after field abs_code
         call lib_message("zoom_off")

      before field first_abs_num
         if length(get_fldbuf(s_pnabsen.addr_nr)) > 0
         then
            call lib_message("zoom_on")
         end if

      after field first_abs_num
         call lib_message("zoom_off")

      before field first_abs_code
         call lib_message("zoom_on")

      after field first_abs_code
         call lib_message("zoom_off")

      on key (f4)
         case
            when infield(addr_nr)
               if zoom("persz", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.addr_nr
               end if
            when infield(abs_code)
               call set_zoom_code_column("pn_abs_type.abs_code")
               call set_zoom_desc_column("pn_abs_type.abs_name")
               call set_zoom_sort_column("1 dummy")
               if f_std_zoom("pn_abs_type", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.abs_code
               end if
            when infield(first_abs_num)
                 and length(get_fldbuf(s_pnabsen.addr_nr)) > 0
               call set_zoom_code_column("pn_absence.abs_num")
               call set_zoom_desc_column("pn_absence.abs_code||' '||pn_absence.date_from||'-'||pn_absence.date_to")
               call set_zoom_sort_column("pn_absence.date_from desc")
               let scratch = get_fldbuf(s_pnabsen.addr_nr)
               let scratch = "pn_absence.addr_nr = ", scratch clipped
               call set_join_filter(scratch clipped)
               if f_std_zoom("pn_absence", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.first_abs_num
               end if
            when infield(first_abs_code)
               call set_zoom_code_column("pn_abs_type.abs_code")
               call set_zoom_desc_column("pn_abs_type.abs_name")
               call set_zoom_sort_column("1 dummy")
               if f_std_zoom("pn_abs_type", "1=1")
               then
                  let fld_help_buff = scratch
                  display fld_help_buff to s_pnabsen.first_abs_code
               end if
    
         end case

   end construct
    
   if not int_flag
   then
      call mlh_init_filters()
      let pn_absho_cond = sel_filter
   end if

end function
# Q_pn_absho()
