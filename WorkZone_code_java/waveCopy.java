import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.Calendar;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;

public class waveCopy {

	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub

		FileSystem hdfs =FileSystem.get(new Configuration());
		
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
    	
    	
    	String targetdata = M + D + Y + ".txt";
    	
    	System.out.println(targetdata);


				Path newFolderPath1= new Path("Shuo/wavetronix/"+Y+M);

				if(!hdfs.exists(newFolderPath1))
				{
				hdfs.mkdirs(newFolderPath1);
				}
		
				Path localFilePath1 = new Path("wavetronix/" + targetdata);
				Path hdfsFilePath1=new Path(newFolderPath1+"/"+targetdata);
				System.out.println(localFilePath1);
				System.out.println(hdfsFilePath1);
				hdfs.copyFromLocalFile(localFilePath1, hdfsFilePath1);
		
	}
	
}


