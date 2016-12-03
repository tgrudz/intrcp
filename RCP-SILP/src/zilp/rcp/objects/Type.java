package zilp.rcp.objects;

import java.io.Serializable;

/**
 * This class represents type node
 * @author Jakub Pawlowski
 * @version 1.0
 **/

public class Type  implements Serializable{
    
    public Type() {}
    
    private String dayType;       // typDnia
    private String days;          // dni
    private String amount;        // wymiar
    private String wokingTime;    // czasPracy
    private String ng;            // ng
    private String presence;      // obecnosc
    private String absenceAmount; // wymiarNieob

    public void setDayType(String dayType) {
        this.dayType = dayType;
    }

    public String getDayType() {
        return dayType;
    }

    public void setDays(String days) {
        this.days = days;
    }

    public String getDays() {
        return days;
    }

    public void setAmount(String amount) {
        this.amount = amount;
    }

    public String getAmount() {
        return amount;
    }

    public void setWokingTime(String wokingTime) {
        this.wokingTime = wokingTime;
    }

    public String getWokingTime() {
        return wokingTime;
    }

    public void setPresence(String presence) {
        this.presence = presence;
    }

    public String getPresence() {
        return presence;
    }

    public void setAbsenceAmount(String absenceAmount) {
        this.absenceAmount = absenceAmount;
    }

    public String getAbsenceAmount() {
        return absenceAmount;
    }

    public void setNg(String ng) {
        this.ng = ng;
    }

    public String getNg() {
        return ng;
    }
}
