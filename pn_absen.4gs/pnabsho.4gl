######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################
# Screen Generator version: 4.10.UC1

globals "globals.4gl"

#_local_static - Local (static) variables
define
        display_mode  char(1),
    p_pnabsho array[100] of record      # Record like the pnabsho screen
        abs_day like pn_absen_hours.abs_day,
        abs_hours like pn_absen_hours.abs_hours
    end record,
    q_pnabsho array[100] of record      # Parallel pnabsho record
        row_id integer, # SQL rowid
        data_changed integer, # check for needed update
        abs_num like pn_absen_hours.abs_num
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
function S_pnabsho()
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
      when scr_funct = "init" call A_pnabsho()        # Initialize screen
      #_read - read function
      when scr_funct = "read" call R_pnabsho()        # Read from disk
      #_write - write function
      when scr_funct = "write" call W_pnabsho()       # Write to disk
      #_clear - clear function
      when scr_funct = "clear" call C_pnabsho()       # Clear variables
      #_key - build key function
      when scr_funct = "build key" call K_pnabsho()   # Build unique key
      #_input - input function
      when scr_funct = "input" call I_pnabsho()       # Input data
      #_flow - flow function
      when scr_funct = "flow" call F_pnabsho()        # Flow Control
      #_pread - program read function
      when scr_funct = "pread" call PR_pnabsho()      # Read from program
      #_pwrite - program write function
      when scr_funct = "pwrite" call PW_pnabsho()     # Write to program
      #_setdata - set this data function
      when scr_funct = "set this_data" call SD_pnabsho()# Set 'this_data'
      #_showdata - showdata function
      when scr_funct = "showdata" call SH_pnabsho()  # Highlight a field
      #_showline - showline function
      when scr_funct = "showline" call SL_pnabsho()  # Highlight a field
      #_highlight - highlight function
      when scr_funct = "highlight" call HI_pnabsho()  # Highlight a field
      #_close - close function
      when scr_funct = "close" call Z_pnabsho()       # Close the object
      #_dsp_arr - display array function
      when scr_funct = "display array" call DS_pnabsho() # Display array
      #_arr_count - arr_count function
      when scr_funct = "arr_count" call AC_pnabsho()   # Compress detail lines
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
# S_pnabsho()

######################################################################
function A_pnabsho()
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
    let scr_max = 8
    let arr_max = 100
    let arr_cnt = arr_max
    let sql_order  = "abs_day"

    #_before_init
        let display_mode = "N"
        return
    #_end

    #_open - Open the window and present the form
    if open_level = 1
    then
        #_window - window position
        call window_pos(2,3) returning y_pos, x_pos
        open window win_pnabsho at y_pos, x_pos
          #_form_path - path to screen form
          with form "pnabsho"
          #_end
          attribute (border, white)
    end if

    #_after_init
    #_end

end function
# A_pnabsho()

######################################################################
function C_pnabsho()
######################################################################
# This function clears the program variables.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        n       smallint

    #_init - Initialize variables
    initialize p_pnabsho[1].* to null # clear the p_record
    initialize q_pnabsho[1].* to null # clear the q_record

    #_clear_pq - clear p or q records
    for n = 2 to arr_cnt
        let p_pnabsho[n].* = p_pnabsho[1].* # clear subsequent p_records
        let q_pnabsho[n].* = q_pnabsho[1].* # clear subsequent q_records
    end for
    let arr_cnt = 0              # reset the active element counter


end function
# C_pnabsho()

######################################################################
function K_pnabsho()
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
    call put_vararg("pn_absen_hours")

    #_col_abs_num - column name
    call put_vararg("abs_num")
    #_pnabsho_abs_num - column value
    call put_vararg(q_pnabsho[p_cur].abs_num)
    #_col_abs_day - column name
    call put_vararg("abs_day")
    #_pnabsho_abs_day - column value
    call put_vararg(p_pnabsho[p_cur].abs_day)

end function
# K_pnabsho()

