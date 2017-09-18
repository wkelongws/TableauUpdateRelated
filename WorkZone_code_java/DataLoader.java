import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import bean.Lane;
import bean.Wavetronix;

public class DataLoader {

	/**
	 * Download the Wavetronix dataset and parse the xml file to a list
	 * @return
	 */
	public List<Wavetronix> getWavetronixData() {
		
		// List of the wavetronix dataset
		List<Wavetronix> wavetronixList = new ArrayList<Wavetronix>();

		// Parse the wavetronix xml file, add each item to the list
		String link = "http://205.221.97.102/Iowa.Sims.AllSites.C2C/IADOT_SIMS_AllSites_C2C.asmx/OP_ShareTrafficDetectorData?MSG_TrafficDetectorDataRequest=string%20HTTP/1.1";
		
		//String waveXMLPath = "./temp";
		String waveXMLPath = "C:/Users/shuowang/Desktop/WaveDownload/waveXML";
		String waveFileName = "wavetronix.xml";
		
		try {
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = factory.newDocumentBuilder();
			// Document document = builder.parse(link);
			Document document = builder.parse(downloadFromUrl(link, waveXMLPath, waveFileName));
			document.getDocumentElement();
			
			// get the date and time
			String date = document.getElementsByTagName("local-date").item(0).getTextContent();
			String start = document.getElementsByTagName("start-time").item(0).getTextContent();
			String end = document.getElementsByTagName("end-time").item(0).getTextContent();

			// get detectors
			NodeList detectorList = document.getElementsByTagName("detector-report");
			for (int i=0; i<detectorList.getLength(); i++) {
				Element detector = (Element)detectorList.item(i);
				String id = detector.getElementsByTagName("detector-id")
						.item(0).getTextContent().trim();
				String status = detector.getElementsByTagName("status")
						.item(0).getTextContent();
				NodeList lanes = detector.getElementsByTagName("lane");
				int numOfLanes = lanes.getLength();
				
				List<Lane> laneList = new ArrayList<Lane>();
				for (int j=0; j<lanes.getLength(); j++) {
					Lane lane = parseLane(lanes.item(j));
					laneList.add(lane);
				}
				
				Wavetronix wavetronix = new Wavetronix(id, date, start, end,
						status, numOfLanes, laneList);
				wavetronixList.add(wavetronix);
			}
		} 
		catch (Exception e) {
			e.printStackTrace();
		}
		
		return wavetronixList;
	}
	
	/**
	 * Parse the lane object
	 * @param laneNode
	 * @return
	 */
	private Lane parseLane(Node laneNode) {
		
		Lane lane = new Lane();
		
		NodeList laneNodeChildren = laneNode.getChildNodes();
		for (int i=0; i<laneNodeChildren.getLength(); i++) {
			Node laneChild = laneNodeChildren.item(i);
			
			if (laneChild.getNodeType() == Node.ELEMENT_NODE) {
				String nodeName = laneChild.getNodeName();
				if (nodeName.equals("lane-id")) {
					lane.setLaneID(laneChild.getTextContent());
				}
				else if (nodeName.equals("count")) {
					lane.setCount(laneChild.getTextContent());
				}
				else if (nodeName.equals("volume")) {
					lane.setVolume(laneChild.getTextContent());
				}
				else if (nodeName.equals("occupancy")) {
					lane.setOccupancy(laneChild.getTextContent());
				}
				else if (nodeName.equals("speed")) {
					lane.setSpeed(laneChild.getTextContent());
				}
				else if (nodeName.equals("classes")) {
					NodeList classes = ((Element)laneChild).getElementsByTagName("class");
					for (int j=0; j<classes.getLength(); j++) {
						Node classNode = classes.item(j);
						NodeList classChildren = classNode.getChildNodes();
						if (classChildren.getLength() == 7) {
							String classID = classChildren.item(1).getTextContent();
							String classCount = classChildren.item(3).getTextContent();
							String classVolume = classChildren.item(5).getTextContent();
							if (classID.equals("Small")) {
								lane.setSmallCount(classCount);
								lane.setSmallVolume(classVolume);
							}
							else if (classID.equals("Medium")) {
								lane.setMediumCount(classCount);
								lane.setMediumVolume(classVolume);
							}
							else if (classID.equals("Large")) {
								lane.setLargeCount(classCount);
								lane.setLargeVolume(classVolume);
							}
						}
					}
				}
			}
			
		}
		return lane;
	}

	
	/**
	 * Download file from a URL
	 * @param urlStr
     * @param fileName
     * @param savePath
     * @throws IOException
	 */
	public static File downloadFromUrl(String urlStr, String savePath, String fileName) throws IOException{
        
		URL url = new URL(urlStr);  
        HttpURLConnection conn = (HttpURLConnection)url.openConnection();  
        conn.setConnectTimeout(5*1000);
        // avoid the block program
        conn.setRequestProperty("User-Agent", "Mozilla/4.0 (compatible; MSIE 5.0; Windows NT; DigExt)");

        // get input stream
        InputStream inputStream = conn.getInputStream();  
        // get the data array
        byte[] getData = readInputStream(inputStream);    

        File saveDir = new File(savePath);
        if(!saveDir.exists()){
            saveDir.mkdir();
        }
        // output data to the file
        File file = new File(saveDir + File.separator + fileName); 
        FileOutputStream fos = new FileOutputStream(file);     
        fos.write(getData); 
        
        // close fos and input stream
        fos.close(); 
        inputStream.close();
        
        return file;
    }


    /**
     * @param inputStream
     * @return
     * @throws IOException
     */
    public static byte[] readInputStream(InputStream inputStream) throws IOException {  
        byte[] buffer = new byte[1024];  
        int len = 0;  
        ByteArrayOutputStream bos = new ByteArrayOutputStream();  
        while((len = inputStream.read(buffer)) != -1) {  
            bos.write(buffer, 0, len);  
        }  
        bos.close();  
        return bos.toByteArray();  
    }  
    
}
