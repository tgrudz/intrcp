######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################
# Screen Generator version: 4.10.UC1

globals "globals.4gl"

######################################################################
main
######################################################################
#
    #_define_var - define local variables

    #_err - Trap fatal errors
    whenever error call error_handler

    #_set_up - Basic set up
        clear screen
        defer interrupt
        call start_error_log()

    #_init - Initialize
    let progid = "kp.pn_absen"
    call put_scrlib("version", "4.10.UC1")
    call put_scrlib("dbname", "forest")
    call put_scrlib("y_pos", "2")
    call put_scrlib("x_pos", "3")

    let scr1_max = 5
    let rec1_max = 50
    let rec1_cnt = rec1_max

    #_open_win1 - open window 1
    open window win1 at 2,3 with 22 rows, 76 columns
      attribute (border,blue)
    #_before_init
    #_end
    call init()

    clear window win1

    #_open_win2 - open window 2
    open window win2 at 2,3 with 22 rows, 76 columns
      attribute (border, white)

      #_form_path - form to be opened
          options form line first + 3
          open form screen1 from "pn_absen"
      #_end
    #_after_init
        call mlh_init_forms()
        call mlh_init_filters()
        call set_cur_screen("pn_absen")
    #_end

    #_dsp_form - display form
    display form screen1

    #_r_detail - call ring_detail function
    call ring_detail()

    #_on_exit - Exit program
    exit program (0)

end main

######################################################################
function switchbox(funct)
######################################################################
# This is the switchbox function for version 4.10.UC1 screens.
# It is used to pass flow control to the appropriate screen functions.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        funct char(20)   # Function to pass on to the screen

    #_post_scr_funct -  Post the current function
    let scr_funct = funct

    #_switchbox -  Pass flow control to appropriate screen
    case
      when scr_id = "diczoom" call diczoom()
      when scr_id = "persz" call persz()
      when scr_id = "diczoom" call diczoom()
      when scr_id = "diczoom" call diczoom()
      when scr_id = "diczoom" call diczoom()
      when scr_id = "default" call lib_screen()
      otherwise let scratch = "no screen"
      #_otherwise - otherwise clause
    end case

    #_scr_funct - Reset scr_funct upon return
    let scr_funct = ""

end function
# switchbox()


######################################################################
function global_events(act_key, p_funct)
# returning true if it runs the event, otherwise false
######################################################################
# This function's job is to run all events that need to be run
# on a global (program wide) basis.  If you have defined an event
# that needs to be run at the menu level in addition to the local
# input level, the event must be listed here.
# If you wish to know the function name that called hot_key, it
# is passed as p_funct.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        act_key char(15),       # Action to process
        p_funct char(15)        # Current function name

    #_on_event - Process the events based on act_key
    case
      when false
        return false
      otherwise
        return false
    end case

    #_ret - Return
    return true

end function
# global_events()
