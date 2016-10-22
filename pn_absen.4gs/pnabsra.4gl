######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################
# Screen Generator version: 4.10.UC1

globals "globals.4gl"

#_local_static - Local (static) variables
define
    p_pnabsra array[20] of record      # Record like the pnabsra screen
        date_from like pn_absen_rates.date_from,
        date_to like pn_absen_rates.date_to,
        block_cause_dc like pn_absen_rates.block_cause_dc,
        abs_days like pn_absen_rates.abs_days,
        abs_cnt_days like pn_absen_rates.abs_cnt_days,
        abs_cnt_fl like pn_absen_rates.abs_cnt_fl,
        abs_per_days like pn_absen_rates.abs_per_days,
        abs_per_fl like pn_absen_rates.abs_per_fl,
        pay_amount like pn_absen_rates.pay_amount,
        pay_month like pn_absen_rates.pay_month,
        abs_base like pn_absen_rates.abs_base,
        abs_rate1 like pn_absen_rates.abs_rate1,
        abs_perc like pn_absen_rates.abs_perc,
        abs_rate2 like pn_absen_rates.abs_rate2,
        abs_rate3 like pn_absen_rates.abs_rate3
    end record,
    q_pnabsra array[20] of record      # Parallel pnabsra record
        row_id integer, # SQL rowid
        data_changed integer, # check for needed update
        abs_rate_num like pn_absen_rates.abs_rate_num,
        abs_num like pn_absen_rates.abs_num,
        dor_num like pn_absen_rates.dor_num,
        earn_no like pn_absen_rates.earn_no
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
function S_pnabsra()
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
      when scr_funct = "init" call A_pnabsra()        # Initialize screen
      #_read - read function
      when scr_funct = "read" call R_pnabsra()        # Read from disk
      #_write - write function
      when scr_funct = "write" call W_pnabsra()       # Write to disk
      #_clear - clear function
      when scr_funct = "clear" call C_pnabsra()       # Clear variables
      #_key - build key function
      when scr_funct = "build key" call K_pnabsra()   # Build unique key
      #_input - input function
      when scr_funct = "input" call I_pnabsra()       # Input data
      #_flow - flow function
      when scr_funct = "flow" call F_pnabsra()        # Flow Control
      #_pread - program read function
      when scr_funct = "pread" call PR_pnabsra()      # Read from program
      #_pwrite - program write function
      when scr_funct = "pwrite" call PW_pnabsra()     # Write to program
      #_setdata - set this data function
      when scr_funct = "set this_data" call SD_pnabsra()# Set 'this_data'
      #_showdata - showdata function
      when scr_funct = "showdata" call SH_pnabsra()  # Highlight a field
      #_showline - showline function
      when scr_funct = "showline" call SL_pnabsra()  # Highlight a field
      #_highlight - highlight function
      when scr_funct = "highlight" call HI_pnabsra()  # Highlight a field
      #_close - close function
      when scr_funct = "close" call Z_pnabsra()       # Close the object
      #_dsp_arr - display array function
      when scr_funct = "display array" call DS_pnabsra() # Display array
      #_arr_count - arr_count function
      when scr_funct = "arr_count" call AC_pnabsra()   # Compress detail lines
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
# S_pnabsra()

######################################################################
function A_pnabsra()
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
    let scr_max = 4
    let arr_max = 20
    let arr_cnt = arr_max
    let sql_order  = "date_from"

    #_before_init
        return
    #_end

    #_open - Open the window and present the form
    if open_level = 1
    then
        #_window - window position
        call window_pos(2,3) returning y_pos, x_pos
        open window win_pnabsra at y_pos, x_pos
          #_form_path - path to screen form
          with form "pnabsra"
          #_end
          attribute (border, white)
    end if

    #_after_init
    #_end

end function
# A_pnabsra()

######################################################################
function C_pnabsra()
######################################################################
# This function clears the program variables.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        n       smallint

    #_init - Initialize variables
    initialize p_pnabsra[1].* to null # clear the p_record
    initialize q_pnabsra[1].* to null # clear the q_record

    #_clear_pq - clear p or q records
    for n = 2 to arr_cnt
        let p_pnabsra[n].* = p_pnabsra[1].* # clear subsequent p_records
        let q_pnabsra[n].* = q_pnabsra[1].* # clear subsequent q_records
    end for
    let arr_cnt = 0              # reset the active element counter


end function
# C_pnabsra()

######################################################################
function K_pnabsra()
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
    call put_vararg("pn_absen_rates")


end function
# K_pnabsra()

