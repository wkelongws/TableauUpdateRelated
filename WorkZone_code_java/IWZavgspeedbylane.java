/**
  *****************************************
  *****************************************
  * by Shuo Wang **
  *****************************************
  *****************************************
  */

import java.io.*;
import java.lang.*;
import java.util.*;
import java.net.*;

import org.apache.hadoop.fs.*;
import org.apache.hadoop.conf.*;
import org.apache.hadoop.io.*;
import org.apache.hadoop.util.*;
import org.apache.hadoop.mapreduce.*;
import org.apache.hadoop.mapreduce.Reducer.Context;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat; 
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat; 
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat; 
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;



public class IWZavgspeedbylane extends Configured implements Tool {
	
	public static void main ( String[] args ) throws Exception {
		
		int res = ToolRunner.run(new Configuration(), new IWZavgspeedbylane(), args);
		System.exit(res); 
		
	} // End main
	
	public int run ( String[] args ) throws Exception {
		
		
		//String input = args[0];
		

		//if (numberinput==0){input = "Shuo/twoweekdatapull.txt";}

		
		    // Input
		String temp = "Shuo/output";       // Round one output
		//String temp1 = "/scr/shuowang/lab3/exp2/temp1/";     // Round two output
		//String output1 = "/scr/shuowang/lab3/exp2/output1/";   // Round three/final output
		//String output2 = "/scr/shuowang/lab3/exp2/output2/";   // Round three/final output
		
		int reduce_tasks = 12;  // The number of reduce tasks that will be assigned to the job
		Configuration conf = new Configuration();
		
		// Create job for round 1: round 1 gets all the neighbors of A and the number of triplets with A in the middle, output to 'temp'
		
		// Create the job
		Job job_one = new Job(conf, "Exp2 Program Round One"); 	
		
		// Attach the job to this Driver
		job_one.setJarByClass(IWZavgspeedbylane.class); 
		
		// Fix the number of reduce tasks to run
		// If not provided, the system decides on its own
		job_one.setNumReduceTasks(reduce_tasks);		
		
		job_one.setMapOutputKeyClass(Text.class); 
		job_one.setMapOutputValueClass(Text.class); 
		job_one.setOutputKeyClass(NullWritable.class);         
		job_one.setOutputValueClass(Text.class);
		
		// The class that provides the map method
		job_one.setMapperClass(Map_One.class); 
		
		// The class that provides the reduce method
		job_one.setReducerClass(Reduce_One.class);
		
		// Decides how the input will be split
		// We are using TextInputFormat which splits the data line by line
		// This means each map method receives one line as an input
		job_one.setInputFormatClass(TextInputFormat.class);  
		
		// Decides the Output Format
		job_one.setOutputFormatClass(TextOutputFormat.class);
		
		// The input HDFS path for this job
		// The path can be a directory containing several files
		// You can add multiple input paths including multiple directories
		if (args.length==0){FileInputFormat.addInputPath(job_one, new Path("Shuo/twoweekdatapull.txt"));}
		for (String input:args){FileInputFormat.addInputPath(job_one, new Path(input)); }
		
		//FileInputFormat.addInputPath(job_one, new Path(input1)); 
		// FileInputFormat.addInputPath(job_one, new Path(another_input_path)); // This is legal
		
		// The output HDFS path for this job
		// The output path must be one and only one
		// This must not be shared with other running jobs in the system
		FileOutputFormat.setOutputPath(job_one, new Path(temp));
		// FileOutputFormat.setOutputPath(job_one, new Path(another_output_path)); // This is not allowed
		
		// Run the job
		job_one.waitForCompletion(true); 
		
		
	
		return 0;
	
	} // End run
	
	// The round one: round 1 gets all the neighbors of A and the number of triplets with A in the middle

	public static class Map_One extends Mapper<LongWritable, Text, Text, Text>  {		
	
