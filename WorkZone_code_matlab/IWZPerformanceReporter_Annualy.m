clc;clear;close all;

days = {'2016-01-01','2016-12-31';
        '2016-06-07','2016-09-29';
        '2016-01-01','2016-12-31';
        '2016-04-26','2016-11-01';
        '2016-05-27','2016-11-29';
        '2016-01-01','2016-12-31';
        '2016-09-01','2016-10-13';
        '2016-01-01','2016-12-31';
        '2016-01-01','2016-12-31';
        '2016-01-01','2016-12-31';
        '2016-06-01','2016-11-10';
        '2016-04-07','2016-09-26';
        '2016-01-01','2016-12-31';
        '2016-01-01','2016-12-31';
        '2016-05-05','2016-08-31';
        '2016-01-01','2016-12-31';
        '2016-05-05','2016-10-28';
        '2016-01-01','2016-12-31';
        '2016-01-01','2016-12-31';
        '2016-01-01','2016-12-31'};

reportstartday = '2016-01-01'; 
reportendday = '2016-12-31';
%IWZ = 20;

x = 'C:\Users\shuowang\Desktop\Projects & Papers\IWZ bi-weekly report_laptop modified\IWZ_DATA_txt';
y = ['S:\(S) SHARE\_project CTRE\1_Active Research Projects\Iowa DOT OTO Support\14_Traffic Critical Projects 2\2016\AnnualReport\2016'];
% rmdir(y);
mkdir(y);

list1 = dir([x '\*.txt']);
list2 = dir([x '\*.csv']);

