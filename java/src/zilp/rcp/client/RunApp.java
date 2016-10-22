package zilp.rcp.client;

import zilp.rcp.util.Util;

/**
 * This class contains main method that runs creator
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class RunApp{

    /**
     * Main method that runs creator
     * @param args
     */
    public static void main(String[] args) {
        
        String fileName = (args == null || args.length == 0) ? null : args[0];
        Creator creator = new Creator();
        creator.run(fileName);
    }
}