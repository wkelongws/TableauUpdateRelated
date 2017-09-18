clc;clear;close all;

% reportstartday = inputdlg('please specify the first day of study period (yyyy-mm-dd):');
% reportendday = inputdlg('please specify the last day of study period (yyyy-mm-dd):');
% reportstartday=reportstartday{1};
% reportendday=reportendday{1};
reportstartday = '2016-01-01';
reportendday = '2016-01-31';
% datafilefolder='C:\Shuo Wang\study\study\Projects & Papers\IWZ bi-weekly report\IWZ_DATA_txt';
% milemarkerfolder='C:\Shuo Wang\study\study\Projects & Papers\IWZ bi-weekly report\mat files';
% x=inputdlg('please specify the directory of the folder containing IWZ data:');
% y=inputdlg('please specify the directory of the folder which you want to put results in:');
% x=x{1};
% y=y{1};
x = 'C:\Users\shuowang\Desktop\Projects & Papers\IWZ bi-weekly report_laptop modified\IWZ_DATA_txt';
y = 'C:\Users\shuowang\Desktop\Projects & Papers\IWZ bi-weekly report_laptop modified\PDF figures';

% milemarkerfolder=input('mile marker folder:','s');

list1 = dir([x '\*.txt']);
list2 = dir([x '\*.csv']);
% list2 = dir([milemarkerfolder '\*.mat']);
%list3 = dir('C:\Shuo Wang\study\study\Projects & Papers\IWZ bi-weekly report\MileMarkers\*.csv');