		// The map method 
		public void map(LongWritable key, Text value, Context context) 
								throws IOException, InterruptedException  {
			
			// The TextInputFormat splits the data line by line.
			// So each map method receives one line (edge) from the input
			String line = value.toString();
			
			// Split the edge into two nodes 
			String[] nodes = line.split(",");
			
			if(nodes.length>=6 & (nodes.length-6)%11==0)
			{
			
			int weightedspeedsum = 0;			
			int countsum = 0;			
			int occupancysum = 0;
			double avgoccupancy = 0.0;
			double avgspeed = 0.0;
			int smallcountsum = 0;
			int middlecountsum = 0;
			int largecountsum = 0;
			
			String date = nodes[1];
			String yy = date.substring(0,4);
			String m = date.substring(4,6);
			String dd = date.substring(6,8);
			String D = m+"/"+dd+"/"+yy;
			
			String time = nodes[2];
			String hh = time.substring(0,2);
			String mm = time.substring(2,4);
			String ss = time.substring(4,6);
			int minnum = Integer.parseInt(mm)/5;			
			
			
			
			if(nodes[4].equals("failed"))
			{
				context.write(new Text(nodes[0].trim()+","+D+","+hh+","+Integer.toString(minnum)), new Text("nocomma"));				
			}
			if(nodes[4].equals("off"))
			{
				context.write(new Text(nodes[0].trim()+","+D+","+hh+","+Integer.toString(minnum)), new Text("one,comma"));				
			}
			
			
			if(nodes.length>6)
			{
				int numlanes = Integer.parseInt(nodes[5]);
				int zerospeednonzerocountflag = 0;
				
				for(int i=0;i<numlanes;i++)
				{
					if (i*11+10<=nodes.length)
					{
					String count = nodes[i*11+7];
					String speed = nodes[i*11+10];
					String occupancy = nodes[i*11+9];
					String smallcount = nodes[i*11+11];
					String middlecount = nodes[i*11+13];
					String largecount = nodes[i*11+15];
					
					if(count.equals("null"))
					{
						count = "0";
					}
					if(Integer.parseInt(count)>17)
					{
						count = "0";
					}
					if(speed.equals("null"))
					{
						speed = "0";
					}
					if(Integer.parseInt(speed)<0)
					{
						speed = "0";
					}					
					if(occupancy.equals("null"))
					{
						occupancy = "0";
					}
					if(smallcount.equals("null"))
					{
						smallcount = "0";
					}
					if(middlecount.equals("null"))
					{
						middlecount = "0";
					}
					if(largecount.equals("null"))
					{
						largecount = "0";
					}
										
					countsum += Integer.parseInt(count);							
					weightedspeedsum += Integer.parseInt(count)*Integer.parseInt(speed);					
					occupancysum += Integer.parseInt(occupancy);
					smallcountsum += Integer.parseInt(smallcount);
					middlecountsum += Integer.parseInt(middlecount);
					largecountsum += Integer.parseInt(largecount);
					
					if (Integer.parseInt(count)>0 & Integer.parseInt(speed)==0)
					{
						zerospeednonzerocountflag++;
					}
					
					}
				}
				avgoccupancy = occupancysum/numlanes;
				if (countsum>0)
				{
					avgspeed = weightedspeedsum/1.6/countsum;
				}				
				context.write(new Text(nodes[0].trim()+","+D+","+hh+","+Integer.toString(minnum)), new Text(Double.toString(avgspeed)+","+Integer.toString(countsum)+","+Double.toString(avgoccupancy)));
				if (countsum!=smallcountsum+middlecountsum+largecountsum)
				{
					context.write(new Text(nodes[0].trim()+","+D+","+hh+","+Integer.toString(minnum)), new Text("th,ree,com,ma"));
				}
				if (zerospeednonzerocountflag>0)
				{
					context.write(new Text(nodes[0].trim()+","+D+","+hh+","+Integer.toString(minnum)), new Text("fo,ur,co,mm,a"));
				}
			}					
			}
		} // End method "map"
		
	} // End Class Map_One
	
	
	// The reduce class	
	public static class Reduce_One extends Reducer<Text, Text, NullWritable, Text>  {		
		
		// The reduce method
		// For key, we have an Iterable over all values associated with this key
		// The values come in a sorted fashion.
		public void reduce(Text key, Iterable<Text> values, Context context) 
											throws IOException, InterruptedException  {
			
			int totalcount = 0;
			double totalspeed = 0.0;
			double totaloccupancy = 0.0;
			int num = 0;
			int fail = 0;
			int off = 0;
			int classmisscount = 0;
			int zerospeednonzerocount = 0;
			int missingveh = 0;
			int issue=0;
			
			for (Text val : values) {
				
				num++;
				String data = val.toString();
				
				String[] data1 = data.split(",");
				
				if (data1.length==1)
				{
					fail++;
				}
				if (data1.length==2)
				{
					off++;
				}
				if (data1.length==4)
				{
					classmisscount++;
				}
				if (data1.length==5)
				{
					zerospeednonzerocount++;
				}
				if (data1.length==3)
				{
				totalcount += Integer.parseInt(data1[1]);
				totalspeed += Double.parseDouble(data1[0])*Integer.parseInt(data1[1]);
				totaloccupancy += Double.parseDouble(data1[2]);	
				}
			}
			
			double meanspeed = 0.0;
			if(totalcount>0)
			{
				meanspeed = totalspeed/totalcount;	
			}
			double meanoccupancy = totaloccupancy/num;
			
			int hh = Integer.parseInt(key.toString().split(",")[2]);
			if (fail + off ==0 & hh>5 & hh<21 & totalcount==0)
			{
				missingveh++;
			}
			
						
			if (off>0)
			{
				issue = 10;
				context.write(NullWritable.get(),new Text(key.toString()+","+Double.toString(meanspeed)+","+Integer.toString(totalcount)+","+Double.toString(meanoccupancy)+","+Integer.toString(issue)));
			}
			if (fail>0)
			{
				issue = 20;
				context.write(NullWritable.get(),new Text(key.toString()+","+Double.toString(meanspeed)+","+Integer.toString(totalcount)+","+Double.toString(meanoccupancy)+","+Integer.toString(issue)));
			}
			if (zerospeednonzerocount>0)
			{
				issue = 30;
				context.write(NullWritable.get(),new Text(key.toString()+","+Double.toString(meanspeed)+","+Integer.toString(totalcount)+","+Double.toString(meanoccupancy)+","+Integer.toString(issue)));
			}
			if (missingveh>0)
			{
				issue = 40;
				context.write(NullWritable.get(),new Text(key.toString()+","+Double.toString(meanspeed)+","+Integer.toString(totalcount)+","+Double.toString(meanoccupancy)+","+Integer.toString(issue)));
			}
			
			
			if (classmisscount>0)
			{
				issue = 60;   
				context.write(NullWritable.get(),new Text(key.toString()+","+Double.toString(meanspeed)+","+Integer.toString(totalcount)+","+Double.toString(meanoccupancy)+","+Integer.toString(issue)));
			}
			if (fail+off+classmisscount+zerospeednonzerocount+missingveh==0)
			{
				issue = 0;
				context.write(NullWritable.get(),new Text(key.toString()+","+Double.toString(meanspeed)+","+Integer.toString(totalcount)+","+Double.toString(meanoccupancy)+","+Integer.toString(issue)));
			}
		} // End method "reduce" 
		
	} // End Class Reduce_One
	
	
 	
}
 	
 	
 	
	


