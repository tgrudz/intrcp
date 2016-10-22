package zilp.rcp.proc;

import org.jdom.Element;

import zilp.rcp.objects.Report;

/**
 * This class build Report object from xml element
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class ReportProc {
    
    Report rep;
    
    public ReportProc() {
    
        rep = new Report();
    }
    
    public Report processReport(Element e){
        
        String name = e.getAttributeValue("nazwa");
        String sinceDay = e.getAttributeValue("odDnia");
        String toDay = e.getAttributeValue("doDnia");
        String loc = e.getAttributeValue("lokalizacja");
        
            rep.setName(name);
            rep.setSinceDay(sinceDay);
            rep.setToDay(toDay);
            rep.setLocalization(loc);
        
        return rep;
    }
    
}
