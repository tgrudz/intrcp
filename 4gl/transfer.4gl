#Interfejs RCP->SILP
#----------------------------------------------------------------------------------------------------------------
#Autor: Katarzyna Osi�ska
#       Zak�ad Informatyki LP
#Data:  2010.01.14
#----------------------------------------------------------------------------------------------------------------
# 1.02/2010.04.26 - zapisywanie danych do tabeli pn_absen_rates (okresy akcencji)
#----------------------------------------------------------------------------------------------------------------

globals "rcp_glob.4gl"
   define 
      dbname CHAR(18),
      m_naz_kat_app char(128),
      m_naz_kat_dat char(128),
      m_naz_plik_txt char(128),
      m_naz_plik_imp char(128),
      m_date_from, m_date_to date,
      max_rek_ekr,
      biez_rek smallint,
      naz_rap char(128),
      chk_curs_prep char(1),
      abs_param_prep   char(1),
      abs_type_prep    char(1),
      chk_plan_prep    char(1),
      cur_abs_code     like pn_abs_type.abs_code,
      m_email char(64),
      m_import_fl smallint,
      m_passwd char(16),
      mr_rcp_adm record 
            server_rcp char(32),
            login      char(16),
            passwd     char(32)
          end record
   

main
   define param smallint

   DEFER INTERRUPT 

   let param = arg_val(1)

   if not rcp_param() then
      exit program
   end if
   if param = 0 then
      call rcp_adm()
      exit program
   end if

   if not rcp_adm_haslo () then
      error "Brak danych adminstracyjnych serwera z RCP"
      sleep 3
      exit program
   end if

   open window w_intrcp at 2,2 with form "rcp_addr" attribute (border)
   call prn_set_std_esc()
   call rcp_tmp_table()
   
    menu "Akcja"
      command "Import" "Import danych z RCP"
         let m_import_fl = true
         call rcp_imp_kont() 
      command "Kontrola" "Kontrola zapis�w RCP - SILP" 
         let m_import_fl = false
         call rcp_imp_kont() 
      command "Exit" "Wyj�cie"
         exit menu
    end menu
end main

function rcp_param()
   define l_naz_app char(32),
          l_naz_plik char(128)

   let dbname = fgl_getenv("DBSNAME")
   if length ( dbname clipped ) = 0 then
	error "Nie ustawiona zmienna $DBSNAME"
	sleep 3
        return false
   end if
   whenever error continue 
   database dbname
   whenever error stop 
   if sqlca.sqlcode < 0 then
      error "Nie mo�na otworzy� bazy: ", dbname
      sleep 3
      return false
   end if

   let l_naz_app = fgl_getenv("INTRCPDIR")
   if length ( l_naz_app clipped ) = 0 then
      let l_naz_app = 'intrcp'
   end if

   let m_naz_kat_app = env_silp_app_dir() clipped, "/", l_naz_app
   let m_naz_kat_dat = env_silp_dat_dir ( ) clipped, "/", l_naz_app

   let l_naz_plik = env_silp_dat_dir ( ) clipped, "/logs/", 
       l_naz_app clipped, ".log"
   call env_start_log (l_naz_plik)
   call env_prog_set_name (l_naz_app)
   call env_db_set_name (dbname)
   let max_rek_ekr = 14
   return true
end function --rcp_param()

function rcp_tmp_table()
   define l_naz_plik char(128)

   create temp table tmp_rcp
      (abs_hours      char(4),  --wymiarNieob - ilo�� godzin nieobecnosci
       day_hours      char(4),  --wymiar dnia
       txt            char(1),  --uwagi
       day_type_ds    char(1),  --typ dnia 
       in_hours       char(4),  --planWE
       work_hours     char(4),  --obecnosc czas w pracy
       rcp_abs_code   char(5),  --kod nieobecnosci
       dor_date       char(10), --dzie�
       day_works      char(4))  --czasPracy

   create temp table tmp_abs_dic
       (rcp_abs_code  char(5),
        silp_abs_code char(5),
        fl             smallint) #0-tylko do kontroli, 
                                 #1-konwersja podczas importu do silp
                                 #2-konwersja podczas importu do silp
                                 #  po przekroczeniu limitu dla kodu
                                 #  z fl=1

   let l_naz_plik = m_naz_kat_app clipped, "/dsg/rcp_silp_abs_dic.unl"
   load from l_naz_plik insert into tmp_abs_dic
end function --rcp_tmp_table()



function rcp_adm()

   open window w_rcp_adm at 1,1 with form "rcp_adm" 
   options comment line 4
   call fgl_drawbox( 3,79, 5, 1)  
   call fgl_drawbox(16,79, 8, 1)
   
   if rcp_adm_haslo () then
   end if
   display by name mr_rcp_adm.server_rcp, mr_rcp_adm.login
   call rcp_wys_passwd()

   menu "Adminstrator RCP"
      command "Kor" "Edycja/korekta"
         call rcp_adm_cor()
      command "Exit" "Wyj�cie"
         exit menu
   end menu

