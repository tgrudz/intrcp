######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################
# Screen Generator version: 4.10.UC1

globals "globals.4gl"

#_local_static - Local (static) variable definition
define
    #_misc_static - Misc static variables
    tab_pressed smallint,# (boolean) was the tab pressed?
    lookup_prep char(1), # Lookups prepared?
    insert_prep char(1), # Insert statement prepared?
    select_prep char(1), # Select statement been prepared?
    dup_prep char(1),    # Duplicate check prepared?
    defaulted char(1),   # Defaulting done?
    read_prep char(1),   # Read statement prepared?
    write_prep char(1),  # Write statement prepared?
    exit_level smallint, # 0=input, 1=row, 2=field
    del_flag smallint,   # Insert after a delete?
    in_insert smallint,  # True if we're in 'insert row'
    arr_cnt integer,     # Active program array elements
    arr_max integer,     # Size of program array
    scr_max integer,     # Size of screen array
    first_show char(1),  # Call showdata on first call to showline
    open_level smallint  # Open window level

######################################################################
function lld_input()
######################################################################
# returning -1 if tab pressed (next window), 0 otherwise
# This is the main input function
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        goto_top  smallint   # (boolean) Go to the top

    #_err - Trap fatal errors
    whenever error call error_handler
    call turn_on_ins_key()
    call turn_on_del_key()

    if do_scr_funct("input")
    then
       if tab_pressed
         then return -1
         else return 0
       end if
    end if

    #_init - Initialize variables
    let goto_top = true
    let first_show = null

    #_before_input
        if get_pay_rates()
        then
           return -1
        end if
    #_end
    # This loop provides the ability to goto the top of the array.
    # Logic contained within the loop is not indented for readability.

    #_while - start while loop
    while goto_top

    let goto_top = false
    let in_insert = false
    let exit_level = 0
    let tab_pressed = false
    call set_count(rec1_cnt)
    #_input_array - Detail input array
    input array p__block without defaults from s_dpnabsen.*

    #_begin_input - The following section is for array type inputs

    #_bf_row - Before row logic
    before row
      if in_insert
      then
          # F1/F2 Scenario - fix parallel array if pre-informix 4.0
          if not is_4_0() and rec1_cnt > 0
            then call lld_a_delete() end if
          let in_insert = false  # Reset in_insert flag
      end if
      let scr_fld = ""           # Reset the current field
      let p_cur = arr_curr()     # Set the current array line
      let s_cur = scr_line()     # Set the current screen line
      let rec1_cnt = arr_count()  # Set the number of array elements
      call lld_b_row()
      goto next_field

    #_af_row - After row logic
    after row
      let del_flag = false
      call lld_showline()
      call lld_a_row()
      goto next_field

    #_bf_insert - Before insert logic
    before insert
      let in_insert = true
      let rec1_cnt = arr_count()  # Set the number of array elements
      call lld_b_insert()
      goto next_field

    #_af_insert - After insert logic
    after insert
      let in_insert = false
      call lld_a_insert()
      goto next_field

    #_bf_delete - Before delete logic
    before delete
      call lld_b_delete()
      goto next_field

    #_af_delete - After delete logic
    after delete
      let del_flag = true
      call lld_a_delete()
      goto next_field

      # All entry fields must have before and after field processing

      #_bf_field - Before field logic
      before field date_from call lld_b_field("pn_absen_block.date_from")
        goto next_field
      before field date_to call lld_b_field("pn_absen_block.date_to")
        goto next_field
      before field block_cause_dc call lld_b_field("pn_absen_block.block_cause_dc")
        goto next_field

      #_af_field - After field logic
      after field date_from call lld_a_field()
        goto next_field
      after field date_to call lld_a_field()
        goto next_field
      after field block_cause_dc call lld_a_field()
        goto next_field

      #_af_input - After input logic
      after input
        label end_input:
        let nxt_fld = null

        #_int_flag - Exit directly upon interrupt
        if int_flag
        then
            exit input
        end if

        #_run_afield - Run the 'after field' logic if necessary
        if exit_level >= 2 then call lld_a_field() end if
        if nxt_fld is not null then goto next_field end if

        #_ar_row - Run the 'after row' logic if necessary
        if exit_level >= 1 then call lld_a_row() end if
        if nxt_fld is not null then goto next_field end if

        #_goto_top - Don't run 'after input' logic if loop
        if goto_top then exit input end if

        #_run_ainput - Run the 'after input' logic before exiting input
        call lld_a_input()
        if nxt_fld is not null then goto next_field end if
        exit input

      #_on_key - Event trapping logic
      on key (control-b) let hotkey = 2  goto event
      on key (control-c) let hotkey = 3  goto event
      on key (control-e) let hotkey = 5  goto event
      on key (control-f) let hotkey = 6  goto event
      on key (control-g) let hotkey = 7  goto event
      on key (control-i) let hotkey = 9  goto event
      on key (control-n) let hotkey = 14 goto event
      on key (control-o) let hotkey = 15 goto event
      on key (control-p) let hotkey = 16 goto event
      on key (control-t) let hotkey = 20 goto event
      on key (control-u) let hotkey = 21 goto event
      on key (control-v) let hotkey = 22 goto event
      on key (control-w) let hotkey = 23 goto event
      on key (control-y) let hotkey = 25 goto event
      on key (control-z) let hotkey = 26 goto event
      on key (f1)  let hotkey = 101 goto event
      on key (f2)  let hotkey = 102 goto event
      on key (f3)  let hotkey = 103 goto event
      on key (f4)  let hotkey = 104 goto event
      on key (f5)  let hotkey = 105 goto event
      on key (f6)  let hotkey = 106 goto event
      on key (f7)  let hotkey = 107 goto event
      on key (f8)  let hotkey = 108 goto event
      on key (f9)  let hotkey = 109 goto event
      on key (f10) let hotkey = 110 goto event
      on key (f11) let hotkey = 111 goto event
      on key (f12) let hotkey = 112 goto event
      on key (f13) let hotkey = 113 goto event
      on key (f14) let hotkey = 114 goto event
      on key (f15) let hotkey = 115 goto event
      on key (f16) let hotkey = 116 goto event
      on key (f17) let hotkey = 117 goto event
      on key (f18) let hotkey = 118 goto event
      on key (f19) let hotkey = 119 goto event
      on key (f20) let hotkey = 120 goto event
      on key (f21) let hotkey = 121 goto event
      on key (f22) let hotkey = 122 goto event
      on key (f23) let hotkey = 123 goto event
      on key (f24) let hotkey = 124 goto event
      on key (f25) let hotkey = 125 goto event
      on key (f26) let hotkey = 126 goto event
      on key (f27) let hotkey = 127 goto event
      on key (f28) let hotkey = 128 goto event
      on key (f29) let hotkey = 129 goto event
      on key (f30) let hotkey = 130 goto event
      on key (f31) let hotkey = 131 goto event
      on key (f32) let hotkey = 132 goto event
      on key (f33) let hotkey = 133 goto event
      on key (f34) let hotkey = 134 goto event
      on key (f35) let hotkey = 135 goto event
      on key (f36,interrupt) let hotkey = 136 goto event

      #_on_event - Local event processing
      label event:
        #_hot_key - hot key
        call hot_key("lld_input")   # Map the key to the event
        #_hot_event - event handler
        call lld_event()

      #_nxt_fld - Programmatic next field logic
      label next_field:
        let scratch = nxt_fld
        let nxt_fld = null
        case
          when scratch is null  # No need to go through 'case'
          when scratch = "date_from" next field date_from
          when scratch = "date_to" next field date_to
          when scratch = "block_cause_dc" next field block_cause_dc
          when scratch = "block_cause_desc" next field block_cause_desc
          when scratch = "exit input" goto end_input
          when scratch = "event" goto event
          when scratch = "goto top"
              call mld_arr_count()
            let goto_top = true
            goto end_input
          #_otherwise - otherwise clause
        end case

    #_end_input - end input statement
    end input

    #_end_while - This is the end of the 'goto top' loop.
    end while

    #_tab_pressed - Return -1 if tab was pressed
    if tab_pressed
      then return -1
      else return 0
    end if