######################################################################
function I_pnabsho()
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
    input array p_pnabsho without defaults from s_pnabsho.*

    #_begin_input - The following section is for array type inputs

    #_bf_row - Before row logic
    before row
      if in_insert
      then
          # F1/F2 Scenario - fix parallel array if pre-informix 4.0
          if not is_4_0() and arr_cnt > 0
            then call AD_pnabsho() end if
          let in_insert = false  # Reset in_insert flag
      end if
      let scr_fld = ""           # Reset the current field
      let p_cur = arr_curr()     # Set the current array line
      let s_cur = scr_line()     # Set the current screen line
      let arr_cnt = arr_count()  # Set the number of array elements
      call BR_pnabsho()
      goto next_field

    #_af_row - After row logic
    after row
      let del_flag = false
      call SL_pnabsho()
      call AR_pnabsho()
      goto next_field

    #_bf_insert - Before insert logic
    before insert
      let in_insert = true
      let arr_cnt = arr_count()  # Set the number of array elements
      call BS_pnabsho()
      goto next_field

    #_af_insert - After insert logic
    after insert
      let in_insert = false
      call AS_pnabsho()
      goto next_field

    #_bf_delete - Before delete logic
    before delete
      call BD_pnabsho()
      goto next_field

    #_af_delete - After delete logic
    after delete
      let del_flag = true
      call AD_pnabsho()
      goto next_field

      # All entry fields must have before and after field processing

      #_bf_field - Before field logic
      before field abs_day call BF_pnabsho("pn_absen_hours.abs_day")
        goto next_field
      before field abs_hours call BF_pnabsho("pn_absen_hours.abs_hours")
        goto next_field

      #_af_field - After field logic
      after field abs_day call AF_pnabsho()
        goto next_field
      after field abs_hours call AF_pnabsho()
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
        if exit_level >= 2 then call AF_pnabsho() end if
        if nxt_fld is not null then goto next_field end if

        #_ar_row - Run the 'after row' logic if necessary
        if exit_level >= 1 then call AR_pnabsho() end if
        if nxt_fld is not null then goto next_field end if

        #_goto_top - Don't run 'after input' logic if loop
        if goto_top then exit input end if

        #_run_ainput - Run the 'after input' logic before exiting input
        call AI_pnabsho()
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
        call hot_key("I_pnabsho")   # Map the key to the event
        #_hot_event - event handler
        call EV_pnabsho()

      #_nxt_fld - Programmatic next field logic
      label next_field:
        let scratch = nxt_fld
        let nxt_fld = null
        case
          when scratch is null  # No need to go through 'case'
          when scratch = "abs_day" next field abs_day
          when scratch = "abs_hours" next field abs_hours
          when scratch = "exit input" goto end_input
          when scratch = "event" goto event
          when scratch = "goto top"
              call AC_pnabsho()
            let goto_top = true
            goto end_input
          #_otherwise - otherwise clause
        end case

    #_end_input - end input statement
    end input

    #_end_while - This is the end of the 'goto top' loop.
    end while

end function
# I_pnabsho()

######################################################################
function BR_pnabsho()
######################################################################
# This func is called before you enter a new row.
#
    #_define_var - define local variables

    #_before_row
        if display_mode = "N"
        then
           call pnabsho_set_del_key()
        end if
    #_end

end function
# BR_pnabsho()

######################################################################
function AR_pnabsho()
######################################################################
# This function is called whenever you leave a row.
#
    #_define_var - define local variables

    #_exit_level - No more exit levels required
    let exit_level = 0

    #_after_row
    #_end

end function
# AR_pnabsho()

######################################################################
function BS_pnabsho()
######################################################################
# This func is called before a new row is added
#
    #_define_var - define local variables
    define
        #_local_var - define local variables
        n smallint   # Generic counter

    #_shift - Expand (shift) the parallel array
    for n = (arr_cnt - 1) to p_cur step -1
        let q_pnabsho[n+1].* = q_pnabsho[n].*
    end for

    #_init - Blank out the current array element
    initialize q_pnabsho[p_cur].* to null

    #_defaults - Call function to default variables
    call DF_pnabsho()

    #_before_insert
    #_end

end function
# BS_pnabsho()

######################################################################
function AS_pnabsho()
######################################################################
# This func is called after a row has been added to array.
#
    #_define_var - define local variables

    #_after_insert
    #_end

end function
# AS_pnabsho()

