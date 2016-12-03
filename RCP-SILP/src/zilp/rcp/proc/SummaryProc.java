package zilp.rcp.proc;

import org.jdom.Element;

import zilp.rcp.objects.Summary;

/**
 * This class build Summary object from xml element
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class SummaryProc {
    
    Summary sum;
    
    public SummaryProc() {
    
        sum =new Summary();
    }
    
    
    public Summary processSummary(Element e){
    
        
        String days          = e.getAttributeValue("dni");
        String amount        = e.getAttributeValue("wymiar");
        String workingTime   = e.getAttributeValue("czasPracy");
        String ng            = e.getAttributeValue("ng");
        String presence      = e.getAttributeValue("obecnosc");
        String absenceAmount = e.getAttributeValue("wymiarNieob");
            
            sum.setDays(days);
            sum.setAmount(amount);
            sum.setWokingTime(workingTime);
            sum.setNg(ng);
            sum.setPresence(presence);
            sum.setAbsenceAmount(absenceAmount);
        
        return sum;
    }
}
