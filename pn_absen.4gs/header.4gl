######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################
# Screen Generator version: 4.10.UC1

globals "globals.4gl"

# Local (static) variables
define
    lookup_prep char(1), # Have the lookups been prepared?
    select_prep char(1), # Has the select statement been prepared?
    dup_prep char(1),    # Has the duplicate check been prepared?
    defaulted char(1),   # Has the defaulting been done?
    exit_level smallint, # 0=input, 1=field
    tab_pressed smallint # (boolean) was the tab key pressed?

######################################################################
function llh_input()
######################################################################
# returning -1 if tab pressed (next window), 0 otherwise
# This is the main input function
#
    #_define_var - define local variables

    #_err - Trap fatal errors
    whenever error call error_handler

    #_init - Initialize variables
    let exit_level = 0
    let tab_pressed = false

    #_defaults - default program variables
    call llh_defaults()

    #_before_input
        call cdisplay(102)
        call cdisplay(103)
        if menu_item = "add"
        then
           let p_bsence.ins_ref_cd = get_ref_cd(fg_username())
           let p_bsence.ins_date = today
        else
           let p_bsence.upd_ref_cd = get_ref_cd(fg_username())
           let p_bsence.upd_date = today
        end if
        if get_cur_screen() <> "pn_absen"
        then
           return -1
        end if
        call bdisplay(107, "PRZELICZ")
        if length(p_bsence.abs_code) > 0
        then
           if get_abs_type() then end if
        end if
    #_end

    #_input - Main input loop
    input p_bsence.* without defaults from s_pnabsen.*

      # All entry fields must have before and after field processing

      #_bf_field - Before field logic
      before field addr_nr call llh_b_field("pn_absence.addr_nr")
        goto next_field
      before field name_1 call llh_b_field("v_address.name_1")
        goto next_field
      before field abs_code call llh_b_field("pn_absence.abs_code")
        goto next_field
      before field date_from call llh_b_field("pn_absence.date_from")
        goto next_field
      before field date_to call llh_b_field("pn_absence.date_to")
        goto next_field
      before field abs_hours call llh_b_field("pn_absence.abs_hours")
        goto next_field
      before field first_abs_num call llh_b_field("pn_absence.first_abs_num")
        goto next_field
      before field first_abs_code call llh_b_field("formonly.first_abs_code")
        goto next_field
      before field abs_doc_type_dc call llh_b_field("pn_absence.abs_doc_type_dc")
        goto next_field
      before field abs_stat_code call llh_b_field("pn_absence.abs_stat_code")
        goto next_field
      before field ins_ref_cd call llh_b_field("pn_absence.ins_ref_cd")
        goto next_field
      before field upd_ref_cd call llh_b_field("pn_absence.upd_ref_cd")
        goto next_field

      #_af_field - After field logic
      after field addr_nr call llh_a_field()
        goto next_field
      after field name_1 call llh_a_field()
        goto next_field
      after field abs_code call llh_a_field()
        goto next_field
      after field date_from call llh_a_field()
        goto next_field
      after field date_to call llh_a_field()
        goto next_field
      after field abs_hours call llh_a_field()
        goto next_field
      after field first_abs_num call llh_a_field()
        goto next_field
      after field first_abs_code call llh_a_field()
        goto next_field
      after field abs_doc_type_dc call llh_a_field()
        goto next_field
      after field abs_stat_code call llh_a_field()
        goto next_field
      after field ins_ref_cd call llh_a_field()
        goto next_field
      after field upd_ref_cd call llh_a_field()
        goto next_field

      #_af_input - After input logic
      after input
        label end_input:
        let nxt_fld = null

        #_exit_input - Exit directly upon interrupt
        if int_flag
        then
            exit input
        end if

        #_run_afield - Run the 'after field' logic if necessary
        if exit_level >= 1 then call llh_a_field() end if
        if nxt_fld is not null then goto next_field end if

        #_run_ainput - Run the 'after input' logic before exiting input
        call llh_a_input()
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
        call hot_key("llh_input")   # Map the key to the event
        #_hot_event - event handler
        call llh_event()

      #_nxt_fld - Programmatic next field logic
      label next_field:
        let scratch = nxt_fld
        let nxt_fld = null
        case
          when scratch is null  # No need to go through 'case'
          when scratch = "addr_nr" next field addr_nr
          when scratch = "name_1" next field name_1
          when scratch = "name_2" next field name_2
          when scratch = "abs_code" next field abs_code
          when scratch = "abs_name" next field abs_name
          when scratch = "date_from" next field date_from
          when scratch = "date_to" next field date_to
          when scratch = "abs_days" next field abs_days
          when scratch = "abs_hours" next field abs_hours
          when scratch = "abs_work_days" next field abs_work_days
          when scratch = "abs_work_hours" next field abs_work_hours
          when scratch = "days_avail_limit" next field days_avail_limit
          when scratch = "hours_avail_limit" next field hours_avail_limit
          when scratch = "abs_absolute" next field abs_absolute
          when scratch = "abs_absol_days" next field abs_absol_days
          when scratch = "days_used_limit" next field days_used_limit
          when scratch = "hours_used_limit" next field hours_used_limit
          when scratch = "first_abs_num" next field first_abs_num
          when scratch = "first_abs_code" next field first_abs_code
          when scratch = "first_date_from" next field first_date_from
          when scratch = "first_date_to" next field first_date_to
          when scratch = "abs_doc_type_dc" next field abs_doc_type_dc
          when scratch = "abs_doc_desc" next field abs_doc_desc
          when scratch = "abs_stat_code" next field abs_stat_code
          when scratch = "ins_ref_cd" next field ins_ref_cd
          when scratch = "ins_date" next field ins_date
          when scratch = "upd_ref_cd" next field upd_ref_cd
          when scratch = "upd_date" next field upd_date
          when scratch = "exit input" goto end_input
          when scratch = "event" goto event
          #_otherwise - otherwise clause
        end case

    #_end_input - end input statement
    end input

    #_tab_pressed - Return -1 if tab was pressed
    if tab_pressed
      then return -1
      else return 0
    end if

