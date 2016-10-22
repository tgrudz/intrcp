######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################
# Screen Generator version: 4.10.UC1

globals "globals.4gl"

#_local_static - Local (static) variables
define
        display_mode  char(1),
        p_fpnabsba    record
                         base_avg   like pn_absen_bases.base_value1,
                       amount       decimal(9,2),
                       suma         decimal(9,2),
                       year_from    smallint,
                       month_from   smallint,
                       year_to      smallint,
                       month_to     smallint, 
                         abs_rate   like pn_absen_rates.abs_rate1,
                         base_cnt   smallint
                      end record,
    p_pnabsba array[24] of record      # Record like the pnabsba screen
        base_year like pn_absen_bases.base_year,
        base_month like pn_absen_bases.base_month,
        base_value1 like pn_absen_bases.base_value1,
        base_value2 like pn_absen_bases.base_value2,
        nom_days like pn_absen_bases.nom_days,
        work_days like pn_absen_bases.work_days,
        include_fl char(1)
    end record,
    q_pnabsba array[24] of record      # Parallel pnabsba record
        row_id integer, # SQL rowid
        data_changed integer, # check for needed update
        abs_num like pn_absen_bases.abs_num
        #_define_1
        #_end
    end record,

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
    del_rows array[100] of integer,   # detail line maintenance
    del_cnt smallint,                 # counr of deleted rows
    join_elems array[20] of char(37), # join elements
    num_join_elems smallint,          # working number
    del_flag smallint,   # Insert after a delete?
    in_insert smallint,  # True if we're in 'insert row'
    arr_cnt integer,     # Active program array elements
    arr_max integer,     # Size of program array
    scr_max integer,     # Size of screen array
    first_show char(1),  # Call showdata on first call to showline
    open_level smallint  # Open window level

######################################################################
function S_pnabsba()
######################################################################
# This is a FourGen:Screen function switching mechanism.
# It's job is to route requests from the screen manager
# to the appropriate local function.
#
    #_define_var - define local variables
    define
        no_function smallint  # true if scr_funct not in case statement

    #_err - Trap fatal errors
    whenever error call error_handler

    #_flow_init - initialize flags
    let no_function = false

    #_switchbox - Screen switchbox function
    case
    #_case - case statement
      #_init - init function
      when scr_funct = "init" call A_pnabsba()        # Initialize screen
      #_read - read function
      when scr_funct = "read" call R_pnabsba()        # Read from disk
      #_write - write function
      when scr_funct = "write" call W_pnabsba()       # Write to disk
      #_clear - clear function
      when scr_funct = "clear" call C_pnabsba()       # Clear variables
      #_key - build key function
      when scr_funct = "build key" call K_pnabsba()   # Build unique key
      #_input - input function
      when scr_funct = "input" call I_pnabsba()       # Input data
      #_flow - flow function
      when scr_funct = "flow" call F_pnabsba()        # Flow Control
      #_pread - program read function
      when scr_funct = "pread" call PR_pnabsba()      # Read from program
      #_pwrite - program write function
      when scr_funct = "pwrite" call PW_pnabsba()     # Write to program
      #_setdata - set this data function
      when scr_funct = "set this_data" call SD_pnabsba()# Set 'this_data'
      #_showdata - showdata function
      when scr_funct = "showdata" call SH_pnabsba()  # Highlight a field
      #_showline - showline function
      when scr_funct = "showline" call SL_pnabsba()  # Highlight a field
      #_highlight - highlight function
      when scr_funct = "highlight" call HI_pnabsba()  # Highlight a field
      #_close - close function
      when scr_funct = "close" call Z_pnabsba()       # Close the object
      #_dsp_arr - display array function
      when scr_funct = "display array" call DS_pnabsba() # Display array
      #_arr_count - arr_count function
      when scr_funct = "arr_count" call AC_pnabsba()   # Compress detail lines
      #_otherwise - otherwise clause
      otherwise let no_function = true
    end case

    #_flow_close - check no_function status
    case
      #_no_function - no function found
      when no_function
        let scratch = "no function"
      #_reset - function was found, reset scratch
      when scratch = "no function"
        let scratch = null
      #_flow_close_otherwise - otherwise clause
    end case

end function
# S_pnabsba()

######################################################################
function A_pnabsba()
######################################################################
# This function opens and initializes the screen.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        y_pos smallint,  # window y position
        x_pos smallint   # window x position

    #_init - Initialize variables
    let open_level = open_level + 1
    let scr_max = 6
    let arr_max = 24
    let arr_cnt = arr_max
    let sql_order  = "base_year, base_month"

    #_before_init
        let display_mode = "N"
        return
    #_end

    #_open - Open the window and present the form
    if open_level = 1
    then
        #_window - window position
        call window_pos(2,3) returning y_pos, x_pos
        open window win_pnabsba at y_pos, x_pos
          #_form_path - path to screen form
          with form "pnabsba"
          #_end
          attribute (border, white)
    end if

    #_after_init
    #_end