end function --rcp_adm()
   
function rcp_adm_haslo () 
   define i,j,k smallint
   
   let m_passwd = " "
   select * into mr_rcp_adm.* from x_adm_rcp
   if status = notfound then
      let mr_rcp_adm.server_rcp =' '
      let mr_rcp_adm.login =' '
      let mr_rcp_adm.passwd =' '
      return false
   else
      if mr_rcp_adm.login is null then
          let mr_rcp_adm.login =' '
      end if 
      if mr_rcp_adm.login is null then
          let mr_rcp_adm.passwd =' '
      end if 
      if length(mr_rcp_adm.server_rcp) = 0 or length(mr_rcp_adm.login) = 0 
         or length(mr_rcp_adm.passwd) = 0 
      then
         return false
      end if
      let j = 1
      let i = length(mr_rcp_adm.passwd)-1
      if i = -1 then
         return false
      end if
      for k = i to 1 step -2
         let m_passwd[j] = mr_rcp_adm.passwd[k]
         let j = j+1
      end for
      return true
   end if
end function --rcp_adm_haslo () 

function rcp_wys_passwd()
   define i,k  smallint, x_passwd char(16)

   let x_passwd =""
   let i = length (m_passwd)
   for k = 1 to i
       let x_passwd[k] = "*"
   end for 
   display x_passwd at 15, 14
end function

function rcp_adm_cor()
   define mh_rcp_adm record 
            server_rcp char(32),
            login      char(16),
            passwd     char(32)
          end record,
          kod char(64),
          i,j,k smallint
   
   let mh_rcp_adm.* = mr_rcp_adm.*
   let int_flag = false
   let mr_rcp_adm.passwd = null
   call info_stm_lines_41("corr")
   call info_lines_f_key(4, "        ")
   display "          " at 15, 14
   input by name mr_rcp_adm.server_rcp, 
                 mr_rcp_adm.login, 
                 mr_rcp_adm.passwd without defaults
      after field passwd
         if fgl_lastkey () <> fgl_keyval ("accept") then
            next field next
         end if
      after input
         if int_flag then
            exit input
         end if
         if mr_rcp_adm.server_rcp is null then
            error "Pole musi by� wype�nione"
            next field server_rcp
         end if
         if mr_rcp_adm.login is null then
            error "Pole musi by� wype�nione"
            next field login
         end if

         if mr_rcp_adm.passwd is null and m_passwd = " "
         then
            error "Pole musi by� wype�nione"
            next field passwd
         end if
   end input
   if int_flag then
     let int_flag = false
     let mr_rcp_adm.* = mh_rcp_adm.*
     display by name mr_rcp_adm.server_rcp, mr_rcp_adm.login
     call rcp_wys_passwd()
     error "Przerwano dzia�anie"
     return
   end if
   
   if mr_rcp_adm.passwd is not null and mr_rcp_adm.passwd <> m_passwd then
      let kod = "!1q@2w#3e$4r%t^y&u*i(o)p_[+]!q2wxT@RK%TsKW"
      let m_passwd = mr_rcp_adm.passwd
      let i = length(m_passwd)
      let j = 1
      for k = i TO 1 step -1
         let mr_rcp_adm.passwd[j] = m_passwd[k]
         let mr_rcp_adm.passwd[j+1] = kod[j]
         let j = j+2
      end for     
   else
     let  mr_rcp_adm.passwd =  mh_rcp_adm.passwd 
   end if
   if mr_rcp_adm.login <> mh_rcp_adm.login 
      or mr_rcp_adm.passwd <> mh_rcp_adm.passwd 
      or mr_rcp_adm.server_rcp <> mh_rcp_adm.server_rcp 
   then
      delete from x_adm_rcp
      insert into x_adm_rcp values (mr_rcp_adm.*)
   end if
   call rcp_wys_passwd()
end function --rcp_adm_cor()

function rcp_jest_plik(naz_plik)
#sprawdzenie czy jest plik i jest niepusty
   define naz_plik CHAR(128), jest SMALLINT, inst CHAR(256)

    let jest = false
    let inst = "test -s ",  naz_plik CLIPPED
    run inst returning jest
    if jest <> 0 then
        return false
    end if
    return true

end function --rcp_jest_plik()