end function
# llh_input()

######################################################################
function llh_a_input()
######################################################################
# This function is called whenever the input statement exits
# (except due to an interrupt).  If you don't want the input session
# to end, set the nxt_fld variable to contain the field to be placed
# back into.
#
    #_define_var - define local variables

    #_after_input
    #_end

    case
      #_required_addr_nr - required field logic
      when p_bsence.addr_nr is null
        let nxt_fld = "addr_nr"
        call scr_error("required", nxt_fld)
      #_required_date_from - required field logic
      when p_bsence.date_from is null
        let nxt_fld = "date_from"
        call scr_error("required", nxt_fld)
      #_required_date_to - required field logic
      when p_bsence.date_to is null
        let nxt_fld = "date_to"
        call scr_error("required", nxt_fld)
    end case

    #_nxt_fld - Programmed exit
    if nxt_fld is not null then return end if

end function
# llh_a_input()

######################################################################
function llh_b_field(field_name)
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

    #_field_name - Convert field_name from 'tab.col' to 'col'
    let field_name = set_fldtab(field_name)

    #_init - Rearrange field names
    let prv_fld = scr_fld
    let scr_fld = field_name
    let nxt_fld = null

    #_exit_level - Require field level exit
    let exit_level = 1

    #_before_field_logic - only if work needs to be done.
    case
      when scr_fld = "addr_nr"
        #_before_field addr_nr
            if length(prv_fld) = 0
            then
               let prv_fld = "upd_ref_cd"
            end if
            if get_pay_rates()
            then
               call llh_skip(prv_fld)
               return
            end if
        #_end
        let scratch = "zoom"
      when scr_fld = "name_1"
        #_before_field name_1
            call llh_skip(prv_fld)
        #_end
      when scr_fld = "abs_code"
        #_before_field abs_code
            if get_pay_rates()
            then
               call llh_skip(prv_fld)
               return
            end if
        #_end
        let scratch = "zoom"
      when scr_fld = "date_from"
        #_before_field date_from
            if get_pay_rates()
            then
               call llh_skip(prv_fld)
               return
            end if
            if p_bsence.addr_nr is null
            then
               let nxt_fld = "addr_nr"
               call scr_error("required", nxt_fld)
               return
            end if
            if length(p_bsence.abs_code) = 0
            then
               let nxt_fld = "abs_code"
               call scr_error("required", nxt_fld)
               return
            end if
        #_end
      when scr_fld = "date_to"
        #_before_field date_to
            if get_pay_rates()
            then
               call llh_skip(prv_fld)
               return
            end if
            if p_bsence.addr_nr is null
            then
               let nxt_fld = "addr_nr"
               call scr_error("required", nxt_fld)
               return
            end if
            if length(p_bsence.abs_code) = 0
            then
               let nxt_fld = "abs_code"
               call scr_error("required", nxt_fld)
               return
            end if
        #_end
      when scr_fld = "abs_hours"
        #_before_field abs_hours
            call llh_skip(prv_fld)
        #_end
      when scr_fld = "first_abs_num"
        #_before_field first_abs_num
            if get_pay_rates()
            then
               call llh_skip(prv_fld)
               return
            end if
        #_end
        let scratch = "zoom"
      when scr_fld = "first_abs_code"
        #_before_field first_abs_code
            call llh_skip(prv_fld)
        #_end
      when scr_fld = "abs_doc_type_dc"
        #_before_field abs_doc_type_dc
        #_end
        let scratch = "zoom"
      when scr_fld = "abs_stat_code"
        #_before_field abs_stat_code
        #_end
      when scr_fld = "ins_ref_cd"
        #_before_field ins_ref_cd
            call llh_skip(prv_fld)
        #_end
      when scr_fld = "upd_ref_cd"
        #_before_field upd_ref_cd
            call llh_skip(prv_fld)
        #_end
      #_otherwise - otherwise clause
    end case

    #_ret - Programmed exit
    if nxt_fld is not null then return end if

    #_lib_before - Setup for lib_before
    let scr_fld = prv_fld
    call lib_before(field_name)

end function
# llh_b_field()

