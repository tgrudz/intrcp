
database forest

globals
  define

    p_bsence record   # Record like the pnabsen screen
        addr_nr like pn_absence.addr_nr,
        name_1 like v_address.name_1,
        name_2 like v_address.name_2,
        abs_code like pn_absence.abs_code,
        abs_name like pn_abs_type.abs_name,
        date_from like pn_absence.date_from,
        date_to like pn_absence.date_to,
        abs_days like pn_absence.abs_days,
        abs_hours like pn_absence.abs_hours,
        abs_work_days like pn_absence.abs_work_days,
        abs_work_hours like pn_absence.abs_work_hours,
        days_avail_limit smallint,
        hours_avail_limit decimal(7),
        abs_absolute like pn_absence.abs_absolute,
        abs_absol_days like pn_absence.abs_absol_days,
        days_used_limit smallint,
        hours_used_limit decimal(7),
        first_abs_num like pn_absence.first_abs_num,
        first_abs_code char(5),
        first_date_from date,
        first_date_to date,
        abs_doc_type_dc like pn_absence.abs_doc_type_dc,
        abs_doc_desc char(30),
        abs_stat_code like pn_absence.abs_stat_code,
        ins_ref_cd like pn_absence.ins_ref_cd,
        ins_date like pn_absence.ins_date,
        upd_ref_cd like pn_absence.upd_ref_cd,
        upd_date like pn_absence.upd_date
    end record,
    ma_addr array[14] of record
        addr_nr like v_address.addr_nr,
        name_1 like v_address.name_1,
        name_2 like v_address.name_2,
        status char(3)
      end record,

   abs_type_rec     record
                       abs_period_dc  like pn_abs_type.abs_period_dc,
                       abs_limit      like pn_abs_type.abs_limit,
                       is_plan_fl     like pn_abs_type.is_plan_fl,
                       is_hours_fl    like pn_abs_type.is_hours_fl,
                       day_hours      like pn_abs_type.day_hours
                    end record,

   scratch char(1024),
   m_txt   char(128)


end globals
