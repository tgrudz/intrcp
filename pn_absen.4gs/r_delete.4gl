######################################################################
# Program wykonany przez Pro-Holding Sp. z o. o., Kraków 2004
######################################################################

globals "globals.4gl"

define
    arr_mesgs array[2] of record    # Message text
        mssg_text char(132)
    end record,
    mssg_prep char(1)                  # Y/null Message cursor prepared?

######################################################################
function ring_delete(ring_rowid)
#   returning ring_rowid
######################################################################
#
    define
        ring_rowid      integer,
        must_close_trx  smallint,
        z               smallint,      # misc number
        yesno           char(1)

    # Trap fatal errors
    whenever error call error_handler

    # check for 'delete' privilege.
    if not security_chk("delete")
    then
        call security_msg("delete")
        return ring_rowid
    end if

    if mssg_prep is null
    then
        let mssg_prep = "Y"
        #1: "Delete:  Verify document deletion"
        let arr_mesgs[1].mssg_text = fg_message("lib_scr","rdelete",1)
        #2: " Erase this document? (Y/N) "
        let arr_mesgs[2].mssg_text = fg_message("lib_scr","rdelete",2)
    end if

    # Disregard the rowid that is passed (retained as an argument
    # for backward compatibility only)
    let ring_rowid = get_scrlib("curs_rowid")

    # Check for already deleted
    if ring_rowid = 0
    then
        call fg_error("lib_scr","r_delete",1)
        return ring_rowid
    end if

    # Check for no items in cursor
    if ring_rowid < 0
    then
        call fg_error("lib_scr","r_delete",2)
        return ring_rowid
    end if

    # Database transactions
    if is_trx() then
       whenever error continue
       begin work
       let must_close_trx = (sqlca.sqlcode = 0)
       whenever error call error_handler
    end if

    # Inserted for program level security.  (Retained for backward
    # compatibility with old security system.)
    # Check for write permission
    if not perms_ck("W")
    then
        if is_trx() then
          if must_close_trx then
            rollback work
          end if
        end if
        return ring_rowid
    end if

    # intelligent deletion routine
    if not ok_delete()
    then
        if is_trx() then
          if must_close_trx then
            rollback work
          end if
        end if
        return ring_rowid
    end if

    call ring_clear()
    let int_flag = 0
    let z = length(arr_mesgs[1].mssg_text)
    call str_display(arr_mesgs[1].mssg_text, z, 1, 2, "")
    let z = length(arr_mesgs[2].mssg_text)
    call str_prompt(arr_mesgs[2].mssg_text, z, "Y")
    let yesno = upshift(scratch[1])
#    if lang_put_yesno(yesno) matches "[yY]" and int_flag = 0
	if yesno = to_foreign("Y") and int_flag = 0
    then
        # no-op
    else
        if is_trx() then
          if must_close_trx then
            rollback work
          end if
        end if
        let int_flag = 0
        return ring_rowid
    end if

    # read, and lock the record
    call mlh_lock(ring_rowid)
    if sqlca.sqlcode != 0
    then
        if status = notfound
        then
            # somebody has already deleted it.
            clear form
            let ring_rowid = -1
            call put_scrlib("curs_rowid",ring_rowid)
        else
            call fg_error("lib_scr","r_delete",3)
        end if
        let status = 0
        if is_trx() then
          if must_close_trx then
            rollback work
          end if
        end if
        return ring_rowid
    end if

    call lld_delete()
    call llh_delete(ring_rowid)
    call lib_delkey()  # delete documents tied to this key
    call mlh_unlock()
    if is_trx() then
       if must_close_trx then
          commit work
       end if
    end if
    clear form
    call put_scrlib("curs_rowid",-1)
    return -1
end function
# ring_delete()