fid = fopen([x '\' list2(1).name]);
C = textscan(fid, '%s %f %f %f %f %s %s %s %s %f %f %f', 'Delimiter',',','HeaderLines', 1);
fclose(fid);
[~,~,uniqueindex]=unique(C{9});
accumindex=accumarray(uniqueindex(:),1);
bb=[C{2} C{3} C{10} C{11}];
MileMarkers = mat2cell(bb,accumindex,size(bb,2));
celldata = [mat2cell(C{10},accumindex,size(C{10},2)) mat2cell(C{6},accumindex,size(C{6},2))];

for i=1:size(MileMarkers,1)
    [aaa,bbb]=sortrows(MileMarkers{i,1},4);
    MileMarkers(i,1)={aaa};
    yyy=celldata{i,1};
    xxx=celldata{i,2};
    celldata(i,1)={yyy(bbb)};
    celldata(i,2)={xxx(bbb)};
end

sensornames = celldata(floor(1:0.5:size(celldata,1)+0.5),:);

performanceTable = cell (2*length(list1),14);
AverageSpeednorm = cell (2*length(list1),6);
AverageSpeed = cell (2*length(list1),6);
MissingData = cell (2*length(list1),3);
figurenum=1;
for i = 1:length(list1)
%i=6;
    figurenum=1;
milemarker = MileMarkers{i};    
% load(list2(i).name)
% name=list2(i).name;
groupname=list1(i).name;
groupname=groupname(1:end-4);

%milemarker=eval(name(1:12));      
speeddata = IWZread([x '\' list1(i).name]);

if speeddata==0;
    plot(i,1,'r*');
else

EB=1; % NB detector ID in column 1                  % change this
WB=2; % SB detector ID in column 2                  % change this
timeinterval=5; % aggregated time interval (min)    % changed to 15 30 60, etc

[EBspeed,WBspeed,EBvolume,WBvolume,EBissue,WBissue,startdatenum,...
    EBoff,EBfail,EBzerospeednonzerocount,EBmissingveh,EBclassmisscount,...
    WBoff,WBfail,WBzerospeednonzerocount,WBmissingveh,WBclassmisscount]...
    =SpeedMatrixReduction(speeddata,milemarker,timeinterval,EB,WB,reportstartday);

method='linear'; % 'spline' or 'linear' or 'cube'   % change this
distanceinterval=0.1; % mile                        % change this

[EBspeednorm]=distanceinterpolation(EBspeed,milemarker,distanceinterval,method,EB);
[WBspeednorm]=distanceinterpolation(WBspeed,milemarker,distanceinterval,method,WB);

weekdays=mod(weekday(startdatenum):weekday(startdatenum)+size(EBspeed,3)-1,7)>1;
weekends=mod(weekday(startdatenum):weekday(startdatenum)+size(EBspeed,3)-1,7)<=1;
AvgWeekday1norm = nanmean(EBspeednorm(:,:,weekdays),3);
AvgWeekend1norm = nanmean(EBspeednorm(:,:,weekends),3);
AvgWeekday1 = nanmean(EBspeed(:,:,weekdays),3);
AvgWeekend1 = nanmean(EBspeed(:,:,weekends),3);
weekdays=mod(weekday(startdatenum):weekday(startdatenum)+size(WBspeed,3)-1,7)>1;
weekends=mod(weekday(startdatenum):weekday(startdatenum)+size(WBspeed,3)-1,7)<=1;
AvgWeekday2norm = nanmean(WBspeednorm(:,:,weekdays),3);
AvgWeekend2norm = nanmean(WBspeednorm(:,:,weekends),3);
AvgWeekday2 = nanmean(WBspeed(:,:,weekdays),3);
AvgWeekend2 = nanmean(WBspeed(:,:,weekends),3);
AverageSpeednorm(2*i-1,:)={[groupname ' dir1'],1,AvgWeekday1norm,AvgWeekend1norm,milemarker(milemarker(:,1)==1,:),milemarker(milemarker(:,1)==3,:)};
AverageSpeednorm(2*i,:)={[groupname ' dir2'],2,AvgWeekday2norm,AvgWeekend2norm,milemarker(milemarker(:,1)==2,:),milemarker(milemarker(:,1)==3,:)};
AverageSpeed(2*i-1,:)={[groupname ' dir1'],1,AvgWeekday1,AvgWeekend1,milemarker(milemarker(:,1)==1,:),milemarker(milemarker(:,1)==3,:)};
AverageSpeed(2*i,:)={[groupname ' dir2'],2,AvgWeekday2,AvgWeekend2,milemarker(milemarker(:,1)==2,:),milemarker(milemarker(:,1)==3,:)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TrafficData=EBspeednorm; 
[eventnum, maxduration, avgduration, maxlength, avglength,filteredeventnum]=performance(TrafficData);
VolumeData=EBvolume;
refspeed = 65;
[volumn,avgdelay] = delay(TrafficData,VolumeData,refspeed,reportstartday,reportendday);

[missing,figurenum]=missingdata(EBspeed,figurenum,EBissue);
title([groupname ' Direction 1'])
% print(['C:\Shuo Wang\study\study\Projects & Papers\IWZ bi-weekly report\MissingPDFs\' groupname ' dir1.pdf'],'-dpdf')
%export_fig missingdata.pdf -append
MissingData(2*i-1,:)={[groupname 'dir1'],missing,milemarker(milemarker(:,1)==1,:)};
performanceTable(2*i-1,:)={groupname,'direction 1',volumn/1000,eventnum,filteredeventnum, maxduration, avgduration, ...
    maxlength, avglength,avgdelay,max(missing(:,1)),prctile(missing(:,1),90),prctile(missing(:,1),70),prctile(missing(:,1),50)};

TrafficData=WBspeednorm; 
[eventnum, maxduration, avgduration, maxlength, avglength,filteredeventnum]=performance(TrafficData);
VolumeData=WBvolume;
refspeed = 65;
[volumn,avgdelay] = delay(TrafficData,VolumeData,refspeed,reportstartday,reportendday);

[missing,figurenum]=missingdata(WBspeed,figurenum,WBissue);
title([groupname ' Direction 2'])
% print(['C:\Shuo Wang\study\study\Projects & Papers\IWZ bi-weekly report\MissingPDFs\' groupname ' dir2.pdf'],'-dpdf')
%export_fig missingdata.pdf -append
MissingData(2*i,:)={[groupname 'dir2'],missing,milemarker(milemarker(:,1)==2,:)};
performanceTable(2*i,:)={groupname,'direction 2',volumn/1000,eventnum,filteredeventnum, maxduration, avgduration, ...
    maxlength, avglength,avgdelay,max(missing(:,1)),prctile(missing(:,1),90),prctile(missing(:,1),70),prctile(missing(:,1),50)};
% end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% figures
% summarize missing data 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minspeed=0; % color bar scale                       % change this
maxspeed=75;% color bar scale                       % change this


TrafficData=EBspeed(:,:,1:end);                  % change this
direction = EB;
figurenum=onemonthplot(TrafficData,startdatenum,minspeed,maxspeed,figurenum,milemarker,direction,groupname,reportstartday,sensornames(2*i,:));
export_fig([y '\5.daily_rawheatmap.pdf'],'-append')

figurenum=dailysensorissue_monthly(EBissue,startdatenum,figurenum,milemarker,direction,groupname,reportstartday,sensornames(2*i,:));
export_fig([y '\daily_sensor_issues.pdf'],'-append')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TrafficData=EBspeednorm(:,:,1:end);                  % change this
direction = EB;
figurenum=onemonthplotnorm(TrafficData,startdatenum,minspeed,maxspeed,figurenum,milemarker,direction,groupname,reportstartday);
export_fig([y '\6.daily_smoothedheatmap.pdf'],'-append')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TrafficData=WBspeed(:,:,1:end);                  % change this
direction = WB;
figurenum=onemonthplot(TrafficData,startdatenum,minspeed,maxspeed,figurenum,milemarker,direction,groupname,reportstartday,sensornames(2*i,:));
export_fig([y '\5.daily_rawheatmap.pdf'],'-append')

figurenum=dailysensorissue_monthly(WBissue,startdatenum,figurenum,milemarker,direction,groupname,reportstartday,sensornames(2*i,:));
export_fig([y '\daily_sensor_issues.pdf'],'-append')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TrafficData=WBspeednorm(:,:,1:end);                  % change this
direction = WB;
figurenum=onemonthplotnorm(TrafficData,startdatenum,minspeed,maxspeed,figurenum,milemarker,direction,groupname,reportstartday);
export_fig([y '\6.daily_smoothedheatmap.pdf'],'-append')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figurenum=onetypeofsensorissue_monthly(EBoff,startdatenum,figurenum,milemarker,EB,groupname,reportstartday,sensornames(2*i,:),[0,0,0],'off');
export_fig([y '\2.daily_sensor_issues_seperate.pdf'],'-append')
figurenum=onetypeofsensorissue_monthly(WBoff,startdatenum,figurenum,milemarker,WB,groupname,reportstartday,sensornames(2*i,:),[0,0,0],'off');
export_fig([y '\2.daily_sensor_issues_seperate.pdf'],'-append')
figurenum=onetypeofsensorissue_monthly(EBfail,startdatenum,figurenum,milemarker,EB,groupname,reportstartday,sensornames(2*i,:),[255,0,0],'fail');
export_fig([y '\2.daily_sensor_issues_seperate.pdf'],'-append')
figurenum=onetypeofsensorissue_monthly(WBfail,startdatenum,figurenum,milemarker,WB,groupname,reportstartday,sensornames(2*i,:),[255,0,0],'fail');
export_fig([y '\2.daily_sensor_issues_seperate.pdf'],'-append')
figurenum=onetypeofsensorissue_monthly(EBzerospeednonzerocount,startdatenum,figurenum,milemarker,EB,groupname,reportstartday,sensornames(2*i,:),[100,200,0],'zerospeednonzerocount');
export_fig([y '\2.daily_sensor_issues_seperate.pdf'],'-append')
figurenum=onetypeofsensorissue_monthly(WBzerospeednonzerocount,startdatenum,figurenum,milemarker,WB,groupname,reportstartday,sensornames(2*i,:),[100,200,0],'zerospeednonzerocount');
export_fig([y '\2.daily_sensor_issues_seperate.pdf'],'-append')
figurenum=onetypeofsensorissue_monthly(EBmissingveh,startdatenum,figurenum,milemarker,EB,groupname,reportstartday,sensornames(2*i,:),[109,196,239],'missingveh');
export_fig([y '\2.daily_sensor_issues_seperate.pdf'],'-append')
figurenum=onetypeofsensorissue_monthly(WBmissingveh,startdatenum,figurenum,milemarker,WB,groupname,reportstartday,sensornames(2*i,:),[109,196,239],'missingveh');
export_fig([y '\2.daily_sensor_issues_seperate.pdf'],'-append')
figurenum=onetypeofsensorissue_monthly(EBclassmisscount,startdatenum,figurenum,milemarker,EB,groupname,reportstartday,sensornames(2*i,:),[255,135,44],'classmisscount');
export_fig([y '\2.daily_sensor_issues_seperate.pdf'],'-append')
figurenum=onetypeofsensorissue_monthly(WBclassmisscount,startdatenum,figurenum,milemarker,WB,groupname,reportstartday,sensornames(2*i,:),[255,135,44],'classmisscount');
export_fig([y '\2.daily_sensor_issues_seperate.pdf'],'-append')

close all;
end
end
%%%%%%%%%%%%%%%%%%%%%%%% join all missing data bar charts to one pdf file
% list4 = dir('C:\Shuo Wang\study\study\Projects & Papers\IWZ bi-weekly report\MissingPDFs\*.pdf');
% a=cell(1,length(list4));
% for i=1:length(list4) 
%     a(i)={['C:\Shuo Wang\study\study\Projects & Papers\IWZ bi-weekly report\MissingPDFs\' list4(i).name]};
% end
% append_pdfs(['C:\Shuo Wang\study\study\Projects & Papers\IWZ bi-weekly report\PDF figures\' 'missing.pdf'], a{:});
%%%%%%%%%%%%%%%%%%%%%%%% weekday and weekend summary heat maps

%load sensornames

AverageSpeednorm=[AverageSpeednorm sensornames];
AverageSpeed=[AverageSpeed sensornames];
MissingData=[MissingData sensornames];

minspeed=0; % color bar scale                       % change this
maxspeed=80;% color bar scale                       % change this    
figurenum=Avgplotnorm(AverageSpeednorm,minspeed,maxspeed,figurenum,reportstartday,reportendday,y);   
figurenum=Avgplot(AverageSpeed,minspeed,maxspeed,figurenum,reportstartday,reportendday,y); 

figurenum=WeekdayRawPlotGenerator(AverageSpeed,minspeed,maxspeed,figurenum,reportstartday,reportendday,y);
%%%%%%%%%%%%%%%%%%%%%%%% summary missing data bar charts
figurenum=MissingSummary(MissingData,figurenum,reportstartday,reportendday,y);
a= {[y '\MissingDataSummary.pdf'];[y '\daily_sensor_issues.pdf']};
append_pdfs([y '\1.sensor_workingcondition.pdf'], a{:});

close all;
%figurenum=performancetrend(test,figurenum);



