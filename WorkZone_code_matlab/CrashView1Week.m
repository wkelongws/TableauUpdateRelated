clc;clear;close all;

reportstartday = '2016-08-22';
reportendday = '2016-08-28';

x = 'C:\Users\shuowang\Desktop\Projects & Papers\IWZ bi-weekly report_laptop modified\IWZ_DATA_txt';
y = ['S:\(S) SHARE\_project CTRE\1_Active Research Projects\Iowa DOT OTO Support\14_Traffic Critical Projects 2\2016\Weekly Reports\' reportstartday '-' reportendday];

mkdir(y);

list1 = dir([x '\*.txt']);
list2 = dir([x '\*.csv']);

fid = fopen([x '\' list2(1).name]);
C = textscan(fid, '%s %f %f %f %f %s %s %s %s %f %f %f %s %f %f %s', 'Delimiter',',','HeaderLines', 1);
fclose(fid);
[~,~,uniqueindex]=unique(C{9});
accumindex=accumarray(uniqueindex(:),1);
bb=[C{2} C{3} C{4} C{5} C{10} C{11}];
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

%% crash data loading
% file = 'C:\Users\shuowang\Desktop\Projects & Papers\IWZ bi-weekly report_laptop modified\Crashes\Council Bluffs I-29.csv';
file = 'C:\Users\shuowang\Desktop\Projects & Papers\IWZ bi-weekly report_laptop modified\Crashes\Council Bluffs I-80.csv';
fid = fopen(file);
% C = textscan(fid, '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', 'Delimiter',',','HeaderLines', 2);
C = textscan(fid, '%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q', 'Delimiter',',','HeaderLines', 1);
fclose(fid);
ReportID = C{2};
Date = cellfun(@str2num,C{3})+693960;
Time = cellfun(@str2num,C{4});
Location = C{11};
Direction = C{9};
LightCondition = C{13};
Weather = C{14};
Surface = C{15};
InWorkZone = C{16};
WorkZoneRelate = C{17};
DriverCondition = C{18};
Injury = C{19};
Lat = cellfun(@str2num,C{20});
Long = cellfun(@str2num,C{21});
Narrative = C{22};
hour = floor(Time*24);
Minute5 = floor(12*(Time*24-floor(Time*24)));
CrashInfo = [ReportID Location LightCondition Weather Surface InWorkZone WorkZoneRelate DriverCondition Injury Narrative C{20} C{21}];
IDs=(1:length(ReportID))';
Crashdirection = [IDs zeros(length(ReportID),1)];
Crashdirection(~cellfun(@isempty,strfind(lower(Direction),'wb')),2)=2;%for I-80
Crashdirection(~cellfun(@isempty,strfind(lower(Direction),'eb')),2)=1;%for I-80
% Crashdirection(~cellfun(@isempty,strfind(lower(Direction),'nb')),2)=1;%for I-29
% Crashdirection(~cellfun(@isempty,strfind(lower(Direction),'sb')),2)=2;%for I-29
Crashes = [Crashdirection Date hour Minute5 Lat Long];
% Crashes(~cellfun(@isempty,strfind(lower(Location),'ramp')),:)=[];
Crashes(Crashes(:,2)==0,:)=[];
%%
% i=7: I-29; i=8: I-80 Council Bluffs
for i = 8

    figurenum=1;
    milemarker = MileMarkers{i};
    milemarker = sortrows(milemarker,6);
    coordinates = milemarker(:,[3 4 end]);
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
        =SpeedMatrixReduction(speeddata,milemarker(:,[1 2 5 6]),timeinterval,EB,WB,reportstartday,reportendday);

    method='linear'; % 'spline' or 'linear' or 'cube'   % change this
    distanceinterval=0.1; % mile                        % change this

    [EBspeednorm]=distanceinterpolation(EBspeed,milemarker(:,[1 2 5 6]),distanceinterval,method,EB);
    [WBspeednorm]=distanceinterpolation(WBspeed,milemarker(:,[1 2 5 6]),distanceinterval,method,WB);

    minspeed=0; % color bar scale                       % change this
    maxspeed=75;% color bar scale                       % change this


    %%
    % direction 1
        milemarker_dir1=milemarker(milemarker(:,1)==1,:);
        % crashes on direction 1
        Crashes_dir1=Crashes(Crashes(:,2)==1,:);
        LL_crash_dir1 = Crashes_dir1(:,[1 6 7]);
        MM_crash_dir1 = LL2MM (LL_crash_dir1,milemarker_dir1,distanceinterval);
        Crashes_dir1=[Crashes_dir1 MM_crash_dir1(:,4:5)];

        % speed data on direction 1
        TrafficData=EBspeednorm;                  % change this
        direction = EB;    
        % plot
        figurenum=oneWeekCrashDisplay(TrafficData,startdatenum,minspeed,maxspeed,...
            figurenum,milemarker(:,[1 2 5 6]),direction,groupname,Crashes_dir1,CrashInfo,reportstartday);
        export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_SmoothedHeatMapWithCrash.pdf'],'-append')
        close all;

        % direction 2
        milemarker_dir2=milemarker(milemarker(:,1)==2,:);
        % crashes on direction 2
        Crashes_dir2=Crashes(Crashes(:,2)==2,:);
        LL_crash_dir2 = Crashes_dir2(:,[1 6 7]);
        MM_crash_dir2 = LL2MM (LL_crash_dir2,milemarker_dir2,distanceinterval);
        Crashes_dir2=[Crashes_dir2 MM_crash_dir2(:,4:5)];
        % speed data on direction 2
        TrafficData=WBspeednorm;                  % change this
        direction = WB;    
        % plot
        figurenum=oneWeekCrashDisplay(TrafficData,startdatenum,minspeed,maxspeed,...
            figurenum,milemarker(:,[1 2 5 6]),direction,groupname,Crashes_dir2,CrashInfo,reportstartday); 
        export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_SmoothedHeatMapWithCrash.pdf'],'-append')
        close all;
    end
end

close all;



