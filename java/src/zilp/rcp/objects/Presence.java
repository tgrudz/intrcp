package zilp.rcp.objects;

/**
 * This class represents Presence node
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class Presence {
    
    private String entry; // wejscie
    private String exit;  // wyjscie
    private String presenceTime; // czasObecnosci
    private String incomplette; // niekompletna
    private String officialExit; // wyjscieSluzbowe
    
    public Presence() {
    }

    public void setEntry(String entry) {
        this.entry = entry;
    }

    public String getEntry() {
        return entry;
    }

    public void setExit(String exit) {
        this.exit = exit;
    }

    public String getExit() {
        return exit;
    }

    public void setPresenceTime(String presenceTime) {
        this.presenceTime = presenceTime;
    }

    public String getPresenceTime() {
        return presenceTime;
    }

    public void setIncomplette(String incomplette) {
        this.incomplette = incomplette;
    }

    public String getIncomplette() {
        return incomplette;
    }

    public void setOfficialExit(String officialExit) {
        this.officialExit = officialExit;
    }

    public String getOfficialExit() {
        return officialExit;
    }
}