end function
# lld_input()

######################################################################
function lld_b_field(field_name)
######################################################################
# This func is called from the input func before every field
# The 'prv_fld' variable contains the field we came from
# The 'scr_fld' variable contains the field we're going into
# Set 'nxt_fld' if you want to skip this field or exit input
#
    #_define_var - define local variables
    define
        #_local_var - define local variables
        field_name char(40),  # Fieldname passed
        prv_fld char(40)      # The field we were just in

    #_init - Initialize
    let field_name = set_fldtab(field_name)

    #_fld_names - Rearrange field names
    let prv_fld = scr_fld
    let scr_fld = field_name
    let nxt_fld = null

    #_exit_level - Require field level exit
    let exit_level = 2

    #_bf_field - Before field logic
    case
      when scr_fld = "date_from"
        #_before_field date_from
        #_end
      when scr_fld = "date_to"
        #_before_field date_to
        #_end
      when scr_fld = "block_cause_dc"
        #_before_field block_cause_dc
        #_end
        let scratch = "zoom"
      #_otherwise - otherwise clause
    end case

    #_nxt_fld - Programmed exit
    if nxt_fld is not null then return end if

    #_lib_before - Setup for lib_before
    let scr_fld = prv_fld
    call lib_before(field_name)

end function
# lld_b_field()