######################################################################
function BD_pnabsho()
######################################################################
# This function is called when [F2] is pressed (del row),
# and before actual array elements have been shifted.
#
    #_define_var - define local variables

    #_before_delete
    #_end

end function
# BD_pnabsho()

######################################################################
function AD_pnabsho()
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
    if q_pnabsho[p_cur].row_id > 0
    then
        let del_cnt = del_cnt + 1
        let del_rows[del_cnt] = q_pnabsho[p_cur].row_id
    end if

    #_shift - Compress (shift) the parallel array
    for n = (p_cur + 1) to arr_cnt
        let q_pnabsho[n-1].* = q_pnabsho[n].*
    end for

    #_init - Blank out the last (duplicate) data element
    initialize p_pnabsho[arr_cnt].* to null
    initialize q_pnabsho[arr_cnt].* to null

    #_after_delete
    #_end

end function
# AD_pnabsho()

######################################################################
function DS_pnabsho()
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

    #_init - Initialize
    let exit_type = "quit"


    #_display_array - Display the Zoom array
    display array p_pnabsho to s_pnabsho.*
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
        call hot_key("DS_pnabsho")  # Map the key to the event
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
# DS_pnabsho()

######################################################################
function BI_pnabsho()
######################################################################
# This function is called before the input statement
#
    #_define_var - define local variables

    #_before_input
    #_end

end function
# BI_pnabsho()

######################################################################
function AI_pnabsho()
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
# AI_pnabsho()

######################################################################
function BF_pnabsho(field_name)
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
      when scr_fld = "abs_day"
        #_before_field abs_day
        #_end
      when scr_fld = "abs_hours"
        #_before_field abs_hours
        #_end
      #_otherwise - otherwise clause
    end case

    #_nxt_fld - Programmed exit
    if nxt_fld is not null then return end if

    #_lib_before - Setup for lib_before
    let scr_fld = prv_fld
    call lib_before(field_name)

end function
# BF_pnabsho()

######################################################################
function AF_pnabsho()
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
      when scr_fld = "abs_day"
        #_after_field abs_day
            if display_mode = "Y"
            then
               let p_pnabsho[p_cur].abs_day = prev_data
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
                   let nxt_fld = "abs_day"
                   error " There are no more rows in the direction you are going "
               end if
            end if
        #_end
      when scr_fld = "abs_hours"
        #_after_field abs_hours
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
        if q_pnabsho[p_cur].row_id > 0
          then let q_pnabsho[p_cur].data_changed = true end if
        case
          when scr_fld = "abs_day"
            #_after_change_in abs_day
            #_end
          when scr_fld = "abs_hours"
            #_after_change_in abs_hours
            #_end
          #_otherwise - otherwise clause
        end case
    end if
    if nxt_fld is not null
    then
       return
    end if
    call pnabsho_req_dup_chk(scr_fld)

end function
# AF_pnabsho()

######################################################################
function EV_pnabsho()
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
# EV_pnabsho()

######################################################################
function SD_pnabsho()
######################################################################
# This function is called to set the this_data global variable.
#
    #_define_var - define local variables
    define
       #_local_var - local variables
       tmp_str char(70)

    #_setdata - Set this_data variable
    case
      when scr_fld = "abs_day"
        #_set_abs_day
        call set_data(p_pnabsho[p_cur].abs_day)
      when scr_fld = "abs_hours"
        #_set_abs_hours
        let tmp_str = dec_let(p_pnabsho[p_cur].abs_hours)
        call set_data(tmp_str)
      #_otherwise - otherwise clause
    end case

end function
# SD_pnabsho()

######################################################################
function HI_pnabsho()
######################################################################
# This function highlights the specified field name.
# Only input type fields need to be specified.
#
    #_define_var - define local variables

    #_highlight - Highlight current field data
    case
      when scr_fld = "abs_day"
        #_dsp_abs_day
        display p_pnabsho[p_cur].abs_day
          to s_pnabsho[s_cur].abs_day attribute(reverse)
      when scr_fld = "abs_hours"
        #_dsp_abs_hours
        display p_pnabsho[p_cur].abs_hours
          to s_pnabsho[s_cur].abs_hours attribute(reverse)
      #_otherwise - otherwise clause
    end case

end function
# HI_pnabsho()