######################################################################
function I_pnabsra()
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

    #_while - start while loop
    while goto_top

    let goto_top = false
    let in_insert = false
    let exit_level = 0
    let tab_pressed = false
    call set_count(arr_cnt)
    #_input_array - Detail input array
    input array p_pnabsra without defaults from s_pnabsra.*

    #_begin_input - The following section is for array type inputs

    #_bf_row - Before row logic
    before row
      if in_insert
      then
          # F1/F2 Scenario - fix parallel array if pre-informix 4.0
          if not is_4_0() and arr_cnt > 0
            then call AD_pnabsra() end if
          let in_insert = false  # Reset in_insert flag
      end if
      let scr_fld = ""           # Reset the current field
      let p_cur = arr_curr()     # Set the current array line
      let s_cur = scr_line()     # Set the current screen line
      let arr_cnt = arr_count()  # Set the number of array elements
      call BR_pnabsra()
      goto next_field

    #_af_row - After row logic
    after row
      let del_flag = false
      call SL_pnabsra()
      call AR_pnabsra()
      goto next_field

    #_bf_insert - Before insert logic
    before insert
      let in_insert = true
      let arr_cnt = arr_count()  # Set the number of array elements
      call BS_pnabsra()
      goto next_field

    #_af_insert - After insert logic
    after insert
      let in_insert = false
      call AS_pnabsra()
      goto next_field

    #_bf_delete - Before delete logic
    before delete
      call BD_pnabsra()
      goto next_field

    #_af_delete - After delete logic
    after delete
      let del_flag = true
      call AD_pnabsra()
      goto next_field

      # All entry fields must have before and after field processing

      #_bf_field - Before field logic
      before field date_from call BF_pnabsra("pn_absen_rates.date_from")
        goto next_field
      before field date_to call BF_pnabsra("pn_absen_rates.date_to")
        goto next_field
      before field block_cause_dc call BF_pnabsra("pn_absen_rates.block_cause_dc")
        goto next_field
      before field abs_cnt_fl call BF_pnabsra("pn_absen_rates.abs_cnt_fl")
        goto next_field
      before field abs_per_fl call BF_pnabsra("pn_absen_rates.abs_per_fl")
        goto next_field
      before field pay_amount call BF_pnabsra("pn_absen_rates.pay_amount")
        goto next_field
      before field pay_month call BF_pnabsra("pn_absen_rates.pay_month")
        goto next_field
      before field abs_perc call BF_pnabsra("pn_absen_rates.abs_perc")
        goto next_field
      before field abs_rate3 call BF_pnabsra("pn_absen_rates.abs_rate3")
        goto next_field

      #_af_field - After field logic
      after field date_from call AF_pnabsra()
        goto next_field
      after field date_to call AF_pnabsra()
        goto next_field
      after field block_cause_dc call AF_pnabsra()
        goto next_field
      after field abs_cnt_fl call AF_pnabsra()
        goto next_field
      after field abs_per_fl call AF_pnabsra()
        goto next_field
      after field pay_amount call AF_pnabsra()
        goto next_field
      after field pay_month call AF_pnabsra()
        goto next_field
      after field abs_perc call AF_pnabsra()
        goto next_field
      after field abs_rate3 call AF_pnabsra()
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
        if exit_level >= 2 then call AF_pnabsra() end if
        if nxt_fld is not null then goto next_field end if

        #_ar_row - Run the 'after row' logic if necessary
        if exit_level >= 1 then call AR_pnabsra() end if
        if nxt_fld is not null then goto next_field end if

        #_goto_top - Don't run 'after input' logic if loop
        if goto_top then exit input end if

        #_run_ainput - Run the 'after input' logic before exiting input
        call AI_pnabsra()
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
        call hot_key("I_pnabsra")   # Map the key to the event
        #_hot_event - event handler
        call EV_pnabsra()

      #_nxt_fld - Programmatic next field logic
      label next_field:
        let scratch = nxt_fld
        let nxt_fld = null
        case
          when scratch is null  # No need to go through 'case'
          when scratch = "date_from" next field date_from
          when scratch = "date_to" next field date_to
          when scratch = "block_cause_dc" next field block_cause_dc
          when scratch = "abs_days" next field abs_days
          when scratch = "abs_cnt_days" next field abs_cnt_days
          when scratch = "abs_cnt_fl" next field abs_cnt_fl
          when scratch = "abs_per_days" next field abs_per_days
          when scratch = "abs_per_fl" next field abs_per_fl
          when scratch = "pay_amount" next field pay_amount
          when scratch = "pay_month" next field pay_month
          when scratch = "abs_base" next field abs_base
          when scratch = "abs_rate1" next field abs_rate1
          when scratch = "abs_perc" next field abs_perc
          when scratch = "abs_rate2" next field abs_rate2
          when scratch = "abs_rate3" next field abs_rate3
          when scratch = "exit input" goto end_input
          when scratch = "event" goto event
          when scratch = "goto top"
              call AC_pnabsra()
            let goto_top = true
            goto end_input
          #_otherwise - otherwise clause
        end case

    #_end_input - end input statement
    end input

    #_end_while - This is the end of the 'goto top' loop.
    end while

end function
# I_pnabsra()

