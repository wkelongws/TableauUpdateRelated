% use after IWZheatmapReporter

clc;clear;close all;

reportstartday = '2015-11-09';
reportendday = '2015-11-22';

x = 'C:\Users\shuowang\Desktop\Projects & Papers\IWZ bi-weekly report_laptop modified\IWZ_DATA_txt';
y = 'C:\Users\shuowang\Desktop\Projects & Papers\IWZ bi-weekly report_laptop modified\PDF figures';

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

performanceTable = cell (2*length(list1),10);
AverageSpeednorm = cell (2*length(list1),6);
AverageSpeed = cell (2*length(list1),6);
MissingData = cell (2*length(list1),3);
figurenum=1;
for i = 1:length(list1)
%i=6;
    figurenum=1;
milemarker = MileMarkers{i};    

groupname=list1(i).name;
groupname=groupname(1:end-4);

speeddata = IWZread([x '\' list1(i).name]);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TrafficData=EBspeednorm; 
[eventnum, maxduration, avgduration, maxlength, avglength,filteredeventnum]=performance(TrafficData);
VolumeData=EBvolume;
refspeed = 65;
[volumn,avgdelay] = delay(TrafficData,VolumeData,refspeed);

performanceTable(2*i-1,:)={groupname,'direction 1',volumn/1000,eventnum,filteredeventnum, maxduration, avgduration, ...
    maxlength, avglength,avgdelay};

TrafficData=WBspeednorm; 
[eventnum, maxduration, avgduration, maxlength, avglength,filteredeventnum]=performance(TrafficData);
VolumeData=WBvolume;
refspeed = 65;
[volumn,avgdelay] = delay(TrafficData,VolumeData,refspeed);

performanceTable(2*i,:)={groupname,'direction 2',volumn/1000,eventnum,filteredeventnum, maxduration, avgduration, ...
    maxlength, avglength,avgdelay};


end


close all;





% ntime=3;
% mmile=10;
% traveltimelose=TTL(ntime,mmile,speeddist(:,:,1));
% 
% figurenum=figurenum+1;
% figure(figurenum);
% h=bar3(traveltimelose);
% for k = 1:length(h)
%     zdata = get(h(k),'ZData');
%     set(h(k),'CData',zdata,...
%              'FaceColor','interp','EdgeColor','none')
% end