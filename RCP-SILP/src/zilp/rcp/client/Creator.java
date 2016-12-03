package zilp.rcp.client;

import java.util.List;

import zilp.rcp.builder.Builder;
import zilp.rcp.objects.Day;
import zilp.rcp.objects.Presence;
import zilp.rcp.objects.Report;
import zilp.rcp.util.Util;

/**
 * This class creates .txt file with data from Java objects
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class Creator{

	private static final String presenceFileNamePrefix = "_" + "presence";
	private static final String emptyString = "";
	private static final String delimiterString = "|";

    /**
     * Method reads Java objects created from .xml file and 
     * saves this data to .txt file
     * @param fileName
     */
    public void run(final String fileName) {

        final Util util = new Util();
        //util.createLogDir();

        if (fileName != null && fileName.length() > 0) {

            util.log("Poczatek procedury dla: " + fileName);

            final Builder builder = new Builder();
            final Report r = builder.buildReport(fileName);
            final List<Day> days = r.getEmployee().getDays();
            final BuildData buildData = buildData(days); 
            
            // StringBuilder sb = new StringBuilder();
            // sb.append("wymiarNieob|wymiar|uwagi|typDnia|planWe|obecnosc|kodNieob|dzien|czasPracy\n");
            // sb.append(data);
            
            util.create(buildData.getDay(), fileName);
            util.create(buildData.getPresence(), getPresenceFileName(fileName));
            
            util.log("Zakonczono procedure dla: " + fileName);
            util.log("################################################################################");
            
        } else {
        	util.log("Nie podano nazwy pliku wejsciowego");
        }         
   }

    /**
     * Buid data as String from Java objects.
     * In this application it buid data from lis of Day objec
     * @param days
     * @return
     */
    private BuildData buildData(final List<Day> days){

        final StringBuilder dayStrBuilder = new StringBuilder();
        final StringBuilder presenceStrBuilder  = new StringBuilder();      
        
        for(final Day day : days) {
        	dayStrBuilder.append(getField(day.getAbsenceAmount()));
        	dayStrBuilder.append(getField(day.getAmount()));
        	dayStrBuilder.append(getField(day.getNotes()));
        	dayStrBuilder.append(getField(day.getDayType()));
        	dayStrBuilder.append(getField(day.getEntryPlan()));
        	dayStrBuilder.append(getField(day.getPresence()));
        	dayStrBuilder.append(getField(day.getAbsenceCode()));
        	dayStrBuilder.append(getField(day.getDay()));
        	dayStrBuilder.append(getField(day.getWokingTime()));
        	dayStrBuilder.append("\n");
        	
        	if (!isPresencesEmpty(day)) {
            	presenceStrBuilder.append(getPresenceData(day));
            }	
        }

        if (dayStrBuilder.length() > 1) {
        	dayStrBuilder.setLength(dayStrBuilder.length() - 1);
        }
        if (presenceStrBuilder.length() > 1) {
        	presenceStrBuilder.setLength(presenceStrBuilder.length() - 1);
        }
        final BuildData buildData = new BuildData(dayStrBuilder.toString(), presenceStrBuilder.toString());        
        return buildData;
    }

    private boolean isPresencesEmpty(final Day day) {
    	return (day.getPresences() == null || day.getPresences().isEmpty());
    }

    private String getPresenceFileName(final String fileName) {
    	return fileName + presenceFileNamePrefix;
    }

    private String getPresenceData(final Day day) {
    	final List<Presence> presences = day.getPresences();
    	final StringBuilder sb = new StringBuilder();
    	for (final Presence presence : presences) {
    		sb.append(getField(day.getDay()));
    		sb.append(getField(presence.getEntry()));
    		sb.append(getField(presence.getExit()));
    		sb.append(getField(presence.getTypeExit()));
    		sb.append(getField(presence.getPresenceTime()));
    		sb.append("\n");
    	}    	
        return sb.toString();
    }

    private String getField(final String field) {
    	return ((field == null) ? emptyString : field) + delimiterString;
    }
}