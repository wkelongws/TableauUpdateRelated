# TableauUpdateRelated
java codes to update database for IWZ online visualization using Tableau

### For TCP program, Iowa DOT

This code is created to calculate desired performance measures of the on-going work zone project in Iowa from the extracted data from HDFS and append result to a Tableau linked database.

4 tags of the visualization panel are dependent on this code:
1. daily performance measure
2. daily event log
3. daily speed heatmaps and sensor condition heatmaps
4. speed issue stats

All codes are converted to excutable jar and scheduled on local machine to daily auto-update the visualization panel on REACTOR website: [REACTOR-IWZ](https://reactor.ctre.iastate.edu/index.php/iwz/overview/)

#### code brief description and usage

`CreateTargetDataPull.java` is the source code for the jar program running on 10.29.19.65 sever of InTrans. It generates the input data in HDFS for all the following programs based on the current date. This jar file is scheduled as cron job to run daily on 10.29.19.65

All other .java files are the source code for the excutable jars scheduled daily by window task schedular to run on intran-isu213. These excutables jars read data from 10.29.19.65, compute and then append results to different .csv files on `//intrans-luigi.intrans.iastate.edu/SHARE//(S) SHARE/_project CTRE/1_Active Research Projects/Iowa DOT OTO Support/14_Traffic Critical Projects 2/2017/Tableau/`

`SensorIssueAppending` computes the cummulative running time by working conditions of each sensor and append the results to `IWZSensorIssue-2017.csv`

`HeatmapDataAppending` reformat each row and append to `Historical Raw-2017.csv`

`EventCalculation` computes the charateristics of the low speed events and append to `event_daily-2017.csv`

`IWZPerformanceCalculation_dailyappending` computes the traffic performance measures and append them to `performance_daily-2017.csv`

All the _MultipleDays.java file are the variants of the 4 files above. They are designed to process multiple days as needed.
