main
define
   argument       smallint,
   sts_errorlog   CHAR(60)

   defer interrupt
   let sts_errorlog = get_log_file()
   call startlog(sts_errorlog)
   let argument = arg_val(1)
   call main2(argument)

end main