######################################################################
function llh_a_field()
######################################################################
# This function is called after every field.
#
    #_define_var - define local variables

    #_init - Reset nxt_fld
    let nxt_fld = null

    #_exit_level - set exit level
    let exit_level = 0

    #_after_field_logic - After field logic
    case
      when scr_fld = "addr_nr"
        #_after_field addr_nr
        #_end
      when scr_fld = "name_1"
        #_after_field name_1
        #_end
      when scr_fld = "abs_code"
        #_after_field abs_code
        #_end
      when scr_fld = "date_from"
        #_after_field date_from
        #_end
      when scr_fld = "date_to"
        #_after_field date_to
        #_end
      when scr_fld = "abs_hours"
        #_after_field abs_hours
        #_end
      when scr_fld = "first_abs_num"
        #_after_field first_abs_num
        #_end
      when scr_fld = "first_abs_code"
        #_after_field first_abs_code
        #_end
      when scr_fld = "abs_doc_type_dc"
        #_after_field abs_doc_type_dc
        #_end
      when scr_fld = "abs_stat_code"
        #_after_field abs_stat_code
        #_end
      when scr_fld = "ins_ref_cd"
        #_after_field ins_ref_cd
        #_end
      when scr_fld = "upd_ref_cd"
        #_after_field upd_ref_cd
        #_end
      #_otherwise - otherwise clause
    end case

    #_ret - Programmed exit
    if nxt_fld is not null then return end if

    #_lib_after - This (among other things) sets data_changed
    call lib_after()

    #_data_changed - After data_changed logic
    if data_changed
    then
        case
          when scr_fld = "addr_nr"
            # Perform lookups
            #_personal_lk_addr_nr_lookup - Lookup personal_lk for addr_nr
            if llh_lookup("personal_lk", true) = false and
              length(this_data) != 0
            then
                let nxt_fld = "addr_nr"
                return
            end if
            #_address_lk_addr_nr_lookup - Lookup address_lk for addr_nr
            if llh_lookup("address_lk", true) = false and
              length(this_data) != 0
            then
                let nxt_fld = "addr_nr"
                return
            end if
            #_after_change_in addr_nr
            #_end
          when scr_fld = "name_1"
            #_after_change_in name_1
            #_end
          when scr_fld = "abs_code"
            # Perform lookups
            #_abs_code_lk_abs_code_lookup - Lookup abs_code_lk for abs_code
            if llh_lookup("abs_code_lk", true) = false and
              length(this_data) != 0
            then
                let nxt_fld = "abs_code"
                return
            end if
            #_after_change_in abs_code
                if length(p_bsence.abs_code) > 0
                   and not get_abs_type()
                then
                   let nxt_fld = "abs_code"
                end if
            #_end
          when scr_fld = "date_from"
            #_after_change_in date_from
            #_end
          when scr_fld = "date_to"
            #_after_change_in date_to
            #_end
          when scr_fld = "abs_hours"
            #_after_change_in abs_hours
            #_end
          when scr_fld = "first_abs_num"
            # Perform lookups
            #_first_abs_lk_first_abs_num_lookup - Lookup first_abs_lk for first_abs_num
            if llh_lookup("first_abs_lk", true) = false and
              length(this_data) != 0
            then
                let nxt_fld = "first_abs_num"
                return
            end if
            #_after_change_in first_abs_num
                if p_bsence.first_abs_num is not null
                   and (p_bsence.date_to - p_bsence.first_date_from) > get_abs_param(2)
                then
                   call fg_er("UWAGA - Przekroczono maksymaln± ilo¶æ dni absencji ci±g³ej !!!")
                end if
            #_end
          when scr_fld = "first_abs_code"
            #_after_change_in first_abs_code
            #_end
          when scr_fld = "abs_doc_type_dc"
            # Perform lookups
            #_abs_doc_lk_abs_doc_type_dc_lookup - Lookup abs_doc_lk for abs_doc_type_dc
            if llh_lookup("abs_doc_lk", true) = false and
              length(this_data) != 0
            then
                let nxt_fld = "abs_doc_type_dc"
                return
            end if
            #_after_change_in abs_doc_type_dc
            #_end
          when scr_fld = "abs_stat_code"
            #_after_change_in abs_stat_code
            #_end
          when scr_fld = "ins_ref_cd"
            #_after_change_in ins_ref_cd
            #_end
          when scr_fld = "upd_ref_cd"
            #_after_change_in upd_ref_cd
            #_end
          #_otherwise - otherwise clause
        end case
    end if
    if data_changed
       and nxt_fld is null
    then
       call chk_absence()
    end if

end function
# llh_a_field()

######################################################################
function llh_event()
######################################################################
# This function is called whenever the user presses an event key.
# The event is mapped to the 'scr_funct' variable and processed here.
#
    #_define_var - define local variables

    #_init - Reset tab pressed to false
    let tab_pressed = false

    #_on_event - Local event processing
    case
      #_zoom_abs_code
      when scr_funct = "zoom" and infield(abs_code)
         call set_zoom_code_column("pn_abs_type.abs_code")
         call set_zoom_desc_column("pn_abs_type.abs_name")
         call set_zoom_sort_column("1 dummy")
         if f_std_zoom("pn_abs_type", "1=1")
         then
            let p_bsence.abs_code = scratch
            let nxt_fld = "abs_code"
         end if
      #_zoom_addr_nr
      when scr_funct = "zoom" and infield(addr_nr)
        let scratch =
          " 1 = 1"
        if zoom("persz","(see scratch)")
        then
            let p_bsence.addr_nr = scratch
            let nxt_fld = "addr_nr"
        end if
      #_zoom_abs_doc_type_dc
      when scr_funct = "zoom" and infield(abs_doc_type_dc)
         call set_zoom_code_column("pn_dict_pos.code")
         call set_zoom_desc_column("pn_dict_pos.descr")
         call set_zoom_sort_column("1 dummy")
         call set_join_filter("pn_dict_pos.type = 'abs_doc_type'")
         if f_std_zoom("pn_dict_pos", "1=1")
         then
            let p_bsence.abs_doc_type_dc = scratch
            let nxt_fld = "abs_doc_type_dc"
         end if
      #_zoom_first_abs_num
      when scr_funct = "zoom" and infield(first_abs_num)
         call set_zoom_code_column("pn_absence.abs_num")
         call set_zoom_desc_column("pn_absence.abs_code||' '||pn_absence.date_from||'-'||pn_absence.date_to")
         call set_zoom_sort_column("pn_absence.date_from desc")
         let scratch = p_bsence.addr_nr
         let scratch = "pn_absence.addr_nr = ", scratch clipped
         if q_bsence.abs_num > 0
         then
            let scratch = scratch clipped,
                          " and pn_absence.abs_num != ", q_bsence.abs_num
         end if
         call set_join_filter(scratch clipped)
         if f_std_zoom("pn_absence", "1=1")
         then
            let p_bsence.first_abs_num = scratch
            let nxt_fld = "first_abs_num"
         end if
        when scr_funct = "abscount"
          #_on_event abscount
      or hotkey = 107
         call chk_absence()
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
# llh_event()

