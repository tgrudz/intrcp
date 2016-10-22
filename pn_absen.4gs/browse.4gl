######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################
# Screen Generator version: 4.10.UC1

globals "globals.4gl"

#_local_static - Local (static) variables
######################################################################
function brw_open()
# returning num_rows
######################################################################
#  This function opens the browse window and tells the ring_menu
#  the number of rows there are on the screen to scroll through.
#
    #_define_var - define local variables

    #_init - initialize and setup browser elements
        open window browse at 2,3 with form "br_absen"
            attribute (border, white)
        let scr_id = "browse"
        return 16


end function
# brw_open()

######################################################################
function brw_display(line_no, highlight)
######################################################################
#  This function displays the header p_* variables into the correct
#  window line number (either highlighted, or not)
#
    #_define_var - define local variables
    define
        #_local_var - define local variables
        line_no      smallint,        # window line number
        highlight    smallint         # boolean true/false

    #_showdata - Display rows to browse screen
    if highlight
    then
        #_highlight - Highlight current row
        display
            p_bsence.addr_nr,
            p_bsence.name_1,
            p_bsence.abs_code,
            p_bsence.date_from,
            p_bsence.date_to
          to
            s_browse[line_no].*
          attribute(reverse)
    else
        #_display - Display browser rows
        display
            p_bsence.addr_nr,
            p_bsence.name_1,
            p_bsence.abs_code,
            p_bsence.date_from,
            p_bsence.date_to
          to
            s_browse[line_no].*
          attribute(red)
    end if

end function
# brw_display()

######################################################################
function brw_hook(ring_rowid, ring_cursor, ring_total)
# returning true, ring_rowid, ring_cursor, ring_total
######################################################################
#  This is the hook for ring_menu into the browser.  If this hook
#  is not present, then the browser functions are not compiled into
#  the generated code.  This hook tells the linker to load all of the
#  ring_scroll utilities from the ring_lib library.  The true return
#  status tells ring_menu (at run-time) to use this browser versus the
#  default browse menu.
#
    #_define_var - define local variables
    define
        #_local_var - define local variables
        ring_rowid  integer,        # rowid of current selection
        ring_cursor integer,        # absolute cursor address
        ring_total  integer         # number of elements in cursor

    #_err - Trap fatal errors
    whenever error call error_handler

    #_brw_scroll - Scrolling browser
    call ring_scroll(ring_rowid, ring_cursor, ring_total)
      returning ring_rowid, ring_cursor, ring_total
    return true, ring_rowid, ring_cursor, ring_total

end function
# brw_hook()

######################################################################
function brw_close()
######################################################################
#  This function closes the browse window
#
    #_define_var - define local variables

    #_close - Close browser window
    close window browse

end function
# brw_close()
