package zilp.rcp.proc;

import java.util.ArrayList;
import java.util.List;

import org.jdom.Element;

import zilp.rcp.objects.Presence;

/**
 * This class build list of Presence objects object from list of xml elements
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class PresenceProc {

    Presence pres;
    List<Presence> presList;
    
    public PresenceProc() {
    
        presList = new ArrayList<Presence>();
    }
    
    public List<Presence> precessPresences(List<Element> presencesList){
    
        for(Element elPres : presencesList){
            
            pres = new Presence();
                
                String entry        = elPres.getAttributeValue("wejscie");
                String exit         = elPres.getAttributeValue("wyjscie");
                String presenceTime = elPres.getAttributeValue("czasObecnosci");
                String incomplette  = elPres.getAttributeValue("niekompletna");
                String officialExit = elPres.getAttributeValue("wyjscieSluzbowe");
                    
                    pres.setEntry(entry);
                    pres.setExit(exit);
                    pres.setPresenceTime(presenceTime);
                    pres.setIncomplette(incomplette);
                    pres.setOfficialExit(officialExit);
                    
            presList.add(pres);
        }
        
        return presList;
    }
    
}