######################################################################
function BR_pnabsra()
######################################################################
# This func is called before you enter a new row.
#
    #_define_var - define local variables

    #_before_row
    #_end

end function
# BR_pnabsra()

######################################################################
function AR_pnabsra()
######################################################################
# This function is called whenever you leave a row.
#
    #_define_var - define local variables

    #_exit_level - No more exit levels required
    let exit_level = 0

    #_after_row
    #_end

end function
# AR_pnabsra()

######################################################################
function BS_pnabsra()
######################################################################
# This func is called before a new row is added
#
    #_define_var - define local variables
    define
        #_local_var - define local variables
        n smallint   # Generic counter

    #_shift - Expand (shift) the parallel array
    for n = (arr_cnt - 1) to p_cur step -1
        let q_pnabsra[n+1].* = q_pnabsra[n].*
    end for

    #_init - Blank out the current array element
    initialize q_pnabsra[p_cur].* to null

    #_defaults - Call function to default variables
    call DF_pnabsra()

    #_before_insert
    #_end

end function
# BS_pnabsra()

######################################################################
function AS_pnabsra()
######################################################################
# This func is called after a row has been added to array.
#
    #_define_var - define local variables

    #_after_insert
    #_end

end function
# AS_pnabsra()

######################################################################
function BD_pnabsra()
######################################################################
# This function is called when [F2] is pressed (del row),
# and before actual array elements have been shifted.
#
    #_define_var - define local variables

    #_before_delete
    #_end

end function
# BD_pnabsra()

######################################################################
function AD_pnabsra()
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
    if q_pnabsra[p_cur].row_id > 0
    then
        let del_cnt = del_cnt + 1
        let del_rows[del_cnt] = q_pnabsra[p_cur].row_id
    end if

    #_shift - Compress (shift) the parallel array
    for n = (p_cur + 1) to arr_cnt
        let q_pnabsra[n-1].* = q_pnabsra[n].*
    end for

    #_init - Blank out the last (duplicate) data element
    initialize p_pnabsra[arr_cnt].* to null
    initialize q_pnabsra[arr_cnt].* to null

    #_after_delete
    #_end

end function
# AD_pnabsra()

######################################################################
function DS_pnabsra()
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
    display array p_pnabsra to s_pnabsra.*
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
        call hot_key("DS_pnabsra")  # Map the key to the event
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
# DS_pnabsra()

######################################################################
function BI_pnabsra()
######################################################################
# This function is called before the input statement
#
    #_define_var - define local variables

    #_before_input
    #_end

end function
# BI_pnabsra()

######################################################################
function AI_pnabsra()
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
# AI_pnabsra()

######################################################################
function BF_pnabsra(field_name)
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
            if length(prv_fld) = 0
            then
               let prv_fld = "abs_rate3"
            end if
            call SK_pnabsra(prv_fld)
        #_end
      when scr_fld = "date_to"
        #_before_field date_to
            call SK_pnabsra(prv_fld)
        #_end
      when scr_fld = "block_cause_dc"
        #_before_field block_cause_dc
            if p_pnabsra[p_cur].block_cause_dc is null
            then
               call SK_pnabsra(prv_fld)
            end if
        #_end
        let scratch = "zoom"
      when scr_fld = "abs_cnt_fl"
        #_before_field abs_cnt_fl
            call SK_pnabsra(prv_fld)
        #_end
      when scr_fld = "abs_per_fl"
        #_before_field abs_per_fl
            call SK_pnabsra(prv_fld)
        #_end
      when scr_fld = "pay_amount"
        #_before_field pay_amount
            if q_pnabsra[p_cur].earn_no is not null
            then
            #   call SK_pnabsra(prv_fld)
            end if
        #_end
      when scr_fld = "pay_month"
        #_before_field pay_month
            if q_pnabsra[p_cur].earn_no is not null
            then
            #   call SK_pnabsra(prv_fld)
            end if
        #_end
      when scr_fld = "abs_perc"
        #_before_field abs_perc
            call SK_pnabsra(prv_fld)
        #_end
      when scr_fld = "abs_rate3"
        #_before_field abs_rate3
        #_end
      #_otherwise - otherwise clause
    end case

    #_nxt_fld - Programmed exit
    if nxt_fld is not null then return end if

    #_lib_before - Setup for lib_before
    let scr_fld = prv_fld
    call lib_before(field_name)

end function
# BF_pnabsra()