######################################################################
function SH_pnabsho()
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
        display p_pnabsho[m + n].* to s_pnabsho[n].*  attribute(red)
    end for

end function
# SH_pnabsho()

######################################################################
function SL_pnabsho()
######################################################################
# This function displays all p_* variables to the screen
#
    #_define_var - define local variables

    #_first_show - call showdata function on first call
    if first_show is null
    then
        let first_show = "Y"
        call SH_pnabsho()
        let p_cur = 1
    end if

    #_showdata - Display rows to detail screen
    display p_pnabsho[p_cur].* to s_pnabsho[s_cur].* attribute(red)


end function
# SL_pnabsho()

######################################################################
function F_pnabsho()
######################################################################
# This function is used as the custom data flow control manager
#
    #_define_var - define local variables

    #_flow - custom flow control manager

end function
# F_pnabsho()

######################################################################
function R_pnabsho()
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
        m              smallint          # working number

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
        "abs_day,",
        "abs_hours ",
        " from pn_absen_hours ",
        "where pn_absen_hours.abs_num = ?"

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
        #_use_hard_order - as found in the pnabsho.per
        let scratch = scratch clipped, " order by abs_day"
    end if

    #_prep_curs - Prepare the SQL string for execution
    prepare a_pnabsho from scratch
    declare c_pnabsho cursor for a_pnabsho

    #_read_dtl - Read in the detail lines
        let p_cur = 1
        open c_pnabsho using m_bsence.abs_num

    #_read_data - Read in the detail data
    while true

        #_max_read - maximum number of elements read
        if p_cur = arr_max then exit while end if

        #_fetch - fetch statement
        fetch c_pnabsho into q_pnabsho[p_cur].row_id,
            q_pnabsho[p_cur].abs_num,
            p_pnabsho[p_cur].abs_day,
            p_pnabsho[p_cur].abs_hours
        if sqlca.sqlcode = notfound
        then
            let p_cur = p_cur - 1
            exit while
        end if
        #_on_disk_read
        #_end
        let p_cur = p_cur + 1


    end while

    #_close_curs - close cursor statement
    close c_pnabsho
    let arr_cnt = p_cur
    let p_cur = 1
    let s_cur = 1

    #_set_cnt - set record count
    call set_count(arr_cnt)

end function
# R_pnabsho()

######################################################################
function W_pnabsho()
######################################################################
# This function writes the program variables to disk.
#
    #_define_var - define local variables

    define
        n            smallint  # working number

    #_row_maintenance - either update or insert existing
    for p_cur = 1 to arr_cnt
        if pnabsho_empty_line(p_cur)
        then
           if q_pnabsho[p_cur].row_id > 0
           then
              delete from pn_absen_rates
              where pn_absen_rates.rowid = q_pnabsho[p_cur].row_id
           end if
           continue for
        end if
        #_update_check - check for update
        if q_pnabsho[p_cur].row_id > 0 and q_pnabsho[p_cur].data_changed
        then
            #_update - Update the existing row
            update pn_absen_hours set
                abs_num = q_pnabsho[p_cur].abs_num,
                abs_day = p_pnabsho[p_cur].abs_day,
                abs_hours = p_pnabsho[p_cur].abs_hours
            where rowid = q_pnabsho[p_cur].row_id
        end if

        #_insert_check - check for insert
        if q_pnabsho[p_cur].row_id = 0 or q_pnabsho[p_cur].row_id is null
        then
            #_join_elems - prep the join elements
                let q_pnabsho[p_cur].abs_num = m_bsence.abs_num
            #_insert_row - Insert the new row
            insert into pn_absen_hours (
                abs_num, abs_day, abs_hours)
            values (
                q_pnabsho[p_cur].abs_num, p_pnabsho[p_cur].abs_day,
                p_pnabsho[p_cur].abs_hours)

        end if
    end for

    #_row_deletion - delete all rows that where marked for deletion
    for n = 1 to del_cnt
        #_delete_row - delete this row
        delete from pn_absen_hours where rowid = del_rows[n]
    end for

end function
# W_pnabsho()

