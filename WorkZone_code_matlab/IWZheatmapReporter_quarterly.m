clc;clear;close all;

reportstartday = '2016-01-01';
reportendday = '2016-03-31';

x = 'C:\Users\shuowang\Desktop\Projects & Papers\IWZ bi-weekly report_laptop modified\IWZ_DATA_txt';
y = ['C:\Users\shuowang\Desktop\Projects & Papers\' reportstartday '-' reportendday];
% rmdir(y);
mkdir(y);

list1 = dir([x '\*.txt']);
list2 = dir([x '\*.csv']);

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


AverageSpeednorm = cell (2*length(list1),6);
AverageSpeed = cell (2*length(list1),6);
MissingData = cell (2*length(list1),3);
figurenum=1;

topheader={'IWZ','Direction','1. number of days','2. number of events','3. number of daytime events','4. number of days when events happened',...
    '5. average duration of each event','6. median duration of each event','7. average queue length',...
    '8. average maximum queue length of each event','9. median maximum queue length of each event',...
    '10. max maximum queue length of each event','11.percentage of queue > 1 mile','12.amount of traffic that encounters a queue',...
    '13.total traffic','14.percentage of traffic that encounters a queue','15.percentage of time that encounters a queue',...
    '16.total delay','17.total delay per day','18.average delay per vehicle','19.maximum delay','20.total delay when queue is present',...
    '21.percentage of delay caused by queue','22.avg delay when queue is present','23.percent of vehicles experiencing delay > 5 min',...
    '24.percent of vehicles experiencing delay > 10 min','25.percent of vehicles in queue experiencing delay > 5 min',...
    '26.percent of vehicles in queue experiencing delay > 10 min'};

IWZ = [1 2 3 4 7 8 9 10 11 12];
% IWZ = 13;
leftheader=cell(1+2*length(IWZ),2);
performanceTable = cell (1+2*length(IWZ),28);
performanceTable(1,:)=topheader;
for i = IWZ
%     i = 1:length(list1)
%i=6;
    figurenum=1;
milemarker = MileMarkers{i};    
groupname=list1(i).name;
groupname=groupname(1:end-4);   

mkdir([y '\' groupname])

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% figures

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minspeed=0; % color bar scale                       % change this
maxspeed=75;% color bar scale                       % change this
eventspeed=40;  %mph
eventamplifier=50;
speedlimit=70;

TrafficData=EBspeed(:,:,1:end);                  % change this
direction = EB;
% figurenum=oneweekplot(TrafficData,startdatenum,minspeed,maxspeed,figurenum,milemarker,direction,groupname,reportstartday,sensornames(2*i,:));
% export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_RawHeatMap.pdf'],'-append')

% figurenum=dailysensorissue_oneweek(EBissue,startdatenum,figurenum,milemarker,direction,groupname,reportstartday,sensornames(2*i,:));
% export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_SensorIssues.pdf'],'-append')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TrafficData=EBspeednorm(:,:,1:end);                  % change this
direction = EB;
% figurenum=oneweekplotnorm(TrafficData,startdatenum,minspeed,maxspeed,figurenum,milemarker,direction,groupname,reportstartday);
% export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_SmoothedHeatMap.pdf'],'-append')

    [performancemetrics1,figurenum]...
        =PerformanceMeasure(eventamplifier,TrafficData,EBvolume,figurenum,eventspeed,...
        timeinterval,distanceinterval,startdatenum,speedlimit,direction,milemarker,groupname);
%     [figurenum,cellevent,spreadsheet]=eventplot_Q(eventamplifier,...
%         TrafficData,EBvolume(:,:,:),EBspeed(:,:,:),figurenum,eventspeed,timeinterval,...
%         distanceinterval,startdatenum,speedlimit,direction,milemarker,groupname,performancemetrics1,y,reportstartday,reportendday);
%     close all;
%     
%     [figurenum]...
%         =eventplotcontinue_Q(eventamplifier,TrafficData,EBvolume,figurenum,eventspeed,...
%         timeinterval,startdatenum,direction,milemarker,groupname,y,reportstartday,reportendday);
%     close all;
%     [figurenum,celleventdaytime,spreadsheet]...
%         =eventplotdaytime_Q(eventamplifier,TrafficData,EBvolume,EBspeed(:,:,:),figurenum,eventspeed,...
%         timeinterval,distanceinterval,startdatenum,speedlimit,direction,milemarker,groupname,y,reportstartday,reportendday);
%     close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TrafficData=WBspeed(:,:,1:end);                  % change this
direction = WB;
% figurenum=oneweekplot(TrafficData,startdatenum,minspeed,maxspeed,figurenum,milemarker,direction,groupname,reportstartday,sensornames(2*i,:));
% export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_RawHeatMap.pdf'],'-append')

% figurenum=dailysensorissue_oneweek(WBissue,startdatenum,figurenum,milemarker,direction,groupname,reportstartday,sensornames(2*i,:));
% export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_SensorIssues.pdf'],'-append')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TrafficData=WBspeednorm(:,:,1:end);                  % change this
direction = WB;
% figurenum=oneweekplotnorm(TrafficData,startdatenum,minspeed,maxspeed,figurenum,milemarker,direction,groupname,reportstartday);
% export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_SmoothedHeatmap.pdf'],'-append')

    [performancemetrics2,figurenum]...
        =PerformanceMeasure(eventamplifier,TrafficData,WBvolume,figurenum,eventspeed,...
        timeinterval,distanceinterval,startdatenum,speedlimit,direction,milemarker,groupname);
%     [figurenum,cellevent,spreadsheet]=eventplot_Q(eventamplifier,...
%         TrafficData,WBvolume(:,:,:),WBspeed(:,:,:),figurenum,eventspeed,timeinterval,...
%         distanceinterval,startdatenum,speedlimit,direction,milemarker,groupname,performancemetrics2,y,reportstartday,reportendday);
%     close all;
%     
%     [figurenum]...
%     =eventplotcontinue_Q(eventamplifier,TrafficData,WBvolume,figurenum,eventspeed,...
%     timeinterval,startdatenum,direction,milemarker,groupname,y,reportstartday,reportendday);
%     close all;
%     [figurenum,celleventdaytime,spreadsheet]...
%     =eventplotdaytime_Q(eventamplifier,TrafficData,WBvolume,WBspeed(:,:,:),figurenum,eventspeed,...
%     timeinterval,distanceinterval,startdatenum,speedlimit,direction,milemarker,groupname,y,reportstartday,reportendday);
%     close all;

close all;
end

index= find(i==IWZ);
leftheader(1+2*index-1:1+2*index,:)=[{groupname},{'1'};{groupname},{'2'}];

performanceTable(1+2*index-1,3:end)=num2cell(performancemetrics1);
performanceTable(1+2*index,3:end)=num2cell(performancemetrics2);
performanceTable(2:end,1:2)=leftheader(2:end,:);
end

cell2csv([y '\performance_table_' reportstartday '-' reportendday '.csv'], performanceTable)

close all;




