package zilp.rcp.client;

import java.util.List;

import zilp.rcp.builder.Builder;
import zilp.rcp.objects.Day;
import zilp.rcp.objects.Report;
import zilp.rcp.util.Util;

/**
 * This class creates .txt file with data from Java objects
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class Creator{

    /**
     * Method reads Java objects created from .xml file and 
     * saves this data to .txt file
     * @param fileName
     */
    public void run(String fileName){
        
        Util util = new Util();
        //util.createLogDir();
        
        if (fileName != null && fileName.length() >0){
        
            util.log("Poczatek procedury dla: "+fileName);
            
            Builder builder = new Builder();
            Report r = builder.buildReport(fileName);
            List<Day> days = r.getEmployee().getDays();
            String data = buildData(days);
            
            StringBuilder sb = new StringBuilder();
                //sb.append("wymiarNieob|wymiar|uwagi|typDnia|planWe|obecnosc|kodNieob|dzien|czasPracy\n");
                sb.append(data);
            String allData = sb.toString();
            
            util.create(allData,fileName);
            
            util.log("Zakonczono procedure dla: "+fileName);
            util.log("################################################################################");
            
        }else{
                util.log("Nie podano nazwy pliku wejsciowego");
            }         
        }


    /**
     * Buid data as String from Java objects.
     * In this application it buid data from lis of Day objec
     * @param days
     * @return
     */
    private String buildData(List<Day> days){
        
        StringBuilder sb = new StringBuilder();
        
        for(Day d : days){
        
            sb.append(d.getAbsenceAmount()  != null ? d.getAbsenceAmount()  : "");
            sb.append("|");
            sb.append(d.getAmount()         != null ? d.getAmount()         : "");
            sb.append("|");
            sb.append(d.getNotes()          != null ? d.getNotes()          : "");
            sb.append("|");
            sb.append(d.getDayType()        != null ? d.getDayType()        : "");
            sb.append("|");
            sb.append(d.getEntryPlan()      != null ? d.getEntryPlan()      : "");
            sb.append("|");
            sb.append(d.getPresence()       != null ? d.getPresence()       : "");
            sb.append("|");
            sb.append(d.getAbsenceCode()    != null ? d.getAbsenceCode()    : "");
            sb.append("|");
            sb.append(d.getDay()            != null ? d.getDay()            : "");
            sb.append("|");
            sb.append(d.getWokingTime()     != null ? d.getWokingTime()     : "");
            sb.append("|");
            
            if(days.indexOf(d)+1 < days.size()){
                sb.append("\n");
            }
        }
        
        return sb.toString();
    }

}
