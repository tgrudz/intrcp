package zilp.rcp.objects;

import java.io.Serializable;

import java.util.List;

/**
 * This class represents day node
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class Day implements Serializable{
    
    public Day() {}
    
    private String absenceAmount;       // wymiarNieob
    private String amount;              // wymiar
    private String notes;               // uwagi
    private String dayType;             // typDnia
    private String entryPlan;           // planWe
    private String presence;            // obecnosc
    private String absenceCode;         // kodNieob
    private String day;                 // dzien
    private String wokingTime;          // czasPracy
    private List<Presence> presences;


    public void setAbsenceAmount(String absenceAmount) {
        this.absenceAmount = absenceAmount;
    }

    public String getAbsenceAmount() {
        return absenceAmount;
    }

    public void setAmount(String amount) {
        this.amount = amount;
    }

    public String getAmount() {
        return amount;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getNotes() {
        return notes;
    }


    public void setEntryPlan(String entryPlan) {
        this.entryPlan = entryPlan;
    }

    public String getEntryPlan() {
        return entryPlan;
    }

    public void setPresence(String presence) {
        this.presence = presence;
    }

    public String getPresence() {
        return presence;
    }

    public void setAbsenceCode(String absenceCode) {
        this.absenceCode = absenceCode;
    }

    public String getAbsenceCode() {
        return absenceCode;
    }

    public void setDay(String day) {
        this.day = day;
    }

    public String getDay() {
        return day;
    }


    public void setWokingTime(String wokingTime) {
        this.wokingTime = wokingTime;
    }

    public String getWokingTime() {
        return wokingTime;
    }


    public void setDayType(String dayType) {
        this.dayType = dayType;
    }

    public String getDayType() {
        return dayType;
    }

    public void setPresences(List<Presence> presences) {
        this.presences = presences;
    }

    public List<Presence> getPresences() {
        return presences;
    }
}