######################################################################
function AF_pnabsra()
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
      when scr_fld = "abs_cnt_fl"
        #_after_field abs_cnt_fl
        #_end
      when scr_fld = "abs_per_fl"
        #_after_field abs_per_fl
        #_end
      when scr_fld = "pay_amount"
        #_after_field pay_amount
        #_end
      when scr_fld = "pay_month"
        #_after_field pay_month
        #_end
      when scr_fld = "abs_perc"
        #_after_field abs_perc
        #_end
      when scr_fld = "abs_rate3"
        #_after_field abs_rate3
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
        if q_pnabsra[p_cur].row_id > 0
          then let q_pnabsra[p_cur].data_changed = true end if
        case
          when scr_fld = "date_from"
            #_after_change_in date_from
            #_end
          when scr_fld = "date_to"
            #_after_change_in date_to
            #_end
          when scr_fld = "block_cause_dc"
            # Perform lookups
            #_block_lk_block_cause_dc_lookup - Lookup block_lk for block_cause_dc
            if PL_pnabsra("block_lk", true) = false and
              length(this_data) != 0
            then
                let nxt_fld = "block_cause_dc"
                return
            end if
            #_after_change_in block_cause_dc
            #_end
          when scr_fld = "abs_cnt_fl"
            #_after_change_in abs_cnt_fl
            #_end
          when scr_fld = "abs_per_fl"
            #_after_change_in abs_per_fl
            #_end
          when scr_fld = "pay_amount"
            #_after_change_in pay_amount
                if q_pnabsra[p_cur].earn_no is not null
                then
                   call fg_er("UWAGA !!! Sprawd¼ zgodno¶æ z korekt± w kartotece zarobkowej.")
                end if
            #_end
          when scr_fld = "pay_month"
            #_after_change_in pay_month
            #_end
          when scr_fld = "abs_perc"
            #_after_change_in abs_perc
            #_end
          when scr_fld = "abs_rate3"
            #_after_change_in abs_rate3
            #_end
          #_otherwise - otherwise clause
        end case
    end if
    if nxt_fld is not null
    then
       return
    end if
    call pnabsra_req_dup_chk(scr_fld)

end function
# AF_pnabsra()

######################################################################
function EV_pnabsra()
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
         call set_zoom_code_column("pn_dict_pos.code")
         call set_zoom_desc_column("pn_dict_pos.descr")
         call set_join_filter("pn_dict_pos.type='block_cause'")
         call set_zoom_sort_column(" 1 dummy")
         if f_std_zoom("pn_dict_pos", "1=1")
         then
            let p_pnabsra[p_cur].block_cause_dc = scratch
            let nxt_fld = "block_cause_dc"
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
# EV_pnabsra()

######################################################################
function SD_pnabsra()
######################################################################
# This function is called to set the this_data global variable.
#
    #_define_var - define local variables
    define
       #_local_var - local variables
       tmp_str char(70)

    #_setdata - Set this_data variable
    case
      when scr_fld = "date_from"
        #_set_date_from
        call set_data(p_pnabsra[p_cur].date_from)
      when scr_fld = "date_to"
        #_set_date_to
        call set_data(p_pnabsra[p_cur].date_to)
      when scr_fld = "block_cause_dc"
        #_set_block_cause_dc
        call set_data(p_pnabsra[p_cur].block_cause_dc)
      when scr_fld = "abs_cnt_fl"
        #_set_abs_cnt_fl
        call set_data(p_pnabsra[p_cur].abs_cnt_fl)
      when scr_fld = "abs_per_fl"
        #_set_abs_per_fl
        call set_data(p_pnabsra[p_cur].abs_per_fl)
      when scr_fld = "pay_amount"
        #_set_pay_amount
        let tmp_str = dec_let(p_pnabsra[p_cur].pay_amount)
        call set_data(tmp_str)
      when scr_fld = "pay_month"
        #_set_pay_month
        call set_data(p_pnabsra[p_cur].pay_month)
      when scr_fld = "abs_perc"
        #_set_abs_perc
        let tmp_str = dec_let(p_pnabsra[p_cur].abs_perc)
        call set_data(tmp_str)
      when scr_fld = "abs_rate3"
        #_set_abs_rate3
        let tmp_str = dec_let(p_pnabsra[p_cur].abs_rate3)
        call set_data(tmp_str)
      #_otherwise - otherwise clause
    end case

end function
# SD_pnabsra()