fid = fopen([x '\' list2(1).name]);
C = textscan(fid, '%s %f %f %f %f %s %s %s %s %f %f %f %s %f %f %s', 'Delimiter',',','HeaderLines', 1);
fclose(fid);
[~,~,uniqueindex]=unique(C{9});
accumindex=accumarray(uniqueindex(:),1);
bb=[C{2} C{3} C{10} C{11}];
MileMarkers = mat2cell(bb,accumindex,size(bb,2));
celldata = [mat2cell(C{10},accumindex,size(C{10},2)) mat2cell(C{6},accumindex,size(C{6},2))];

dir_order = mat2cell([C{1} cellfun(@num2str,mat2cell(C{2},ones(numel(C{2}),1),1),'UniformOutput',false) C{6}],accumindex,size([C{1} cellfun(@num2str,mat2cell(C{2},ones(numel(C{2}),1),1),'UniformOutput',false) C{6}],2));

for i=1:size(MileMarkers,1)
    [aaa,bbb]=sortrows(MileMarkers{i,1},4);
    MileMarkers(i,1)={aaa};
    yyy=celldata{i,1};
    xxx=celldata{i,2};
    celldata(i,1)={yyy(bbb)};
    celldata(i,2)={xxx(bbb)};
    zzz=dir_order{i};
    dir_order(i)={zzz(bbb,:)};
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
    '26.percent of vehicles in queue experiencing delay > 10 min','27.95 percentile of delay for all times','28.95 percentile of delay when there is delay'};

%IWZ = 14;
IWZ = 1:length(list1);
leftheader=cell(1+2*length(IWZ),2);
performanceTable = cell (1+2*length(IWZ),30);
performanceTable(1,:)=topheader;
for i = IWZ
     reportstartday = days{i,1};
     reportendday = days{i,2};
%i=6;
    figurenum=1;
    milemarker = MileMarkers{i};    
    groupname=list1(i).name;
    groupname=groupname(1:end-4);   

    mkdir([y '\' groupname])

    [speeddata,csvdata] = IWZread([x '\' list1(i).name]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% write data into csv. disable when unwanted %%%%%%%%%%%%%%
% [~,ddd]=cellfun(@weekday,csvdata(:,2),'UniformOutput',false);
% csvdata=[csvdata,ddd];
% % csvfilename=['S:\(S) SHARE\_project CTRE\1_Active Research Projects\Iowa DOT OTO Support\14_Traffic Critical Projects 2\2016\IWZ Data for Tableau\' groupname '.csv'];
% dirorder=dir_order{i};
% dirorder(strcmp('',dirorder(:,1)),:)=[];
% % 
% % nrows = size(csvdata,1);
% % fid = fopen(csvfilename,'a');
% % for aa = 1 : nrows
% %     
% %     ind=find(strcmp(csvdata{aa,1},dirorder(:,3)));
% %     
% %     fprintf(fid,'%s,%s,%f,%f,%f,%f,%f,%f,%s,%s,%s,%s,%s,%s\r\n', csvdata{aa,1},csvdata{aa,2},...
% %         csvdata{aa,3},csvdata{aa,4},csvdata{aa,5},csvdata{aa,6},csvdata{aa,7},...
% %         csvdata{aa,8},csvdata{aa,9},[csvdata{aa,2} ' ' num2str(csvdata{aa,3}) ':' num2str(csvdata{aa,4}*5) ':00'],...
% %         groupname,dirorder{ind,1},dirorder{ind,2},num2str(ind));
% % end
% % fclose(fid);
% % csvfilename=['S:\(S) SHARE\_project CTRE\1_Active Research Projects\Iowa DOT OTO Support\14_Traffic Critical Projects 2\2016\IWZ Data for Tableau\CSV Tableau All in One\' groupname '.csv'];
% % nrows = size(csvdata,1);
% % fid = fopen(csvfilename,'a');
% % for aa = 1 : nrows
% %     
% %     ind=find(strcmp(csvdata{aa,1},dirorder(:,3)));
% %     
% %     fprintf(fid,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\r\n', csvdata{aa,1},csvdata{aa,2},...
% %         num2str(csvdata{aa,3}),num2str(csvdata{aa,4}),num2str(csvdata{aa,5}),num2str(csvdata{aa,6}),num2str(csvdata{aa,7}),...
% %         num2str(csvdata{aa,8}),csvdata{aa,9},[csvdata{aa,2} ' ' num2str(csvdata{aa,3}) ':' num2str(csvdata{aa,4}*5) ':00'],...
% %         groupname,dirorder{ind,1},dirorder{ind,2},num2str(ind));
% % end
% % fclose(fid);
% csvfilename='S:\(S) SHARE\_project CTRE\1_Active Research Projects\Iowa DOT OTO Support\14_Traffic Critical Projects 2\2016\IWZ Data for Tableau\CSV Tableau All in One\Historical Raw.csv';
% nrows = size(csvdata,1);
% fid = fopen(csvfilename,'a');
% for aa = 1 : nrows
%     
%     ind=find(strcmp(csvdata{aa,1},dirorder(:,3)));
%     
%     fprintf(fid,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\r\n', csvdata{aa,1},csvdata{aa,2},...
%         num2str(csvdata{aa,3}),num2str(csvdata{aa,4}),num2str(csvdata{aa,5}),num2str(csvdata{aa,6}),num2str(csvdata{aa,7}),...
%         num2str(csvdata{aa,8}),csvdata{aa,9},[csvdata{aa,2} ' ' num2str(csvdata{aa,3}) ':' num2str(csvdata{aa,4}*5) ':00'],...
%         groupname,dirorder{ind,1},dirorder{ind,2},num2str(ind));
% end
% fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(speeddata);
    %     plot(i,1,'r*');
else    

    EB=1; % NB detector ID in column 1                  % change this
    WB=2; % SB detector ID in column 2                  % change this
    timeinterval=5; % aggregated time interval (min)    % changed to 15 30 60, etc

    [EBspeed,WBspeed,EBvolume,WBvolume,EBissue,WBissue,startdatenum,...
        EBoff,EBfail,EBzerospeednonzerocount,EBmissingveh,EBclassmisscount,...
        WBoff,WBfail,WBzerospeednonzerocount,WBmissingveh,WBclassmisscount]...
        =SpeedMatrixReduction(speeddata,milemarker,timeinterval,EB,WB,reportstartday,reportendday);

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
    %figurenum=oneweekplot(TrafficData,startdatenum,minspeed,maxspeed,figurenum,milemarker,direction,groupname,reportstartday,sensornames(2*i,:));
    %export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_RawHeatMap.pdf'],'-append')

    %figurenum=dailysensorissue_oneweek(EBissue,startdatenum,figurenum,milemarker,direction,groupname,reportstartday,sensornames(2*i,:));
    %export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_SensorIssues.pdf'],'-append')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TrafficData=EBspeednorm(:,:,1:end);                  % change this
    direction = EB;
    %figurenum=oneweekplotnorm(TrafficData,startdatenum,minspeed,maxspeed,figurenum,milemarker,direction,groupname,reportstartday);
    %export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_SmoothedHeatMap.pdf'],'-append')

    [performancemetrics1,figurenum]...
        =PerformanceMeasure(eventamplifier,TrafficData,EBvolume,figurenum,eventspeed,...
        timeinterval,distanceinterval,startdatenum,speedlimit,direction,milemarker,groupname);
    %[figurenum,cellevent,spreadsheet]=eventplot(eventamplifier,...
    %    TrafficData,EBvolume(:,:,:),EBspeed(:,:,:),figurenum,eventspeed,timeinterval,...
    %    distanceinterval,startdatenum,speedlimit,direction,milemarker,groupname,performancemetrics1,y,reportstartday,reportendday);
    close all;
    
    %[figurenum]...
    %    =eventplotcontinue(eventamplifier,TrafficData,EBvolume,figurenum,eventspeed,...
    %    timeinterval,startdatenum,direction,milemarker,groupname,y,reportstartday,reportendday);
    close all;
    %[figurenum,celleventdaytime,spreadsheet]...
    %    =eventplotdaytime(eventamplifier,TrafficData,EBvolume,EBspeed(:,:,:),figurenum,eventspeed,...
    %    timeinterval,distanceinterval,startdatenum,speedlimit,direction,milemarker,groupname,y,reportstartday,reportendday);
    close all;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TrafficData=WBspeed(:,:,1:end);                  % change this
    direction = WB;
    %figurenum=oneweekplot(TrafficData,startdatenum,minspeed,maxspeed,figurenum,milemarker,direction,groupname,reportstartday,sensornames(2*i,:));
    %export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_RawHeatMap.pdf'],'-append')

    %figurenum=dailysensorissue_oneweek(WBissue,startdatenum,figurenum,milemarker,direction,groupname,reportstartday,sensornames(2*i,:));
    %export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_SensorIssues.pdf'],'-append')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TrafficData=WBspeednorm(:,:,1:end);                  % change this
    direction = WB;
    %figurenum=oneweekplotnorm(TrafficData,startdatenum,minspeed,maxspeed,figurenum,milemarker,direction,groupname,reportstartday);
    %export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_SmoothedHeatmap.pdf'],'-append')

    [performancemetrics2,figurenum]...
        =PerformanceMeasure(eventamplifier,TrafficData,WBvolume,figurenum,eventspeed,...
        timeinterval,distanceinterval,startdatenum,speedlimit,direction,milemarker,groupname);
    %[figurenum,cellevent,spreadsheet]=eventplot(eventamplifier,...
    %    TrafficData,WBvolume(:,:,:),WBspeed(:,:,:),figurenum,eventspeed,timeinterval,...
    %    distanceinterval,startdatenum,speedlimit,direction,milemarker,groupname,performancemetrics2,y,reportstartday,reportendday);
    close all;
    
    %[figurenum]...
    %=eventplotcontinue(eventamplifier,TrafficData,WBvolume,figurenum,eventspeed,...
    %timeinterval,startdatenum,direction,milemarker,groupname,y,reportstartday,reportendday);
    close all;
    %[figurenum,celleventdaytime,spreadsheet]...
    %=eventplotdaytime(eventamplifier,TrafficData,WBvolume,WBspeed(:,:,:),figurenum,eventspeed,...
    %timeinterval,distanceinterval,startdatenum,speedlimit,direction,milemarker,groupname,y,reportstartday,reportendday);
    close all;

    close all;
end

index= find(i==IWZ);
leftheader(1+2*index-1:1+2*index,:)=[{groupname},{'1'};{groupname},{'2'}];

performanceTable(1+2*index-1,3:end)=num2cell(performancemetrics1);
performanceTable(1+2*index,3:end)=num2cell(performancemetrics2);
performanceTable(2:end,1:2)=leftheader(2:end,:);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% write performance measure into CSV. disable when unwanted
cell2csv([y '\performance_table.csv'], performanceTable)

%% performance summary
fid = fopen('S:\(S) SHARE\_project CTRE\1_Active Research Projects\Iowa DOT OTO Support\14_Traffic Critical Projects 2\2016\AnnualReport\performance_table_weekly_2016.csv');
% fid = fopen('S:\(S) SHARE\_project CTRE\1_Active Research Projects\Iowa DOT OTO Support\14_Traffic Critical Projects 2\2016\Weekly Reports\performance_table.csv');
C = textscan(fid, '%s %s %s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter',',','HeaderLines', 1);
fclose(fid);
period=C{2};
[~,~,uniqueindex]=unique(period);
currentperiod=uniqueindex==max(uniqueindex);
name=C{3};
name(currentperiod)=[];
dir=C{4};
dir(currentperiod)=[];
IDs=cell(size(name,1),1);
for i=1:size(IDs,1)
    IDs{i}=[name{i} dir{i}];
end
Cdata=[C{5} C{6} C{7} C{8} C{9} C{10} C{11} C{12} C{13} C{14} C{15} C{16} C{17} C{18} C{19} C{20} C{21} C{22} C{23} C{24} C{25} C{26} C{27} C{28} C{29} C{30}];
Cdata(currentperiod,:)=[];
[~,~,uniqueindex]=unique(IDs);
header=topheader(3:end);

fid1 = fopen('S:\(S) SHARE\_project CTRE\1_Active Research Projects\Iowa DOT OTO Support\14_Traffic Critical Projects 2\2016\AnnualReport\performance_table_summary.csv','w');
% fid1 = fopen('S:\(S) SHARE\_project CTRE\1_Active Research Projects\Iowa DOT OTO Support\14_Traffic Critical Projects 2\2016\Weekly Reports\performance_table_summary.csv','w');
fprintf(fid1,'%s,%s,%s,','ID','IWZ','Direction');
for i=1:numel(header)
    fprintf(fid1,'%s,%s,%s,%s,%s,%s,',['min_' header{i}],['max_' header{i}],...
        ['mean_' header{i}],['median_' header{i}],['25prctile_' header{i}],['75prctile_' header{i}]);
end
fprintf(fid1,'\r\n');
for i=1:max(uniqueindex)
    data=Cdata(uniqueindex==i,:);
    sensorname=unique(name(uniqueindex==i));
    sensordir=unique(dir(uniqueindex==i));
    fprintf(fid1,'%f,%s,%s,',i,sensorname{:},sensordir{:});
    data_min=min(data);
    data_max=max(data);
    data_mean=nanmean(data,1);
    %data_median=nanstd(data,1);
    data_median=prctile(data,50,1);
    data_25=prctile(data,25,1);
    data_75=prctile(data,75,1);
    for k=1:numel(data_min)
        fprintf(fid1,'%f,%f,%f,%f,%f,%f,',data_min(k),data_max(k),data_mean(k),...
            data_median(k),data_25(k),data_75(k));
    end
    fprintf(fid1,'\r\n');
end
fclose(fid1);