function rcp_imp_kont()
   define  
          l_txt, l_kom char(128),
          licz_rek, i  smallint,
          inst_rm char(256)

   if not rcp_okres()then
      return
   end if
   if m_import_fl then
      let l_txt = "Importowa� dane z RCP" 
      let l_kom = "IMPORT   DANYCH"
   else
      let l_txt = "Kontrolawa� dane z RCP z SILP"
      let l_kom = "KONTROLA  DANYCH  RCP  Z  SILP"  
   end if
   let l_txt = l_txt clipped, " za okres ", m_date_from, " - ", 
                  m_date_to, " ?"

   if not get_yes_no (l_txt) then
      return
   end if
   let l_kom = l_kom clipped, "  ZA  OKRES  " , m_date_from, " - ", m_date_to
   display l_kom at 1, 1 
   display "" at 2, 1

   select count(*) into licz_rek 
      from pn_personal, v_address, pn_employ
      where pn_personal.addr_nr = v_address.addr_nr
        and pn_personal.addr_nr = pn_employ.addr_nr
        and pn_personal.addr_type_fl = "P"     --pracownik
        and pn_personal.addr_actual_fl = "T"   --aktualny pracownik
        and (m_date_from between pn_employ.date_from and pn_employ.date_to
        or m_date_to between pn_employ.date_from and pn_employ.date_to)
   if licz_rek = 0 then
      error 'Brak pracownik�w w bazie!'
      return
   end if

   let naz_rap = env_report_set ("imp", "rap", "del")
   start report rcp_imp_rap

   declare c1_pn_personal cursor with hold for 
      select unique pn_personal.addr_nr, 
             v_address.name_1,
             v_address.name_2,
             v_address.email
      from pn_personal, v_address, pn_employ
      where pn_personal.addr_nr = v_address.addr_nr
        and pn_personal.addr_nr = pn_employ.addr_nr
        and pn_personal.addr_type_fl = "P"   
        and pn_personal.addr_actual_fl = "T"  
        and (m_date_from between pn_employ.date_from and pn_employ.date_to
        or m_date_to between pn_employ.date_from and pn_employ.date_to)
      order by v_address.name_1, v_address.name_2
   
   let biez_rek = 0
   initialize p_bsence.* to null
   let p_bsence.ins_date = today
   let p_bsence.ins_ref_cd = get_ref_cd()

   foreach c1_pn_personal into p_bsence.addr_nr,
                               p_bsence.name_1,
                               p_bsence.name_2,
                               m_email
       let biez_rek = biez_rek + 1
       display "(", biez_rek using "<<<<", " z ", licz_rek using "<<<<", ")"
          at 3, 35
       call rcp_wysw_prac()

       let m_txt = p_bsence.addr_nr USING '-----#', "  ", 
                        p_bsence.name_1 clipped, " ",
                        p_bsence.name_2


       if m_email is null or m_email = ' ' then
          output to report rcp_imp_rap (m_txt)
          call rcp_zapisz_do_rap("Brak adresu mailowego")
          call rcp_wysw_status ("NIE")
          continue foreach
       end if
       
       let m_naz_plik_imp = null
       for i = 1 to length(m_email)
          if m_email[i] = "@" then
             exit for
          end if
          if m_email[i] = "." then
             continue for
          end if
          let m_naz_plik_imp = m_naz_plik_imp clipped, m_email[i]
       end for
       let inst_rm = "rm -f ", m_naz_kat_dat clipped, "/", 
                       m_naz_plik_imp clipped, ".* >/dev/null" 

       if not rcp_imp_xml () then
          output to report rcp_imp_rap (m_txt)
          let l_kom = "B��d podczas transferu pliku ",
              m_naz_plik_imp clipped, ".xml !"
          call rcp_zapisz_do_rap(l_kom)
          call rcp_wysw_status ("NIE")
          run inst_rm
          continue foreach
       end if

       if not rcp_kon_xml_txt () then
          output to report rcp_imp_rap (m_txt)
          call rcp_zapisz_do_rap ("B��d podczas konwersji !")
          call rcp_wysw_status ("NIE")
          run inst_rm
          continue foreach
       end if
       if rcp_imp_to_tmp () then
          if m_import_fl then
             output to report rcp_imp_rap (m_txt)
             call rcp_imp_silp () 
          else
             call rcp_kontrola_silp () 
          end if
          call rcp_wysw_status ("TAK")
       else 
          output to report rcp_imp_rap (m_txt)
          call rcp_zapisz_do_rap ("B��d podczas importu danych do tabeli tmp !")
          call rcp_wysw_status ("NIE")
       end if
       run inst_rm
   end foreach
   finish report rcp_imp_rap
   call env_report_view()
   clear form  
   display "" at 3,1
end function --rcp_imp()

function rcp_okres()
   define ok, i smallint,
          l_rok char(4), l_mc char(2),
          l_date char(10)

   open window w_okres at 2,2 with form "rcp_okres" attribute (border)
   if m_import_fl then
   display "Wprowad� okres do importu           Koniec: <ESC>  Przerwij: <DEL>" 
       at 2,1 
   else
   display "Wprowad� okres do kontroli          Koniec: <ESC>  Przerwij: <DEL>" 
       at 2,1 
   end if
   
   let ok = true
   
   let l_mc = month(TODAY) using "&&"
   let l_rok = year(TODAY)
   input l_mc, l_rok WITHOUT DEFAULTS FROM mc, rok 
      after input  
         if int_flag then
            let int_flag = false
            let ok = false
            exit input
         end if 
   end input
   if not ok then
      error "Przerwano wprowadzanie okresu!"
      return false
   end if
   let l_date = l_rok using '&&&&', ".", l_mc, ".01"
   let m_date_from = l_date
   if l_mc = 12 then
      let l_date = l_rok using "&&&&", ".", l_mc, ".31"
      let m_date_to = l_date
   else
      let i = l_mc+1 
      let l_date = l_rok using "&&&&", ".", i using "&&", ".01" 
      let  m_date_to = l_date
      let m_date_to = m_date_to-1
   end if
   close window w_okres
   if m_date_from is null or m_date_to is null then
      error "Bledny okres!"
      return false
   else
      return true
   end if