end function
# A_pnabsba()

######################################################################
function C_pnabsba()
######################################################################
# This function clears the program variables.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        n       smallint

    #_init - Initialize variables
    initialize p_pnabsba[1].* to null # clear the p_record
    initialize q_pnabsba[1].* to null # clear the q_record

    #_clear_pq - clear p or q records
    for n = 2 to arr_cnt
        let p_pnabsba[n].* = p_pnabsba[1].* # clear subsequent p_records
        let q_pnabsba[n].* = q_pnabsba[1].* # clear subsequent q_records
    end for
    let arr_cnt = 0              # reset the active element counter
    initialize p_fpnabsba.* to null


end function
# C_pnabsba()

######################################################################
function K_pnabsba()
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

    #_key - Store the unique key
    call put_vararg("pn_absen_bases")


end function
# K_pnabsba()

######################################################################
function I_pnabsba()
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

    #_init - Initialize variables
    let goto_top = true
    let first_show = null
    let del_cnt = 0

    #_before_input - before input logic
        call turn_off_ins_key()
        call turn_off_del_key()
        if display_mode != "Y"
        then
        #   call turn_on_del_key()
        end if

    #_while - start while loop
    while goto_top

    let goto_top = false
    let in_insert = false
    let exit_level = 0
    let tab_pressed = false
    call set_count(arr_cnt)
    #_input_array - Detail input array
    input array p_pnabsba without defaults from s_pnabsba.*

    #_begin_input - The following section is for array type inputs

    #_bf_row - Before row logic
    before row
      if in_insert
      then
          # F1/F2 Scenario - fix parallel array if pre-informix 4.0
          if not is_4_0() and arr_cnt > 0
            then call AD_pnabsba() end if
          let in_insert = false  # Reset in_insert flag
      end if
      let scr_fld = ""           # Reset the current field
      let p_cur = arr_curr()     # Set the current array line
      let s_cur = scr_line()     # Set the current screen line
      let arr_cnt = arr_count()  # Set the number of array elements
      call BR_pnabsba()
      goto next_field

    #_af_row - After row logic
    after row
      let del_flag = false
      call SL_pnabsba()
      call AR_pnabsba()
      goto next_field

    #_bf_insert - Before insert logic
    before insert
      let in_insert = true
      let arr_cnt = arr_count()  # Set the number of array elements
      call BS_pnabsba()
      goto next_field

    #_af_insert - After insert logic
    after insert
      let in_insert = false
      call AS_pnabsba()
      goto next_field

    #_bf_delete - Before delete logic
    before delete
      call BD_pnabsba()
      goto next_field

    #_af_delete - After delete logic
    after delete
      let del_flag = true
      call AD_pnabsba()
      goto next_field

      # All entry fields must have before and after field processing

      #_bf_field - Before field logic
      before field base_year call BF_pnabsba("pn_absen_bases.base_year")
        goto next_field
      before field base_month call BF_pnabsba("pn_absen_bases.base_month")
        goto next_field
      before field base_value1 call BF_pnabsba("pn_absen_bases.base_value1")
        goto next_field
      before field base_value2 call BF_pnabsba("pn_absen_bases.base_value2")
        goto next_field
      before field nom_days call BF_pnabsba("pn_absen_bases.nom_days")
        goto next_field
      before field work_days call BF_pnabsba("pn_absen_bases.work_days")
        goto next_field

      #_af_field - After field logic
      after field base_year call AF_pnabsba()
        goto next_field
      after field base_month call AF_pnabsba()
        goto next_field
      after field base_value1 call AF_pnabsba()
        goto next_field
      after field base_value2 call AF_pnabsba()
        goto next_field
      after field nom_days call AF_pnabsba()
        goto next_field
      after field work_days call AF_pnabsba()
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
        if exit_level >= 2 then call AF_pnabsba() end if
        if nxt_fld is not null then goto next_field end if

        #_ar_row - Run the 'after row' logic if necessary
        if exit_level >= 1 then call AR_pnabsba() end if
        if nxt_fld is not null then goto next_field end if

        #_goto_top - Don't run 'after input' logic if loop
        if goto_top then exit input end if

        #_run_ainput - Run the 'after input' logic before exiting input
        call AI_pnabsba()
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
        call hot_key("I_pnabsba")   # Map the key to the event
        #_hot_event - event handler
        call EV_pnabsba()

      #_nxt_fld - Programmatic next field logic
      label next_field:
        let scratch = nxt_fld
        let nxt_fld = null
        case
          when scratch is null  # No need to go through 'case'
          when scratch = "base_year" next field base_year
          when scratch = "base_month" next field base_month
          when scratch = "base_value1" next field base_value1
          when scratch = "base_value2" next field base_value2
          when scratch = "nom_days" next field nom_days
          when scratch = "work_days" next field work_days
          when scratch = "include_fl" next field include_fl
          when scratch = "exit input" goto end_input
          when scratch = "event" goto event
          when scratch = "goto top"
              call AC_pnabsba()
            let goto_top = true
            goto end_input
          #_otherwise - otherwise clause
        end case

    #_end_input - end input statement
    end input

    #_end_while - This is the end of the 'goto top' loop.
    end while

