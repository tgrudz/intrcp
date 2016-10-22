package zilp.rcp.util;

import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.Properties;

public class TestEnv {
    public static void main(String[] args) {
        
        System.out.println("##############################################################################");
        System.out.println("Zmienna SILPDDIR --> "+System.getenv("SILPDDIR"));
        System.out.println("Zmienna INTRCPDIR --> "+System.getenv("INTRCPDIR"));
        System.out.println("##############################################################################");
        System.out.println("Kalatog z plikami --> "+System.getenv("SILPDDIR") +"/"+System.getenv("INTRCPDIR"));
        System.out.println("Plik logu --> "+System.getenv("SILPDDIR") +"/logs/"+System.getenv("INTRCPDIR")+".log");
        System.out.println("##############################################################################");
            
    }
}