######################################################################
function llh_setdata()
######################################################################
# This function is called to set the this_data global variable.
#
    #_define_var - define local variables
    define
       #_local_var - local variables
       tmp_str char(70)

    #_set_this_data - Set this_data variable
    case
      when scr_fld = "addr_nr"
        #_set_addr_nr
        call set_data(p_bsence.addr_nr)
      when scr_fld = "name_1"
        #_set_name_1
        call set_data(p_bsence.name_1)
      when scr_fld = "abs_code"
        #_set_abs_code
        call set_data(p_bsence.abs_code)
      when scr_fld = "date_from"
        #_set_date_from
        call set_data(p_bsence.date_from)
      when scr_fld = "date_to"
        #_set_date_to
        call set_data(p_bsence.date_to)
      when scr_fld = "abs_hours"
        #_set_abs_hours
        let tmp_str = dec_let(p_bsence.abs_hours)
        call set_data(tmp_str)
      when scr_fld = "first_abs_num"
        #_set_first_abs_num
        call set_data(p_bsence.first_abs_num)
      when scr_fld = "first_abs_code"
        #_set_first_abs_code
        call set_data(p_bsence.first_abs_code)
      when scr_fld = "abs_doc_type_dc"
        #_set_abs_doc_type_dc
        call set_data(p_bsence.abs_doc_type_dc)
      when scr_fld = "abs_stat_code"
        #_set_abs_stat_code
        call set_data(p_bsence.abs_stat_code)
      when scr_fld = "ins_ref_cd"
        #_set_ins_ref_cd
        call set_data(p_bsence.ins_ref_cd)
      when scr_fld = "upd_ref_cd"
        #_set_upd_ref_cd
        call set_data(p_bsence.upd_ref_cd)
      #_otherwise - otherwise clause
    end case

end function
# llh_setdata()

######################################################################
function llh_high()
######################################################################
# This function highlights the specified field name.
# Only input type fields need to be specified.
#
    #_define_var - define local variables

    #_highlight - Highlight current field data
    case
      when scr_fld = "addr_nr"
        #_dsp_addr_nr
        display by name p_bsence.addr_nr attribute(reverse)
      when scr_fld = "name_1"
        #_dsp_name_1
        display by name p_bsence.name_1 attribute(reverse)
      when scr_fld = "abs_code"
        #_dsp_abs_code
        display by name p_bsence.abs_code attribute(reverse)
      when scr_fld = "date_from"
        #_dsp_date_from
        display by name p_bsence.date_from attribute(reverse)
      when scr_fld = "date_to"
        #_dsp_date_to
        display by name p_bsence.date_to attribute(reverse)
      when scr_fld = "abs_hours"
        #_dsp_abs_hours
        display by name p_bsence.abs_hours attribute(reverse)
      when scr_fld = "first_abs_num"
        #_dsp_first_abs_num
        display by name p_bsence.first_abs_num attribute(reverse)
      when scr_fld = "first_abs_code"
        #_dsp_first_abs_code
        display by name p_bsence.first_abs_code attribute(reverse)
      when scr_fld = "abs_doc_type_dc"
        #_dsp_abs_doc_type_dc
        display by name p_bsence.abs_doc_type_dc attribute(reverse)
      when scr_fld = "abs_stat_code"
        #_dsp_abs_stat_code
        display by name p_bsence.abs_stat_code attribute(reverse)
      when scr_fld = "ins_ref_cd"
        #_dsp_ins_ref_cd
        display by name p_bsence.ins_ref_cd attribute(reverse)
      when scr_fld = "upd_ref_cd"
        #_dsp_upd_ref_cd
        display by name p_bsence.upd_ref_cd attribute(reverse)
      #_otherwise - otherwise clause
    end case

end function
# llh_high()

######################################################################
function llh_display()
######################################################################
# This function displays all p_* variables to the screen
#
    #_define_var - define local variables

    #_display - Display record
        if get_cur_screen() = "pn_absen"
        then
           display p_bsence.* to s_pnabsen.* attribute(red)
        else
           call llh_display_small()
        end if


end function
# llh_display()

######################################################################
function llh_p_prep()
######################################################################
# This function creates the p_* record from the m_* record
#
    #_define_var - define local variables

    #_p_prep - P record setup
    let p_bsence.addr_nr = m_bsence.addr_nr
    let p_bsence.abs_code = m_bsence.abs_code
    let p_bsence.date_from = m_bsence.date_from
    let p_bsence.date_to = m_bsence.date_to
    let p_bsence.abs_days = m_bsence.abs_days
    let p_bsence.abs_hours = m_bsence.abs_hours
    let p_bsence.abs_work_days = m_bsence.abs_work_days
    let p_bsence.abs_work_hours = m_bsence.abs_work_hours
    let p_bsence.abs_absolute = m_bsence.abs_absolute
    let p_bsence.abs_absol_days = m_bsence.abs_absol_days
    let p_bsence.first_abs_num = m_bsence.first_abs_num
    let p_bsence.abs_doc_type_dc = m_bsence.abs_doc_type_dc
    let p_bsence.abs_stat_code = m_bsence.abs_stat_code
    let p_bsence.ins_ref_cd = m_bsence.ins_ref_cd
    let p_bsence.ins_date = m_bsence.ins_date
    let p_bsence.upd_ref_cd = m_bsence.upd_ref_cd
    let p_bsence.upd_date = m_bsence.upd_date

    #_pq_prep - Q record setup
    let q_bsence.abs_num = m_bsence.abs_num

    #_lookups - Perform lookups
        if llh_lookup("address_lk",false) then end if
        if llh_lookup("abs_code_lk",false) then end if
        if llh_lookup("first_abs_lk",false) then end if
        if llh_lookup("abs_doc_lk",false) then end if

    #_on_screen_record_prep
        let q_bsence.addr_actual_fl = get_addr_actual_fl(p_bsence.addr_nr)
        let q_bsence.addr_type_fl = get_addr_type_fl(p_bsence.addr_nr)
        call get_abs_limit()
    #_end

end function
# llh_p_prep()