end function
# I_pnabsba()

######################################################################
function BR_pnabsba()
######################################################################
# This func is called before you enter a new row.
#
    #_define_var - define local variables

    #_before_row
        if display_mode = "N"
        then
           call pnabsba_set_del_key()
        end if
    #_end

end function
# BR_pnabsba()

######################################################################
function AR_pnabsba()
######################################################################
# This function is called whenever you leave a row.
#
    #_define_var - define local variables

    #_exit_level - No more exit levels required
    let exit_level = 0

    #_after_row
    #_end

end function
# AR_pnabsba()

######################################################################
function BS_pnabsba()
######################################################################
# This func is called before a new row is added
#
    #_define_var - define local variables
    define
        #_local_var - define local variables
        n smallint   # Generic counter

    #_shift - Expand (shift) the parallel array
    for n = (arr_cnt - 1) to p_cur step -1
        let q_pnabsba[n+1].* = q_pnabsba[n].*
    end for

    #_init - Blank out the current array element
    initialize q_pnabsba[p_cur].* to null

    #_defaults - Call function to default variables
    call DF_pnabsba()

    #_before_insert
    #_end

end function
# BS_pnabsba()

######################################################################
function AS_pnabsba()
######################################################################
# This func is called after a row has been added to array.
#
    #_define_var - define local variables

    #_after_insert
    #_end

end function
# AS_pnabsba()

######################################################################
function BD_pnabsba()
######################################################################
# This function is called when [F2] is pressed (del row),
# and before actual array elements have been shifted.
#
    #_define_var - define local variables

    #_before_delete
    #_end

end function
# BD_pnabsba()

######################################################################
function AD_pnabsba()
######################################################################
# This func is called when user presses [F2] (del a row),
# and after the actual array elements have been shifted.
# (arr_cnt contains the num of elements before the delete)
#
    #_define_var - define local variables
    define
        #_local_var - define local variables
        n smallint   # Generic counter

    #_record_deletion - stores rowid of deleted record
    if q_pnabsba[p_cur].row_id > 0
    then
        let del_cnt = del_cnt + 1
        let del_rows[del_cnt] = q_pnabsba[p_cur].row_id
    end if

    #_shift - Compress (shift) the parallel array
    for n = (p_cur + 1) to arr_cnt
        let q_pnabsba[n-1].* = q_pnabsba[n].*
    end for

    #_init - Blank out the last (duplicate) data element
    initialize p_pnabsba[arr_cnt].* to null
    initialize q_pnabsba[arr_cnt].* to null

    #_after_delete
    #_end

end function
# AD_pnabsba()

######################################################################
function DS_pnabsba()
# returning true/false
######################################################################
# This function calls the display array.  If the user selects the row
# by pressing [ESC] or if they press [DEL] to cancel the operation,
# it informs the screen manager to exit this screen by setting
# int_flag to true.
#
    #_define_var - define local variables
    define
        s_input_num smallint,
        #_local_var - local variables
        exit_type char(5)  # Exit types: quit or tab

    #_init - Initialize
    let exit_type = "quit"


    #_display_array - Display the Zoom array
    display array p_pnabsba to s_pnabsba.*
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
        call hot_key("DS_pnabsba")  # Map the key to the event
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
# DS_pnabsba()

######################################################################
function BI_pnabsba()
######################################################################
# This function is called before the input statement
#
    #_define_var - define local variables

    #_before_input
    #_end

end function
# BI_pnabsba()

######################################################################
function AI_pnabsba()
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
# AI_pnabsba()

######################################################################
function BF_pnabsba(field_name)
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
      when scr_fld = "base_year"
        #_before_field base_year
        #_end
      when scr_fld = "base_month"
        #_before_field base_month
            if display_mode = "Y"
            then
               let nxt_fld = "base_year"
            end if
        #_end
      when scr_fld = "base_value1"
        #_before_field base_value1
        #_end
      when scr_fld = "base_value2"
        #_before_field base_value2
        #_end
      when scr_fld = "nom_days"
        #_before_field nom_days
        #_end
      when scr_fld = "work_days"
        #_before_field work_days
        #_end
      #_otherwise - otherwise clause
    end case

    #_nxt_fld - Programmed exit
    if nxt_fld is not null then return end if

    #_lib_before - Setup for lib_before
    let scr_fld = prv_fld
    call lib_before(field_name)

end function
# BF_pnabsba()

