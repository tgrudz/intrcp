######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################

globals "globals.4gl"

######################################################################
function ring_llupdate(ring_rowid)
######################################################################
#  this is a function that can be called from the utilities menu.
#  this updates an already m_prepped record
#   also returning sqlca.sqlcode != 0 if update failed.
#
    define
        ring_rowid  integer

    # trap fatal errors
    whenever error call error_handler

    # what a nice program...
    call please_wait()
    let sqlca.sqlcode = 0

    # default screen is handled different from add-on screens.
    # the detail section on default screens perform a delete/insert
    # vs. line by line update.  add-on screen detail sections perform
    # line by line updates. (future)

    # automatically update items keyed to the screen.  this may
    # require screen input for auto udfs and/or notes.  because of
    # the index locking scheme currently used by online, all such
    # screen input must be completed before the header and detail
    # rows are written.
    call lib_chkkey()

    if scr_id = "default"
    then
        # detail line delete must be done before the header m_prep (done
        # in mlh_validate) because it must delete using the old key to
        # the data (stored in m_header).
        call lld_delete()   # delete all detail rows from disk
        if sqlca.sqlcode < 0
        then
            call fg_error("lib_scr","r_llupdate",1)
            call ring_restore(ring_rowid)
            let sqlca.sqlcode = -1
            return
        end if
        
        # this is kept for backward compatibility and because the
        # validate functions perform the m_preps for the "default"
        # scr_id.
        call mlh_validate()
        call mld_validate()

        # now update the header record.
        call llh_update(ring_rowid)

        # write new detail rows to disk
        # call was moved to 'llh_update' function
        if get_cur_screen() != "pn_absen"
        then
           call lld_add()
        end if
        if sqlca.sqlcode < 0
        then
            call fg_error("lib_scr","r_llupdate",2)
            call ring_restore(ring_rowid)
            let sqlca.sqlcode = -1
            return
        end if
    else
        # call the disk write function for add-on screens
        call switchbox("write")
    end if

    call lib_newkey()  # (possibly) change documents tied to this key
    let sqlca.sqlcode = 0 # prepare for return
    return

end function
# ring_llupdate()