######################################################################
function llh_m_prep()
######################################################################
# This function creates the m_* record from the p_* record
#
    #_define_var - define local variables

    #_m_prep - M record setup
    let m_bsence.addr_nr = p_bsence.addr_nr
    let m_bsence.abs_code = p_bsence.abs_code
    let m_bsence.date_from = p_bsence.date_from
    let m_bsence.date_to = p_bsence.date_to
    let m_bsence.abs_days = p_bsence.abs_days
    let m_bsence.abs_hours = p_bsence.abs_hours
    let m_bsence.abs_work_days = p_bsence.abs_work_days
    let m_bsence.abs_work_hours = p_bsence.abs_work_hours
    let m_bsence.abs_absolute = p_bsence.abs_absolute
    let m_bsence.abs_absol_days = p_bsence.abs_absol_days
    let m_bsence.first_abs_num = p_bsence.first_abs_num
    let m_bsence.abs_doc_type_dc = p_bsence.abs_doc_type_dc
    let m_bsence.abs_stat_code = p_bsence.abs_stat_code
    let m_bsence.ins_ref_cd = p_bsence.ins_ref_cd
    let m_bsence.ins_date = p_bsence.ins_date
    let m_bsence.upd_ref_cd = p_bsence.upd_ref_cd
    let m_bsence.upd_date = p_bsence.upd_date

    #_mq_prep - Q record setup
    let m_bsence.abs_num = q_bsence.abs_num

    #_on_disk_record_prep
    #_end

end function
# llh_m_prep()

######################################################################
function llh_read(ring_rowid)
######################################################################
# This function reads the data from the disk into
# the program variables.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        ring_rowid  integer   # rowid of record to read

    #_build_curs - Build the SQL string
    if select_prep is null
    then
        let select_prep = "Y"
        #_select - select statement
        let scratch = "select ",
            "abs_num,",
            "addr_nr,",
            "abs_code,",
            "first_abs_num,",
            "abs_doc_type_dc,",
            "abs_stat_code,",
            "date_from,",
            "date_to,",
            "abs_days,",
            "abs_hours,",
            "abs_work_days,",
            "abs_work_hours,",
            "abs_absolute,",
            "abs_absol_days,",
            "ins_ref_cd,",
            "ins_date,",
            "upd_ref_cd,",
            "upd_date ",
            " from pn_absence where rowid = ?"

        #_prep_curs - Prepare the SQL string for execution
        prepare read_specs from scratch
        declare h_cursor cursor for read_specs
    end if

    #_read_data - Read the data
    open h_cursor using ring_rowid
    whenever error continue

    #_fetch - fetch statement
    fetch h_cursor into
        m_bsence.abs_num,
        m_bsence.addr_nr,
        m_bsence.abs_code,
        m_bsence.first_abs_num,
        m_bsence.abs_doc_type_dc,
        m_bsence.abs_stat_code,
        m_bsence.date_from,
        m_bsence.date_to,
        m_bsence.abs_days,
        m_bsence.abs_hours,
        m_bsence.abs_work_days,
        m_bsence.abs_work_hours,
        m_bsence.abs_absolute,
        m_bsence.abs_absol_days,
        m_bsence.ins_ref_cd,
        m_bsence.ins_date,
        m_bsence.upd_ref_cd,
        m_bsence.upd_date
    whenever error call error_handler
    #_ret - Return before closing the cursor if read failed
    if sqlca.sqlcode != 0 then return end if
    let q_bsence.row_id = ring_rowid

    #_close - close statement
    close h_cursor

    #_on_disk_read
    #_end

    #_p_prep - P record prep
    call llh_p_prep()


    #_sqlcode - sqlcode
    let sqlca.sqlcode = 0

end function
# llh_read()

######################################################################
function llh_delete(ring_rowid)
######################################################################
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        ring_rowid  integer     # rowid passed
    call delete_ref(m_bsence.abs_num)
    call update_dor(m_bsence.abs_num)


    #_delete - Delete Header record
    delete from pn_absence
        where rowid = ring_rowid

    #_on_disk_delete
        if not abs_dor(m_bsence.abs_num, m_bsence.addr_nr,
                       m_bsence.date_from, m_bsence.date_to)
        then
        #   call update_dor(m_bsence.abs_num)
        end if
        call update_limit(m_bsence.addr_nr, m_bsence.abs_code,
                          year(m_bsence.date_from))
    #_end

end function
# llh_delete()

######################################################################
function llh_add()
######################################################################
# This function inserts data into the header table.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        new_rowid integer  # Rowid after insert

    # Set the serial field
    let m_bsence.abs_num = 0

    #_insert_row - Insert the new row
    insert into pn_absence (
        abs_num, addr_nr, abs_code, first_abs_num, abs_doc_type_dc,
        abs_stat_code, date_from, date_to, abs_days, abs_hours,
        abs_work_days, abs_work_hours, abs_absolute, abs_absol_days,
        ins_ref_cd, ins_date, upd_ref_cd, upd_date)
    values (
        0, m_bsence.addr_nr, m_bsence.abs_code, m_bsence.first_abs_num,
        m_bsence.abs_doc_type_dc, m_bsence.abs_stat_code,
        m_bsence.date_from, m_bsence.date_to, m_bsence.abs_days,
        m_bsence.abs_hours, m_bsence.abs_work_days,
        m_bsence.abs_work_hours, m_bsence.abs_absolute,
        m_bsence.abs_absol_days, m_bsence.ins_ref_cd,
        m_bsence.ins_date, m_bsence.upd_ref_cd, m_bsence.upd_date)

    let new_rowid = sqlca.sqlerrd[6]

    #_serial - Bring back the serial field & display it
    let m_bsence.abs_num = sqlca.sqlerrd[2]

    #_on_disk_add
        call lld_add()
        call abs_rates_count(m_bsence.abs_num, m_bsence.addr_nr,
                             m_bsence.abs_code, m_bsence.date_from,
                             m_bsence.date_to, m_bsence.first_abs_num)
        call abs_ins_hours(m_bsence.abs_num)
        if abs_dor(m_bsence.abs_num, m_bsence.addr_nr,
                   m_bsence.date_from, m_bsence.date_to)
        then end if
    #_end

    #_rowid - Reset rowid
    let sqlca.sqlerrd[6] = new_rowid

