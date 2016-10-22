######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################

globals "globals.4gl"

######################################################################
function head_menu(ring_rowid,ring_cursor,ring_total, ring_type)
######################################################################
# This is the main menu interface for header only screens.
# This is called from ring_header and passed the "ring_" values
# to do the basic menuing logic. It is to be modified for other
# languages by copying the "menu to end menu" logic and adding
# more case statement values such as German "GER", French "FRN", etc.
#
# The separate "modules" such as this allow for the various menus to
# be accessed from a applications local directory for "menu" command
# modifications. These would include the deletions of menu_item
# commands or the addition new menu-items.
#
# Add other language case values here and copy the menu through end
# menu logic here.  CHANGE THE COMMAND OPTIONS, THE PROMPT, AND
# ALL LABELS.
#

    define
        ring_rowid  integer, # the rowid of the current screen record
                             # or -1 if there is no record on the screen
        ring_cursor integer, # pointer to the absolute cursor address.
                             # undefined for a closed cursor
        ring_total  integer, # total number of elements in the cursor.
                             # if ring_total > 0, then cursor is open.
                             # if ring_total = 0, then cursor is closed.
        ring_type   smallint,# 1 - header, 2 - header/detail
        menu_lang   char(3), # language value loads into here
        new_rec     smallint,# 1 - new record added, 0 - ok
        menut       char(25),
        cur_cmd     char(25),
        i           smallint,
        mitem       array[19] of record
                       mtitle  char(25),
                       mdesc   char(75)
                    end record

    # if ring_cursor is 0 and ring_total > 0, then there is a open
    # cursor, but the record on the screen doesn't have anything
    # to do with it.  (a newly added document)

    # Trap fatal errors
    whenever error call error_handler

    # Get the language value
    let menu_lang = get_scrlib("language")


    # wprowadzenie tekstow do menu z pliku
	let menut = fg_message("lib_scr","menuhead",1) clipped
    for i = 1 to 9
        let mitem[i].mtitle = fg_message("lib_scr","menuhead",2*i + 9) clipped
        let mitem[i].mdesc  = fg_message("lib_scr","menuhead",2*i + 10) clipped
    end for
    for i = 10 to 19
		call extra_menu_items(i-10)
			returning mitem[i].mtitle, mitem[i].mdesc
		if  mitem[i].mtitle is null
		then
			let  mitem[i].mtitle = "???", i using "<<"
		end if
	end for

    let cur_cmd = mitem[10].mtitle
    let new_rec = false

    menu menut
	  before menu
	    if not show_add()     then hide option mitem[1].mtitle end if
	    if not show_update()  then hide option mitem[2].mtitle end if
	    if not show_delete()  then hide option mitem[3].mtitle end if
	    if not show_find()    then hide option mitem[4].mtitle end if
	    if not show_browse()  then hide option mitem[5].mtitle end if
	    if not show_next()    then hide option mitem[6].mtitle end if
	    if not show_prev()    then hide option mitem[7].mtitle end if
	    if not show_quit()    then hide option mitem[9].mtitle end if
        if ring_type = 1      then hide option mitem[8].mtitle end if
        if not show_tab()     then hide option mitem[8].mtitle end if
		for i = 10 to 19
			if mitem[i].mtitle[1,3] = "???" 
			then
				hide option mitem[i].mtitle
			end if
		end for 
        hide option cur_cmd
      command mitem[4].mtitle mitem[4].mdesc 
        label m_find:
	    if not show_find()     then continue menu end if
        let menu_item = "find"
        call ring_find(ring_rowid,ring_cursor,ring_total)
          returning ring_rowid, ring_cursor, ring_total
        call ring_border(ring_rowid, ring_cursor, ring_total)
        if ring_cursor > 0
        then
           let new_rec = false
        end if
      command mitem[6].mtitle mitem[6].mdesc 
        label m_next:
	    if not show_next()     then continue menu end if
        let menu_item = "next"
        if ring_total = 0 then continue menu end if
        if not security_chk("next")
        then
            call security_msg("next")
            continue menu
        end if
        if not ok_next() then continue menu end if
        if new_rec
        then
           call str_error(get_mssg("msg_scr", "message", 42), "")
           continue menu
        end if
        if ring_cursor = ring_total
        then
           #let ring_cursor = 0
           call str_error(get_mssg("msg_scr", "message", 39), "")
           continue menu
        end if
        let ring_cursor = ring_cursor + 1
        call put_scrlib("curs_pos",ring_cursor)
        call ring_view(ring_cursor) returning ring_rowid, ring_cursor
        call ring_border(ring_rowid, ring_cursor, ring_total)
      command mitem[7].mtitle mitem[7].mdesc 
        label m_prev:
	    if not show_prev()     then continue menu end if
        let menu_item = "prev"
        if ring_total = 0 then continue menu end if
        if not security_chk("previous")
        then
            call security_msg("previous")
            continue menu
        end if
        if not ok_prev() then continue menu end if
        if new_rec
        then
           call str_error(get_mssg("msg_scr", "message", 42), "")
           continue menu
        end if
        if ring_cursor <= 1
        then
           #let ring_cursor = ring_total + 1
           call str_error(get_mssg("msg_scr", "message", 40), "")
           continue menu
        end if
        let ring_cursor = ring_cursor - 1
        call put_scrlib("curs_pos",ring_cursor)
        call ring_view(ring_cursor) returning ring_rowid, ring_cursor
        call ring_border(ring_rowid, ring_cursor, ring_total)
      command mitem[5].mtitle mitem[5].mdesc 
        label m_browse:
	    if not show_browse()     then continue menu end if
        let menu_item = "browse"
        call ring_browse(ring_rowid,ring_cursor,ring_total)
          returning ring_rowid, ring_cursor, ring_total
        call put_scrlib("curs_pos",ring_cursor)
        call ring_border(ring_rowid, ring_cursor, ring_total)
      command mitem[1].mtitle mitem[1].mdesc 
        label m_add:
	    if not show_add()     then continue menu end if
        let menu_item = "add"
        call ring_add(ring_type, ring_rowid, ring_cursor, ring_total)
          returning ring_rowid, ring_cursor, ring_total
        if ring_cursor = 0 and ring_rowid != 1
        then
           let new_rec = true
           call mlh_init_filters()
           let scratch = ring_rowid
           let scratch = "pn_absence.rowid = ", scratch clipped
           call ring_define(scratch clipped)
                returning ring_rowid, ring_cursor, ring_total
        end if
        call ring_border(ring_rowid, ring_cursor, ring_total)
      command mitem[2].mtitle mitem[2].mdesc 
        label m_update:
	    if not show_update()     then continue menu end if
        let menu_item = "update"
        call ring_refresh(ring_rowid) returning ring_rowid
        call ring_update(ring_type,ring_rowid)
        call ring_view(ring_cursor) returning ring_rowid, ring_cursor
        call ring_border(ring_rowid, ring_cursor, ring_total)
      command mitem[3].mtitle mitem[3].mdesc 
        label m_delete:
	    if not show_delete()     then continue menu end if
        let menu_item = "delete"
        call ring_delete(ring_rowid) returning ring_rowid
        if ring_rowid = -1 and ring_total > 0
        then
            let ring_rowid = 0      # deleted cursor element
            call put_scrlib("curs_rowid",ring_rowid)
        end if
        call ring_border(ring_rowid, ring_cursor, ring_total)
      command mitem[8].mtitle mitem[8].mdesc 
        label m_tab:
        let menu_item = "tab"
	    if not show_tab()     then continue menu end if
        if not ok_tab() then continue menu end if
        call lib_message("scroll")
        call mld_scroll()
        let int_flag = 0
        call ring_border(ring_rowid, ring_cursor, ring_total)
      command mitem[10].mtitle mitem[10].mdesc 
        let menu_item = "extra0"
        # pholding 2007.02.05
        if not fg_authorized(mitem[10].mtitle) then
           continue menu
        end if
        # end pholding 2007.02.05
        show option cur_cmd
        let cur_cmd = mitem[10].mtitle
        hide option cur_cmd
        show option mitem[1].mtitle
        show option mitem[2].mtitle
        show option mitem[3].mtitle
        call switch_scr("pn_absen")
	#call extra_menu_call(0, ring_type, ring_rowid, ring_cursor, ring_total)
        #  returning ring_rowid, ring_cursor, ring_total
	#goto event
      command mitem[11].mtitle mitem[11].mdesc 
        let menu_item = "extra1"
        # pholding 2007.02.05
        if not fg_authorized(mitem[11].mtitle) then
           continue menu
        end if
        # end pholding 2007.02.05
        show option cur_cmd
        let cur_cmd = mitem[11].mtitle
        hide option cur_cmd
        hide option mitem[1].mtitle
        show option mitem[2].mtitle
        hide option mitem[3].mtitle
        call switch_scr("pn_absra")
	#call extra_menu_call(1, ring_type, ring_rowid, ring_cursor, ring_total)
        #  returning ring_rowid, ring_cursor, ring_total
	#goto event
      command mitem[12].mtitle mitem[12].mdesc 
        let menu_item = "extra2"
        # pholding 2007.02.05
        if not fg_authorized(mitem[12].mtitle) then
           continue menu
        end if
        # end pholding 2007.02.05
        show option cur_cmd
        let cur_cmd = mitem[12].mtitle
        hide option cur_cmd
        hide option mitem[1].mtitle
        hide option mitem[2].mtitle
        hide option mitem[3].mtitle
        call switch_scr("pn_absba")
	#call extra_menu_call(2, ring_type, ring_rowid, ring_cursor, ring_total)
        #  returning ring_rowid, ring_cursor, ring_total
	#goto event
      command mitem[13].mtitle mitem[13].mdesc 
        let menu_item = "extra3"
        # pholding 2007.02.05
        if not fg_authorized(mitem[13].mtitle) then
           continue menu
        end if
        # end pholding 2007.02.05
        show option cur_cmd
        let cur_cmd = mitem[13].mtitle
        hide option cur_cmd
        hide option mitem[1].mtitle
        hide option mitem[2].mtitle
        hide option mitem[3].mtitle
        call switch_scr("pn_absho")
	#call extra_menu_call(3, ring_type, ring_rowid, ring_cursor, ring_total)
        #  returning ring_rowid, ring_cursor, ring_total
	#goto event
      command mitem[14].mtitle mitem[14].mdesc 
        let menu_item = "extra4"
        # pholding 2007.02.05
        if not fg_authorized(mitem[14].mtitle) then
           continue menu
        end if
        # end pholding 2007.02.05
        show option cur_cmd
        let cur_cmd = mitem[14].mtitle
        hide option cur_cmd
        hide option mitem[1].mtitle
	#call extra_menu_call(4, ring_type, ring_rowid, ring_cursor, ring_total)
        #  returning ring_rowid, ring_cursor, ring_total
	#goto event
      command mitem[15].mtitle mitem[15].mdesc 
        let menu_item = "extra5"
        # pholding 2007.02.05
        if not fg_authorized(mitem[15].mtitle) then
           continue menu
        end if
        # end pholding 2007.02.05
        show option cur_cmd
        let cur_cmd = mitem[15].mtitle
        hide option cur_cmd
        hide option mitem[1].mtitle
	#call extra_menu_call(5, ring_type, ring_rowid, ring_cursor, ring_total)
        #  returning ring_rowid, ring_cursor, ring_total
	#goto event
      command mitem[16].mtitle mitem[16].mdesc 
        let menu_item = "extra6"
        # pholding 2007.02.05
        if not fg_authorized(mitem[16].mtitle) then
           continue menu
        end if
        # end pholding 2007.02.05
        show option cur_cmd
        let cur_cmd = mitem[16].mtitle
        hide option cur_cmd
        hide option mitem[1].mtitle
	#call extra_menu_call(6, ring_type, ring_rowid, ring_cursor, ring_total)
        #  returning ring_rowid, ring_cursor, ring_total
	#goto event
      command mitem[17].mtitle mitem[17].mdesc 
        let menu_item = "extra7"
        # pholding 2007.02.05
        if not fg_authorized(mitem[17].mtitle) then
           continue menu
        end if
        # end pholding 2007.02.05
        show option cur_cmd
        let cur_cmd = mitem[17].mtitle
        hide option cur_cmd
        hide option mitem[1].mtitle
	#call extra_menu_call(7, ring_type, ring_rowid, ring_cursor, ring_total)
        #  returning ring_rowid, ring_cursor, ring_total
	#goto event
      command mitem[18].mtitle mitem[18].mdesc 
        let menu_item = "extra8"
        # pholding 2007.02.05
        if not fg_authorized(mitem[18].mtitle) then
           continue menu
        end if
        # end pholding 2007.02.05
        show option cur_cmd
        let cur_cmd = mitem[18].mtitle
        hide option cur_cmd
        hide option mitem[1].mtitle
	#call extra_menu_call(8, ring_type, ring_rowid, ring_cursor, ring_total)
        #  returning ring_rowid, ring_cursor, ring_total
	#goto event
      command mitem[19].mtitle mitem[19].mdesc 
        let menu_item = "extra9"
        # pholding 2007.02.05
        if not fg_authorized(mitem[19].mtitle) then
           continue menu
        end if
        # end pholding 2007.02.05
        show option cur_cmd
        let cur_cmd = mitem[19].mtitle
        hide option cur_cmd
        hide option mitem[1].mtitle
	#call extra_menu_call(9, ring_type, ring_rowid, ring_cursor, ring_total)
        #  returning ring_rowid, ring_cursor, ring_total
	#goto event
      command mitem[9].mtitle mitem[9].mdesc 
        label m_quit:
	    if not show_quit()     then continue menu end if
        let menu_item = "quit"
        if ok_exit() then exit menu end if
      command key (x)
		goto m_quit
      command key ("!")
        call ring_bang()

      # Event trapping logic
      command key (control-b) let hotkey = 2  goto event
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
      command key (f34) let hotkey = 134 goto event
      command key (f35) let hotkey = 135 goto event
      command key (f36) let hotkey = 136 goto event

      label event:
        let menu_item = "menu"
        call hot_local("help")
        call hot_key("ring_header")
        case
          when scr_funct = "m_add" goto m_add
          when scr_funct = "m_update" goto m_update
          when scr_funct = "m_delete" goto m_delete
          when scr_funct = "m_find" goto m_find
          when scr_funct = "m_browse" goto m_browse
          when scr_funct = "m_tab" goto m_tab
          when scr_funct = "m_next" goto m_next
          when scr_funct = "m_prev" goto m_prev
          when scr_funct = "m_quit" goto m_quit
          when scr_funct = "tab" or scr_funct = "btab" goto m_tab
          when scr_funct = "accept" exit menu
          when scr_funct = "help" call fg_help(1)
        end case

    end menu

    return
end function
# head_menu()
