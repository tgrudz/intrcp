######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################
# Screen Generator version: 4.10.UC1

database forest

globals
  define

    #_define_0
    #_end
    m_bsence record like pn_absence.*,  # Record like the header table
    p_bsence record   # Record like the pnabsen screen
        addr_nr like pn_absence.addr_nr,
        name_1 like v_address.name_1,
        name_2 like v_address.name_2,
        abs_code like pn_absence.abs_code,
        abs_name like pn_abs_type.abs_name,
        date_from like pn_absence.date_from,
        date_to like pn_absence.date_to,
        abs_days like pn_absence.abs_days,
        abs_hours like pn_absence.abs_hours,
        abs_work_days like pn_absence.abs_work_days,
        abs_work_hours like pn_absence.abs_work_hours,
        days_avail_limit smallint,
        hours_avail_limit decimal(7),
        abs_absolute like pn_absence.abs_absolute,
        abs_absol_days like pn_absence.abs_absol_days,
        days_used_limit smallint,
        hours_used_limit decimal(7),
        first_abs_num like pn_absence.first_abs_num,
        first_abs_code char(5),
        first_date_from date,
        first_date_to date,
        abs_doc_type_dc like pn_absence.abs_doc_type_dc,
        abs_doc_desc char(30),
        abs_stat_code like pn_absence.abs_stat_code,
        ins_ref_cd like pn_absence.ins_ref_cd,
        ins_date like pn_absence.ins_date,
        upd_ref_cd like pn_absence.upd_ref_cd,
        upd_date like pn_absence.upd_date
    end record,
    q_bsence record    # Parallel pnabsen record
        row_id integer, # SQL rowid
        abs_num like pn_absence.abs_num
        #_define_1
        #_end
        , addr_type_fl     char(1)
        , addr_actual_fl   char(1)
    end record,
    m__block record like pn_absen_block.*,  # Record like the detail table
    p__block array[50] of record      # Record like the pnabsen screen
        date_from like pn_absen_block.date_from,
        date_to like pn_absen_block.date_to,
        block_cause_dc like pn_absen_block.block_cause_dc,
        block_cause_desc char(30)
    end record,
    q__block array[50] of record      # Parallel pnabsen record
        row_id integer, # SQL rowid
        abs_num like pn_absen_block.abs_num
        #_define_2
        #_end
    end record,

    scr1_max smallint,   # Number of elements in screen array 1
    rec1_max smallint,   # Number of elements in record array 1
    rec1_cnt smallint,   # Number of active elements in array 1
    is_setup char(1),   # Flag for new record

    ###############################################################
    # Library communication area 4.10.UC1
    ###############################################################
    # Global variables in this section should not be changed.
    # They are used to communicate to the screen library functions,
    # and must be of the same type as defined in the library.
    # Don't remove these comments.  The codegenerator keys on them.
    #
    progid       char(17),   # Program identification
    scr_id       char(7),    # Current screen id
    menu_item    char(10),   # Current menu item running
    scr_funct    char(20),   # Current screen function being run
    sql_filter   char(512),  # Filter portion of SQL statement
    sql_order    char(100),  # Order portion of SQL statement
    input_num    smallint,   # Current input section within screen
    p_cur        smallint,   # Current input array element
    s_cur        smallint,   # Current screen array element
    scr_fld      char(40),   # Current screen field
    nxt_fld      char(40),   # Programmatic next screen field
    prev_data    char(80),   # Data before field entry
    this_data    char(80),   # Data after field entry
    data_changed smallint,   # Has the field data changed?
    hotkey       smallint,   # The hot key that has been pressed
    scratch      char(2047)  # Scratchpad for scribbling on and
                             # communicating between functions
    # End library communication area
    ###############################################################

end globals
