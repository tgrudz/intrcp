package zilp.rcp.builder;

import java.io.File;
import java.io.IOException;

import java.util.ArrayList;
import java.util.List;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;

import zilp.rcp.objects.Day;
import zilp.rcp.objects.Employee;
import zilp.rcp.objects.Presence;
import zilp.rcp.objects.Report;
import zilp.rcp.objects.Summary;
import zilp.rcp.objects.Type;
import zilp.rcp.proc.DayProc;
import zilp.rcp.proc.EmployeeProc;
import zilp.rcp.proc.PresenceProc;
import zilp.rcp.proc.ReportProc;
import zilp.rcp.proc.SummaryProc;
import zilp.rcp.proc.TypeProc;
import zilp.rcp.util.Util;

/**
 * This class build object mapping form xml DOM tree to Java objects
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class Builder{
    
    Report rep = null;
    Employee emp = null;
    Summary sum = null;
    List<Type> types = null;
    List<Day> days = null;
    Day day = null;
    List<Presence> presences = null;
    Util util = new Util();

    /**
     * Method to create Java mapping from passed xml file 
     * @param fileName
     * @return object Report
     */
    public Report buildReport(String fileName) {
        
        String path = util.getSrcPath()+"/"+fileName+".xml";
        File xmlFile = new File(path);
        SAXBuilder builder = new SAXBuilder();   
        
        try {
            
            util.log("Przetwarzam plik: "+fileName+".xml");
            
            Document doc = builder.build(xmlFile);
            
             /** Process report */
            Element root = doc.getRootElement();
            ReportProc repProc = new ReportProc();
            rep = repProc.processReport(root);       
            
                /** Process employee */
                Element elEmp = root.getChild("pracownik");
                EmployeeProc empProc = new EmployeeProc();
                emp = empProc.processEmployee(elEmp);
            
                    /** Process days */
                    Element elDays = elEmp.getChild("dni");
                    List<Element> daysList = elDays.getChildren();
                    days = new ArrayList<Day>();
                    
                    for(Element elDay : daysList){
                        
                        DayProc daysProc = new DayProc();
                        day = daysProc.processDay(elDay);
                        presences = new ArrayList<Presence>();    
                        
                        /** Process presences*/
                        if(elDay.getChild("obecnosci") != null){
                            
                            Element elPresences = elDay.getChild("obecnosci");
                            List<Element> presencesList = elPresences.getChildren();
                            PresenceProc presProc = new PresenceProc();
                            presences = presProc.precessPresences(presencesList);
                        }
                            
                            day.setPresences(presences);
                        days.add(day);
                            
                    }
                    
                    /** Process summary */
                    Element elSumm = elEmp.getChild("podsumowanie");
                    SummaryProc summProc = new SummaryProc();
                    sum = summProc.processSummary(elSumm);
                        
                        /** Process types */
                        List<Element> typeList = elSumm.getChildren();
                        TypeProc typeProc = new TypeProc();
                        types = typeProc.processTypes(typeList);
            
                
                sum.setTypes(types);
                emp.setSummary(sum);
                emp.setDays(days);
                
                
            rep.setEmployee(emp);
            
            util.log("Przetworzono plik: "+fileName+".xml");
            
        }catch (IOException e)   { util.log(e.getMessage()); } 
         catch (JDOMException e) { util.log(e.getMessage()); } 
          
     return rep;
    }

}
