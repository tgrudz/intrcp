######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################

globals "globals.4gl"

######################################################################
function ring_find(ring_rowid,ring_cursor,ring_total)
#   returning ring_rowid, ring_cursor, ring_total
######################################################################
# This function is run when "find" is selected from the ring menu.
#
    define
        ring_rowid  integer,
        ring_cursor integer,
        ring_total  integer,
        c char(1)             # input character

    # Trap fatal errors
    whenever error call error_handler

    # check for 'find' privilege.
    if not security_chk("find")
    then
        call security_msg("find")
        return ring_rowid, ring_cursor, ring_total
    end if

    # intelligent find routine
    if not ok_find()
      then return ring_rowid, ring_cursor, ring_total end if

    call lib_message("find")
    clear form
    let int_flag = 0

    # define a new cursor
    let sql_filter = mlh_construct()
    if int_flag != 0
    then
        # decided against "find" command
        clear form
        let status = 0
        let int_flag = 0
        call ring_view(ring_cursor)
            returning ring_rowid, ring_cursor
        return ring_rowid, ring_cursor, ring_total
    end if

    # close the cursor if open.
    if ring_total > 0
    then
        call mlh_close_cur()
    end if

    # define the cursor/present the first record
    call ring_define(sql_filter)
        returning ring_rowid, ring_cursor, ring_total

    return ring_rowid, ring_cursor, ring_total
end function
# ring_find()

######################################################################
function ring_define(criteria)
# returning ring_rowid, ring_cursor, ring_total
######################################################################
#
    define
        criteria        char(512),  # construct criteria
        must_close_trx  smallint,
        ring_rowid      integer,
        ring_cursor     integer,
        ring_total      integer

    # Database transactions
    if is_trx() then
       whenever error continue
       begin work
       let must_close_trx = (sqlca.sqlcode = 0)
       whenever error call error_handler
    end if

    call please_wait()
    call mlh_define_cur(criteria)

    # error if bad status, interrupt, or no rows processed
    if sqlca.sqlcode < 0 or sqlca.sqlerrd[3] = 0
    then
        clear form
        call mlh_clear()
        call llh_p_prep()
        call lib_getkey()
        let status = 0
        let ring_rowid = -1
        let ring_total = 0
        let ring_cursor = 0
        call put_scrlib("curs_rowid",ring_rowid)
        call put_scrlib("curs_count",ring_total)
        call put_scrlib("curs_pos",ring_cursor)
        if is_trx() then
          if must_close_trx then
             commit work
          end if
        end if
        return ring_rowid, ring_cursor, ring_total
    end if

    # cursor defined ok.
    let ring_total = sqlca.sqlerrd[3]
    call put_scrlib("curs_count",ring_total)
    call put_scrlib("curs_pos", 1)

    # grab the first row of the cursor
    call ring_view(1) returning ring_rowid, ring_cursor

    # Transaction processing
    if is_trx() then
       if must_close_trx then
          commit work
       end if
    end if

    return ring_rowid, ring_cursor, ring_total
end function
# ring_define()