end function
# llh_add()

######################################################################
function llh_update(ring_rowid)
######################################################################
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        ring_rowid  integer     # rowid passed

    #_update - Update the existing row
    update pn_absence set
        addr_nr = m_bsence.addr_nr,
        abs_code = m_bsence.abs_code,
        first_abs_num = m_bsence.first_abs_num,
        abs_doc_type_dc = m_bsence.abs_doc_type_dc,
        abs_stat_code = m_bsence.abs_stat_code,
        date_from = m_bsence.date_from,
        date_to = m_bsence.date_to,
        abs_days = m_bsence.abs_days,
        abs_hours = m_bsence.abs_hours,
        abs_work_days = m_bsence.abs_work_days,
        abs_work_hours = m_bsence.abs_work_hours,
        abs_absolute = m_bsence.abs_absolute,
        abs_absol_days = m_bsence.abs_absol_days,
        ins_ref_cd = m_bsence.ins_ref_cd,
        ins_date = m_bsence.ins_date,
        upd_ref_cd = m_bsence.upd_ref_cd,
        upd_date = m_bsence.upd_date
    where rowid = ring_rowid

    #_on_disk_update
        if get_cur_screen() = "pn_absen"
        then
           call lld_add()
           if not get_pay_rates()
           then
              call abs_rates_count(m_bsence.abs_num, m_bsence.addr_nr,
                                   m_bsence.abs_code, m_bsence.date_from,
                                   m_bsence.date_to, m_bsence.first_abs_num)
              if not abs_dor(m_bsence.abs_num, m_bsence.addr_nr,
                             m_bsence.date_from, m_bsence.date_to)
              then
                 call update_dor(m_bsence.abs_num)
              end if
           end if
        end if
    #_end

end function
# llh_update()

######################################################################
function llh_lookup(tbl_name, mustfind)
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
        #_scratch_personal_lk - set scratch for lookup personal_lk
        let scratch = "select addr_actual_fl, addr_type_fl ",
          "from pn_personal where ",
          " pn_personal.addr_actual_fl = \"T\" and",
          " pn_personal.addr_type_fl = \"P\" and",
          " pn_personal.addr_nr = ?"
        prepare str_personal_lk from scratch
        declare cur_personal_lk cursor for str_personal_lk
        #_scratch_address_lk - set scratch for lookup address_lk
        let scratch = "select name_1, name_2 ",
          "from v_address where ",
          " v_address.addr_nr = ?"
        prepare str_address_lk from scratch
        declare cur_address_lk cursor for str_address_lk
        #_scratch_abs_code_lk - set scratch for lookup abs_code_lk
        let scratch = "select abs_name ",
          "from pn_abs_type where ",
          " pn_abs_type.abs_code = ?"
        prepare str_abs_code_lk from scratch
        declare cur_abs_code_lk cursor for str_abs_code_lk
        #_scratch_first_abs_lk - set scratch for lookup first_abs_lk
        let scratch = "select abs_code, date_from, date_to ",
          "from pn_absence where ",
          " pn_absence.abs_num = ?"
        prepare str_first_abs_lk from scratch
        declare cur_first_abs_lk cursor for str_first_abs_lk
        #_scratch_abs_doc_lk - set scratch for lookup abs_doc_lk
        let scratch = "select descr ",
          "from pn_dict_pos where ",
          " pn_dict_pos.type = \"abs_doc_type\" and",
          " pn_dict_pos.code = ?"
        prepare str_abs_doc_lk from scratch
        declare cur_abs_doc_lk cursor for str_abs_doc_lk
    end if

    #_lookups - Perform the lookup
    case
    #_case_tbl_name - case table name statement
      #_bf_lkup_personal_lk
      when tbl_name = "personal_lk"
        #_af_lkup_personal_lk
        open cur_personal_lk using p_bsence.addr_nr
        #_fetch - fetch the p record
        fetch cur_personal_lk into q_bsence.addr_actual_fl,
          q_bsence.addr_type_fl
        let stat = sqlca.sqlcode
        close cur_personal_lk
      #_bf_lkup_address_lk
      when tbl_name = "address_lk"
        #_af_lkup_address_lk
        open cur_address_lk using p_bsence.addr_nr
        #_fetch - fetch the p record
        fetch cur_address_lk into p_bsence.name_1, p_bsence.name_2
        let stat = sqlca.sqlcode
        close cur_address_lk
      #_bf_lkup_abs_code_lk
      when tbl_name = "abs_code_lk"
        #_af_lkup_abs_code_lk
        open cur_abs_code_lk using p_bsence.abs_code
        #_fetch - fetch the p record
        fetch cur_abs_code_lk into p_bsence.abs_name
        let stat = sqlca.sqlcode
        close cur_abs_code_lk
      #_bf_lkup_first_abs_lk
      when tbl_name = "first_abs_lk"
        #_af_lkup_first_abs_lk
        open cur_first_abs_lk using p_bsence.first_abs_num
        #_fetch - fetch the p record
        fetch cur_first_abs_lk into p_bsence.first_abs_code,
          p_bsence.first_date_from, p_bsence.first_date_to
        let stat = sqlca.sqlcode
        close cur_first_abs_lk
      #_bf_lkup_abs_doc_lk
      when tbl_name = "abs_doc_lk"
        #_af_lkup_abs_doc_lk
        open cur_abs_doc_lk using p_bsence.abs_doc_type_dc
        #_fetch - fetch the p record
        fetch cur_abs_doc_lk into p_bsence.abs_doc_desc
        let stat = sqlca.sqlcode
        close cur_abs_doc_lk
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
          #_bf_f_lkup_personal_lk
          when tbl_name = "personal_lk"
            #_af_f_lkup_personal_lk
            #_initialize - initialize the p record
            initialize q_bsence.addr_actual_fl,
              q_bsence.addr_type_fl to null
          #_bf_f_lkup_address_lk
          when tbl_name = "address_lk"
            #_af_f_lkup_address_lk
            #_initialize - initialize the p record
            initialize p_bsence.name_1, p_bsence.name_2 to null
          #_bf_f_lkup_abs_code_lk
          when tbl_name = "abs_code_lk"
            #_af_f_lkup_abs_code_lk
            #_initialize - initialize the p record
            initialize p_bsence.abs_name to null
          #_bf_f_lkup_first_abs_lk
          when tbl_name = "first_abs_lk"
            #_af_f_lkup_first_abs_lk
            #_initialize - initialize the p record
            initialize p_bsence.first_abs_code,
              p_bsence.first_date_from, p_bsence.first_date_to to null
          #_bf_f_lkup_abs_doc_lk
          when tbl_name = "abs_doc_lk"
            #_af_f_lkup_abs_doc_lk
            #_initialize - initialize the p record
            initialize p_bsence.abs_doc_desc to null
          #_otherwise - otherwise clause
        end case
        return false
    else
        return true
    end if