######################################################################
function PR_pnabsho()
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
          when get_name = "abs_day"
            let p_pnabsho[p_cur].abs_day = get_data
          when get_name = "abs_hours"
            let p_pnabsho[p_cur].abs_hours = get_data

          #_q_read - Read the Q record
          when get_name = "abs_num"
            let q_pnabsho[p_cur].abs_num = get_data

          #_otherwise - otherwise clause
        end case
    end while

    #_on_program_read - program read

end function
# PR_pnabsho()

######################################################################
function PW_pnabsho()
######################################################################
# This function writes the p_ & q_ records to the temp table
#
    #_define_var - define local variables
    define
       #_local_var - local variables
       tmp_str char(70)

    #_p_write - Write the P record to the temp table
    call t_write(p_cur, "abs_day", p_pnabsho[p_cur].abs_day)
    let tmp_str = dec_let(p_pnabsho[p_cur].abs_hours)
    call t_write(p_cur, "abs_hours", tmp_str)

    #_q_write - Write the Q record
    call t_write(p_cur, "abs_num", q_pnabsho[p_cur].abs_num)

    #_on_program_write - program write

end function
# PW_pnabsho()

######################################################################
function DF_pnabsho()
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
# DF_pnabsho()

######################################################################
function AC_pnabsho()
######################################################################
# This function sets arr_cnt to the correct number of array elements.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        n smallint

    #_arr_count - Array count
    for n = arr_count() to 1 step -1
        if p_pnabsho[n].abs_day is not null
          or p_pnabsho[n].abs_hours is not null
          or q_pnabsho[n].row_id is not null
        then
            let arr_cnt = n
            return
        end if
    end for

    #_arr_cnt - set arr_cnt
    let arr_cnt = 0

end function
# AC_pnabsho()

######################################################################
function SK_pnabsho(prv_fld)
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
      #_abs_day - Skip logic for abs_day
      when scr_fld = "abs_day"
        if prv_fld = "abs_hours" or prv_fld is null
          then let nxt_fld = "abs_hours"
          else let nxt_fld = "abs_hours"
        end if
      #_abs_hours - Skip logic for abs_hours
      when scr_fld = "abs_hours"
        if prv_fld = "abs_day"
          then let nxt_fld = "abs_day"
          else let nxt_fld = "abs_day"
        end if
    end case

end function
# SK_pnabsho()

######################################################################
function Z_pnabsho()
######################################################################
# This function is called upon return from this screen.
#
    #_define_var - define local variables

    #_close - Close the window and make the data available
    if open_level = 1
    then
        close window win_pnabsho
    end if
    #_reset_open - reset open level
    let open_level = open_level - 1

    #_on_exit
    #_end

end function
# Z_pnabsho()
######################################################################
function pnabsho_req_dup_chk(scr_fld)
######################################################################
#
define
   scr_fld char(80)

   if after_row_occured(scr_fld = "abs_hours")
   then
      if not pnabsho_empty_line(p_cur)
      then
         case
            when p_pnabsho[p_cur].abs_day is null
               let nxt_fld = "abs_day"
               call scr_error("required", nxt_fld)
            when p_pnabsho[p_cur].abs_hours is null
               let nxt_fld = "abs_hours"
               call scr_error("required", nxt_fld)
         end case
      end if
      if nxt_fld is not null
      then
         return
      end if
      if not pnabsho_dup_chk(p_cur)
      then
         return
      end if
   end if

end function
# pnabsho_req_dup_chk()


######################################################################
function pnabsho_empty_line(idx)
######################################################################
#
define
   idx smallint

   if p_pnabsho[idx].abs_day is null
      and p_pnabsho[idx].abs_hours
   then
      return true
   end if

   return false

end function
# pnabsho_empty_line()


######################################################################
function pnabsho_dup_chk(idx)
######################################################################
#
define
   idx smallint,
   i   smallint

   for i = 1 to arr_count()
      if i != idx
      then
         if p_pnabsho[idx].abs_day = p_pnabsho[i].abs_day
         then
         end if
      end if
   end for

   return true

end function
# pnabsho_dup_chk()


######################################################################
function pnabsho_set_del_key()
######################################################################
#

#  if pnattpo_get_arr_cnt() <> 0
#    then call turn_off_del_key()
#    else call turn_on_del_key()
#  end if

end function
# pnabsho_set_del_key()

