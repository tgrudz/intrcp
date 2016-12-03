package zilp.rcp.proc;

import org.jdom.Element;

import zilp.rcp.objects.Employee;

/**
 * This class build Employee object from xml element
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class EmployeeProc {
    
    Employee emp;

    public EmployeeProc() {
        
        emp = new Employee();
    }
    
    public Employee processEmployee(Element e){
            
        String lastName       = e.getAttributeValue("nazwisko");
        String firstName      = e.getAttributeValue("imie");
        String departmentCode = e.getAttributeValue("kodDzialu");
        String departmentName = e.getAttributeValue("nazwaDzialu");
         
            emp.setLastName(lastName);
            emp.setFirstName(firstName);
            emp.setDepartmentCode(departmentCode);
            emp.setDepartmentName(departmentName);
            
        return emp;
    }
}
