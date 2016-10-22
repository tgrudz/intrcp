globals "globals.4gl"

############################################################################
function ret_prog_info(info_type)
############################################################################
#
 define
       info_type    char(30)


case info_type
    when "version"
         return "SILP_VER_VVVVVVVVVV"
    when "ctime"
{DT}     return "SILP_CT_TTTTTTTTTTT"
    when "program"
        return progid
    when "screen"
        case
           when scr_id = "default"
              return get_cur_screen()
           when scr_id = "browse"
              return "br_absen"
           otherwise
              return scr_id
        end case
    when "database"
        return get_scrlib("dbname")
    when "user"
        return fg_username()
end case
        
return ""

end function
# ret_prog_info()
