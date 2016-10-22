######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################

globals "globals.4gl"

######################################################################
function ring_lladd(ring_rowid, ring_cursor, ring_total)
#   returning ring_rowid, ring_cursor, ring_total
#   also returning sqlca.sqlcode != 0 if update failed.
######################################################################
# This function is broken apart from ring_add() because you may want
# to call the low level disk add from a trigger.  It prepares the
# m_* record (for default screens).  It then inserts the data onto 
# disk.
# It must call the "write" event for all screen sections.
#
    define
        ring_rowid  integer,
        ring_cursor integer,
        ring_total  integer

    # Trap fatal errors
    whenever error call error_handler

    # what a nice program...
    call please_wait()

    # This is kept for backward compatibility and because the validate
    # functions perform the m_preps for the "default" scr_id.
    if scr_id = "default"
    then
        call mlh_validate()
        call mld_validate()
    end if

    # automatically update items keyed to the screen.  this may
    # require screen input for auto udfs and/or notes.  because of
    # the index locking scheme currently used by online, all such
    # screen input must be completed before the header and detail
    # rows are written.
    call lib_chkkey()

    # This part of the program must call the add function for each
    # section of the screen.

    # Default and add-on screens must be handled differently
    if scr_id = "default"
    then
        # Default screens have only 2 sections.
        # Add the header record
        call llh_add()
    
        # Bring back the row id & check keyed documents.
        let ring_rowid = sqlca.sqlerrd[6]
        call put_scrlib("curs_rowid",ring_rowid)
        call lib_newkey() # (possibly) change documents tied to this key

        # Add the detail rows
        # call was moved to 'llh_add' function
        #call lld_add()
    else
        # This section is for add-on screens.
        # (at this time, it only handles header-only addon types)
        call switchbox("write")
    
        # Bring back the row id & check keyed documents.
        let ring_rowid = get_scrlib("curs_rowid")
        call lib_newkey() # (possibly) change documents tied to this key

    end if


    # Identify this as a new document
    let ring_cursor = 0
    call put_scrlib("curs_pos",ring_cursor)
    let sqlca.sqlcode = 0
    return ring_rowid, ring_cursor, ring_total
end function
# ring_lladd()