######################################################################
function lld_a_field()
######################################################################
# This function is called after every field.
#
    #_define_var - define local variables

    #_init - Reset nxt_fld
    let nxt_fld = null

    #_exit_level - set exit level
    let exit_level = 1

    #_af_field - After field logic
    case
      when scr_fld = "date_from"
        #_after_field date_from
        #_end
      when scr_fld = "date_to"
        #_after_field date_to
        #_end
      when scr_fld = "block_cause_dc"
        #_after_field block_cause_dc
        #_end
      #_otherwise - otherwise clause
    end case

    #_nxt_fld Programmed exit
    if nxt_fld is not null then return end if

    #_lib_after - This (among other things) sets data_changed
    call lib_after()

    #_data_changed - After data_changed logic
    if data_changed
    then
        case
          when scr_fld = "date_from"
            #_after_change_in date_from
                if p__block[p_cur].date_from < p_bsence.date_from
                   or p__block[p_cur].date_from > p_bsence.date_to
                then
                   call fg_er("Nieprawid³owy przedzia³ daty !!!")
                   let nxt_fld = "date_from"
                end if
            #_end
          when scr_fld = "date_to"
            #_after_change_in date_to
                if p__block[p_cur].date_to < p_bsence.date_from
                   or p__block[p_cur].date_to > p_bsence.date_to
                then
                   call fg_er("Nieprawid³owy przedzia³ daty !!!")
                   let nxt_fld = "date_to"
                end if
            #_end
          when scr_fld = "block_cause_dc"
            # Perform lookups
            #_block_lk_block_cause_dc_lookup - Lookup block_lk for block_cause_dc
            if lld_lookup("block_lk", true) = false and
              length(this_data) != 0
            then
                let nxt_fld = "block_cause_dc"
                return
            end if
            #_after_change_in block_cause_dc
            #_end
          #_otherwise - otherwise clause
        end case
    end if
    if nxt_fld is not null
    then
       return
    end if
    call lld_req_dup_chk(scr_fld)

end function
# lld_a_field()

######################################################################
function lld_a_input()
######################################################################
# This function is called whenever the input statement exits
# (except due to an interrupt).  If you don't want the input session
# to end, set the nxt_fld variable to contain the field to be placed
# back into.
#
    #_define_var - define local variables

    #_after_input
    #_end

end function
# lld_a_input()

######################################################################
function lld_event()
######################################################################
# This function is called whenever the user presses an event key.
# The event is mapped to the 'scr_funct' variable and processed here.
#
    #_define_var - define local variables

    #_tab_pressed -  Reset tab pressed to false
    let tab_pressed = false

    #_on_event - Local event processing
    case
      #_zoom_block_cause_dc
      when scr_funct = "zoom" and infield(block_cause_dc)
         call set_zoom_code_column("code")
         call set_zoom_desc_column("pn_dict_pos.descr")
         call set_zoom_sort_column("1 dummy")
         call set_join_filter("pn_dict_pos.type = 'block_cause'")
         if f_std_zoom("pn_dict_pos", "1=1")
         then
            let p__block[p_cur].block_cause_dc = scratch
            let nxt_fld = "block_cause_dc"
         end if
      when scr_funct = "accept"
        #_accept - when accept key is pressed
        let nxt_fld = "exit input"
      when scr_funct = "tab" or scr_funct = "btab"
        #_tab - when tab/btab key is pressed
        let tab_pressed = true
        let nxt_fld = "exit input"
      when scr_funct = "cancel"
        #_cancel - when cancel key is pressed
        if no_cancel()
        then
            let int_flag = false
            let nxt_fld = null
        else
            let int_flag = true
            let nxt_fld = "exit input"
        end if
      otherwise
        #_otherwise - otherwise clause
    end case

    #_scr_funct - set screen function
    let scr_funct = ""

