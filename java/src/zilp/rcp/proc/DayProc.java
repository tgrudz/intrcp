package zilp.rcp.proc;

import java.lang.reflect.Field;

import java.util.ArrayList;
import java.util.List;

import org.jdom.Element;

import zilp.rcp.objects.Day;

/**
 * This class build Day object from xml element
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class DayProc {
    
    Day day;

    public DayProc() {
    
        day = new Day();
    }
    
    public Day processDay(Element elDay){

                String d             = elDay.getAttributeValue("dzien");
                String dayType       = elDay.getAttributeValue("typDnia");
                String amount        = elDay.getAttributeValue("wymiar");
                String wokingTime    = elDay.getAttributeValue("czasPracy");
                String presence      = elDay.getAttributeValue("obecnosc");
                String absenceCode   = elDay.getAttributeValue("kodNieob");
                String absenceAmount = elDay.getAttributeValue("wymiarNieob");
                String entryPlan     = elDay.getAttributeValue("planWe");
                String notes         = elDay.getAttributeValue("uwagi");
                
                    day.setDay(d);
                    day.setDayType(dayType);
                    day.setAmount(amount);
                    day.setWokingTime(wokingTime);
                    day.setPresence(presence);
                    day.setAbsenceCode(absenceCode);
                    day.setAbsenceAmount(absenceAmount);
                    day.setEntryPlan(entryPlan);
                    day.setNotes(notes);
         
            return day;   
        }
}