######################################################################
function HI_pnabsra()
######################################################################
# This function highlights the specified field name.
# Only input type fields need to be specified.
#
    #_define_var - define local variables

    #_highlight - Highlight current field data
    case
      when scr_fld = "date_from"
        #_dsp_date_from
        display p_pnabsra[p_cur].date_from
          to s_pnabsra[s_cur].date_from attribute(reverse)
      when scr_fld = "date_to"
        #_dsp_date_to
        display p_pnabsra[p_cur].date_to
          to s_pnabsra[s_cur].date_to attribute(reverse)
      when scr_fld = "block_cause_dc"
        #_dsp_block_cause_dc
        display p_pnabsra[p_cur].block_cause_dc
          to s_pnabsra[s_cur].block_cause_dc attribute(reverse)
      when scr_fld = "abs_cnt_fl"
        #_dsp_abs_cnt_fl
        display p_pnabsra[p_cur].abs_cnt_fl
          to s_pnabsra[s_cur].abs_cnt_fl attribute(reverse)
      when scr_fld = "abs_per_fl"
        #_dsp_abs_per_fl
        display p_pnabsra[p_cur].abs_per_fl
          to s_pnabsra[s_cur].abs_per_fl attribute(reverse)
      when scr_fld = "pay_amount"
        #_dsp_pay_amount
        display p_pnabsra[p_cur].pay_amount
          to s_pnabsra[s_cur].pay_amount attribute(reverse)
      when scr_fld = "pay_month"
        #_dsp_pay_month
        display p_pnabsra[p_cur].pay_month
          to s_pnabsra[s_cur].pay_month attribute(reverse)
      when scr_fld = "abs_perc"
        #_dsp_abs_perc
        display p_pnabsra[p_cur].abs_perc
          to s_pnabsra[s_cur].abs_perc attribute(reverse)
      when scr_fld = "abs_rate3"
        #_dsp_abs_rate3
        display p_pnabsra[p_cur].abs_rate3
          to s_pnabsra[s_cur].abs_rate3 attribute(reverse)
      #_otherwise - otherwise clause
    end case

end function
# HI_pnabsra()

######################################################################
function SH_pnabsra()
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
        display p_pnabsra[m + n].* to s_pnabsra[n].*  attribute(red)
    end for

end function
# SH_pnabsra()

######################################################################
function SL_pnabsra()
######################################################################
# This function displays all p_* variables to the screen
#
    #_define_var - define local variables

    #_first_show - call showdata function on first call
    if first_show is null
    then
        let first_show = "Y"
        call SH_pnabsra()
        let p_cur = 1
    end if

    #_showdata - Display rows to detail screen
    display p_pnabsra[p_cur].* to s_pnabsra[s_cur].* attribute(red)


end function
# SL_pnabsra()

######################################################################
function F_pnabsra()
######################################################################
# This function is used as the custom data flow control manager
#
    #_define_var - define local variables

    #_flow - custom flow control manager

end function
# F_pnabsra()

######################################################################
function R_pnabsra()
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
        "abs_rate_num,",
        "abs_num,",
        "dor_num,",
        "earn_no,",
        "date_from,",
        "date_to,",
        "block_cause_dc,",
        "abs_days,",
        "abs_cnt_days,",
        "abs_per_days,",
        "abs_cnt_fl,",
        "abs_per_fl,",
        "abs_base,",
        "abs_rate1,",
        "abs_rate2,",
        "abs_rate3,",
        "abs_perc,",
        "pay_month,",
        "pay_amount ",
        " from pn_absen_rates ",
        "where pn_absen_rates.abs_num = ?"

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
        #_use_hard_order - as found in the pnabsra.per
        let scratch = scratch clipped, " order by date_from"
    end if

    #_prep_curs - Prepare the SQL string for execution
    prepare a_pnabsra from scratch
    declare c_pnabsra cursor for a_pnabsra

    #_read_dtl - Read in the detail lines
        let p_cur = 1
        open c_pnabsra using m_bsence.abs_num

    #_read_data - Read in the detail data
    while true

        #_max_read - maximum number of elements read
        if p_cur = arr_max then exit while end if

        #_fetch - fetch statement
        fetch c_pnabsra into q_pnabsra[p_cur].row_id,
            q_pnabsra[p_cur].abs_rate_num,
            q_pnabsra[p_cur].abs_num,
            q_pnabsra[p_cur].dor_num,
            q_pnabsra[p_cur].earn_no,
            p_pnabsra[p_cur].date_from,
            p_pnabsra[p_cur].date_to,
            p_pnabsra[p_cur].block_cause_dc,
            p_pnabsra[p_cur].abs_days,
            p_pnabsra[p_cur].abs_cnt_days,
            p_pnabsra[p_cur].abs_per_days,
            p_pnabsra[p_cur].abs_cnt_fl,
            p_pnabsra[p_cur].abs_per_fl,
            p_pnabsra[p_cur].abs_base,
            p_pnabsra[p_cur].abs_rate1,
            p_pnabsra[p_cur].abs_rate2,
            p_pnabsra[p_cur].abs_rate3,
            p_pnabsra[p_cur].abs_perc,
            p_pnabsra[p_cur].pay_month,
            p_pnabsra[p_cur].pay_amount
        if sqlca.sqlcode = notfound
        then
            let p_cur = p_cur - 1
            exit while
        end if
        #_on_disk_read
        #_end

        #_lookups - Perform lookups
          #_lkup_block_lk - block_lk lookup
          if PL_pnabsra("block_lk",false) then end if
        let p_cur = p_cur + 1


    end while

    #_close_curs - close cursor statement
    close c_pnabsra
    let arr_cnt = p_cur
    let p_cur = 1
    let s_cur = 1

    #_set_cnt - set record count
    call set_count(arr_cnt)

end function
# R_pnabsra()