end function
# lld_event()

######################################################################
function lld_b_row()
######################################################################
# This func is called before you enter a new row.
#
    #_define_var - define local variables

    #_before_row
    #_end

end function
# lld_b_row()

######################################################################
function lld_a_row()
######################################################################
# This function is called whenever you leave a row.
#
    #_define_var - define local variables

    #_exit_level - No more exit levels required
    let exit_level = 0

    #_after_row
    #_end

end function
# lld_a_row()

######################################################################
function lld_b_insert()
######################################################################
# This func is called before a new row is added
#
    #_define_var - define local variables
    define
        #_local_var - define local variables
        n smallint   # Generic counter

    #_shift - Expand (shift) the parallel array
    for n = (rec1_cnt - 1) to p_cur step -1
        let q__block[n+1].* = q__block[n].*
    end for

    #_init - Blank out the current array element
    initialize q__block[p_cur].* to null

    #_defaults - Call function to default variables
    call lld_defaults()

    #_before_insert
    #_end

end function
# lld_b_insert()

######################################################################
function lld_a_insert()
######################################################################
# This func is called after a row has been added to array.
#
    #_define_var - define local variables

    #_after_insert
    #_end

end function
# lld_a_insert()

######################################################################
function lld_b_delete()
######################################################################
# This function is called when [F2] is pressed (del row),
# and before actual array elements have been shifted.
#
    #_define_var - define local variables

    #_before_delete
    #_end

end function
# lld_b_delete()

######################################################################
function lld_a_delete()
######################################################################
# This func is called when user presses [F2] (del a row),
# and after the actual array elements have been shifted.
# (rec1_cnt contains the num of elements before the delete)
#
    #_define_var - define local variables
    define
        #_local_var - define local variables
        n smallint   # Generic counter

    #_shift - Compress (shift) the parallel array
    for n = (p_cur + 1) to rec1_cnt
        let q__block[n-1].* = q__block[n].*
    end for

    #_init - Blank out the last (duplicate) data element
    initialize p__block[rec1_cnt].* to null
    initialize q__block[rec1_cnt].* to null

    #_math - Perform array math
    call llh_math()
    call llh_display()

    #_after_delete
    #_end

end function
# lld_a_delete()

######################################################################
function lld_read()
######################################################################
# This function reads the data from the disk into
# the program variables.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        row_id          integer          # rowid of fetched element
    if do_scr_funct("read")
    then
       return
    end if

    #_build_curs - Build the SQL string
    if select_prep is null
    then
        let select_prep = "Y"
        #_select - select statement
        let scratch = "select rowid, ",
            "abs_num,",
            "date_from,",
            "date_to,",
            "block_cause_dc ",
            " from pn_absen_block ",
            "where pn_absen_block.abs_num = ?",
            " and 1=1",
            " order by date_from"

        #_prep_curs - Prepare the SQL string for execution
        prepare read_specs from scratch
        declare d_cursor cursor for read_specs
    end if

    #_read_dtl - Read in the detail lines
    let p_cur = 0
    open d_cursor using m_bsence.abs_num

    #_read_data - Read in the detail data
    while true

        #_fetch - fetch statement
        fetch d_cursor into row_id,
            m__block.abs_num,
            m__block.date_from,
            m__block.date_to,
            m__block.block_cause_dc
        if sqlca.sqlcode = notfound then exit while end if
        let p_cur = p_cur + 1

        if p_cur > rec1_max
        then
            let sqlca.sqlcode = -1
            return
        end if
        #_on_disk_read
        #_end

        #_p_prep - P record prep
        call lld_p_prep(p_cur)

        let q__block[p_cur].row_id = row_id

    end while

    #_close_curs - close cursor statement
    close d_cursor
    let rec1_cnt = p_cur
    let p_cur = 1
    let s_cur = 1

    #_set_cnt - set record count
    call set_count(rec1_cnt)

end function
# lld_read()

