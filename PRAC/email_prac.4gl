main
  define dbname char(18),
         m_naz1, m_naz2 char(64),
         m_adres_email char(128),
         m_imie char(64),
         m_addr_nr,
         k, i, j smallint


  let dbname = fgl_getenv("DBSNAME")
   if length ( dbname clipped ) = 0 then
        error "Nie ustawiona zmienna $DBSNAME"
        sleep 3
        exit program 
   end if
   whenever error continue
   database dbname
   whenever error stop
   if sqlca.sqlcode < 0 then
      error "Nie mo¿na otworzyæ bazy: ", dbname
      sleep 3
      exit program 
   end if

   declare k1 cursor for 
      select a.addr_nr, a.name_1, a.name_2  from v_address a, pn_personal b
        where a.addr_nr = b.addr_nr
          and addr_type_fl = 'P'
          and addr_actual_fl = "T"
          and email is null
     order by 2
   

   foreach k1 into m_addr_nr, m_naz1, m_naz2
      let m_adres_email = null
      let m_imie = null
      
      let i = length (m_naz1)
      for k = 1 to i 
          if m_naz1[k] = '-' then
              exit for
          end if       
      end for
      if i = k-1 then
         let k = 1
      else
         let k = k+1
      end if 
  
      let i = 0
      for j = k to length (m_naz1)
          let i = i+1
          case m_naz1[j]
             when '±'
                 let m_adres_email[i] = 'a'
             when '¡'
                 let m_adres_email[i] = 'a'
             when 'ê'
                 let m_adres_email[i] = 'e'
             when 'Ê'
                 let m_adres_email[i] = 'e'
             when '³'
                 let m_adres_email[i] = 'l'
             when '£'
                 let m_adres_email[i] = 'l'
             when 'ó'
                 let m_adres_email[i] = 'o'
             when 'Ó'
                 let m_adres_email[i] = 'o'
             when 'ñ'
                 let m_adres_email[i] = 'n'
             when 'Ñ'
                 let m_adres_email[i] = 'n'
             when '¶'
                 let m_adres_email[i] = 's'
             when '¦'
                 let m_adres_email[i] = 's'
             when '¿'
                 let m_adres_email[i] = 'z'
             when '¯'
                 let m_adres_email[i] = 'z'
             when '¼'
                 let m_adres_email[i] = 'z'
             when '¬'
                 let m_adres_email[i] = 'z'
             otherwise
                 let m_adres_email[i] = m_naz1[j]
           end case
      end for 
      
      ######### imie
  
      for i = 1 to length (m_naz2)
       
          case m_naz2[i]
             when '±'
                 let m_imie[i] = 'a'
             when '¡'
                 let m_imie[j] = 'i'
             when 'ê'
                 let m_imie[i] = 'e'
             when 'Ê'
                 let m_imie[i] = 'e'
             when '³'
                 let m_imie[i] = 'l'
             when '£'
                 let m_imie[i] = 'l'
             when 'ó'
                 let m_imie[i] = 'o'
             when 'Ó'
                 let m_imie[i] = 'o'
             when 'ñ'
                 let m_imie[i] = 'n'
             when 'Ñ'
                 let m_imie[i] = 'n'
             when '¶'
                 let m_imie[i] = 's'
             when '¦'
                 let m_imie[i] = 's'
             when '¿'
                 let m_imie[i] = 'z'
             when '¯'
                 let m_imie[i] = 'z'
             when '¼'
                 let m_imie[i] = 'z'
             when '¬'
                 let m_imie[i] = 'z'
             otherwise
                 let m_imie[i] = m_naz2[i]
           end case
      end for 
	  ##################

      let m_adres_email = downshift (m_imie), ".", 
             downshift (m_adres_email) clipped, "@ad.lasy.gov.pl"
      display m_naz2 clipped, " ", m_naz1 clipped, " " , m_adres_email clipped
      update v_address set email = m_adres_email
          where addr_nr = m_addr_nr

   end foreach
end main