######################################################################
function W_pnabsra()
######################################################################
# This function writes the program variables to disk.
#
    #_define_var - define local variables

    define
        n            smallint  # working number

    #_row_maintenance - either update or insert existing
    for p_cur = 1 to arr_cnt
        if pnabsra_empty_line(p_cur)
        then
           if q_pnabsra[p_cur].row_id > 0
           then
              delete from pn_absen_rates
              where pn_absen_rates.rowid = q_pnabsra[p_cur].row_id
           end if
           continue for
        end if
        #_update_check - check for update
        if q_pnabsra[p_cur].row_id > 0 and q_pnabsra[p_cur].data_changed
        then
            #_update - Update the existing row
            update pn_absen_rates set
                abs_num = q_pnabsra[p_cur].abs_num,
                dor_num = q_pnabsra[p_cur].dor_num,
                earn_no = q_pnabsra[p_cur].earn_no,
                date_from = p_pnabsra[p_cur].date_from,
                date_to = p_pnabsra[p_cur].date_to,
                block_cause_dc = p_pnabsra[p_cur].block_cause_dc,
                abs_days = p_pnabsra[p_cur].abs_days,
                abs_cnt_days = p_pnabsra[p_cur].abs_cnt_days,
                abs_per_days = p_pnabsra[p_cur].abs_per_days,
                abs_cnt_fl = p_pnabsra[p_cur].abs_cnt_fl,
                abs_per_fl = p_pnabsra[p_cur].abs_per_fl,
                abs_base = p_pnabsra[p_cur].abs_base,
                abs_rate1 = p_pnabsra[p_cur].abs_rate1,
                abs_rate2 = p_pnabsra[p_cur].abs_rate2,
                abs_rate3 = p_pnabsra[p_cur].abs_rate3,
                abs_perc = p_pnabsra[p_cur].abs_perc,
                pay_month = p_pnabsra[p_cur].pay_month,
                pay_amount = p_pnabsra[p_cur].pay_amount
            where rowid = q_pnabsra[p_cur].row_id
        end if

        #_insert_check - check for insert
        if q_pnabsra[p_cur].row_id = 0 or q_pnabsra[p_cur].row_id is null
        then
            #_join_elems - prep the join elements
                let q_pnabsra[p_cur].abs_num = m_bsence.abs_num
            #_insert_row - Insert the new row
            insert into pn_absen_rates (
                abs_rate_num, abs_num, dor_num, earn_no, date_from,
                date_to, block_cause_dc, abs_days, abs_cnt_days,
                abs_per_days, abs_cnt_fl, abs_per_fl, abs_base,
                abs_rate1, abs_rate2, abs_rate3, abs_perc, pay_month,
                pay_amount)
            values (
                0, q_pnabsra[p_cur].abs_num, q_pnabsra[p_cur].dor_num,
                q_pnabsra[p_cur].earn_no, p_pnabsra[p_cur].date_from,
                p_pnabsra[p_cur].date_to,
                p_pnabsra[p_cur].block_cause_dc,
                p_pnabsra[p_cur].abs_days,
                p_pnabsra[p_cur].abs_cnt_days,
                p_pnabsra[p_cur].abs_per_days,
                p_pnabsra[p_cur].abs_cnt_fl,
                p_pnabsra[p_cur].abs_per_fl, p_pnabsra[p_cur].abs_base,
                p_pnabsra[p_cur].abs_rate1, p_pnabsra[p_cur].abs_rate2,
                p_pnabsra[p_cur].abs_rate3, p_pnabsra[p_cur].abs_perc,
                p_pnabsra[p_cur].pay_month,
                p_pnabsra[p_cur].pay_amount)

        end if
    end for

    #_row_deletion - delete all rows that where marked for deletion
    for n = 1 to del_cnt
        #_delete_row - delete this row
        delete from pn_absen_rates where rowid = del_rows[n]
    end for

end function
# W_pnabsra()