######################################################################
function lld_setdata()
######################################################################
# This function is called to set the this_data global variable.
#
    #_define_var - define local variables
    define
       #_local_var - local variables
       tmp_str char(70)
    if do_scr_funct("set this_data")
    then
       return
    end if

    #_setdata - Set this_data variable
    case
      when scr_fld = "date_from"
        #_set_date_from
        call set_data(p__block[p_cur].date_from)
      when scr_fld = "date_to"
        #_set_date_to
        call set_data(p__block[p_cur].date_to)
      when scr_fld = "block_cause_dc"
        #_set_block_cause_dc
        call set_data(p__block[p_cur].block_cause_dc)
      #_otherwise - otherwise clause
    end case

end function
# lld_setdata()

######################################################################
function lld_high()
######################################################################
# This function highlights the specified field name.
# Only input type fields need to be specified.
#
    #_define_var - define local variables
    if do_scr_funct("highlight")
    then
       return
    end if

    #_highlight - Highlight current field data
    case
      when scr_fld = "date_from"
        #_dsp_date_from
        display p__block[p_cur].date_from
          to s_dpnabsen[s_cur].date_from attribute(reverse)
      when scr_fld = "date_to"
        #_dsp_date_to
        display p__block[p_cur].date_to
          to s_dpnabsen[s_cur].date_to attribute(reverse)
      when scr_fld = "block_cause_dc"
        #_dsp_block_cause_dc
        display p__block[p_cur].block_cause_dc
          to s_dpnabsen[s_cur].block_cause_dc attribute(reverse)
      #_otherwise - otherwise clause
    end case

end function
# lld_high()

######################################################################
function lld_display()
######################################################################
# This function displays the first screenful of data.
# Set $detl_display = current_context before code
# generation to take advantage the display of current
# context verses first page only
#
    #_define_var - define local variables
    define
        n        smallint, # working number
        m        smallint  # working number
    if do_scr_funct("showdata")
    then
       return
    end if

    #_start_elem - starting element for loop
    if p_cur > rec1_cnt
    then
        let p_cur = 1
        let s_cur = 1
    end if
    let m = p_cur - s_cur
    if m >= 0 then else let m = 0 end if

    #_display - Display the current screenful of data
    for n = 1 to scr1_max
        display p__block[m + n].* to s_dpnabsen[n].*  attribute(red)
    end for

end function
# lld_display()

######################################################################
function lld_showline()
######################################################################
# This function displays all p_* variables to the screen
#
    #_define_var - define local variables
    if do_scr_funct("showline")
    then
       return
    end if

    #_first_show - call showdata function on first call
    if first_show is null
    then
        let first_show = "Y"
        call lld_display()
        let p_cur = 1
    end if

    #_showdata - Display rows to detail screen
    display p__block[p_cur].* to s_dpnabsen[s_cur].* attribute(red)


end function
# lld_showline()

######################################################################
function lld_p_prep(n)
######################################################################
# This function creates the p_[]* record from the m_* record
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        n smallint      # Array element to process

    #_p_prep - P record setup
    let p__block[n].date_from = m__block.date_from
    let p__block[n].date_to = m__block.date_to
    let p__block[n].block_cause_dc = m__block.block_cause_dc

    #_pq_prep - Q record setup
    let q__block[n].abs_num = m__block.abs_num

    #_lookups - Perform lookups
    let p_cur = n
    if lld_lookup("block_lk",false) then end if

    #_on_screen_record_prep
    #_end

end function
# lld_p_prep()

######################################################################
function lld_m_prep(n)
######################################################################
# This function creates the m_* record from the specified element
# of the p_.* array, and from elements of the header that tie the
# detail lines to the header
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        n smallint      # Array element to process

    #_m_prep - M record setup
    let m__block.abs_num = q__block[n].abs_num

    #_join - Items from the header...
    let m__block.abs_num = m_bsence.abs_num

    #_mp_prep - Items from the p_ record array...
    let m__block.date_from = p__block[n].date_from
    let m__block.date_to = p__block[n].date_to
    let m__block.block_cause_dc = p__block[n].block_cause_dc
    #_on_disk_record_prep
    #_end

end function
# lld_m_prep()

######################################################################
function lld_delete()
######################################################################
# This function deletes the rows in the detail table
# that match the where clause
#
    #_define_var - define local variables
    if do_scr_funct("delete")
    then
       return
    end if

    #_delete - Delete the detail data
    delete from pn_absen_block
      where pn_absen_block.abs_num = m_bsence.abs_num
        and 1=1

      #_on_disk_delete
      #_end

end function
# lld_delete()