######################################################################
function AF_pnabsba()
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
      when scr_fld = "base_year"
        #_after_field base_year
            if display_mode = "Y"
            then
               let p_pnabsba[p_cur].base_year = prev_data
               if p_cur = arr_cnt
               then
                  if (fgl_lastkey() = fgl_keyval("down")) or
                     (fgl_lastkey() = fgl_keyval("nextpage"))
                  then
                      let nxt_fld = "date_from"
                      error " There are no more rows in the direction you are going "
                  end if
            #      if fgl_lastkey() <> fgl_keyval("interrupt")
            #         and fgl_lastkey() <> fgl_keyval("accept")
            #         and fgl_lastkey() <> fgl_keyval("up")
            #         and fgl_lastkey() <> fgl_keyval("prevpage")
            #         and fgl_lastkey() <> fgl_keyval("control-b")
            #      then
            #          let nxt_fld = "date_from"
            #      end if
               end if
               if (p_cur + scr_max) > arr_cnt
                  and fgl_lastkey() = fgl_keyval("nextpage")
               then
                   let nxt_fld = "base_year"
                   error " There are no more rows in the direction you are going "
               end if
            end if
        #_end
      when scr_fld = "base_month"
        #_after_field base_month
        #_end
      when scr_fld = "base_value1"
        #_after_field base_value1
        #_end
      when scr_fld = "base_value2"
        #_after_field base_value2
        #_end
      when scr_fld = "nom_days"
        #_after_field nom_days
        #_end
      when scr_fld = "work_days"
        #_after_field work_days
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
        if q_pnabsba[p_cur].row_id > 0
          then let q_pnabsba[p_cur].data_changed = true end if
        case
          when scr_fld = "base_year"
            #_after_change_in base_year
            #_end
          when scr_fld = "base_month"
            #_after_change_in base_month
            #_end
          when scr_fld = "base_value1"
            #_after_change_in base_value1
            #_end
          when scr_fld = "base_value2"
            #_after_change_in base_value2
            #_end
          when scr_fld = "nom_days"
            #_after_change_in nom_days
            #_end
          when scr_fld = "work_days"
            #_after_change_in work_days
            #_end
          #_otherwise - otherwise clause
        end case
    end if
    if nxt_fld is not null
    then
       return
    end if
    call pnabsba_req_dup_chk(scr_fld)

end function
# AF_pnabsba()

######################################################################
function EV_pnabsba()
######################################################################
# This function is called whenever the user presses an event key.
# The event is mapped to the 'scr_funct' variable and processed here.
#
    #_define_var - define local variables

    #_tab_pressed -  Reset tab pressed to false
    let tab_pressed = false

    #_on_event - Local event processing
    case
        when scr_funct = "btab"
          #_on_event btab
      if display_mode = "Y"
      then
         let nxt_fld = "exit input"
      end if
      when scr_funct = "accept"
        #_accept - when accept key is pressed
        let nxt_fld = "exit input"
      when scr_funct = "tab" or scr_funct = "btab"
        #_tab - when tab/btab key is pressed
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
# EV_pnabsba()

######################################################################
function SD_pnabsba()
######################################################################
# This function is called to set the this_data global variable.
#
    #_define_var - define local variables
    define
       #_local_var - local variables
       tmp_str char(70)

    #_setdata - Set this_data variable
    case
      when scr_fld = "base_year"
        #_set_base_year
        call set_data(p_pnabsba[p_cur].base_year)
      when scr_fld = "base_month"
        #_set_base_month
        call set_data(p_pnabsba[p_cur].base_month)
      when scr_fld = "base_value1"
        #_set_base_value1
        let tmp_str = dec_let(p_pnabsba[p_cur].base_value1)
        call set_data(tmp_str)
      when scr_fld = "base_value2"
        #_set_base_value2
        let tmp_str = dec_let(p_pnabsba[p_cur].base_value2)
        call set_data(tmp_str)
      when scr_fld = "nom_days"
        #_set_nom_days
        let tmp_str = dec_let(p_pnabsba[p_cur].nom_days)
        call set_data(tmp_str)
      when scr_fld = "work_days"
        #_set_work_days
        let tmp_str = dec_let(p_pnabsba[p_cur].work_days)
        call set_data(tmp_str)
      #_otherwise - otherwise clause
    end case

end function
# SD_pnabsba()

######################################################################
function HI_pnabsba()
######################################################################
# This function highlights the specified field name.
# Only input type fields need to be specified.
#
    #_define_var - define local variables

    #_highlight - Highlight current field data
    case
      when scr_fld = "base_year"
        #_dsp_base_year
        display p_pnabsba[p_cur].base_year
          to s_pnabsba[s_cur].base_year attribute(reverse)
      when scr_fld = "base_month"
        #_dsp_base_month
        display p_pnabsba[p_cur].base_month
          to s_pnabsba[s_cur].base_month attribute(reverse)
      when scr_fld = "base_value1"
        #_dsp_base_value1
        display p_pnabsba[p_cur].base_value1
          to s_pnabsba[s_cur].base_value1 attribute(reverse)
      when scr_fld = "base_value2"
        #_dsp_base_value2
        display p_pnabsba[p_cur].base_value2
          to s_pnabsba[s_cur].base_value2 attribute(reverse)
      when scr_fld = "nom_days"
        #_dsp_nom_days
        display p_pnabsba[p_cur].nom_days
          to s_pnabsba[s_cur].nom_days attribute(reverse)
      when scr_fld = "work_days"
        #_dsp_work_days
        display p_pnabsba[p_cur].work_days
          to s_pnabsba[s_cur].work_days attribute(reverse)
      #_otherwise - otherwise clause
    end case

