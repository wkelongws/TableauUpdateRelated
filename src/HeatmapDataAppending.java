import com.jcraft.jsch.*;
import java.io.*;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Vector;

public class HeatmapDataAppending 
{
public static void main(String[] args) throws Exception 
{
    String user = "team";
    //String password = "ctr3intrans";
    //String host = "10.29.19.56";
    String password = "t3xasheat";
    String host = "10.29.19.65";
    int port=22;    

    try
    {
        JSch jsch = new JSch();
        Session session = jsch.getSession(user, host, port);
        session.setPassword(password);
        session.setConfig("StrictHostKeyChecking", "no");
        System.out.println("Establishing Connection...");
        session.connect();
        System.out.println("Connection established.");
        System.out.println("Crating SFTP Channel.");
        ChannelSftp sftpChannel = (ChannelSftp) session.openChannel("sftp");
        sftpChannel.connect();
        System.out.println("SFTP Channel created.");
         
        sftpChannel.cd("Shuo/IWZ");        

        // Get a listing of the remote directory       
        Vector<ChannelSftp.LsEntry> list = sftpChannel.ls(".");         

        // iterate through objects in list, identifying specific file names
        for (ChannelSftp.LsEntry oListItem : list) {
            
            // If it is a file (not a directory)
            if (!oListItem.getAttrs().isDir()) {
                
                System.out.println("get: " + oListItem.getFilename());
                //c.get(oListItem.getFilename(), oListItem.getFilename());  // while testing, disable this or all of your test files will be grabbed
                String remoteFile = oListItem.getFilename();
                
                InputStream out= null;
                out= sftpChannel.get(remoteFile);
                BufferedReader br = new BufferedReader(new InputStreamReader(out));
                String line;
                //String localFile = remoteFile.split(".txt")[0] + ".csv";
                String localFile = "Historical Raw.csv";
                String localDir = "S:/(S) SHARE/_project CTRE/1_Active Research Projects/Iowa DOT OTO Support/14_Traffic Critical Projects 2/2016/IWZ Data for Tableau/test_Shuo/";
                //String localDir = "S:/(S) SHARE/_project CTRE/1_Active Research Projects/Iowa DOT OTO Support/14_Traffic Critical Projects 2/2016/IWZ Data for Tableau/test_Shuo/";
                System.out.println("append to: " + localFile);
                
                FileWriter pw = new FileWriter(localDir + localFile,true);
                
                File src=new File(localDir + localFile);
                System.out.println(src.exists());
                
                while ((line = br.readLine()) != null) 
                {
                	String[] columns = line.split("\t");
                	
                	String name = columns[0];
                	String dateStr = columns[1];
                	String hour = columns[2];
                	String min5 = columns[3];
                	String speed = columns[4];
                	String count = columns[5];
                	String occup = columns[6];
                	String issue = columns[7];
                	
                	String group_old = columns[8];
                	
                	String group = columns[9];
                	String direction = columns[10];
                	String coded_direction = columns[11];
                	String order = columns[12];
                	        	
            		DateFormat formatter = new SimpleDateFormat("MM/dd/yyyy"); 
            		Date date = (Date)formatter.parse(dateStr); 
            		Calendar c = Calendar.getInstance();
            		c.setTime(date);
            		String dayofweek = new SimpleDateFormat("EE").format(date);		
            		String timestamp = dateStr + " " + hour + ":" + Integer.toString(Integer.parseInt(min5)*5) + ":00";
            		SimpleDateFormat format = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");    		
            		String fechaStr = timestamp;  
            		Date fechaNueva = format.parse(fechaStr);
            		String timestamp_formated = format.format(fechaNueva);
            		
            		String line_new = name + "," + dateStr + "," + hour + "," + min5 + "," + speed + "," +
            				count + "," + occup + "," + issue + "," + dayofweek + "," + timestamp_formated + "," +
            				group + "," + direction + "," + coded_direction + "," + order;      		
                    //System.out.println(line_new);
                    
                    pw.append(line_new);

                    pw.append("\n");     
                     
                }
                
                pw.flush();
                pw.close();
                br.close();
                
            }
        }
        
        sftpChannel.disconnect();
        session.disconnect();
    }
    catch(Exception e)
{
    System.out.println(e);
}
}
}