######################################################################
function PR_pnabsra()
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
          when get_name = "date_from"
            let p_pnabsra[p_cur].date_from = get_data
          when get_name = "date_to"
            let p_pnabsra[p_cur].date_to = get_data
          when get_name = "block_cause_dc"
            let p_pnabsra[p_cur].block_cause_dc = get_data
          when get_name = "abs_days"
            let p_pnabsra[p_cur].abs_days = get_data
          when get_name = "abs_cnt_days"
            let p_pnabsra[p_cur].abs_cnt_days = get_data
          when get_name = "abs_cnt_fl"
            let p_pnabsra[p_cur].abs_cnt_fl = get_data
          when get_name = "abs_per_days"
            let p_pnabsra[p_cur].abs_per_days = get_data
          when get_name = "abs_per_fl"
            let p_pnabsra[p_cur].abs_per_fl = get_data
          when get_name = "pay_amount"
            let p_pnabsra[p_cur].pay_amount = get_data
          when get_name = "pay_month"
            let p_pnabsra[p_cur].pay_month = get_data
          when get_name = "abs_base"
            let p_pnabsra[p_cur].abs_base = get_data
          when get_name = "abs_rate1"
            let p_pnabsra[p_cur].abs_rate1 = get_data
          when get_name = "abs_perc"
            let p_pnabsra[p_cur].abs_perc = get_data
          when get_name = "abs_rate2"
            let p_pnabsra[p_cur].abs_rate2 = get_data
          when get_name = "abs_rate3"
            let p_pnabsra[p_cur].abs_rate3 = get_data

          #_q_read - Read the Q record
          when get_name = "abs_rate_num"
            let q_pnabsra[p_cur].abs_rate_num = get_data
          when get_name = "abs_num"
            let q_pnabsra[p_cur].abs_num = get_data
          when get_name = "dor_num"
            let q_pnabsra[p_cur].dor_num = get_data
          when get_name = "earn_no"
            let q_pnabsra[p_cur].earn_no = get_data

          #_otherwise - otherwise clause
        end case
    end while

    #_lookups - Perform lookups
    if PL_pnabsra("block_lk",false) then end if

    #_on_program_read - program read

end function
# PR_pnabsra()

######################################################################
function PW_pnabsra()
######################################################################
# This function writes the p_ & q_ records to the temp table
#
    #_define_var - define local variables
    define
       #_local_var - local variables
       tmp_str char(70)

    #_p_write - Write the P record to the temp table
    call t_write(p_cur, "date_from", p_pnabsra[p_cur].date_from)
    call t_write(p_cur, "date_to", p_pnabsra[p_cur].date_to)
    call t_write(p_cur, "block_cause_dc", p_pnabsra[p_cur].block_cause_dc)
    call t_write(p_cur, "abs_days", p_pnabsra[p_cur].abs_days)
    call t_write(p_cur, "abs_cnt_days", p_pnabsra[p_cur].abs_cnt_days)
    call t_write(p_cur, "abs_cnt_fl", p_pnabsra[p_cur].abs_cnt_fl)
    call t_write(p_cur, "abs_per_days", p_pnabsra[p_cur].abs_per_days)
    call t_write(p_cur, "abs_per_fl", p_pnabsra[p_cur].abs_per_fl)
    let tmp_str = dec_let(p_pnabsra[p_cur].pay_amount)
    call t_write(p_cur, "pay_amount", tmp_str)
    call t_write(p_cur, "pay_month", p_pnabsra[p_cur].pay_month)
    let tmp_str = dec_let(p_pnabsra[p_cur].abs_base)
    call t_write(p_cur, "abs_base", tmp_str)
    let tmp_str = dec_let(p_pnabsra[p_cur].abs_rate1)
    call t_write(p_cur, "abs_rate1", tmp_str)
    let tmp_str = dec_let(p_pnabsra[p_cur].abs_perc)
    call t_write(p_cur, "abs_perc", tmp_str)
    let tmp_str = dec_let(p_pnabsra[p_cur].abs_rate2)
    call t_write(p_cur, "abs_rate2", tmp_str)
    let tmp_str = dec_let(p_pnabsra[p_cur].abs_rate3)
    call t_write(p_cur, "abs_rate3", tmp_str)

    #_q_write - Write the Q record
    call t_write(p_cur, "abs_rate_num", q_pnabsra[p_cur].abs_rate_num)
    call t_write(p_cur, "abs_num", q_pnabsra[p_cur].abs_num)
    call t_write(p_cur, "dor_num", q_pnabsra[p_cur].dor_num)
    call t_write(p_cur, "earn_no", q_pnabsra[p_cur].earn_no)

    #_on_program_write - program write

end function
# PW_pnabsra()

######################################################################
function PL_pnabsra(tbl_name, mustfind)
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
        let scratch = "select rowid ",
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
        open cur_block_lk using p_pnabsra[p_cur].block_cause_dc
        #_fetch - fetch the p record
        fetch cur_block_lk into scratch
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
            initialize scratch to null
          #_otherwise - otherwise clause
        end case
        return false
    else
        return true
    end if

end function
# PL_pnabsra()

######################################################################
function DF_pnabsra()
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
# DF_pnabsra()

######################################################################
function AC_pnabsra()
######################################################################
# This function sets arr_cnt to the correct number of array elements.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        n smallint

    #_arr_count - Array count
    for n = arr_count() to 1 step -1
        if p_pnabsra[n].date_from is not null
          or p_pnabsra[n].date_to is not null
          or p_pnabsra[n].block_cause_dc is not null
          or p_pnabsra[n].abs_days is not null
          or p_pnabsra[n].abs_cnt_days is not null
          or p_pnabsra[n].abs_cnt_fl is not null
          or p_pnabsra[n].abs_per_days is not null
          or p_pnabsra[n].abs_per_fl is not null
          or p_pnabsra[n].pay_amount is not null
          or p_pnabsra[n].pay_month is not null
          or p_pnabsra[n].abs_base is not null
          or p_pnabsra[n].abs_rate1 is not null
          or p_pnabsra[n].abs_perc is not null
          or p_pnabsra[n].abs_rate2 is not null
          or p_pnabsra[n].abs_rate3 is not null
          or q_pnabsra[n].row_id is not null
        then
            let arr_cnt = n
            return
        end if
    end for

    #_arr_cnt - set arr_cnt
    let arr_cnt = 0