end function
# HI_pnabsba()

######################################################################
function SH_pnabsba()
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

    #_start_elem - starting element for loop
    if p_cur > arr_cnt
    then
        let p_cur = 1
        let s_cur = 1
    end if
    let m = p_cur - s_cur
    if m >= 0 then else let m = 0 end if

    #_display - Display the current screenful of data
    for n = 1 to scr_max
        display p_pnabsba[m + n].* to s_pnabsba[n].*  attribute(red)
    end for
    call pnabsba_display_avg()

end function
# SH_pnabsba()

######################################################################
function SL_pnabsba()
######################################################################
# This function displays all p_* variables to the screen
#
    #_define_var - define local variables

    #_first_show - call showdata function on first call
    if first_show is null
    then
        let first_show = "Y"
        call SH_pnabsba()
        let p_cur = 1
    end if

    #_showdata - Display rows to detail screen
    display p_pnabsba[p_cur].* to s_pnabsba[s_cur].* attribute(red)


end function
# SL_pnabsba()

######################################################################
function F_pnabsba()
######################################################################
# This function is used as the custom data flow control manager
#
    #_define_var - define local variables

    #_flow - custom flow control manager

end function
# F_pnabsba()

######################################################################
function R_pnabsba()
######################################################################
# This function reads the data from the disk into
# the program variables.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        row_id          integer,         # rowid of fetched element
        passed_filter  char(512),        # passed filter
        passed_order   char(100),        # passed order elements
        x              smallint,         # working number
        n              smallint,         # working number
        m              smallint,          # working number

        wsk            integer,
        wsk_pocz       integer,
        wsk_kon        integer
        

    #_init - initialize variables
    let passed_filter = null
    let passed_order = null
    let num_join_elems = 0

    #_passed_arguments - collect the passed arguments
    let m = num_vararg()
    for n = 1 to m
        let scratch = get_vararg()  # tab_name is used for scratchpad

        #_soft_filter - retrieve soft filter if supplied
        if scratch = "filter"
        then
            let passed_filter = get_vararg()
            let n = n + 1
        end if

        #_soft_order - retrieve 'order by' if supplied
        if scratch = "order"
        then
            let passed_order = get_vararg()
            let n = n + 1
        end if

        #_join_elems - retrieve join element variables
        if scratch = "join_elems"
        then
            let x = n
            for n = (n + 1) to m
                let num_join_elems = num_join_elems + 1
                let join_elems[n - x] = get_vararg()
                if join_elems[n - x] is null
                  then return end if
            end for
        end if
    end for

    #_build_curs - Build the SQL string
    #_select - select statement
    let scratch = "select rowid, ",
        "abs_num,",
        "base_year,",
        "base_month,",
        "base_value1,",
        "base_value2,",
        "nom_days,",
        "work_days ",
        " from pn_absen_bases ",
        "where pn_absen_bases.abs_num = ?"

    #_append_soft_filter - filter set in vararg for this invocation
    if passed_filter is not null
      then let scratch = scratch clipped, passed_filter clipped
    end if

    #_if_soft_order - order by set in vararg for this invocation
    if passed_order is not null
    then
        let scratch = scratch clipped, " order by ",
            passed_order clipped
    else
        #_use_hard_order - as found in the pnabsba.per
        let scratch = scratch clipped, " order by base_year, base_month"
    end if

    #_prep_curs - Prepare the SQL string for execution
    prepare a_pnabsba from scratch
    declare c_pnabsba cursor for a_pnabsba

    #_read_dtl - Read in the detail lines
        let p_fpnabsba.base_avg = 0
        let p_fpnabsba.abs_rate = 0
        let p_fpnabsba.base_cnt = 0
        let p_cur = 1
        open c_pnabsba using m_bsence.abs_num

    #_read_data - Read in the detail data
    while true

        #_max_read - maximum number of elements read
        if p_cur = arr_max then exit while end if

        #_fetch - fetch statement
        fetch c_pnabsba into q_pnabsba[p_cur].row_id,
            q_pnabsba[p_cur].abs_num,
            p_pnabsba[p_cur].base_year,
            p_pnabsba[p_cur].base_month,
            p_pnabsba[p_cur].base_value1,
            p_pnabsba[p_cur].base_value2,
            p_pnabsba[p_cur].nom_days,
            p_pnabsba[p_cur].work_days
        if sqlca.sqlcode = notfound
        then
            let p_cur = p_cur - 1
            exit while
        end if
        #_on_disk_read
            let p_pnabsba[p_cur].include_fl = "N"
            if p_pnabsba[p_cur].base_value1 = -1
               or p_pnabsba[p_cur].base_value2 = -1
            then
               if p_pnabsba[p_cur].base_value1 = -1
               then
                  let p_pnabsba[p_cur].base_value1 = null
               end if
               if p_pnabsba[p_cur].base_value2 = -1
               then
                  let p_pnabsba[p_cur].base_value2 = null
               end if
            else
               if p_pnabsba[p_cur].base_value2 is not null
               then
                  let p_pnabsba[p_cur].include_fl = "T"
                  let p_fpnabsba.base_cnt = p_fpnabsba.base_cnt + 1
                  let p_fpnabsba.base_avg = p_fpnabsba.base_avg +
                                            p_pnabsba[p_cur].base_value2
               else
                  if p_pnabsba[p_cur].base_value1 is not null
                  then
                     let p_pnabsba[p_cur].include_fl = "T"
                     let p_fpnabsba.base_cnt = p_fpnabsba.base_cnt + 1
                     let p_fpnabsba.base_avg = p_fpnabsba.base_avg +
                                               p_pnabsba[p_cur].base_value1
                  end if
               end if
            end if
        #_end

        let p_cur = p_cur + 1

    end while

    #_close_curs - close cursor statement
    close c_pnabsba

