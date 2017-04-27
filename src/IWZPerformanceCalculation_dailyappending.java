import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.TreeMap;
import java.util.Vector;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.math3.analysis.interpolation.LinearInterpolator;
import org.apache.commons.math3.analysis.polynomials.PolynomialSplineFunction;
import org.apache.commons.math3.ml.clustering.Cluster;
import org.apache.commons.math3.ml.clustering.DBSCANClusterer;
import org.apache.commons.math3.ml.clustering.DoublePoint;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;

import com.jcraft.jsch.ChannelSftp;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.Session;

public class IWZPerformanceCalculation_dailyappending 
{
public static void main(String[] args) throws Exception 
{
	double speed_ref=45.0;
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
                String localDir = "//intrans-luigi.intrans.iastate.edu/SHARE/(S) SHARE/_project CTRE/1_Active Research Projects/Iowa DOT OTO Support/14_Traffic Critical Projects 2/2016/IWZ Data for Tableau/CSV Tableau All in One/";
                String localFile1 = "performance_daily-2017.csv";
                String localDir1 = "//intrans-luigi.intrans.iastate.edu/SHARE/(S) SHARE/_project CTRE/1_Active Research Projects/Iowa DOT OTO Support/14_Traffic Critical Projects 2/2017/Tableau/";
            
                
                System.out.println("append to: " + localDir + localFile);
                
                FileWriter pw = new FileWriter(localDir + localFile,true);
                FileWriter pw1 = new FileWriter(localDir1 + localFile1,true);
                
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
                //pw.append(line_Dir1);
                //pw.append("\n");
                //pw1.append(line_Dir1);
                //pw1.append("\n");
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
                //pw.append(line_Dir2);
                //pw.append("\n");
                //pw1.append(line_Dir2);
                //pw1.append("\n");
                                
                //pw.flush();
                //pw.close();
                //pw1.flush();
                //pw1.close();
                
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////                
//////////////////////////////////////////////////////////////////////////////////////////////////////                
//////////////////////////////////////////////////////////////////////////////////////////////////////                
//////////////////////////////////////////////////////////////////////////////////////////////////////                
                
                final TreeMap<Integer,TreeMap<Integer,String>> IWZData_Dir1 = new TreeMap<Integer,TreeMap<Integer,String>>();  
                final TreeMap<Integer,TreeMap<Integer,String>> IWZData_Dir2 = new TreeMap<Integer,TreeMap<Integer,String>>();  
                
                // get the sensor list for the current IWZ group
                //final HashMap<String,String> sensorsInfo = IWZList.get(remoteFile.split(".txt")[0]);
                
        		for (int h=0; h<24; h++)
        		{
        			for (int m5=0; m5<12; m5++)
        			{
        				IWZData_Dir1.put
        				(
        						h*100+m5,new TreeMap<Integer, String>()
        				{
        							{
        								for(String k:sensorsInfo.keySet())
        									{
        										int sensororder = Integer.parseInt(sensorsInfo.get(k).split(",")[11]);
        										int coded_direction = Integer.parseInt(sensorsInfo.get(k).split(",")[1]);
        										if (coded_direction==1){put(sensororder, "0,0");}
        									}
        							}
        				}
        				);
        				IWZData_Dir2.put
        				(
        						h*100+m5,new TreeMap<Integer, String>()
        				{
        							{
        								for(String k:sensorsInfo.keySet())
        									{
        										int sensororder = Integer.parseInt(sensorsInfo.get(k).split(",")[11]);
        										int coded_direction = Integer.parseInt(sensorsInfo.get(k).split(",")[1]);
        										if (coded_direction==2){put(sensororder, "0,0");}
        									}
        							}
        				}
        				);
        			}
        		} 
        		
        		
//2.1 create initial scale and projected scale
        		// create sorted milemarker list for both direction (in TreeMap)
        		TreeMap<Integer,Double> milemarker_Dir1 = new TreeMap<Integer,Double>();
        		TreeMap<Integer,Double> milemarker_Dir2 = new TreeMap<Integer,Double>();
        		for (String k:sensorsInfo.keySet())
        		{
        			int sensororder = Integer.parseInt(sensorsInfo.get(k).split(",")[11]);
					int coded_direction = Integer.parseInt(sensorsInfo.get(k).split(",")[1]);
					double linearRef = Double.parseDouble(sensorsInfo.get(k).split(",")[10]);
					if (coded_direction==1){milemarker_Dir1.put(sensororder, linearRef);}
					if (coded_direction==2){milemarker_Dir2.put(sensororder, linearRef);}
        		}
        		
        		//System.out.println(milemarker_Dir1);
        		
        		// convert to milemarker list in List
        		List<Double> mm_Dir1 = new ArrayList<Double>();
        		for(int i:milemarker_Dir1.keySet()){mm_Dir1.add(milemarker_Dir1.get(i));}
        		List<Double> mm_Dir2 = new ArrayList<Double>();
        		for(int i:milemarker_Dir2.keySet()){mm_Dir2.add(milemarker_Dir2.get(i));}
        		
        		//System.out.println(mm_Dir1);
        		
        		// convert to milemarker list in DoubleArray
    	        final double[] mm_ini_Dir1 = new double[mm_Dir1.size()];
    	        for (int i = 0; i < mm_ini_Dir1.length; i++) {
    	        	mm_ini_Dir1[i] = mm_Dir1.get(i);     
    	        }
    	        final double[] mm_ini_Dir2 = new double[mm_Dir2.size()];
    	        for (int i = 0; i < mm_ini_Dir2.length; i++) {
    	        	mm_ini_Dir2[i] = mm_Dir2.get(i);     
    	        }
    	        
    	        // Create projected milemarker list in List
    	        List<Double> mm_proj_Dir1 = new ArrayList<Double>();
    	       
    	        
    	        for (double i=milemarker_Dir1.get(milemarker_Dir1.firstKey());i<=milemarker_Dir1.get(milemarker_Dir1.lastKey());i=i+0.1)
    	        {
    	        	mm_proj_Dir1.add(i);
    	        }
    	        List<Double> mm_proj_Dir2 = new ArrayList<Double>();
    	        for (double i=milemarker_Dir2.get(milemarker_Dir2.firstKey());i<=milemarker_Dir2.get(milemarker_Dir2.lastKey());i=i+0.1)
    	        {
    	        	mm_proj_Dir2.add(i);
    	        }
    	        
    	        // convert to projected milemarker list in DoubleArray
    	        final double[] MM_PROJ_Dir1 = new double[mm_proj_Dir1.size()];
    	        for (int i = 0; i < MM_PROJ_Dir1.length; i++) {
    	        	MM_PROJ_Dir1[i] = mm_proj_Dir1.get(i);     
    	        }
    	        
    	        final double[] MM_PROJ_Dir2 = new double[mm_proj_Dir2.size()];
    	        for (int i = 0; i < MM_PROJ_Dir2.length; i++) {
    	        	MM_PROJ_Dir2[i] = mm_proj_Dir2.get(i);     
    	        }
    	        
//1.5 load data into container
    	        
                //InputStream out= null;
                out= sftpChannel.get(remoteFile);
                BufferedReader br11 = new BufferedReader(new InputStreamReader(out));
                String line11;
                //String localFile = remoteFile.split(".txt")[0] + ".csv";
                //String localFile = "event_daily.csv";
                //String localDir = "S:/(S) SHARE/_project CTRE/1_Active Research Projects/Iowa DOT OTO Support/14_Traffic Critical Projects 2/2016/IWZ Data for Tableau/CSV Tableau All in One/";
                //String localFile1 = "event_daily-2017.csv";
                //String localDir1 = "S:/(S) SHARE/_project CTRE/1_Active Research Projects/Iowa DOT OTO Support/14_Traffic Critical Projects 2/2017/Tableau/";
            
                //System.out.println("append to: " + localDir + localFile);
                
                //FileWriter pw = new FileWriter(localDir + localFile,true);
                //FileWriter pw1 = new FileWriter(localDir1 + localFile1,true);
                
                //File src=new File(localDir + localFile);
                //System.out.println(src.exists());
                //String dateString = "";
                
                while ((line11 = br11.readLine()) != null) 
                {
                	//System.out.println(line);
                	String[] columns = line11.split("\t");
                	
                	String name = columns[0];
                	String dateStr = columns[1];
                	dateString = dateStr;
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
                	int order = Integer.parseInt(columns[12]);
                	      	
            		//DateFormat formatter = new SimpleDateFormat("MM/dd/yyyy"); 
            		//Date date = (Date)formatter.parse(dateStr); 
            		//Calendar c = Calendar.getInstance();
            		//c.setTime(date);
            		//String dayofweek = new SimpleDateFormat("EE").format(date);		
            		String timestamp = dateStr + " " + hour + ":" + Integer.toString(Integer.parseInt(min5)*5) + ":00";
            		SimpleDateFormat format = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");    		
            		String fechaStr = timestamp;  
            		Date fechaNueva = format.parse(fechaStr);
            		String timestamp_formated = format.format(fechaNueva);
            		//System.out.println("test ready");
            		int timeIndex = Integer.parseInt(min5)+Integer.parseInt(hour)*100;            		
            		
            		if (Integer.parseInt(coded_direction)==1)
            		{
            			IWZData_Dir1.get(timeIndex).put(order, speed+","+count);
            		}
            		if (Integer.parseInt(coded_direction)==2)
            		{
            			IWZData_Dir2.get(timeIndex).put(order, speed+","+count);
            		}
            		//Thread.sleep(20000);
            		
                }
//                //program check
//                System.out.println("heatmap ready");
//                for(int k:IWZData_Dir1.keySet())
//        		{
//                	for(int s:IWZData_Dir1.get(k).keySet())
//                	{
//                		String line_new = k+","+s+","+IWZData_Dir1.get(k).get(s);
//                		 System.out.println(line_new);
//                	}                	
//                }
//                Thread.sleep(20000);
                
                
//2.2 create projected data container  
                // estabish one list each direction to store IWZ 5min data
                TreeMap<Integer,TreeMap<Integer,String>> IWZData_Proj_Dir1 = new TreeMap<Integer,TreeMap<Integer,String>>();  
                TreeMap<Integer,TreeMap<Integer,String>> IWZData_Proj_Dir2 = new TreeMap<Integer,TreeMap<Integer,String>>();  
                
                // get the sensor list for the current IWZ group
                
        		for (int hh=0; hh<24; hh++)
        		{
        			for (int mm5=0; mm5<12; mm5++)
        			{
        				final int timekey = hh*100+mm5;
        				IWZData_Proj_Dir1.put
        				(
        						
        						hh*100+mm5,new TreeMap<Integer, String>()
        				{
        							{
        								TreeMap<Integer,String> IniData_Dir1 = IWZData_Dir1.get(timekey);
        								double[] speed_ini_Dir1 = new double[IniData_Dir1.size()];
        								int[] count_ini_Dir1 = new int[IniData_Dir1.size()];
        								int smallcounter = 0;
        								// replace 0 speed with avg speed
        								double speed_sum = 0.0;
        								int counter_nonspeed = 0;
        				        		for (int i : IniData_Dir1.keySet()) {
        				        			speed_ini_Dir1[smallcounter] = Double.parseDouble(IniData_Dir1.get(i).split(",")[0]);    
        				        			count_ini_Dir1[smallcounter] = Integer.parseInt(IniData_Dir1.get(i).split(",")[1]); 
        				        			smallcounter++;
        				        			if (Double.parseDouble(IniData_Dir1.get(i).split(",")[0])>0)
        				        			{
        				        				counter_nonspeed++;
        				        				speed_sum += Double.parseDouble(IniData_Dir1.get(i).split(",")[0]);
        				        			}
        				        		}
        				        		double speed_avg = 0.0;
        				        		if (counter_nonspeed>0){speed_avg=speed_sum/counter_nonspeed;}
        				        		
        				        		double[] speed_proj_Dir1 = speed_ini_Dir1;
        				        		
        				        		if (speed_avg>0){
	        				        		// replace 0 speed on both ends with avg speed
	        				        		if(speed_ini_Dir1[0]==0){speed_ini_Dir1[0]=speed_avg;}
	        				        		if(speed_ini_Dir1[speed_ini_Dir1.length-1]==0){speed_ini_Dir1[speed_ini_Dir1.length-1]=speed_avg;}
	        				        		
	        				        		// 2.3 apply projection
	        				        		// remove 0 speed (in the middle) 
	        				        		List<Double> y = new ArrayList<Double>(Arrays.asList(ArrayUtils.toObject(speed_ini_Dir1)));
	        				        		List<Double> x = new ArrayList<Double>(Arrays.asList(ArrayUtils.toObject(mm_ini_Dir1)));
	        				        		while(y.indexOf(0.0)>-1)
	        				        		{
	        				        			int index = y.indexOf(0.0);
	        				        			y.remove(index);
	        				        			x.remove(index);
	        				        		}
	        				        		double[] X = new double[x.size()];
	        				        		double[] Y = new double[y.size()];
	        				        		for (int i=0;i<X.length;i++)
	        				        		{
	        				        			X[i]=x.get(i);
	        				        			Y[i]=y.get(i);
	        				        		}
	        				        		
	        				        		if(mm_ini_Dir1.length>1)
	        				        		{
	        				        			speed_proj_Dir1 = interpLinear(X, Y, MM_PROJ_Dir1);
	        				        		}
        				        		}
        				        		// speed = projected speed, count = the largest count lower than 600
        				        		List<Integer> b = Arrays.asList(ArrayUtils.toObject(count_ini_Dir1));
        				        		int realcount = 0;
        				        		int mincount = Collections.min(b);
        				        		
        				        		Collections.sort(b);
        				        		Collections.reverse(b);
        				        		
        				        		if (mincount>600){realcount=100;}
        				        		else
        				        		{
        				        			int index = 0;
        				        			while (b.get(index)>600){index++;}
        				        			realcount = b.get(index);
        				        		}
        								for (int i = 0; i < speed_proj_Dir1.length; i++) 
        									{
        										put(i, Double.toString(speed_proj_Dir1[i])+","+Integer.toString(realcount));
        									}
        							}
        				}
        				);
        				
        				IWZData_Proj_Dir2.put
        				(
        						hh*100+mm5,new TreeMap<Integer, String>()
        				{
        							{
        								TreeMap<Integer,String> IniData_Dir2 = IWZData_Dir2.get(timekey);
        								double[] speed_ini_Dir2 = new double[IniData_Dir2.size()];
        								int[] count_ini_Dir2 = new int[IniData_Dir2.size()];
        								int smallcounter = 0;
        								// replace 0 speed with avg speed
        								double speed_sum = 0.0;
        								int counter_nonspeed = 0;
        				        		for (int i : IniData_Dir2.keySet()) {
        				        			speed_ini_Dir2[smallcounter] = Double.parseDouble(IniData_Dir2.get(i).split(",")[0]);    
        				        			count_ini_Dir2[smallcounter] = Integer.parseInt(IniData_Dir2.get(i).split(",")[1]);  
        				        			smallcounter++;
        				        			if (Double.parseDouble(IniData_Dir2.get(i).split(",")[0])>0)
        				        			{
        				        				counter_nonspeed++;
        				        				speed_sum += Double.parseDouble(IniData_Dir2.get(i).split(",")[0]);
        				        			}
        				        		}
        				        		double speed_avg = 0.0;
        				        		if (counter_nonspeed>0){speed_avg=speed_sum/counter_nonspeed;}
        				        		
        				        		double[] speed_proj_Dir2 = speed_ini_Dir2;
        				        		
        				        		if (speed_avg>0){
        				        		
        				        			// replace 0 speed on both ends with avg speed
	        				        		if(speed_ini_Dir2[0]==0){speed_ini_Dir2[0]=speed_avg;}
	        				        		if(speed_ini_Dir2[speed_ini_Dir2.length-1]==0){speed_ini_Dir2[speed_ini_Dir2.length-1]=speed_avg;}
	        				        		
	        				        		// 2.3 apply projection 
	        				        		// remove 0 speed (in the middle) 
	        				        		List<Double> y = new ArrayList<Double>(Arrays.asList(ArrayUtils.toObject(speed_ini_Dir2)));
	        				        		List<Double> x = new ArrayList<Double>(Arrays.asList(ArrayUtils.toObject(mm_ini_Dir2)));
	        				        		while(y.indexOf(0.0)>-1)
	        				        		{
	        				        			int index = y.indexOf(0.0);
	        				        			y.remove(index);
	        				        			x.remove(index);
	        				        		}
	        				        		double[] X = new double[x.size()];
	        				        		double[] Y = new double[y.size()];
	        				        		for (int i=0;i<X.length;i++)
	        				        		{
	        				        			X[i]=x.get(i);
	        				        			Y[i]=y.get(i);
	        				        		}
	        				        		
	        				        		if(mm_ini_Dir1.length>1)
	        				        		{
	        				        			speed_proj_Dir2 = interpLinear(X, Y, MM_PROJ_Dir2);
	        				        		}
        				        		}
        				        		// speed = projected speed, count = the largest count lower than 600
        				        		List<Integer> b = Arrays.asList(ArrayUtils.toObject(count_ini_Dir2));
        				        		int realcount = 0;
        				        		int mincount = Collections.min(b);
        				        		
        				        		Collections.sort(b);
        				        		Collections.reverse(b);
        				        		
        				        		if (mincount>600){realcount=100;}
        				        		else
        				        		{
        				        			int index = 0;
        				        			while (b.get(index)>600){index++;}
        				        			realcount = b.get(index);
        				        		}
        								for (int i = 0; i < speed_proj_Dir2.length; i++) 
        									{
        										put(i, Double.toString(speed_proj_Dir2[i])+","+Integer.toString(realcount));
        									}
        							}
        				}
        				);
        			}
        		} 
     
//        		//projected speed heatmap checkout
//        		System.out.println("heatmap ready");
//                for(int k:IWZData_Proj_Dir1.keySet())
//        		{
//                	for(int s:IWZData_Proj_Dir1.get(k).keySet())
//                	{
//                		String line_new = k+","+s+","+IWZData_Proj_Dir1.get(k).get(s);
//                		 System.out.println(line_new);
//                	}                	
//                }
//                Thread.sleep(20000);
        		
//3.2 apply clustering
        		List<DoublePoint> clusterInput_Dir1 = new ArrayList<DoublePoint>();
        		
        		for(int k:IWZData_Proj_Dir1.keySet())
	        	{
	                for(int s:IWZData_Proj_Dir1.get(k).keySet())
	                {
	                	double speed = Double.parseDouble(IWZData_Proj_Dir1.get(k).get(s).split(",")[0]);
	                	if (speed<speed_ref & speed>0)
	                	{
	                		int hour = k/100;
	                		int minute = k-hour*100;
	                		int time = hour*12+minute;
	                		double[] congpoint = {(double)time, (double)s};
	                		clusterInput_Dir1.add(new DoublePoint(congpoint));
	                	}
	                }                	
	            }
        		
        		List<DoublePoint> clusterInput_Dir2 = new ArrayList<DoublePoint>();
        		
        		for(int k:IWZData_Proj_Dir2.keySet())
	        	{
	                for(int s:IWZData_Proj_Dir2.get(k).keySet())
	                {
	                	double speed = Double.parseDouble(IWZData_Proj_Dir2.get(k).get(s).split(",")[0]);
	                	if (speed<speed_ref & speed>0)
	                	{
	                		int hour = k/100;
	                		int minute = k-hour*100;
	                		int time = hour*12+minute;
	                		double[] congpoint = {(double)time, (double)s};
	                		clusterInput_Dir2.add(new DoublePoint(congpoint));
	                	}
	                }                	
	            }
        		
        		
//        		System.out.println(clusterInput);
//        		Thread.sleep(20000);
        		
        		DBSCANClusterer<DoublePoint> dbcluster = new DBSCANClusterer<DoublePoint>(1.2,0);
        		List<Cluster<DoublePoint>> dbclusterResults_Dir1 = dbcluster.cluster(clusterInput_Dir1);
        		// output the clusters
        		System.out.println(dbclusterResults_Dir1.size() + " DB Clusters in direction 1");
        		int eventID = 0;
        		
        		DescriptiveStatistics event_duration_dir1 = new DescriptiveStatistics();
        		DescriptiveStatistics event_length_dir1 = new DescriptiveStatistics();
        		DescriptiveStatistics event_vehicle_dir1 = new DescriptiveStatistics();
        		DescriptiveStatistics event_delay_dir1 = new DescriptiveStatistics();
   
        		for (int i=0; i<dbclusterResults_Dir1.size(); i++) {
        			eventID++;
        			int start_key1 = 2311;
        			int end_key1 = 0;
        			int start_key2 = 999;
        			int end_key2 = 0;
        			int counter = 0;
        			double speed_sum = 0.0;
        			
        			HashMap<Integer,String> queues = new HashMap<Integer,String>();
        			
        			for (DoublePoint a : dbclusterResults_Dir1.get(i).getPoints())
        			{
        				counter++;
        				int time = (int)a.getPoint()[0];
        				int key2 = (int)a.getPoint()[1];
        				int key1 = time/12*100+time%12;
        				if(start_key1>key1){start_key1=key1;}
        				if(end_key1<key1){end_key1=key1;}
        				if(start_key2>key2){start_key2=key2;}
        				if(end_key2<key2){end_key2=key2;}
        				double speed = Double.parseDouble(IWZData_Proj_Dir1.get(key1).get(key2).split(",")[0]);
        				
        				int veh = Integer.parseInt(IWZData_Proj_Dir1.get(key1).get(key2).split(",")[1]);
        				speed_sum += speed;
        				if(queues.containsKey(key1))
        				{
        					int cnt_old = Integer.parseInt(queues.get(key1).split(",")[0])+1;
        					double sp_old = Double.parseDouble(queues.get(key1).split(",")[1])*cnt_old;
        					
        					int cnt_new = cnt_old + 1;
        					double sp_new = (sp_old+speed)/cnt_new;
        					
        					int veh_old = Integer.parseInt(queues.get(key1).split(",")[2]);
        					int veh_new = veh_old;
        					
        					queues.put(key1, Integer.toString(cnt_new)+","+Double.toString(sp_new)+","+Integer.toString(veh_new));
        				}
        				else{queues.put(key1, "1,"+Double.toString(speed)+","+Integer.toString(veh));}
        			}
        			String starttime = Integer.toString(start_key1/100)+":"+Integer.toString(start_key1%100)+":00";
        			String endtime = Integer.toString(end_key1/100)+":"+Integer.toString(end_key1%100*5+4)+":59";
        			double lengthImpacted = (end_key2-start_key2+1)*0.1;//in mile
        			double averageEventSpeed = speed_sum/counter;// in mph
        			int veh_sum = 0;
        			double delay_total = 0.0;
        			for (int n:queues.keySet())
        			{
        				veh_sum += Integer.parseInt(queues.get(n).split(",")[2]);
        				double dist = Double.parseDouble(queues.get(n).split(",")[0])*0.1; // in mile
        				double speed = Double.parseDouble(queues.get(n).split(",")[1])*0.1; // in mph
        				double traveltime = dist/speed*60; // in minute
        				double traveltime_ref = dist/speed_ref*60; //in minute
        				double delay = Math.max(0.0, traveltime-traveltime_ref);
        				delay_total += delay*Double.parseDouble(queues.get(n).split(",")[2]); // in veh*min
        			}
        			int duration = (end_key1/100*60+end_key1%100*5) - (start_key1/100*60+start_key1%100*5); 
        			event_duration_dir1.addValue(duration);
        			event_length_dir1.addValue(lengthImpacted);
        			event_vehicle_dir1.addValue(veh_sum);
        			event_delay_dir1.addValue(delay_total);
        			
        			//String row = dateString + "," + remoteFile.split(".txt")[0] + ",1,"+eventID+","+starttime+","+endtime+","+lengthImpacted+","+counter+","+averageEventSpeed+","+veh_sum+","+delay_total;
        			//pw.append(row);
        			//pw.append("\n");
        			//pw1.append(row);
        			//pw1.append("\n");
        		}
        		
        		List<Cluster<DoublePoint>> dbclusterResults_Dir2 = dbcluster.cluster(clusterInput_Dir2);
    	        // output the clusters
    	        System.out.println(dbclusterResults_Dir2.size() + " DB Clusters in direction 2");
    	        eventID = 0;
    	        DescriptiveStatistics event_duration_dir2 = new DescriptiveStatistics();
        		DescriptiveStatistics event_length_dir2 = new DescriptiveStatistics();
        		DescriptiveStatistics event_vehicle_dir2 = new DescriptiveStatistics();
        		DescriptiveStatistics event_delay_dir2 = new DescriptiveStatistics();
    	        for (int i=0; i<dbclusterResults_Dir2.size(); i++) {
        			eventID++;
        			int start_key1 = 2311;
        			int end_key1 = 0;
        			int start_key2 = 999;
        			int end_key2 = 0;
        			int counter = 0;
        			double speed_sum = 0.0;
        			
        			HashMap<Integer,String> queues = new HashMap<Integer,String>();
        			
        			for (DoublePoint a : dbclusterResults_Dir2.get(i).getPoints())
        			{
        				counter++;
        				int time = (int)a.getPoint()[0];
        				int key2 = (int)a.getPoint()[1];
        				int key1 = time/12*100+time%12;
        				if(start_key1>key1){start_key1=key1;}
        				if(end_key1<key1){end_key1=key1;}
        				if(start_key2>key2){start_key2=key2;}
        				if(end_key2<key2){end_key2=key2;}
        				double speed = Double.parseDouble(IWZData_Proj_Dir2.get(key1).get(key2).split(",")[0]);
        				
        				int veh = Integer.parseInt(IWZData_Proj_Dir2.get(key1).get(key2).split(",")[1]);
        				speed_sum += speed;
        				
        				if(queues.containsKey(key1))
        				{
        					int cnt_old = Integer.parseInt(queues.get(key1).split(",")[0])+1;
        					double sp_old = Double.parseDouble(queues.get(key1).split(",")[1])*cnt_old;
        					
        					int cnt_new = cnt_old + 1;
        					double sp_new = (sp_old+speed)/cnt_new;
        					
        					int veh_old = Integer.parseInt(queues.get(key1).split(",")[2]);
        					int veh_new = veh_old;
        						
        					queues.put(key1, Integer.toString(cnt_new)+","+Double.toString(sp_new)+","+Integer.toString(veh_new));
        				}
        				else
        				{
        					queues.put(key1, "1,"+Double.toString(speed)+","+Integer.toString(veh));
        				}
        			}
        			
        			String starttime = Integer.toString(start_key1/100)+":"+Integer.toString(start_key1%100)+":00";
        			String endtime = Integer.toString(end_key1/100)+":"+Integer.toString(end_key1%100*5+4)+":59";
        			double lengthImpacted = (end_key2-start_key2+1)*0.1;//in mile
        			double averageEventSpeed = speed_sum/counter;// in mph
        			int veh_sum = 0;
        			double delay_total = 0.0;
        			for (int n:queues.keySet())
        			{
        				veh_sum += Integer.parseInt(queues.get(n).split(",")[2]);
        				double dist = Double.parseDouble(queues.get(n).split(",")[0])*0.1; // in mile
        				double speed = Double.parseDouble(queues.get(n).split(",")[1])*0.1; // in mph
        				double traveltime = dist/speed*60; // in minute
        				double traveltime_ref = dist/speed_ref*60; //in minute
        				double delay = Math.max(0.0, traveltime-traveltime_ref);
        				delay_total += delay*Double.parseDouble(queues.get(n).split(",")[2]); // in veh*min
        			}
        			int duration = (end_key1/100*60+end_key1%100*5) - (start_key1/100*60+start_key1%100*5); 
        			event_duration_dir2.addValue(duration);
        			event_length_dir2.addValue(lengthImpacted);
        			event_vehicle_dir2.addValue(veh_sum);
        			event_delay_dir2.addValue(delay_total);
        			
        			//String row = dateString + "," + remoteFile.split(".txt")[0] + ",2,"+eventID+","+starttime+","+endtime+","+lengthImpacted+","+counter+","+averageEventSpeed+","+veh_sum+","+delay_total;
        			//pw.append(row);
        			//pw.append("\n");
        			//pw1.append(row);
        			//pw1.append("\n");
        		}
    	        
    			
    			String row_dir1 = line_Dir1 + "," + event_duration_dir1.getN()
    			+ "," + event_duration_dir1.getMean() + "," + event_duration_dir1.getMax() 
    			+ "," + event_length_dir1.getMean() + "," + event_length_dir1.getMax() 
    			+ "," + event_vehicle_dir1.getMean() + "," + event_vehicle_dir1.getMax() 
    			+ "," + event_delay_dir1.getMean() + "," + event_delay_dir1.getMax();
    			
    			pw.append(row_dir1);
                pw.append("\n");
                pw1.append(row_dir1);
                pw1.append("\n");
    			
    			String row_dir2 = line_Dir2 + "," + event_duration_dir2.getN()
    			+ "," + event_duration_dir2.getMean() + "," + event_duration_dir2.getMax() 
    			+ "," + event_length_dir2.getMean() + "," + event_length_dir2.getMax() 
    			+ "," + event_vehicle_dir2.getMean() + "," + event_vehicle_dir2.getMax() 
    			+ "," + event_delay_dir2.getMean() + "," + event_delay_dir2.getMax();
    			
    			pw.append(row_dir2);
                pw.append("\n");
                pw1.append(row_dir2);
                pw1.append("\n");
    			
    			
    			
    	        pw.flush();
	            pw.close();	
	            pw1.flush();
	            pw1.close();	
                
                
                
                
                
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

public static double[] interpLinear(double[] x, double[] y, double[] xi) {
	   LinearInterpolator li = new LinearInterpolator(); // or other interpolator
	   PolynomialSplineFunction psf = li.interpolate(x, y);

	   double[] yi = new double[xi.length];
	   for (int i = 0; i < xi.length; i++) {
	       yi[i] = psf.value(xi[i]);
	   }
	   return yi;
	}


}