######################################################################
function lld_add()
######################################################################
# This function inserts data into the detail table.
#
    #_define_var - define local variables
    define
        n smallint  # Misc counter
    if do_scr_funct("write")
    then
       return
    end if

    #_insert_curs - Declare an insert cursor for maximum efficiency
    if insert_prep is null
    then
        let insert_prep = "Y"
        declare d_insert cursor for
            #_insert_row - Insert the new row
            insert into pn_absen_block (
                abs_num, date_from, date_to, block_cause_dc)
            values (
                m__block.abs_num, m__block.date_from, m__block.date_to,
                m__block.block_cause_dc)

    end if

    #_insert - Insert all array elements
    open d_insert
    for n = 1 to rec1_cnt
        if lld_empty_line(n)
        then
           continue for
        end if
        #_m_prep - call m_prep function
        call lld_m_prep(n)

        #_on_disk_add
        #_end

        put d_insert
    end for

    #_close_curs - close cursor statement
    close d_insert
    call mld_clear()
    call lld_read()
    call lld_display()

end function
# lld_add()

######################################################################
function lld_lookup(tbl_name, mustfind)
# returning false if notfound
######################################################################
# This is the lookup function.  It is passed a table to lookup, and
# based on that, it looks up the key and fills any variables for
# that table.  The lookup function will produce the error if it is
# called with mustfind=true, and a notfound situation exists.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        tbl_name char(18),  # Lookup table name
        stat integer,       # Value of sqlca.sqlcode after lookup
        mustfind smallint   # (boolean) produce an error if notfound?

    #_build_curs - Build the SQL string
    if lookup_prep is null
    then
        let lookup_prep = "Y"
        #_scratch_block_lk - set scratch for lookup block_lk
        let scratch = "select descr ",
          "from pn_dict_pos where ",
          " pn_dict_pos.type = \"block_cause\" and",
          " pn_dict_pos.code = ?"
        prepare str_block_lk from scratch
        declare cur_block_lk cursor for str_block_lk
    end if

    #_lookups - Perform the lookup
    case
    #_case_tbl_name - case table name statement
      #_bf_lkup_block_lk
      when tbl_name = "block_lk"
        #_af_lkup_block_lk
        open cur_block_lk using p__block[p_cur].block_cause_dc
        #_fetch - fetch the p record
        fetch cur_block_lk into p__block[p_cur].block_cause_desc
        let stat = sqlca.sqlcode
        close cur_block_lk
      #_otherwise - otherwise clause
    end case

    #_must_find -  No mustfind if this_data is empty
    if length(this_data) = 0 then let mustfind = false end if

    #_not_found - Send notfound message to user (if requested)
    let sqlca.sqlcode = stat
    if mustfind and stat = notfound
      then call scr_error("lookup=notfound",tbl_name)
    end if
    let sqlca.sqlcode = 0

    #_lkup_false - Return false if lookup failed and empty into fields
    if stat = notfound
    then
        case
        #_case_lkup_false - lookup false case
          #_bf_f_lkup_block_lk
          when tbl_name = "block_lk"
            #_af_f_lkup_block_lk
            #_initialize - initialize the p record
            initialize p__block[p_cur].block_cause_desc to null
          #_otherwise - otherwise clause
        end case
        return false
    else
        return true
    end if

end function
# lld_lookup()

######################################################################
function lld_defaults()
######################################################################
# This function performs defaulting of program variables
# based upon values placed in the default attribute
# of the perform file
#
    #_define_var

    #_defaults - Default program variables
    if menu_item = "add" and is_setup = "N"
    then
        #_dflt_flag - Reset the defaulting flag
        let is_setup = "Y"
    end if

end function
# lld_defaults()

######################################################################
function PR_detail()
######################################################################
# This function reads the p_ & q_ records from the temp table
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        get_name char(18),
        get_data char(250),
        get_index integer,
        get_status smallint
    if do_scr_funct("pread")
    then
       return
    end if

    #_set_status - Set initial status to true
    let get_status = true

    #_get_data -  Get the data from the temporary table
    while get_status
        call t_read() returning get_name, get_data, get_index, get_status
        case
          #_p_read - Read the P record
          when get_name = "date_from"
            let p__block[p_cur].date_from = get_data
          when get_name = "date_to"
            let p__block[p_cur].date_to = get_data
          when get_name = "block_cause_dc"
            let p__block[p_cur].block_cause_dc = get_data
          when get_name = "block_cause_desc"
            let p__block[p_cur].block_cause_desc = get_data

          #_q_read - Read the Q record
          when get_name = "abs_num"
            let q__block[p_cur].abs_num = get_data

          #_otherwise - otherwise clause
        end case
    end while

    #_lookups - Perform lookups
    if lld_lookup("block_lk",false) then end if

    #_on_program_read - program read