### 30.10.2007
## Program czyta tabele pn_absen13 i pobiera (jesli sa) daty i kwote
## 1/12-13tki wyliczona przez uytkownika(odbruttowiona-zmienna akt_avg , amount)

        let wsk_pocz = year(p_bsence.date_from)*100+month(p_bsence.date_from)
        let wsk_kon =  year(p_bsence.date_to)  *100+month(p_bsence.date_to)

        let scratch = "select year_from ,month_from , year_to, ",
            " month_to , amount",  
            " from pn_absen13 ",
            "where pn_absen13.addr_nr= ?",
            " order by pn_absen13.year_from desc, pn_absen13.month_from desc"
  
           prepare  x_pnabsa from scratch
           declare xx_pnabsa cursor for x_pnabsa
 
           open xx_pnabsa using m_bsence.addr_nr

    while true

       fetch xx_pnabsa into p_fpnabsba.year_from,
             p_fpnabsba.month_from,p_fpnabsba.year_to,
             p_fpnabsba.month_to,p_fpnabsba.amount

          if sqlca.sqlcode = notfound
          then

              let p_fpnabsba.amount    = 0
              let p_fpnabsba.year_from  = null
              let p_fpnabsba.month_from = null
              let p_fpnabsba.year_to    = null
              let p_fpnabsba.month_to   = null
              exit while

          end if
{
          if wsk_kon > (p_fpnabsba.year_to*100+p_fpnabsba.month_to)
              then    ## brak kwoty 13-tki za podany okres
             let p_fpnabsba.amount   = 0
              let p_fpnabsba.year_from  = null
              let p_fpnabsba.month_from = null
              let p_fpnabsba.year_to    = null
              let p_fpnabsba.month_to   = null
              exit while
          end if
}
          if  wsk_pocz < p_fpnabsba.year_from*100+p_fpnabsba.month_from 
              then  ## dalej sprawdzaj
              else
               if wsk_pocz >= p_fpnabsba.year_from*100+p_fpnabsba.month_from and                  wsk_pocz <= p_fpnabsba.year_to*100+p_fpnabsba.month_to
                   then
                      if p_fpnabsba.base_avg=0 or p_fpnabsba.base_avg is null
                      then
                         
                         let p_fpnabsba.year_from  = null
                         let p_fpnabsba.month_from = null
                         let p_fpnabsba.year_to    = null
                         let p_fpnabsba.month_to   = null
                      end if
                      exit while
               else
                   let p_fpnabsba.amount = 0 
                   let p_fpnabsba.year_from  = null
                   let p_fpnabsba.month_from = null
                   let p_fpnabsba.year_to    = null
                   let p_fpnabsba.month_to   = null

                   exit while
               end if
          end if

        end while

       close xx_pnabsa

    let arr_cnt = p_cur
    let p_cur = 1
    let s_cur = 1
    if p_fpnabsba.base_cnt > 0
    then
       let p_fpnabsba.base_avg = p_fpnabsba.base_avg /
                                 p_fpnabsba.base_cnt
       let p_fpnabsba.abs_rate = (p_fpnabsba.base_avg+p_fpnabsba.amount) / 30
       let p_fpnabsba.suma = p_fpnabsba.base_avg + p_fpnabsba.amount

    else
       let p_fpnabsba.base_avg = null
       let p_fpnabsba.amount  = null
       let p_fpnabsba.abs_rate = null
    end if

    #_set_cnt - set record count
    call set_count(arr_cnt)

end function
# R_pnabsba()

