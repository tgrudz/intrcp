package zilp.rcp.util;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import java.text.Format;
import java.text.SimpleDateFormat;

import java.util.Date;
import java.util.Properties;

/**
 * Helper class contains methods to use in all application
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class Util {
    
    public Util(){}

    /** directory with .xml and .txt files */
    private String srcPath = System.getenv("SILPDDIR") +"/"+System.getenv("INTRCPDIR");
    /** Path to log file */
    private String logPath = System.getenv("SILPDDIR") +"/logs/"+System.getenv("INTRCPDIR")+".log";


    /**
     * Method to get current date and time as String
     * @return current date and time as String
     */
    public String getDate(){
     return getDay()+getHour();  
    }


    /**
     * Method to get current date
     * @return  current date
     */
    public String getDay(){
        
        Format formatter = new SimpleDateFormat("yyyy-MM-dd");
        Date date = new Date();
        String s = formatter.format(date);
        
      return "["+s+"]";
    }


    /**
     * Current date current time
     * @return current time
     */
    public String getHour(){
        
        Format formatter = new SimpleDateFormat("HH:mm:ss");
        Date date = new Date();
        String s = formatter.format(date);
        
      return "["+s+"]";
    }



    /**
     * Method to save in log file passed message using following format:
     * [date] [time] message
     * @param msg
     */
    public void log(String msg){
               
        FileWriter fw = null;
        BufferedWriter bw = null;
        try {
                    fw = new FileWriter(logPath,true);
                    bw = new BufferedWriter(fw);
                    bw.write(getDay()+" "+getHour()+" "+msg);
                    bw.newLine();
                    bw.flush();
            } catch (IOException e) {
                    log(e.getMessage());
            } finally {                       
                if (bw != null) try {
                    bw.close();
                } catch (IOException ex) { log(ex.getMessage()); }
            }
    }


    /**
     * This method write passed string into passed file.
     * In this applications writes tranformate xml data to .txt file
     * @param content
     * @param outFileName
     */
    public void create(String content, String outFileName){
          
        String filesDir = srcPath+"/"+outFileName+".txt";
        FileWriter fw = null;
        BufferedWriter bw = null;
        try {
                    log("Poczatek zapisu do pliku: "+filesDir);
                    fw = new FileWriter(filesDir,true);
                    bw = new BufferedWriter(fw);
                    bw.write(content);
                    bw.newLine();
                    bw.flush();
                    log("Zapis udany");
            } catch (IOException e) {
                    log(e.getMessage());
            } finally {                       
                if (bw != null) try {
                    bw.close();
                } catch (IOException ex) { log(ex.getMessage()); }
            }        
    
    }


    public String getSrcPath() {
        return srcPath;
    }

    public String getLogPath() {
        return logPath;
    }
}