end function
# PR_detail()

######################################################################
function PW_detail()
######################################################################
# This function writes the p_ & q_ records to the temp table
#
    #_define_var - define local variables
    define
       #_local_var - local variables
       tmp_str char(70)
    if do_scr_funct("pwrite")
    then
       return
    end if

    #_p_write - Write the P record to the temp table
    call t_write(p_cur, "date_from", p__block[p_cur].date_from)
    call t_write(p_cur, "date_to", p__block[p_cur].date_to)
    call t_write(p_cur, "block_cause_dc", p__block[p_cur].block_cause_dc)
    call t_write(p_cur, "block_cause_desc", p__block[p_cur].block_cause_desc)

    #_q_write - Write the Q record
    call t_write(p_cur, "abs_num", q__block[p_cur].abs_num)

    #_on_program_write - program write

end function
# PW_detail()

######################################################################
function lld_skip(prv_fld)
######################################################################
# This function sets the global nxt_fld based on the
# value of prv_fld in order to skip the current field.
# It is designed to be called from the before field
# function. The global scr_fld must be set to the
# field.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        prv_fld char(18)  # Previous field name

    #_skip - Skip based on the current field.
    case
      #_date_from - Skip logic for date_from
      when scr_fld = "date_from"
        if prv_fld = "date_to" or prv_fld is null
          then let nxt_fld = "block_cause_dc"
          else let nxt_fld = "date_to"
        end if
      #_block_cause_dc - Skip logic for block_cause_dc
      when scr_fld = "block_cause_dc"
        if prv_fld = "date_from"
          then let nxt_fld = "date_to"
          else let nxt_fld = "date_from"
        end if
    end case

end function
# lld_skip()
######################################################################
function lld_req_dup_chk(scr_fld)
######################################################################
#
define
   scr_fld char(80)

   if after_row_occured(scr_fld = "block_cause_dc")
   then
      if not lld_empty_line(p_cur)
      then
         case
            when p__block[p_cur].date_from is null
               let nxt_fld = "date_from"
               call scr_error("required", nxt_fld)
            when p__block[p_cur].date_to is null
               let nxt_fld = "date_to"
               call scr_error("required", nxt_fld)
            when p__block[p_cur].block_cause_dc is null
               let nxt_fld = "block_cause_dc"
               call scr_error("required", nxt_fld)
         end case
      end if
      if nxt_fld is not null
      then
         return
      end if
      if not lld_dup_chk(p_cur)
      then
         #let nxt_fld = "code"
         return
      end if
   end if

end function
# lld_req_dup_chk()


######################################################################
function lld_empty_line(idx)
######################################################################
#
define
   idx smallint

   if p__block[idx].date_from is null
      and p__block[idx].date_to is null
      and p__block[idx].block_cause_dc is null
   then
      return true
   end if

   return false

end function
# lld_empty_line()


######################################################################
function lld_dup_chk(idx)
######################################################################
#
define
   idx smallint,
   i   smallint

   if p__block[idx].date_from > p__block[idx].date_to
   then
      call fg_er("Data pocz±tkowa jest wiêksza od daty ko\361c a okresu !!!")
      let nxt_fld = "date_from"
      return false
   end if

   for i = 1 to arr_count()
      if i != idx
      then
         if p__block[idx].date_from >= p__block[i].date_from
            and p__block[idx].date_from <= p__block[i].date_to
         then
            call fg_er("Okresy absencji pokrywaj\261 si\352 !!!")
            let nxt_fld = "date_from"
            return false
         end if
         if p__block[idx].date_to >= p__block[i].date_from
            and p__block[idx].date_to <= p__block[i].date_to
         then
            call fg_er("Okresy absencji pokrywaj\261 si\352 !!!")
            let nxt_fld = "date_to"
            return false
         end if
         if p__block[idx].date_from <= p__block[i].date_from
            and p__block[idx].date_to >= p__block[i].date_from
         then
            call fg_er("Okresy absencji pokrywaj\261 si\352 !!!")
            let nxt_fld = "date_to"
            return false
         end if
      end if
   end for

   return true

end function
# lld_dup_chk()
