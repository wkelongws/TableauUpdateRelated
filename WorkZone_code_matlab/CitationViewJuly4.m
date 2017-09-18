clc;clear;close all;

reportstartday = '2016-07-04';
reportendday = '2016-07-04';

x = 'C:\Users\shuowang\Desktop\Projects & Papers\IWZ bi-weekly report_laptop modified\IWZ_DATA_txt';
y = ['S:\(S) SHARE\_project CTRE\1_Active Research Projects\Iowa DOT OTO Support\14_Traffic Critical Projects 2\2016\Weekly Reports\' reportstartday '-' reportendday];

mkdir(y);

list2 = dir([x '\*.csv']);

fid = fopen([x '\' list2(1).name]);
C = textscan(fid, '%s %f %f %f %f %s %s %s %s %f %f %f %s %f %f %s', 'Delimiter',',','HeaderLines', 1);
fclose(fid);
[IWZgroup,~,uniqueindex]=unique(C{9});
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



%% citation data loading
list3 = dir('C:\Users\shuowang\Desktop\Projects & Papers\IWZ bi-weekly report_laptop modified\Citations\IWZ separated\*.csv');

i=7;
% i = 1:length(list3)

    file=list3(i).name;
    groupname=file(1:end-4);   

fid = fopen(['C:\Users\shuowang\Desktop\Projects & Papers\IWZ bi-weekly report_laptop modified\Citations\IWZ separated\' file]);
C = textscan(fid, '%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q', 'Delimiter',',','HeaderLines', 1);
fclose(fid);

Date = cellfun(@str2num,C{3})+693960;
Time = cellfun(@str2num,C{18});
Road = C{16};
Direction = C{8};
lat = C{10};
long = C{13};
Lat = cellfun(@str2num,C{10});
Long = cellfun(@str2num,C{13});
County = C{4};
Citationnumber1 = C{1};
Description1 = C{6};
Citationnumber2 = C{2};
Age = C{5};
Gender = C{9};
Description2 = C{7};
Licensestate = C{12};
LicensePlate = C{11};
Roadconstruction = cellfun(@str2num,C{15});

hour = floor(Time*24);
Minute5 = floor(12*(Time*24-floor(Time*24)));

% CitationInfo = [ReportID Location LightCondition Weather Surface InWorkZone WorkZoneRelate DriverCondition Injury Narrative];
CitationInfo = [Age Gender Description1 Description2 lat long Citationnumber1];
IDs=(1:length(Citationnumber1))';

Citationdirection = [IDs zeros(length(Citationnumber1),1)];
Citationdirection(~cellfun(@isempty,strfind(lower(Direction),'sb')),2)=2;%for I-80
Citationdirection(~cellfun(@isempty,strfind(lower(Direction),'nb')),2)=1;%for I-80

Citations = [Citationdirection Date hour Minute5 Lat Long];
% Crashes(~cellfun(@isempty,strfind(lower(Location),'ramp')),:)=[];
Citations(Citations(:,2)==0,:)=[];

%%
    figurenum=1;
          
    milemarker = MileMarkers{strcmp(IWZgroup,groupname)};
    milemarker = sortrows(milemarker,6);
    coordinates = milemarker(:,[3 4 end]);
    mkdir([y '\' groupname])
    speeddata = IWZread([x '\' groupname '.txt']);

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


    
    % direction 1
        milemarker_dir1=milemarker(milemarker(:,1)==1,:);
        % crashes on direction 1
        Citations_dir1=Citations(Citations(:,2)==1,:);
        LL_citation_dir1 = Citations_dir1(:,[1 6 7]);
        MM_citation_dir1 = LL2MM (LL_citation_dir1,milemarker_dir1,distanceinterval);
        Citations_dir1=[Citations_dir1 MM_citation_dir1(:,4:5)];

        % speed data on direction 1
        TrafficData=EBspeednorm;                  % change this
        direction = EB;    
        % plot
        figurenum=oneDayCitationDisplay(TrafficData,startdatenum,minspeed,maxspeed,...
            figurenum,milemarker(:,[1 2 5 6]),direction,groupname,Citations_dir1,CitationInfo,reportstartday);
        export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_SmoothedHeatMapWithCrash.pdf'],'-append')
        close all;

        % direction 2
        milemarker_dir2=milemarker(milemarker(:,1)==2,:);
        % crashes on direction 2
        Crashes_dir2=Citations(Citations(:,2)==2,:);
        LL_crash_dir2 = Crashes_dir2(:,[1 6 7]);
        MM_crash_dir2 = LL2MM (LL_crash_dir2,milemarker_dir2,distanceinterval);
        Crashes_dir2=[Crashes_dir2 MM_crash_dir2(:,4:5)];
        % speed data on direction 2
        TrafficData=WBspeednorm;                  % change this
        direction = WB;    
        % plot
        figurenum=oneDayCitationDisplay(TrafficData,startdatenum,minspeed,maxspeed,...
            figurenum,milemarker(:,[1 2 5 6]),direction,groupname,Crashes_dir2,CitationInfo,reportstartday); 
        export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_SmoothedHeatMapWithCrash.pdf'],'-append')
        close all;
    end







%%
% i=5: I-29; i=6: I-80 Council Bluffs

close all;



