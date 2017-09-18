import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.util.List;

import bean.Wavetronix;

public class TextFileWriter {
	
	/*
	 * Write the deltaspeed data to file
	 */
	public void waveWriteFile(List<Wavetronix> waveList, String currentDay)
			throws Exception {

		//String savePath = "wavetronix";
		String savePath = "C:/Users/shuowang/Desktop/WaveDownload/waveCSV";
		File saveDir = new File(savePath);
		if(!saveDir.exists()){
            saveDir.mkdir();
        }
		
        // output data to the file
        File f = new File(savePath + File.separator + currentDay + ".txt"); 

		FileOutputStream fos = new FileOutputStream(f, f.exists());
		DataOutputStream dos = new DataOutputStream(fos);
		// Write to the new file
		for (Wavetronix w : waveList) {
			dos.writeBytes(w.toString() + "\n");
		}

		dos.flush();
		dos.close();
	}
}