end function
# llh_lookup()

######################################################################
function llh_defaults()
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
# llh_defaults()

######################################################################
function llh_dupchk()
######################################################################
# This function performs duplicate checking of the
# unique key of the input area 1 (header region)
# It returns a value of true when no duplicate is found.
# A value of false is returned if a duplicate is found.
# If any of the key fields contain a null, no duplicate
# checking will occur and this function returns true.
#

    # Since no enterable key was specified in the screen
    # file, no duplicate-row checking is created here.

    return true

end function
# llh_dupchk()

######################################################################
function PR_header()
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
          when get_name = "addr_nr"
            let p_bsence.addr_nr = get_data
          when get_name = "name_1"
            let p_bsence.name_1 = get_data
          when get_name = "name_2"
            let p_bsence.name_2 = get_data
          when get_name = "abs_code"
            let p_bsence.abs_code = get_data
          when get_name = "abs_name"
            let p_bsence.abs_name = get_data
          when get_name = "date_from"
            let p_bsence.date_from = get_data
          when get_name = "date_to"
            let p_bsence.date_to = get_data
          when get_name = "abs_days"
            let p_bsence.abs_days = get_data
          when get_name = "abs_hours"
            let p_bsence.abs_hours = get_data
          when get_name = "abs_work_days"
            let p_bsence.abs_work_days = get_data
          when get_name = "abs_work_hours"
            let p_bsence.abs_work_hours = get_data
          when get_name = "days_avail_limit"
            let p_bsence.days_avail_limit = get_data
          when get_name = "hours_avail_limit"
            let p_bsence.hours_avail_limit = get_data
          when get_name = "abs_absolute"
            let p_bsence.abs_absolute = get_data
          when get_name = "abs_absol_days"
            let p_bsence.abs_absol_days = get_data
          when get_name = "days_used_limit"
            let p_bsence.days_used_limit = get_data
          when get_name = "hours_used_limit"
            let p_bsence.hours_used_limit = get_data
          when get_name = "first_abs_num"
            let p_bsence.first_abs_num = get_data
          when get_name = "first_abs_code"
            let p_bsence.first_abs_code = get_data
          when get_name = "first_date_from"
            let p_bsence.first_date_from = get_data
          when get_name = "first_date_to"
            let p_bsence.first_date_to = get_data
          when get_name = "abs_doc_type_dc"
            let p_bsence.abs_doc_type_dc = get_data
          when get_name = "abs_doc_desc"
            let p_bsence.abs_doc_desc = get_data
          when get_name = "abs_stat_code"
            let p_bsence.abs_stat_code = get_data
          when get_name = "ins_ref_cd"
            let p_bsence.ins_ref_cd = get_data
          when get_name = "ins_date"
            let p_bsence.ins_date = get_data
          when get_name = "upd_ref_cd"
            let p_bsence.upd_ref_cd = get_data
          when get_name = "upd_date"
            let p_bsence.upd_date = get_data

          #_q_read - Read the Q record
          when get_name = "abs_num"
            let q_bsence.abs_num = get_data

          #_otherwise - otherwise clause
        end case
    end while

    #_lookups - Perform lookups
    if llh_lookup("personal_lk",false) then end if
    if llh_lookup("address_lk",false) then end if
    if llh_lookup("abs_code_lk",false) then end if
    if llh_lookup("first_abs_lk",false) then end if
    if llh_lookup("abs_doc_lk",false) then end if

    #_on_program_read - program read

end function
# PR_header()