######################################################################
function W_pnabsba()
######################################################################
# This function writes the program variables to disk.
#
    #_define_var - define local variables

    define
        n            smallint  # working number

    #_row_maintenance - either update or insert existing
    for p_cur = 1 to arr_cnt
        if pnabsba_empty_line(p_cur)
        then
           if q_pnabsba[p_cur].row_id > 0
           then
              delete from pn_absen_rates
              where pn_absen_rates.rowid = q_pnabsba[p_cur].row_id
           end if
           continue for
        end if
        #_update_check - check for update
        if q_pnabsba[p_cur].row_id > 0 and q_pnabsba[p_cur].data_changed
        then
            #_update - Update the existing row
            update pn_absen_bases set
                abs_num = q_pnabsba[p_cur].abs_num,
                base_year = p_pnabsba[p_cur].base_year,
                base_month = p_pnabsba[p_cur].base_month,
                base_value1 = p_pnabsba[p_cur].base_value1,
                base_value2 = p_pnabsba[p_cur].base_value2,
                nom_days = p_pnabsba[p_cur].nom_days,
                work_days = p_pnabsba[p_cur].work_days
            where rowid = q_pnabsba[p_cur].row_id
        end if

        #_insert_check - check for insert
        if q_pnabsba[p_cur].row_id = 0 or q_pnabsba[p_cur].row_id is null
        then
            #_join_elems - prep the join elements
                let q_pnabsba[p_cur].abs_num = m_bsence.abs_num
            #_insert_row - Insert the new row
            insert into pn_absen_bases (
                abs_num, base_year, base_month, base_value1,
                base_value2, nom_days, work_days)
            values (
                q_pnabsba[p_cur].abs_num, p_pnabsba[p_cur].base_year,
                p_pnabsba[p_cur].base_month,
                p_pnabsba[p_cur].base_value1,
                p_pnabsba[p_cur].base_value2,
                p_pnabsba[p_cur].nom_days, p_pnabsba[p_cur].work_days)

        end if
    end for

    #_row_deletion - delete all rows that where marked for deletion
    for n = 1 to del_cnt
        #_delete_row - delete this row
        delete from pn_absen_bases where rowid = del_rows[n]
    end for

end function
# W_pnabsba()

######################################################################
function PR_pnabsba()
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

    #_set_status - Set initial status to true
    let get_status = true

    #_get_data -  Get the data from the temporary table
    while get_status
        call t_read() returning get_name, get_data, get_index, get_status
        case
          #_p_read - Read the P record
          when get_name = "base_year"
            let p_pnabsba[p_cur].base_year = get_data
          when get_name = "base_month"
            let p_pnabsba[p_cur].base_month = get_data
          when get_name = "base_value1"
            let p_pnabsba[p_cur].base_value1 = get_data
          when get_name = "base_value2"
            let p_pnabsba[p_cur].base_value2 = get_data
          when get_name = "nom_days"
            let p_pnabsba[p_cur].nom_days = get_data
          when get_name = "work_days"
            let p_pnabsba[p_cur].work_days = get_data
          when get_name = "include_fl"
            let p_pnabsba[p_cur].include_fl = get_data

          #_q_read - Read the Q record
          when get_name = "abs_num"
            let q_pnabsba[p_cur].abs_num = get_data

          #_otherwise - otherwise clause
        end case
    end while

    #_on_program_read - program read

end function
# PR_pnabsba()

######################################################################
function PW_pnabsba()
######################################################################
# This function writes the p_ & q_ records to the temp table
#
    #_define_var - define local variables
    define
       #_local_var - local variables
       tmp_str char(70)

    #_p_write - Write the P record to the temp table
    call t_write(p_cur, "base_year", p_pnabsba[p_cur].base_year)
    call t_write(p_cur, "base_month", p_pnabsba[p_cur].base_month)
    let tmp_str = dec_let(p_pnabsba[p_cur].base_value1)
    call t_write(p_cur, "base_value1", tmp_str)
    let tmp_str = dec_let(p_pnabsba[p_cur].base_value2)
    call t_write(p_cur, "base_value2", tmp_str)
    let tmp_str = dec_let(p_pnabsba[p_cur].nom_days)
    call t_write(p_cur, "nom_days", tmp_str)
    let tmp_str = dec_let(p_pnabsba[p_cur].work_days)
    call t_write(p_cur, "work_days", tmp_str)
    call t_write(p_cur, "include_fl", p_pnabsba[p_cur].include_fl)

    #_q_write - Write the Q record
    call t_write(p_cur, "abs_num", q_pnabsba[p_cur].abs_num)

    #_on_program_write - program write

end function
# PW_pnabsba()

######################################################################
function DF_pnabsba()
######################################################################
# This function performs defaulting of program variables
# based upon values placed in the default attribute
# of the perform file
#
    #_define_var

    #_defaults - Default program variables
    if menu_item = "add" and defaulted = "N"
    then
        #_dflt_flag - Reset the defaulting flag
        let defaulted = "Y"
    end if

end function
# DF_pnabsba()

