import com.jcraft.jsch.*;
import java.io.*;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

public class IWZPerformanceCalculation_dailyappending 
{
public static void main(String[] args) throws Exception 
{
    String user = "team";
    //String password = "ctr3intrans";
    //String host = "10.29.19.56";
    String password = "t3xasheat";
    String host = "10.29.19.65";
    int port=22;    
    double lowSpeedThreshold = 45.0;  	//45mph
    double referenceSpeed = 65.0;		//expected travel speed
    double delayThreshold1 = 0.1;		//10% more travel time than using referenceSpeed
    double delayThreshold2 = 0.2;		//20% more travel time than using referenceSpeed
    double delayThreshold3 = 0.3;		//30% more travel time than using referenceSpeed
    double delayThreshold4 = 0.4;		//40% more travel time than using referenceSpeed
    double delayThreshold5 = 0.5;		//50% more travel time than using referenceSpeed
    double delayThreshold6 = 0.6;		//60% more travel time than using referenceSpeed
    double delayThreshold7 = 0.7;		//70% more travel time than using referenceSpeed
    double delayThreshold8 = 0.8;		//80% more travel time than using referenceSpeed
    double delayThreshold9 = 0.9;		//90% more travel time than using referenceSpeed
    double delayThreshold10 = 1.0;		//100% more travel time than using referenceSpeed

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
        
        // estabish a HashMap to store IWZ list information
        HashMap<String, HashMap<String,String>> IWZList = new HashMap<String, HashMap<String,String>>();
        InputStream IWZlist= sftpChannel.get("Shuo/IWZ_Sensor_List_withOrder.csv");
        BufferedReader br0 = new BufferedReader(new InputStreamReader(IWZlist));
        String line0;
        while ((line0 = br0.readLine()) != null) 
        {
        	String[] columns0 = line0.split(",");
        	IWZList.put(columns0[8], new HashMap<String,String>());        	
        }
        br0.close();
        InputStream IWZlist1= sftpChannel.get("Shuo/IWZ_Sensor_List_withOrder.csv");
        BufferedReader br1 = new BufferedReader(new InputStreamReader(IWZlist1));
        String line1;
        while ((line1 = br1.readLine()) != null) 
        {
        	String[] columns1 = line1.split(",");
        	HashMap<String,String> sensorInfo = IWZList.get(columns1[8]);
        	sensorInfo.put(columns1[5], line1);
        	IWZList.put(columns1[8], sensorInfo);        	
        }
        br1.close();
        //for(String k:IWZList.keySet()){System.out.println(k+":"+IWZList.get(k));}

        
        // Get a listing of the remote directory   
        sftpChannel.cd("Shuo/IWZ"); 
        Vector<ChannelSftp.LsEntry> list = sftpChannel.ls(".");       
        
        // iterate through objects in list, identifying specific file names
        for (ChannelSftp.LsEntry oListItem : list) {
            
            // If it is a file (not a directory)
            if (!oListItem.getAttrs().isDir()) 
            {
                            	
                System.out.println("get: " + oListItem.getFilename());
                //c.get(oListItem.getFilename(), oListItem.getFilename());  // while testing, disable this or all of your test files will be grabbed
                String remoteFile = oListItem.getFilename();                
                
                // estabish a list to store IWZ 5min data
                TreeMap<Integer,HashMap<String,String>> IWZData = new TreeMap<Integer,HashMap<String,String>>();  
                final HashMap<String,String> sensorsInfo = IWZList.get(remoteFile.split(".txt")[0]);
                HashMap<String,String> tempo = new HashMap<String,String>();
                for(String k:sensorsInfo.keySet()){tempo.put(k, sensorsInfo.get(k).split(",")[6]);} 
                
        		for (int h=0; h<24; h++)
        		{
        			for (int m5=0; m5<12; m5++)
        			{
        				IWZData.put(h*100+m5,new HashMap<String, String>(){{for(String k:sensorsInfo.keySet()){put(k, sensorsInfo.get(k).split(",")[6]);}}});
        			}
        		}                                               
                
                InputStream out= null;
                out= sftpChannel.get(remoteFile);
                BufferedReader br = new BufferedReader(new InputStreamReader(out));
                String line;
                //String localFile = remoteFile.split(".txt")[0] + ".csv";
                String localFile = "performance_daily.csv";
                String localDir = "S:/(S) SHARE/_project CTRE/1_Active Research Projects/Iowa DOT OTO Support/14_Traffic Critical Projects 2/2016/IWZ Data for Tableau/CSV Tableau All in One/";
                System.out.println("append to: " + localDir + localFile);
                
                FileWriter pw = new FileWriter(localDir + localFile,true);
                
                File src=new File(localDir + localFile);
                System.out.println(src.exists());
                
                String dateString = "";
                
                while ((line = br.readLine()) != null) 
                {
                	//System.out.println(line);
                	String[] columns = line.split("\t");
                	
                	String name = columns[0];
                	String dateStr = columns[1];
                	dateString = dateStr;
                	//System.out.println(dateStr);
                	//Thread.sleep(200000000);
                	
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
            		
            		int timeIndex = Integer.parseInt(min5)+Integer.parseInt(hour)*100;            		
            		            		
            		String info = IWZData.get(timeIndex).get(name);
            		
            		String segmentLength = null;
            		
            		if (info.split(",").length==1)
            		{
            			segmentLength = info;
            		}
            		else if (info.split(",").length==4)
            		{
            			segmentLength = info.split(",")[3];
            		}       
            		            		
            		IWZData.get(timeIndex).put(name, coded_direction+","+speed+","+count+","+ segmentLength);

            		//Thread.sleep(20000);
            		
                }
                
                
//                br.close();                  
//                System.out.println("heatmap ready");
//                for(int k:IWZData.keySet())
//        		{
//                	for(String s:IWZData.get(k).keySet())
//                	{
//                		String line_new = k+","+s+","+IWZData.get(k).get(s);
//                		 pw.append(line_new);
//                         pw.append("\n");
//                	}                	
//                }
//                Thread.sleep(20000);
                
                // estabish a treemap to store IWZ perforamnce measures
                     
                TreeMap<Integer,String> IWZPerformanceDir1 = new TreeMap<Integer,String>();  
                TreeMap<Integer,String> IWZPerformanceDir2 = new TreeMap<Integer,String>();  
                for (int h=0; h<24; h++)
        		{
        			for (int m5=0; m5<12; m5++)
        			{
        				IWZPerformanceDir1.put(h*100+m5,"empty1");
        				IWZPerformanceDir2.put(h*100+m5,"empty2");
        			}
        		}   
                
                for (int timeKey:IWZData.keySet())
                {
                	double totalLength_Dir1 = 0.0;
                	double travelTime_Dir1 = 0.0;
                	int vehicles_Dir1 = 0;
                	int flag_LowSpeed_Dir1 = 0;
                	int flag_LargeDelay1_Dir1 = 0;
                	int flag_LargeDelay2_Dir1 = 0;
                	int flag_LargeDelay3_Dir1 = 0;
                	int flag_LargeDelay4_Dir1 = 0;
                	int flag_LargeDelay5_Dir1 = 0;
                	int flag_LargeDelay6_Dir1 = 0;
                	int flag_LargeDelay7_Dir1 = 0;
                	int flag_LargeDelay8_Dir1 = 0;
                	int flag_LargeDelay9_Dir1 = 0;
                	int flag_LargeDelay10_Dir1 = 0;
                	                	
                	double totalLength_Dir2 = 0.0;
                	double travelTime_Dir2 = 0.0;
                	int vehicles_Dir2 = 0;
                	int flag_LowSpeed_Dir2 = 0;
                	int flag_LargeDelay1_Dir2 = 0;
                	int flag_LargeDelay2_Dir2 = 0;
                	int flag_LargeDelay3_Dir2 = 0;
                	int flag_LargeDelay4_Dir2 = 0;
                	int flag_LargeDelay5_Dir2 = 0;
                	int flag_LargeDelay6_Dir2 = 0;
                	int flag_LargeDelay7_Dir2 = 0;
                	int flag_LargeDelay8_Dir2 = 0;
                	int flag_LargeDelay9_Dir2 = 0;
                	int flag_LargeDelay10_Dir2 = 0;
                	
                	for (String sensorKey:IWZData.get(timeKey).keySet())
                	{	
                		String[] elements = IWZData.get(timeKey).get(sensorKey).split(",");
                		if (elements.length>1)
                		{
                			int direction = Integer.parseInt(elements[0]);
                    		double speed = Double.parseDouble(elements[1]);
                    		int vehcnt = Integer.parseInt(elements[2]);
                    		double seglength = Double.parseDouble(elements[3]);                		
                    		if (direction==1)
                    		{
                    			totalLength_Dir1 += seglength;
                    			
                    			if (speed==0)
                    			{travelTime_Dir1 += seglength/referenceSpeed;}
                    			else
                    			{travelTime_Dir1 += seglength/speed;}
                    			
                    			if (speed>0 & speed<lowSpeedThreshold)
                    			{
                    				flag_LowSpeed_Dir1=1;
                    			}
                    			if (vehicles_Dir1<vehcnt)
                    			{
                    				vehicles_Dir1=vehcnt;
                    			}
                    		}
                    		else
                    		{
                    			totalLength_Dir2 += seglength;
                    			
                    			if (speed==0)
                    			{travelTime_Dir2 += seglength/referenceSpeed;}
                    			else
                    			{travelTime_Dir2 += seglength/speed;}
                    			
                    			if (speed>0 & speed<lowSpeedThreshold)
                    			{
                    				flag_LowSpeed_Dir2=1;
                    			}
                    			if (vehicles_Dir2<vehcnt)
                    			{
                    				vehicles_Dir2=vehcnt;
                    			}
                    		}
                		}                		
                	}
                	
                	double excessiveTraveltime_Dir1 = Math.max(0.0,(travelTime_Dir1-totalLength_Dir1/referenceSpeed)/(totalLength_Dir1/referenceSpeed));
                	double excessiveTraveltime_Dir2 = Math.max(0.0,(travelTime_Dir2-totalLength_Dir2/referenceSpeed)/(totalLength_Dir2/referenceSpeed));
                	if (excessiveTraveltime_Dir1>delayThreshold1){flag_LargeDelay1_Dir1 = 1;}
                	if (excessiveTraveltime_Dir1>delayThreshold2){flag_LargeDelay2_Dir1 = 1;}
                	if (excessiveTraveltime_Dir1>delayThreshold3){flag_LargeDelay3_Dir1 = 1;}
                	if (excessiveTraveltime_Dir1>delayThreshold4){flag_LargeDelay4_Dir1 = 1;}
                	if (excessiveTraveltime_Dir1>delayThreshold5){flag_LargeDelay5_Dir1 = 1;}
                	if (excessiveTraveltime_Dir1>delayThreshold6){flag_LargeDelay6_Dir1 = 1;}
                	if (excessiveTraveltime_Dir1>delayThreshold7){flag_LargeDelay7_Dir1 = 1;}
                	if (excessiveTraveltime_Dir1>delayThreshold8){flag_LargeDelay8_Dir1 = 1;}
                	if (excessiveTraveltime_Dir1>delayThreshold9){flag_LargeDelay9_Dir1 = 1;}
                	if (excessiveTraveltime_Dir1>delayThreshold10){flag_LargeDelay10_Dir1 = 1;}
                	
                	if (excessiveTraveltime_Dir2>delayThreshold1){flag_LargeDelay1_Dir2 = 1;}
                	if (excessiveTraveltime_Dir2>delayThreshold2){flag_LargeDelay2_Dir2 = 1;}
                	if (excessiveTraveltime_Dir2>delayThreshold3){flag_LargeDelay3_Dir2 = 1;}
                	if (excessiveTraveltime_Dir2>delayThreshold4){flag_LargeDelay4_Dir2 = 1;}
                	if (excessiveTraveltime_Dir2>delayThreshold5){flag_LargeDelay5_Dir2 = 1;}
                	if (excessiveTraveltime_Dir2>delayThreshold6){flag_LargeDelay6_Dir2 = 1;}
                	if (excessiveTraveltime_Dir2>delayThreshold7){flag_LargeDelay7_Dir2 = 1;}
                	if (excessiveTraveltime_Dir2>delayThreshold8){flag_LargeDelay8_Dir2 = 1;}
                	if (excessiveTraveltime_Dir2>delayThreshold9){flag_LargeDelay9_Dir2 = 1;}
                	if (excessiveTraveltime_Dir2>delayThreshold10){flag_LargeDelay10_Dir2 = 1;}
                	
                	IWZPerformanceDir1.put(timeKey, vehicles_Dir1 + "," + flag_LowSpeed_Dir1 + "," + flag_LargeDelay1_Dir1 + "," + flag_LargeDelay2_Dir1
                			 + "," + flag_LargeDelay3_Dir1 + "," + flag_LargeDelay4_Dir1 + "," + flag_LargeDelay5_Dir1 + "," + flag_LargeDelay6_Dir1
                			 + "," + flag_LargeDelay7_Dir1 + "," + flag_LargeDelay8_Dir1 + "," + flag_LargeDelay9_Dir1 + "," + flag_LargeDelay10_Dir1);
                	IWZPerformanceDir2.put(timeKey, vehicles_Dir2 + "," + flag_LowSpeed_Dir2 + "," + flag_LargeDelay1_Dir2 + "," + flag_LargeDelay2_Dir2
                			 + "," + flag_LargeDelay3_Dir2 + "," + flag_LargeDelay4_Dir2 + "," + flag_LargeDelay5_Dir2 + "," + flag_LargeDelay6_Dir2
                			 + "," + flag_LargeDelay7_Dir2 + "," + flag_LargeDelay8_Dir2 + "," + flag_LargeDelay9_Dir2 + "," + flag_LargeDelay10_Dir2);
                	
                }
                
                System.out.println("flags ready");
                
            	int volume_Dir1 = 0;
            	
                int timeWhenLowSpeedsOccur_Dir1 = 0;	
                int timeWhenLargeDelayOccur1_Dir1 = 0;
                int timeWhenLargeDelayOccur2_Dir1 = 0;
                int timeWhenLargeDelayOccur3_Dir1 = 0;
                int timeWhenLargeDelayOccur4_Dir1 = 0;
                int timeWhenLargeDelayOccur5_Dir1 = 0;
                int timeWhenLargeDelayOccur6_Dir1 = 0;
                int timeWhenLargeDelayOccur7_Dir1 = 0;
                int timeWhenLargeDelayOccur8_Dir1 = 0;
                int timeWhenLargeDelayOccur9_Dir1 = 0;
                int timeWhenLargeDelayOccur10_Dir1 = 0;
                
                int vehWhenLowSpeedsOccur_Dir1 = 0;
                int vehWhenLargeDelayOccur1_Dir1 = 0;
                int vehWhenLargeDelayOccur2_Dir1 = 0;
                int vehWhenLargeDelayOccur3_Dir1 = 0;
                int vehWhenLargeDelayOccur4_Dir1 = 0;
                int vehWhenLargeDelayOccur5_Dir1 = 0;
                int vehWhenLargeDelayOccur6_Dir1 = 0;
                int vehWhenLargeDelayOccur7_Dir1 = 0;
                int vehWhenLargeDelayOccur8_Dir1 = 0;
                int vehWhenLargeDelayOccur9_Dir1 = 0;
                int vehWhenLargeDelayOccur10_Dir1 = 0;
                
                
                for (int k:IWZPerformanceDir1.keySet())
                {
//                	pw.append(IWZPerformanceDir1.get(k));
//                  pw.append("\n");
                	                	
                	volume_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[0]);
                	timeWhenLowSpeedsOccur_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[1]);
                	timeWhenLargeDelayOccur1_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[2]);
                	timeWhenLargeDelayOccur2_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[3]);
                	timeWhenLargeDelayOccur3_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[4]);
                	timeWhenLargeDelayOccur4_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[5]);
                	timeWhenLargeDelayOccur5_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[6]);
                	timeWhenLargeDelayOccur6_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[7]);
                	timeWhenLargeDelayOccur7_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[8]);
                	timeWhenLargeDelayOccur8_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[9]);
                	timeWhenLargeDelayOccur9_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[10]);
                	timeWhenLargeDelayOccur10_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[11]);
                	
                	vehWhenLowSpeedsOccur_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[1]) * Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur1_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[2]) * Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur2_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[3]) * Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur3_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[4]) * Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur4_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[5]) * Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur5_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[6]) * Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur6_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[7]) * Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur7_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[8]) * Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur8_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[9]) * Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur9_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[10]) * Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur10_Dir1 += Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[11]) * Integer.parseInt(IWZPerformanceDir1.get(k).split(",")[0]);
                }
                
                int volume_Dir2 = 0;

                int timeWhenLowSpeedsOccur_Dir2 = 0;	
                int timeWhenLargeDelayOccur1_Dir2 = 0;
                int timeWhenLargeDelayOccur2_Dir2 = 0;
                int timeWhenLargeDelayOccur3_Dir2 = 0;
                int timeWhenLargeDelayOccur4_Dir2 = 0;
                int timeWhenLargeDelayOccur5_Dir2 = 0;
                int timeWhenLargeDelayOccur6_Dir2 = 0;
                int timeWhenLargeDelayOccur7_Dir2 = 0;
                int timeWhenLargeDelayOccur8_Dir2 = 0;
                int timeWhenLargeDelayOccur9_Dir2 = 0;
                int timeWhenLargeDelayOccur10_Dir2 = 0;
                
                int vehWhenLowSpeedsOccur_Dir2 = 0;
                int vehWhenLargeDelayOccur1_Dir2 = 0;
                int vehWhenLargeDelayOccur2_Dir2 = 0;
                int vehWhenLargeDelayOccur3_Dir2 = 0;
                int vehWhenLargeDelayOccur4_Dir2 = 0;
                int vehWhenLargeDelayOccur5_Dir2 = 0;
                int vehWhenLargeDelayOccur6_Dir2 = 0;
                int vehWhenLargeDelayOccur7_Dir2 = 0;
                int vehWhenLargeDelayOccur8_Dir2 = 0;
                int vehWhenLargeDelayOccur9_Dir2 = 0;
                int vehWhenLargeDelayOccur10_Dir2 = 0;
                
                for (int k:IWZPerformanceDir2.keySet())
                {
//                	pw.append(IWZPerformanceDir2.get(k));
//                  pw.append("\n");                	
                	
                	volume_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[0]);
                	timeWhenLowSpeedsOccur_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[1]);
                	timeWhenLargeDelayOccur1_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[2]);
                	timeWhenLargeDelayOccur2_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[3]);
                	timeWhenLargeDelayOccur3_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[4]);
                	timeWhenLargeDelayOccur4_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[5]);
                	timeWhenLargeDelayOccur5_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[6]);
                	timeWhenLargeDelayOccur6_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[7]);
                	timeWhenLargeDelayOccur7_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[8]);
                	timeWhenLargeDelayOccur8_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[9]);
                	timeWhenLargeDelayOccur9_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[10]);
                	timeWhenLargeDelayOccur10_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[11]);
                	
                	vehWhenLowSpeedsOccur_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[1]) * Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur1_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[2]) * Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur2_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[3]) * Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur3_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[4]) * Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur4_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[5]) * Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur5_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[6]) * Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur6_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[7]) * Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur7_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[8]) * Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur8_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[9]) * Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur9_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[10]) * Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[0]);
                	vehWhenLargeDelayOccur10_Dir2 += Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[11]) * Integer.parseInt(IWZPerformanceDir2.get(k).split(",")[0]);
                }
                
                System.out.println("performances ready");
                
                Calendar cal=Calendar.getInstance();
        		cal.add(Calendar.DATE, -1);
            	int dayt=cal.get(Calendar.DAY_OF_MONTH);
            	int month=cal.get(Calendar.MONTH)+1;
            	int year=cal.get(Calendar.YEAR);
            	String D = Integer.toString(dayt);
            	String M = Integer.toString(month);
            	String Y = Integer.toString(year);
            	if (dayt<10){D = "0" + D;}
            	if (month<10){M = "0" + M;}
            	    	
            	String date = M + "/" + D + "/" + Y;
                
                
                String line_Dir1 = dateString + "," + remoteFile.split(".txt")[0] + ",1," + volume_Dir1 + "," + timeWhenLowSpeedsOccur_Dir1/288.0 + "," + (double)vehWhenLowSpeedsOccur_Dir1/volume_Dir1
                		+ "," + timeWhenLargeDelayOccur1_Dir1/288.0 + "," + (double)vehWhenLargeDelayOccur1_Dir1/volume_Dir1
                		+ "," + timeWhenLargeDelayOccur2_Dir1/288.0 + "," + (double)vehWhenLargeDelayOccur2_Dir1/volume_Dir1
                		+ "," + timeWhenLargeDelayOccur3_Dir1/288.0 + "," + (double)vehWhenLargeDelayOccur3_Dir1/volume_Dir1
                		+ "," + timeWhenLargeDelayOccur4_Dir1/288.0 + "," + (double)vehWhenLargeDelayOccur4_Dir1/volume_Dir1
                		+ "," + timeWhenLargeDelayOccur5_Dir1/288.0 + "," + (double)vehWhenLargeDelayOccur5_Dir1/volume_Dir1
                		+ "," + timeWhenLargeDelayOccur6_Dir1/288.0 + "," + (double)vehWhenLargeDelayOccur6_Dir1/volume_Dir1
                		+ "," + timeWhenLargeDelayOccur7_Dir1/288.0 + "," + (double)vehWhenLargeDelayOccur7_Dir1/volume_Dir1
                		+ "," + timeWhenLargeDelayOccur8_Dir1/288.0 + "," + (double)vehWhenLargeDelayOccur8_Dir1/volume_Dir1
                		+ "," + timeWhenLargeDelayOccur9_Dir1/288.0 + "," + (double)vehWhenLargeDelayOccur9_Dir1/volume_Dir1
                		+ "," + timeWhenLargeDelayOccur10_Dir1/288.0 + "," + (double)vehWhenLargeDelayOccur10_Dir1/volume_Dir1;
                pw.append(line_Dir1);
                pw.append("\n");
                String line_Dir2 = dateString + "," + remoteFile.split(".txt")[0] + ",2," + volume_Dir2 + "," + timeWhenLowSpeedsOccur_Dir2/288.0 + "," + (double)vehWhenLowSpeedsOccur_Dir2/volume_Dir2
                		+ "," + timeWhenLargeDelayOccur1_Dir2/288.0 + "," + (double)vehWhenLargeDelayOccur1_Dir2/volume_Dir2
                		+ "," + timeWhenLargeDelayOccur2_Dir2/288.0 + "," + (double)vehWhenLargeDelayOccur2_Dir2/volume_Dir2
                		+ "," + timeWhenLargeDelayOccur3_Dir2/288.0 + "," + (double)vehWhenLargeDelayOccur3_Dir2/volume_Dir2
                		+ "," + timeWhenLargeDelayOccur4_Dir2/288.0 + "," + (double)vehWhenLargeDelayOccur4_Dir2/volume_Dir2
                		+ "," + timeWhenLargeDelayOccur5_Dir2/288.0 + "," + (double)vehWhenLargeDelayOccur5_Dir2/volume_Dir2
                		+ "," + timeWhenLargeDelayOccur6_Dir2/288.0 + "," + (double)vehWhenLargeDelayOccur6_Dir2/volume_Dir2
                		+ "," + timeWhenLargeDelayOccur7_Dir2/288.0 + "," + (double)vehWhenLargeDelayOccur7_Dir2/volume_Dir2
                		+ "," + timeWhenLargeDelayOccur8_Dir2/288.0 + "," + (double)vehWhenLargeDelayOccur8_Dir2/volume_Dir2
                		+ "," + timeWhenLargeDelayOccur9_Dir2/288.0 + "," + (double)vehWhenLargeDelayOccur9_Dir2/volume_Dir2
                		+ "," + timeWhenLargeDelayOccur10_Dir2/288.0 + "," + (double)vehWhenLargeDelayOccur10_Dir2/volume_Dir2;
                pw.append(line_Dir2);
                pw.append("\n");
                                
                pw.flush();
                pw.close();
                

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