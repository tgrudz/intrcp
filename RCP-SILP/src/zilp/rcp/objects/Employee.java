package zilp.rcp.objects;

import java.io.Serializable;

import java.util.List;

/**
 * This class represents employee node
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class Employee implements Serializable{

    public Employee() {}
    
    private String lastName;        // nazwisko
    private String firstName;       // imie
    private String departmentCode;  // kodDzialu
    private String departmentName;  // nazwaDzialu
    private List<Day> days;
    private Summary summary;

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setDepartmentCode(String departmentCode) {
        this.departmentCode = departmentCode;
    }

    public String getDepartmentCode() {
        return departmentCode;
    }

    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
    }

    public String getDepartmentName() {
        return departmentName;
    }

    public void setDays(List<Day> days) {
        this.days = days;
    }

    public List<Day> getDays() {
        return days;
    }

    public void setSummary(Summary summary) {
        this.summary = summary;
    }

    public Summary getSummary() {
        return summary;
    }
}
