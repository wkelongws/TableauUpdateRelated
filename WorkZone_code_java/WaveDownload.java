import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import bean.Wavetronix;


public class WaveDownload {

	public static void main(String[] args) throws Exception {

		String today = new SimpleDateFormat("MMddyyyy").format(new java.util.Date());
		
		DataLoader dataLoader = new DataLoader();
		TextFileWriter fileWriter = new TextFileWriter();
		
		while (true) {
			
			long startTime = System.currentTimeMillis();
			
			List<Wavetronix> waveList = new ArrayList<Wavetronix>();
			try {
				// Download the wavetronix data
				waveList = dataLoader.getWavetronixData();
			} 
			catch (Exception e) {
				// try again
				String date = new SimpleDateFormat("yyyy-MM-dd   HH:mm:ss").format(new java.util.Date());
				System.err.println("Exception in download wavetronix, time: " + date);
				e.printStackTrace();
				continue;
			}
			// long downloadTime = System.currentTimeMillis() - startTime;
			
			// Update the time
			if (waveList.size() > 0) {
				String currentDay = null;
				for (Wavetronix wave : waveList) {
					currentDay = wave.getDate();
					break;
				}
				
				// MMddyyyy
				currentDay = currentDay.substring(4, 8)+ currentDay.substring(0, 4);
				
				if (!today.equals(currentDay)) {
					today = currentDay;
				}
			}
	
			// Write wavetronix data (waveList) to HDFS
			fileWriter.waveWriteFile(waveList, today);
			
			long end = System.currentTimeMillis();
			long duration = end - startTime;
			if (duration < 20000) {
				Thread.sleep(20000 - duration);
			}
			
//			else {
//				// Output to the log file, one iteration lasts longer than 20 seconds
//				SimpleDateFormat sDateFormat = new SimpleDateFormat("yyyy-MM-dd   HH:mm:ss");
//				String date = sDateFormat.format(new java.util.Date());
//				String errorMsg = "wavetronix: " + "date: " + date + "   duration: " + duration
//						+ "ms" + "   download time: " + downloadTime + "ms"
//						+ "\n";
//				
//				// append to the log file
//				FileOutputStream fos = new FileOutputStream("/home/team/deltaspeed/log.txt", true);
//				fos.write(errorMsg.getBytes());
//				fos.close();
//			}
			
		}
	}

}
