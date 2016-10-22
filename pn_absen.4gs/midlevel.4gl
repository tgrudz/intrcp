######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################
# Screen Generator version: 4.10.UC1

globals "globals.4gl"

define
    is_translated char(10),      # Was construct translated?
    num_trans smallint           # Number of translated fields

######################################################################
function mlh_init()
# returning the initial find group filter string.
######################################################################
# This function serves two purposes.
# It is called only once upon program invocation, so you may use
# it as a place to run initialization routines.
# It requires a return value of the default select group.
# examples of return values:
#   return "1=1" (select all rows)
#   return "1=0" (select no rows)
#   return "customer_num is not null" (select non-null customer_num's)
#   return "posted = \"N\"" (select only unposted documents)
#
    #_define_var - define local variables

    #_err - Trap fatal errors
    whenever error call error_handler

    #_ret - Return
    return "1=0"

end function
# mlh_init()

######################################################################
function mlh_clear()
######################################################################
# This function clears the program variables.
#
    #_define_var - define local variables

    #_init - Initialize variables
    initialize m_bsence.* to null    # clear the m_record
    initialize p_bsence.* to null # clear the p_record
    initialize q_bsence.* to null # clear the q_record

    #_setup_flag - Set the setup/defaulting flag
    let is_setup = "N"

end function
# mlh_clear()

######################################################################
function mld_clear()
######################################################################
# This function clears the program variables.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        n       smallint
    if do_scr_funct("clear") then
       return
    end if

    #_init - Initialize variables
    initialize m__block.* to null    # clear the m_record
    initialize p__block[1].* to null # clear the p_record
    initialize q__block[1].* to null # clear the q_record
    call set_count(rec1_cnt)

    #_clear_pq - clear p or q records
    for n = 2 to rec1_cnt
        let p__block[n].* = p__block[1].* # clear subsequent p_records
        let q__block[n].* = q__block[1].* # clear subsequent q_records
    end for
    let rec1_cnt = 0              # reset the active element counter


end function
# mld_clear()

######################################################################
function mlh_cursor()
######################################################################
# This function defines the table, filter, and ordering portions of
# the select statement used to build the FourGen scroller.
#

    #_define_var - define local variables

    #_curs_elements - Identify the cursor table, hard filter, and order

    #_table - cursor table
    call put_vararg("pn_absence")

    #_filter - filter statement
    call put_vararg("1=1")

    #_order - order statement
    call put_vararg("addr_nr, date_from desc")

    #_dtl_tab - detail table statement
    call put_vararg("pn_absen_block")

    #_join - join statement
    call put_vararg("pn_absen_block.abs_num=pn_absence.abs_num")

    #_translate - Tell upper level about translation
    call put_vararg(is_translated)
    call put_vararg(num_trans)


end function
# mlh_cursor()

######################################################################
function mld_scroll()
# returning true/false
######################################################################
# This function calls the display array.  If the user selects the row
# by pressing [ESC] or if they press [DEL] to cancel the operation,
# it informs the screen manager to exit this screen by setting
# int_flag to true.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        exit_type char(5)  # Exit types: quit or tab
    if do_scr_funct("display array") then
       return
    end if

    #_init - Initialize
    let exit_type = "quit"
    let scratch = "tab"

    #_ret - Return
    if rec1_cnt < 1 then return end if
    call set_count(rec1_cnt)

    #_display_array - Display the Zoom array
    display array p__block to s_dpnabsen.*
      attribute(red)

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
        #_hot_key - hot key map
        call hot_key("mld_scroll")  # Map the key to the event
        case
          when scr_funct = "accept"
            #_accept - when accept key is pressed
            exit display
          when scr_funct = "tab" or scr_funct = "btab"
            #_tab - when tab/btab key is pressed
            let exit_type = "tab"
            exit display
          when scr_funct = "cancel"
            #_cancel - when cancel key is pressed
            let int_flag = true
            exit display
          #_otherwise - otherwise clause
        end case

    #_end_dsp - end display array statement
    end display

    #_ret - Return
    let scratch = exit_type

end function
# mld_scroll()

######################################################################
function mld_arr_count()
######################################################################
# This function sets rec1_cnt to the correct number of array elements.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        n smallint
    if do_scr_funct("arr_count") then
       return
    end if

    call set_count(rec1_cnt)

    #_arr_count - Array count
    for n = arr_count() to 1 step -1
        if p__block[n].date_from is not null
          or p__block[n].date_to is not null
          or p__block[n].block_cause_dc is not null
          or p__block[n].block_cause_desc is not null
          or q__block[n].row_id is not null
        then
            let rec1_cnt = n
            return
        end if
    end for

    #_rec1_cnt - set rec1_cnt
    let rec1_cnt = 0

end function
# mld_arr_count()

######################################################################
function mlh_key()
# returning tablename, key_field [,key_field]... in (vararg) scratch
######################################################################
# This function returns (in vararg scratch) the name of the main table
# for this screen and the field name(s) and their data that build
# the unique key into this table.
# This is used to determine the unique key for additional fields,
# notes, and other items that may key off this document.  The key
# field(s) must not exceed 30 characters total.
# The first vararg call is the table name.  The following varargs are
# called in pairs.  The first of the pair is the column name, and
# the second in the pair is the column data.
#
    #_define_var - define local variables

    #_table - key table
    call put_vararg("pn_absence")

    #_col_abs_num - column name
    call put_vararg("abs_num")
    #_bsence_abs_num - column value
    call put_vararg(m_bsence.abs_num)

end function
# mlh_key()
