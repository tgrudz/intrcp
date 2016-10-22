package zilp.rcp.proc;


import java.util.ArrayList;
import java.util.List;

import org.jdom.Element;

import zilp.rcp.objects.Type;

/**
 * This class build list of Type objects object from list of xml elements
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class TypeProc {
    
    Type type;
    List<Type> types;
    
    public TypeProc() {
    
        types = new ArrayList<Type>();
    }
    
    public List<Type> processTypes(List<Element> typesList){
    
        for(Element elType : typesList){
            
            type = new Type();
            
            String dayType       = elType.getAttributeValue("typDnia");
            String days          = elType.getAttributeValue("dni");
            String amount        = elType.getAttributeValue("wymiar");
            String workingTime   = elType.getAttributeValue("czasPracy");
            String ng            = elType.getAttributeValue("ng");
            String presence      = elType.getAttributeValue("obecnosc");
            String absenceAmount = elType.getAttributeValue("wymiarNieob");
                
                type.setDayType(dayType);
                type.setDays(days);
                type.setAmount(amount);
                type.setWokingTime(workingTime);
                type.setNg(ng);
                type.setPresence(presence);
                type.setAbsenceAmount(absenceAmount);
            
            types.add(type);
        }
        
        return types;
    }
    
}