end function --rcp_okres()

function rcp_wysw_prac()
   define i smallint

   if biez_rek = 1 then
      for i = 1 to max_rek_ekr
         initialize ma_addr[i].* to null
      end for
   end if

   if biez_rek <= max_rek_ekr then
	let ma_addr[biez_rek].addr_nr = p_bsence.addr_nr
	let ma_addr[biez_rek].name_1 = p_bsence.name_1
	let ma_addr[biez_rek].name_2 = p_bsence.name_2
        if biez_rek > 1 then
           display ma_addr[biez_rek-1].* to s_addr[biez_rek-1].* 
               attribute(normal)
        end if
        display ma_addr[biez_rek].* to s_addr[biez_rek].* attribute(reverse)
   else
	for i =1 to max_rek_ekr-1
	   let ma_addr[i].addr_nr = ma_addr[i+1].addr_nr
	   let ma_addr[i].name_1 = ma_addr[i+1].name_1
	   let ma_addr[i].name_2 = ma_addr[i+1].name_2
	   let ma_addr[i].status = ma_addr[i+1].status
           display ma_addr[i].* to s_addr[i].* 
        end for    
        let ma_addr[max_rek_ekr].addr_nr = p_bsence.addr_nr
	let ma_addr[max_rek_ekr].name_1 = p_bsence.name_1
	let ma_addr[max_rek_ekr].name_2 = p_bsence.name_2
	let ma_addr[max_rek_ekr].status = null
        display ma_addr[max_rek_ekr].* to s_addr[max_rek_ekr].* 
            attribute(reverse)
   end if
end function --rcp_wysw_prac()

function rcp_wysw_status (stat_fl)
   define stat_fl char(3), i smallint

   if biez_rek <= max_rek_ekr then
      let i = biez_rek
   else
      let i = max_rek_ekr
   end if
   let ma_addr[i].status =  stat_fl
   display ma_addr[i].status to s_addr[i].status 
            attribute(reverse)
end function --rcp_wysw_status

function rcp_zapisz_do_rap(l_kom) 
   define l_kom char(128)

   let l_kom = "          ", l_kom
   output to report rcp_imp_rap (l_kom)
end function --rcp_zapisz_do_rap() 

