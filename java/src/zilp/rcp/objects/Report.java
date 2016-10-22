package zilp.rcp.objects;

/**
 * This class represents report node
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class Report {

    private String name;         // nazwa
    private String sinceDay;     // odDania
    private String toDay;        // doDnia
    private String localization; // lokalizacja
    private Employee employee;
    
    public Report() {
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setSinceDay(String sinceDay) {
        this.sinceDay = sinceDay;
    }

    public String getSinceDay() {
        return sinceDay;
    }

    public void setToDay(String toDay) {
        this.toDay = toDay;
    }

    public String getToDay() {
        return toDay;
    }

    public void setLocalization(String localization) {
        this.localization = localization;
    }

    public String getLocalization() {
        return localization;
    }

    public void setEmployee(Employee employee) {
        this.employee = employee;
    }

    public Employee getEmployee() {
        return employee;
    }
}