######################################################################
function AC_pnabsba()
######################################################################
# This function sets arr_cnt to the correct number of array elements.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        n smallint

    #_arr_count - Array count
    for n = arr_count() to 1 step -1
        if p_pnabsba[n].base_year is not null
          or p_pnabsba[n].base_month is not null
          or p_pnabsba[n].base_value1 is not null
          or p_pnabsba[n].base_value2 is not null
          or p_pnabsba[n].nom_days is not null
          or p_pnabsba[n].work_days is not null
          or p_pnabsba[n].include_fl is not null
          or q_pnabsba[n].row_id is not null
        then
            let arr_cnt = n
            return
        end if
    end for

    #_arr_cnt - set arr_cnt
    let arr_cnt = 0

end function
# AC_pnabsba()

######################################################################
function SK_pnabsba(prv_fld)
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
      #_base_year - Skip logic for base_year
      when scr_fld = "base_year"
        if prv_fld = "base_month" or prv_fld is null
          then let nxt_fld = "work_days"
          else let nxt_fld = "base_month"
        end if
      #_base_month - Skip logic for base_month
      when scr_fld = "base_month"
        if prv_fld = "base_value1"
          then let nxt_fld = "base_year"
          else let nxt_fld = "base_value1"
        end if
      #_base_value1 - Skip logic for base_value1
      when scr_fld = "base_value1"
        if prv_fld = "base_value2"
          then let nxt_fld = "base_month"
          else let nxt_fld = "base_value2"
        end if
      #_base_value2 - Skip logic for base_value2
      when scr_fld = "base_value2"
        if prv_fld = "nom_days"
          then let nxt_fld = "base_value1"
          else let nxt_fld = "nom_days"
        end if
      #_nom_days - Skip logic for nom_days
      when scr_fld = "nom_days"
        if prv_fld = "work_days"
          then let nxt_fld = "base_value2"
          else let nxt_fld = "work_days"
        end if
      #_work_days - Skip logic for work_days
      when scr_fld = "work_days"
        if prv_fld = "base_year"
          then let nxt_fld = "nom_days"
          else let nxt_fld = "base_year"
        end if
      #_include_fl - Skip logic for include_fl
      when scr_fld = "include_fl"
        if prv_fld = "base_year"
          then let nxt_fld = "work_days"
          else let nxt_fld = "base_year"
        end if
    end case

end function
# SK_pnabsba()

######################################################################
function Z_pnabsba()
######################################################################
# This function is called upon return from this screen.
#
    #_define_var - define local variables

    #_close - Close the window and make the data available
    if open_level = 1
    then
        close window win_pnabsba
    end if
    #_reset_open - reset open level
    let open_level = open_level - 1

    #_on_exit
    #_end

end function
# Z_pnabsba()
######################################################################
function pnabsba_req_dup_chk(scr_fld)
######################################################################
#
define
   scr_fld char(80)

   if after_row_occured(scr_fld = "work_days")
   then
      if not pnabsba_empty_line(p_cur)
      then
         case
            when p_pnabsba[p_cur].base_year is null
               let nxt_fld = "base_year"
               call scr_error("required", nxt_fld)
         end case
      end if
      if nxt_fld is not null
      then
         return
      end if
      if not pnabsba_dup_chk(p_cur)
      then
         return
      end if
   end if

end function
# pnabsba_req_dup_chk()


######################################################################
function pnabsba_empty_line(idx)
######################################################################
#
define
   idx smallint

   if p_pnabsba[idx].base_year is null
   then
      return true
   end if

   return false

end function
# pnabsba_empty_line()


######################################################################
function pnabsba_dup_chk(idx)
######################################################################
#
define
   idx smallint,
   i   smallint

   for i = 1 to arr_count()
      if i != idx
      then
         if p_pnabsba[idx].base_year = p_pnabsba[i].base_year
            and p_pnabsba[idx].base_month = p_pnabsba[i].base_month
         then
         end if
      end if
   end for

   return true

end function
# pnabsba_dup_chk()


######################################################################
function pnabsba_set_del_key()
######################################################################
#

#  if pnattpo_get_arr_cnt() <> 0
#    then call turn_off_del_key()
#    else call turn_on_del_key()
#  end if

end function
# pnabsba_set_del_key()

######################################################################
function pnabsba_display_avg()
######################################################################
#

{  display p_fpnabsba.base_avg to s_fpnabsba.base_avg attribute(red)
   display p_fpnabsba.abs_rate to s_fpnabsba.abs_rate attribute(red)
}

   display p_fpnabsba.base_avg   to s_fpnabsba.base_avg   attribute(red)
   display p_fpnabsba.amount     to s_fpnabsba.amount     attribute(red)
   display p_fpnabsba.suma       to s_fpnabsba.suma       attribute(red)
   display p_fpnabsba.year_from  to s_fpnabsba.year_from  attribute(red)
   display p_fpnabsba.month_from to s_fpnabsba.month_from attribute(red)
   display p_fpnabsba.abs_rate   to s_fpnabsba.abs_rate   attribute(red)
   display p_fpnabsba.year_to    to s_fpnabsba.year_to    attribute(red)
   display p_fpnabsba.month_to   to s_fpnabsba.month_to   attribute(red)

end function
# pnabsba_display_avg()