function rcp_imp_xml() 
   define l_naz_plik_xml char(126),
          l_date_from, l_date_to char(10),
          ret integer

   let l_naz_plik_xml = m_naz_kat_dat clipped, "/", m_naz_plik_imp clipped,
       ".xml"


   let l_date_from = m_date_from
   let l_date_from = l_date_from[9,10], '-', l_date_from[6,7],
                     '-', l_date_from[1,4]
   let l_date_to = m_date_to
   let l_date_to = l_date_to[9,10], '-', l_date_to[6,7],
                     '-', l_date_to[1,4]


   let scratch = "wget --http-user=",mr_rcp_adm.login clipped,
             " --http-passwd=", m_passwd clipped,
              " -O ", l_naz_plik_xml clipped, " -t 1", 
              " ""http://", mr_rcp_adm.server_rcp clipped,
              "/webrcp/services/xml/EwidCPPrac.",
              "do?ref=", m_email clipped, "&ood=", l_date_from, 
              "&odo=", l_date_to, """ >/dev/null 2>&1"
#   let scratch = m_naz_kat_app clipped, "/bin/rcp_wget.sh ", m_haslo clipped,
#                 " ", l_naz_plik_xml, " ",
#                 m_email clipped, " ", l_date_from, " ", l_date_to     
   run scratch returning ret
   if ret <> 0 then
      return false
   end if

   if not rcp_jest_plik ( l_naz_plik_xml ) then -- brak pliku
      return false
   end if
   return true
end function --rcp_imp_xml() 

function rcp_kon_xml_txt ()

  
   let scratch = "java -jar ", m_naz_kat_app clipped, "/bin/rcpsilp-1.0.jar ", 
               m_naz_plik_imp clipped, " >/dev/null 2>&1"
   run scratch
   if status <> 0 then
      return false
   end if
   
   let m_naz_plik_txt = m_naz_kat_dat clipped, "/", m_naz_plik_imp clipped,
      ".txt"

   if not rcp_jest_plik  ( m_naz_plik_txt ) then -- brak pliku
      return false
   end if
   return true
end function --rcp_kon_xml_txt ()

function rcp_imp_to_tmp () 
   define i integer,
          l_rcp_dor_date char(10)

   delete from tmp_rcp
   whenever error continue 
   load from m_naz_plik_txt insert into tmp_rcp
   whenever error stop 
   if status < 0 then
      return false
   end if
   update tmp_rcp set rcp_abs_code = " " where rcp_abs_code is null
   declare k0_imp_tmp cursor for 
      select rowid, dor_date from tmp_rcp 
      order by dor_date
   foreach k0_imp_tmp into i, l_rcp_dor_date
      let l_rcp_dor_date = l_rcp_dor_date[7,10], ".",
                           l_rcp_dor_date[4,5], ".",
                           l_rcp_dor_date[1,2]
      update tmp_rcp set dor_date = l_rcp_dor_date where rowid = i
   end foreach
   return true
end function --rcp_imp_to_tmp () 

function rcp_imp_silp ()
   define p_rcp_abs_code, b_rcp_abs_code, l_rcp_dor_date char(10),
          l_day_type_ds char(1),
          l_txt char(128)


   declare k1_imp_silp cursor for 
      select rcp_abs_code, day_type_ds, dor_date from tmp_rcp 
      order by dor_date

   let p_rcp_abs_code = "-"
   foreach k1_imp_silp into b_rcp_abs_code, l_day_type_ds, l_rcp_dor_date
      let b_rcp_abs_code = upshift (b_rcp_abs_code)

      if p_rcp_abs_code <> b_rcp_abs_code then
#w plikach z RCP dla urlopu wypoczynkowego 'UW' dla wolnych dni nie jest
#wprowadzony kod absencji 
          if p_rcp_abs_code = "UW" and b_rcp_abs_code = " " 
             and l_day_type_ds <> "R"
          then
              continue foreach
          end if

          if p_rcp_abs_code <> "-" and p_rcp_abs_code <> " " then
              call rcp_zapisz_abs()
          end if
          select silp_abs_code into p_bsence.abs_code
              from tmp_abs_dic
              where rcp_abs_code = b_rcp_abs_code
                and fl = 1
          if status = notfound then
              let p_bsence.abs_code = "-"
              let m_txt = "Brak konwersji kodu: ", b_rcp_abs_code
          else
              if not get_abs_type() then
                 let p_bsence.abs_code = "-"
              end if
          end if  
          let p_bsence.date_from = l_rcp_dor_date 
          let p_rcp_abs_code = b_rcp_abs_code
      end if
      let p_bsence.date_to = l_rcp_dor_date 
   end foreach
   if p_rcp_abs_code <> "-" and p_rcp_abs_code <> " " then
       call rcp_zapisz_abs()
   end if
end function -- rcp_imp_silp ()


function rcp_imp_kontrola()
define
   tmp_abs_num       integer,
   tmp_int           integer,
   tmp_absgrp_code   char(5),
   tmp_l_day_hours   like pn_calen_pos.day_hours,
   stat              integer

   let tmp_abs_num = -1
   if chk_curs_prep is null then
      let chk_curs_prep = "Y"
      let scratch = "select pn_absence.abs_num",
                   " from pn_absence",
                     " where pn_absence.addr_nr = ? ",
                     " and ? between pn_absence.date_from",
                           " and pn_absence.date_to"
      prepare abs_chk1_stmt from scratch
      declare abs_chk1_curs cursor for abs_chk1_stmt
      
      let scratch = "select pn_absence.abs_num",
                   " from pn_absence",
                   " where pn_absence.addr_nr = ? ",
                     " and pn_absence.date_from between ? and ? "
      prepare abs_chk2_stmt from scratch
      declare abs_chk2_curs cursor for abs_chk2_stmt
   end if

   open abs_chk1_curs using p_bsence.addr_nr,
                               p_bsence.date_from
   fetch abs_chk1_curs into tmp_int
   let stat = sqlca.sqlcode
   close abs_chk1_curs
   if stat != notfound then
      call rcp_zapisz_do_rap("Istnieje dokument absencji na ten okres !!!")
      return false
   end if

   open abs_chk1_curs using p_bsence.addr_nr,
                               p_bsence.date_to
   fetch abs_chk1_curs into tmp_int
   let stat = sqlca.sqlcode
   close abs_chk1_curs
   if stat != notfound then
      call rcp_zapisz_do_rap("Istnieje dokument absencji na ten okres !!!")
      return false
   end if

   open abs_chk2_curs using p_bsence.addr_nr,
                            p_bsence.date_from, p_bsence.date_to
   fetch abs_chk2_curs into tmp_int
   let stat = sqlca.sqlcode
   close abs_chk2_curs
   if stat != notfound then
      call rcp_zapisz_do_rap("Istnieje dokument absencji na ten okres !!!")
      return false
   end if

   # check absence plans
   if abs_type_rec.is_plan_fl = "T"
   then
      if not chk_plan()
      then
         call rcp_zapisz_do_rap("Brak przypisanej pozycji planu na okres absencji !!!")
         return false
      end if
   end if

   # count absence days and hours

   call abs_count(p_bsence.addr_nr, p_bsence.abs_code,
                  p_bsence.date_from, p_bsence.date_to)
        returning stat, p_bsence.abs_days, p_bsence.abs_hours,
                  p_bsence.abs_work_days, p_bsence.abs_work_hours,
                  tmp_l_day_hours

   case stat
      when -1
         call rcp_zapisz_do_rap("Brak pozycji w przebiegu zatrudnienia na okres absencji !!!")
         return false
      when -2
         call rcp_zapisz_do_rap("Przebieg zatrudnienia nie pokrywa ca�ego okresu absencji !!!")
         return false
      when -3
         call rcp_zapisz_do_rap("Brak danych w DOR i kalendarzu dla okresu absencji !!!")
         return false
      when -4
         call rcp_zapisz_do_rap("Brak danych w kalendarzu dla okresu absencji !!!")
         return false
      when -5
         call rcp_zapisz_do_rap("Brak definicji wszystkich dni absencji w DOR i kalendarzu !!!")
         return false
      when -6
         call rcp_zapisz_do_rap("Brak definicji wszystkich dni absencji w kalendarzu !!!")
         return false
   end case

   call abs_limit_check(p_bsence.abs_code, abs_type_rec.abs_period_dc,
                        abs_type_rec.abs_limit, abs_type_rec.is_hours_fl,
                        abs_type_rec.day_hours, tmp_abs_num,
                        p_bsence.addr_nr, p_bsence.date_from,
                        p_bsence.date_to, p_bsence.abs_days,
                        p_bsence.abs_hours, 0)
        returning stat, p_bsence.days_avail_limit, p_bsence.days_used_limit,
                  p_bsence.hours_avail_limit, p_bsence.hours_used_limit,
                  p_bsence.abs_hours, tmp_absgrp_code

   if p_bsence.abs_work_hours > p_bsence.abs_hours
   then
      let p_bsence.abs_work_hours = p_bsence.abs_hours
   end if

   case stat
      when -1
         call rcp_zapisz_do_rap("Przekroczony limit dla kodu absencji !!!")
         return false
      when -2
         call rcp_zapisz_do_rap("UWAGA - niepe�ny ostatni dzie� absencji !!!")
         return false
      when -3
         call rcp_zapisz_do_rap("Przekroczony indywidualny limit dla kodu absencji !!!")
         return false
      when -11
         let m_txt = "Przekroczony limit dla grupy absencji '",
                       tmp_absgrp_code clipped, "' !!!"
         call rcp_zapisz_do_rap(m_txt clipped)
         return false
      when -12
         let m_txt = "Przekroczony indywidualny limit dla grupy absencji '",
                       tmp_absgrp_code clipped, "' !!!"
         call rcp_zapisz_do_rap(m_txt clipped)
         return false
   end case
   return true

end function
#rcp_imp_kontrola

function rcp_zapisz_abs()
    define l_txt char(128), l_date_from, l_date_to date,
           l_silp_abs_code_zus char(5),
           l_limit_dni, l_dni,
           l_prac_zus_fl smallint,
           l_abs_num integer


    let l_prac_zus_fl = false
    select silp_abs_code into l_silp_abs_code_zus
       from tmp_abs_dic
       where rcp_abs_code in (select rcp_abs_code from tmp_abs_dic 
             where silp_abs_code = p_bsence.abs_code)
         and fl = 2
        
    if status <> notfound then
       select (avail_limit-used_limit) into l_limit_dni
           from pn_absli_head, pn_absli_pos
           where pn_absli_head.limit_num = pn_absli_pos.limit_num
             and pn_absli_head.addr_nr =  p_bsence.addr_nr
             and pn_absli_head.limit_code = p_bsence.abs_code
             and pn_absli_pos.limit_year = year(p_bsence.date_from)
       if status = notfound then
           select abs_limit into l_limit_dni
              from pn_abs_type
              where abs_code = p_bsence.abs_code
       end if 
       if l_limit_dni = 0 then
          let p_bsence.abs_code =  l_silp_abs_code_zus
          if not get_abs_type() then
              let p_bsence.abs_code = "-"
          end if
       else
           let l_dni = p_bsence.date_to - p_bsence.date_from + 1
           if l_dni > l_limit_dni then
              let l_date_to = p_bsence.date_to  
              let p_bsence.date_to = p_bsence.date_from+l_limit_dni-1
              let l_date_from = p_bsence.date_to +1
              let l_prac_zus_fl = true
           end if
       end if
    end if 

    while true
       let l_txt =  "        ", p_bsence.date_from, " - ",
                 p_bsence.date_to, "  ", p_bsence.abs_code
       output to report rcp_imp_rap (l_txt)

       if p_bsence.abs_code = "-" then
           call rcp_zapisz_do_rap(m_txt)
           exit while
       end if

       if rcp_imp_kontrola() then
          insert into pn_absence (
             abs_num, addr_nr, abs_code, first_abs_num, abs_doc_type_dc,
             abs_stat_code, date_from, date_to, abs_days, abs_hours,
             abs_work_days, abs_work_hours, abs_absolute, abs_absol_days,
             ins_ref_cd, ins_date, upd_ref_cd, upd_date)
         values (
             0, p_bsence.addr_nr, p_bsence.abs_code, p_bsence.first_abs_num,
             p_bsence.abs_doc_type_dc, p_bsence.abs_stat_code,
             p_bsence.date_from, p_bsence.date_to, p_bsence.abs_days,
             p_bsence.abs_hours, p_bsence.abs_work_days,
             p_bsence.abs_work_hours, p_bsence.abs_absolute,
             p_bsence.abs_absol_days, p_bsence.ins_ref_cd,
             p_bsence.ins_date, p_bsence.upd_ref_cd, p_bsence.upd_date)
# *** 1.02/2010.04.26
         let l_abs_num = sqlca.sqlerrd[2]
         call abs_rates_count(l_abs_num, p_bsence.addr_nr,
                             p_bsence.abs_code, p_bsence.date_from,
                             p_bsence.date_to, p_bsence.first_abs_num)
# *** end 1.02/2010.04.26
      end if 
      if l_prac_zus_fl then
          let p_bsence.abs_code =  l_silp_abs_code_zus
          if not get_abs_type() then
              let p_bsence.abs_code = "-"
          end if
          let p_bsence.date_from = l_date_from 
          let p_bsence.date_to = l_date_to 
	  let l_prac_zus_fl = false
      else
          exit while
      end if
   end while
end function
#rcp_zapisz


function rcp_kontrola_silp()
   define l_rcp_abs_code, l_silp_abs_code char(5),
          l_dor_date date,
          l_txt char(128),
          i  smallint

   declare k1_kont_silp cursor for 
      select dor_date, rcp_abs_code 
      from tmp_rcp
      where day_type_ds = "R" 
         or (day_type_ds <> "R" and rcp_abs_code <> " ")
      order by dor_date
   foreach k1_kont_silp into l_dor_date, l_rcp_abs_code
      let l_rcp_abs_code = upshift(l_rcp_abs_code)

      select abs_code into l_silp_abs_code 
         from pn_absence
         where addr_nr = p_bsence.addr_nr
           and l_dor_date between date_from and date_to
      if status = notfound then 
         if l_rcp_abs_code = " " then --ok
            continue foreach
         else
            let l_silp_abs_code = " -"
         end if
      else
         select count(*) into i  
            from tmp_abs_dic
            where rcp_abs_code = l_rcp_abs_code
              and silp_abs_code = l_silp_abs_code
        if i > 0 then
            continue foreach
        end if
      end if
      let l_txt = p_bsence.addr_nr USING '-----#', "  ", 
                  p_bsence.name_1 clipped, " ",
                  p_bsence.name_2
      let l_txt[50,128] = l_dor_date, "  ", l_rcp_abs_code, "  ",
         l_silp_abs_code
      output to report rcp_imp_rap (l_txt)
   end foreach
end function --rcp_kontrola_silp()


#------------------------------------------------------------------------
#FUNKCJE z modu�u custom.4gl

######################################################################
function get_abs_type()
######################################################################
#
define
   stat   integer

   if abs_type_prep is null
   then
      let abs_type_prep = "Y"
      let scratch = "select pn_abs_type.abs_period_dc,",
                    " pn_abs_type.abs_limit,",
                    " pn_abs_type.is_plan_fl,",
                    " pn_abs_type.is_hours_fl,",
                    " pn_abs_type.day_hours",
                   " from pn_abs_type",
                   " where pn_abs_type.abs_code = ? "
      prepare abs_type_stmt from scratch
     declare abs_type_curs cursor for abs_type_stmt
   end if

   # get absence definition
   if cur_abs_code = p_bsence.abs_code
   then
      return true
   else
      open abs_type_curs using p_bsence.abs_code
      fetch abs_type_curs into abs_type_rec.*
      let stat = sqlca.sqlcode
      close abs_type_curs
      if stat = notfound
      then
         let m_txt = "Brak definicji kodu absencji !!!"
         return false
      end if
   end if

   if abs_type_rec.abs_period_dc is null
   then
      let m_txt = "B��dna definicja okresu zliczania absencji !!!"
      return false
   end if

   return true

end function
# get_abs_type()


######################################################################
function get_abs_param(a_param_code)
######################################################################
#
define
   a_param_code    smallint,
   tmp_feature     smallint,
   tmp_value_dec   decimal(7,3)

   if abs_param_prep is null
   then
      let abs_param_prep = "Y"
      let scratch = "select pn_dict_pos.feature, pn_dict_pos.value_dec",
                   " from pn_dict_pos",
                   " where pn_dict_pos.type = 'abs_params'",
                     " and pn_dict_pos.code = ? "
      prepare get_param_stmt from scratch
      declare get_param_curs cursor for get_param_stmt
   end if

   open get_param_curs using a_param_code
   fetch get_param_curs into tmp_feature, tmp_value_dec
   if sqlca.sqlcode = notfound
   then
      let tmp_feature = null
      let tmp_value_dec = null
   end if
   close get_param_curs

   case a_param_code
      when 1
         if tmp_feature is null
         then
            let tmp_feature = 60
         end if
      when 2
         if tmp_feature is null
         then
            let tmp_feature = 180
         end if
      when 3
         if tmp_feature is null
         then
            let tmp_feature = 12
         end if
   end case

   return tmp_feature

end function
# get_abs_param()


######################################################################
function chk_plan()
######################################################################
#
define
   tmp_wage_code   char(5),
   tmp_abs_year    smallint,
   tmp_year        smallint,
   ret_value       smallint,
   stat            integer

   if chk_plan_prep is null
   then
      let chk_plan_prep = "Y"
      let scratch = "select pn_employ.wage_code",
                   " from pn_employ",
                   " where pn_employ.addr_nr = ? ",
                     " and pn_employ.date_from <= ? ",
                     " and pn_employ.date_to >= ? ",
                   " order by 1"
      prepare get_empl_stmt from scratch
      declare get_empl_curs cursor for get_empl_stmt
      let scratch = "select pn_abspl_pos.abs_year",
                   " from pn_abspl_pos",
                   " where pn_abspl_pos.abs_code = ? ",
                     " and pn_abspl_pos.wage_code = ? ",
                     " and pn_abspl_pos.abs_year = ? "
      prepare get_plan_stmt from scratch
      declare get_plan_curs cursor for get_plan_stmt
   end if

   let ret_value = true

   if p_bsence.addr_nr is null
      or length(p_bsence.abs_code) = 0
      or p_bsence.date_from is null
      or p_bsence.date_to is null
   then
      return ret_value
   end if

   let tmp_abs_year = year(p_bsence.date_from)

   open get_empl_curs using p_bsence.addr_nr,
                            p_bsence.date_to,
                            p_bsence.date_from
   while true
      fetch get_empl_curs into tmp_wage_code
      if sqlca.sqlcode = notfound
      then
         exit while
      end if
      open get_plan_curs using p_bsence.abs_code, tmp_wage_code, tmp_abs_year
      fetch get_plan_curs into tmp_year
      let stat = sqlca.sqlcode
      close get_plan_curs
      if stat = notfound
      then
         let ret_value = false
         exit while
      end if
   end while
   close get_empl_curs

   return ret_value

end function
# chk_plan()

#------------------------------------------------------------------------


report rcp_imp_rap (tekst)
    define tekst, l_txt CHAR(126), 
           licz_kol smallint,
           l_firmen_name, l_ort char(64)

    output report to naz_rap 
    top margin 1
    bottom margin 1
    left margin 5
    page length 64

    format
       page header
          if pageno = 1 then
             print prn_init(), prn_cpi_17()
          else
             print prn_form_feed()
          end if
          let licz_kol = 100 
          print column 1, get_num_char("*", licz_kol) CLIPPED
          if m_import_fl then
             print column 1, "***               Import danych z RCP za okres ", 
                   m_date_from, " - ", m_date_to,
                   column 98, "***"
          else
             print column 1, "***               Kontrola danych z RCP z SILP",
                   " za okres ", m_date_from, " - ", m_date_to,
                   column 98, "***"
          end if
          print column 1, "***", 
                column 98, "***"

          select firmen_name, ort into l_firmen_name, l_ort from sts_liz
          print column 1, "*** Baza: ", dbname clipped, " (", 
                          l_firmen_name clipped, " ", l_ort clipped, ")",
                column 98, "***"

          select name_1 into l_txt from v_address, v_parameter
             where v_address.addr_nr = v_parameter.company_addr_nr                       
          print column 1, "*** ", l_txt clipped, 
                column 66, "Data: ", today,
                column 86, "Strona ", pageno using "<<<<<",
                column 98, "***"
          print column 1, get_num_char("*", licz_kol) CLIPPED
          skip 1 lines
          if m_import_fl then
             print column 1, "Nr adr.",
                   column 9, "Nazwisko i imi�"
          else
             print column 1, "Nr adr.",
                   column 9, "Nazwisko i imi�",
                   column 50, "Data",
                   column 62, "RCP",
                   column 69, "SILP"
          end if
          print column 1, get_num_char("-", licz_kol) CLIPPED
               
	on every row
	    print column 1, tekst
        on last row
	   print column 1, "===============================================",
		"==================================================="
	   print prn_cpi_10(), prn_de_init()
end report