######################################################################
function PW_header()
######################################################################
# This function writes the p_ & q_ records to the temp table
#
    #_define_var - define local variables
    define
       #_local_var - local variables
       tmp_str char(70)

    #_p_write - Write the P record to the temp table
    call t_write(1, "addr_nr", p_bsence.addr_nr)
    call t_write(1, "name_1", p_bsence.name_1)
    call t_write(1, "name_2", p_bsence.name_2)
    call t_write(1, "abs_code", p_bsence.abs_code)
    call t_write(1, "abs_name", p_bsence.abs_name)
    call t_write(1, "date_from", p_bsence.date_from)
    call t_write(1, "date_to", p_bsence.date_to)
    call t_write(1, "abs_days", p_bsence.abs_days)
    let tmp_str = dec_let(p_bsence.abs_hours)
    call t_write(1, "abs_hours", tmp_str)
    call t_write(1, "abs_work_days", p_bsence.abs_work_days)
    let tmp_str = dec_let(p_bsence.abs_work_hours)
    call t_write(1, "abs_work_hours", tmp_str)
    call t_write(1, "days_avail_limit", p_bsence.days_avail_limit)
    let tmp_str = dec_let(p_bsence.hours_avail_limit)
    call t_write(1, "hours_avail_limit", tmp_str)
    call t_write(1, "abs_absolute", p_bsence.abs_absolute)
    call t_write(1, "abs_absol_days", p_bsence.abs_absol_days)
    call t_write(1, "days_used_limit", p_bsence.days_used_limit)
    let tmp_str = dec_let(p_bsence.hours_used_limit)
    call t_write(1, "hours_used_limit", tmp_str)
    call t_write(1, "first_abs_num", p_bsence.first_abs_num)
    call t_write(1, "first_abs_code", p_bsence.first_abs_code)
    call t_write(1, "first_date_from", p_bsence.first_date_from)
    call t_write(1, "first_date_to", p_bsence.first_date_to)
    call t_write(1, "abs_doc_type_dc", p_bsence.abs_doc_type_dc)
    call t_write(1, "abs_doc_desc", p_bsence.abs_doc_desc)
    call t_write(1, "abs_stat_code", p_bsence.abs_stat_code)
    call t_write(1, "ins_ref_cd", p_bsence.ins_ref_cd)
    call t_write(1, "ins_date", p_bsence.ins_date)
    call t_write(1, "upd_ref_cd", p_bsence.upd_ref_cd)
    call t_write(1, "upd_date", p_bsence.upd_date)

    #_q_write - Write the Q record
    call t_write(1, "abs_num", q_bsence.abs_num)

    #_on_program_write - program write

end function
# PW_header()

######################################################################
function llh_skip(prv_fld)
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
      #_addr_nr - Skip logic for addr_nr
      when scr_fld = "addr_nr"
        if prv_fld = "name_1" or prv_fld is null
          then let nxt_fld = "upd_ref_cd"
          else let nxt_fld = "name_1"
        end if
      #_name_1 - Skip logic for name_1
      when scr_fld = "name_1"
        if prv_fld = "abs_code"
          then let nxt_fld = "addr_nr"
          else let nxt_fld = "abs_code"
        end if
      #_abs_code - Skip logic for abs_code
      when scr_fld = "abs_code"
        if prv_fld = "date_from"
          then let nxt_fld = "name_1"
          else let nxt_fld = "date_from"
        end if
      #_date_from - Skip logic for date_from
      when scr_fld = "date_from"
        if prv_fld = "date_to"
          then let nxt_fld = "abs_code"
          else let nxt_fld = "date_to"
        end if
      #_date_to - Skip logic for date_to
      when scr_fld = "date_to"
        if prv_fld = "abs_hours"
          then let nxt_fld = "date_from"
          else let nxt_fld = "abs_hours"
        end if
      #_abs_hours - Skip logic for abs_hours
      when scr_fld = "abs_hours"
        if prv_fld = "first_abs_num"
          then let nxt_fld = "date_to"
          else let nxt_fld = "first_abs_num"
        end if
      #_first_abs_num - Skip logic for first_abs_num
      when scr_fld = "first_abs_num"
        if prv_fld = "first_abs_code"
          then let nxt_fld = "abs_hours"
          else let nxt_fld = "first_abs_code"
        end if
      #_first_abs_code - Skip logic for first_abs_code
      when scr_fld = "first_abs_code"
        if prv_fld = "abs_doc_type_dc"
          then let nxt_fld = "first_abs_num"
          else let nxt_fld = "abs_doc_type_dc"
        end if
      #_abs_doc_type_dc - Skip logic for abs_doc_type_dc
      when scr_fld = "abs_doc_type_dc"
        if prv_fld = "abs_stat_code"
          then let nxt_fld = "first_abs_code"
          else let nxt_fld = "abs_stat_code"
        end if
      #_abs_stat_code - Skip logic for abs_stat_code
      when scr_fld = "abs_stat_code"
        if prv_fld = "ins_ref_cd"
          then let nxt_fld = "abs_doc_type_dc"
          else let nxt_fld = "ins_ref_cd"
        end if
      #_ins_ref_cd - Skip logic for ins_ref_cd
      when scr_fld = "ins_ref_cd"
        if prv_fld = "upd_ref_cd"
          then let nxt_fld = "abs_stat_code"
          else let nxt_fld = "upd_ref_cd"
        end if
      #_upd_ref_cd - Skip logic for upd_ref_cd
      when scr_fld = "upd_ref_cd"
        if prv_fld = "addr_nr"
          then let nxt_fld = "ins_ref_cd"
          else let nxt_fld = "addr_nr"
        end if
    end case

end function
# llh_skip()
######################################################################
function llh_display_small()
######################################################################
#

   display p_bsence.addr_nr         to s_pnabsen.addr_nr         attribute(red)
   display p_bsence.name_1          to s_pnabsen.name_1          attribute(red)
   display p_bsence.name_2          to s_pnabsen.name_2          attribute(red)
   display p_bsence.abs_code        to s_pnabsen.abs_code        attribute(red)
   display p_bsence.abs_name        to s_pnabsen.abs_name        attribute(red)
   display p_bsence.date_from       to s_pnabsen.date_from       attribute(red)
   display p_bsence.date_to         to s_pnabsen.date_to         attribute(red)
   display p_bsence.abs_days        to s_pnabsen.abs_days        attribute(red)
   display p_bsence.abs_hours       to s_pnabsen.abs_hours       attribute(red)
   display p_bsence.first_abs_num   to s_pnabsen.first_abs_num   attribute(red)
   display p_bsence.first_abs_code  to s_pnabsen.first_abs_code  attribute(red)
   display p_bsence.first_date_from to s_pnabsen.first_date_from attribute(red)
   display p_bsence.first_date_to   to s_pnabsen.first_date_to   attribute(red)

end function
# llh_display_small()
