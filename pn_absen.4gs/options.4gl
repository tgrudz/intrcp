######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################
#

globals "globals.4gl"

######################################################################
function ring_options(ring_rowid, ring_cursor, ring_total)
# returning ring_rowid, ring_cursor, ring_total
######################################################################
# This function is called when 'Options' is selected from the menu.
# Local menu options are to be added to this menu.
#
    #_define_var - define local variables
    define
        #_local_var - local variables
        ring_rowid  integer,    # The rowid of the current document
                                # (or -1 if no document is displayed)
        ring_cursor integer,    # The absolute address of the cursor
                                # (0 if document isn't part of the
                                # current cursor group)
        ring_total  integer     # Total number of elements in the cursor

    #_err - Trap fatal errors
    whenever error call error_handler

    #_menu - Menu option
    menu " Options"

    #_begin_menu - begin menu statement

    #_quit  -  command key Quit
      command key (e,x,q,interrupt) "Quit" " Return to the main menu"
        label m_quit:
        let int_flag = 0
        exit menu

      #_command_key - Event trapping logic
      command key (control-b) let hotkey = 2  goto event
      command key (control-c) let hotkey = 3  goto event
      command key (control-e) let hotkey = 5  goto event
      command key (control-f) let hotkey = 6  goto event
      command key (control-g) let hotkey = 7  goto event
      command key (control-i) let hotkey = 9  goto event
      command key (control-n) let hotkey = 14 goto event
      command key (control-o) let hotkey = 15 goto event
      command key (control-p) let hotkey = 16 goto event
      command key (control-t) let hotkey = 20 goto event
      command key (control-u) let hotkey = 21 goto event
      command key (control-v) let hotkey = 22 goto event
      command key (control-w) let hotkey = 23 goto event
      command key (control-y) let hotkey = 25 goto event
      command key (control-z) let hotkey = 26 goto event
      command key (f1)  let hotkey = 101 goto event
      command key (f2)  let hotkey = 102 goto event
      command key (f3)  let hotkey = 103 goto event
      command key (f4)  let hotkey = 104 goto event
      command key (f5)  let hotkey = 105 goto event
      command key (f6)  let hotkey = 106 goto event
      command key (f7)  let hotkey = 107 goto event
      command key (f8)  let hotkey = 108 goto event
      command key (f9)  let hotkey = 109 goto event
      command key (f10) let hotkey = 110 goto event
      command key (f11) let hotkey = 111 goto event
      command key (f12) let hotkey = 112 goto event
      command key (f13) let hotkey = 113 goto event
      command key (f14) let hotkey = 114 goto event
      command key (f15) let hotkey = 115 goto event
      command key (f16) let hotkey = 116 goto event
      command key (f17) let hotkey = 117 goto event
      command key (f18) let hotkey = 118 goto event
      command key (f19) let hotkey = 119 goto event
      command key (f20) let hotkey = 120 goto event
      command key (f21) let hotkey = 121 goto event
      command key (f22) let hotkey = 122 goto event
      command key (f23) let hotkey = 123 goto event
      command key (f24) let hotkey = 124 goto event
      command key (f25) let hotkey = 125 goto event
      command key (f26) let hotkey = 126 goto event
      command key (f27) let hotkey = 127 goto event
      command key (f28) let hotkey = 128 goto event
      command key (f29) let hotkey = 129 goto event
      command key (f30) let hotkey = 130 goto event
      command key (f31) let hotkey = 131 goto event
      command key (f32) let hotkey = 132 goto event
      command key (f33) let hotkey = 133 goto event
      command key (f34) let hotkey = 134 goto event
      command key (f35) let hotkey = 135 goto event
      command key (f36) let hotkey = 136 goto event


      #_on_event - Local event processing
      label event:
        #_help - local help
        call hot_local("help")        # Process help locally
        #_hot_key - hot key event
        call hot_key("ring_options")  # Map the key to the event
        case
          when scr_funct = "help" call fg_help(1)
          when scr_funct = "cancel" or scr_funct = "m_quit" goto m_quit
        end case

    #_end_menu - end menu statement
    end menu

    #_ret - Return
    return ring_rowid, ring_cursor, ring_total

end function
# ring_options()