end function
# AC_pnabsra()

######################################################################
function SK_pnabsra(prv_fld)
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
          then let nxt_fld = "abs_rate3"
          else let nxt_fld = "date_to"
        end if
      #_date_to - Skip logic for date_to
      when scr_fld = "date_to"
        if prv_fld = "block_cause_dc"
          then let nxt_fld = "date_from"
          else let nxt_fld = "block_cause_dc"
        end if
      #_block_cause_dc - Skip logic for block_cause_dc
      when scr_fld = "block_cause_dc"
        if prv_fld = "abs_cnt_fl"
          then let nxt_fld = "date_to"
          else let nxt_fld = "abs_cnt_fl"
        end if
      #_abs_cnt_fl - Skip logic for abs_cnt_fl
      when scr_fld = "abs_cnt_fl"
        if prv_fld = "abs_per_fl"
          then let nxt_fld = "block_cause_dc"
          else let nxt_fld = "abs_per_fl"
        end if
      #_abs_per_fl - Skip logic for abs_per_fl
      when scr_fld = "abs_per_fl"
        if prv_fld = "pay_amount"
          then let nxt_fld = "abs_cnt_fl"
          else let nxt_fld = "pay_amount"
        end if
      #_pay_amount - Skip logic for pay_amount
      when scr_fld = "pay_amount"
        if prv_fld = "pay_month"
          then let nxt_fld = "abs_per_fl"
          else let nxt_fld = "pay_month"
        end if
      #_pay_month - Skip logic for pay_month
      when scr_fld = "pay_month"
        if prv_fld = "abs_perc"
          then let nxt_fld = "pay_amount"
          else let nxt_fld = "abs_perc"
        end if
      #_abs_perc - Skip logic for abs_perc
      when scr_fld = "abs_perc"
        if prv_fld = "abs_rate3"
          then let nxt_fld = "pay_month"
          else let nxt_fld = "abs_rate3"
        end if
      #_abs_rate3 - Skip logic for abs_rate3
      when scr_fld = "abs_rate3"
        if prv_fld = "date_from"
          then let nxt_fld = "abs_perc"
          else let nxt_fld = "date_from"
        end if
    end case

end function
# SK_pnabsra()

######################################################################
function Z_pnabsra()
######################################################################
# This function is called upon return from this screen.
#
    #_define_var - define local variables

    #_close - Close the window and make the data available
    if open_level = 1
    then
        close window win_pnabsra
    end if
    #_reset_open - reset open level
    let open_level = open_level - 1

    #_on_exit
    #_end

end function
# Z_pnabsra()
######################################################################
function pnabsra_req_dup_chk(scr_fld)
######################################################################
#
define
   scr_fld char(80)

   if after_row_occured(scr_fld = "abs_rate3")
   then
      if not pnabsra_empty_line(p_cur)
      then
         case
            when p_pnabsra[p_cur].date_from is null
               let nxt_fld = "date_from"
               call scr_error("required", nxt_fld)
         end case
      end if
      if nxt_fld is not null
      then
         return
      end if
      if not pnabsra_dup_chk(p_cur)
      then
         return
      end if
      if ((p_cur + scr_max) > arr_cnt
          and fgl_lastkey() = fgl_keyval("nextpage"))
         or (p_cur = arr_cnt
             and (fgl_lastkey() = fgl_keyval("down")
                  or fgl_lastkey() = fgl_keyval("nextpage")
                  or fgl_lastkey() = fgl_keyval("return")))
      then
          let nxt_fld = scr_fld
          error " There are no more rows in the direction you are going "
          return
      end if
   end if

end function
# pnabsra_req_dup_chk()


######################################################################
function pnabsra_empty_line(idx)
######################################################################
#
define
   idx smallint

   if p_pnabsra[idx].date_from is null
      and p_pnabsra[idx].date_to is null
   then
      return true
   end if

   return false

end function
# pnabsra_empty_line()


######################################################################
function pnabsra_dup_chk(idx)
######################################################################
#
define
   idx smallint,
   i   smallint

   for i = 1 to arr_count()
      if i != idx
      then
         #if p_pnabsra[idx].attr_grp_cd = p_pnabsra[i].attr_grp_cd
         #then
         #   call fg_er("Kody grup atrybutów pokrywaj± siê !!!")
         #   let nxt_fld = "attr_grp_cd"
         #   return false
         #end if
      end if
   end for

   return true

end function
# pnabsra_dup_chk()
