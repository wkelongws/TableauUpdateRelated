% performance measure
function [performancemetrics,figurenum]...
    =PerformanceMeasure(eventamplifier,TrafficData,volume,figurenum,eventspeed,...
    timeinterval,distanceinterval,startdatenum,speedlimit,direction,milemarker,groupname)

%% initialization
% workzone boundary location calculation (wzloc)
wzmarker = milemarker(milemarker(:,2)==1,4);
milemarker = sortrows(milemarker,4);
milemarker=milemarker(milemarker(:,1)==direction,4);
wzloc = zeros(size(wzmarker,1),size(wzmarker,2));
for i = 1:length(wzmarker)
    wzloc(i)=(wzmarker(i)-milemarker(1))/(milemarker(end)-milemarker(1))*(size(TrafficData,1)-1)+1;
end

% expand the data matrix from 3D to 2D
rawspreadsheet=nan(size(TrafficData,1),size(TrafficData,3)*size(TrafficData,2));
volumespreadsheet=nan(size(volume,1),size(volume,3)*size(volume,2));
for i=1:size(TrafficData,3)
    rawspreadsheet(:,(i-1)*size(TrafficData,2)+1:i*size(TrafficData,2),:)=TrafficData(:,:,i);
    volumespreadsheet(:,(i-1)*size(volume,2)+1:i*size(volume,2),:)=volume(:,:,i);
end
spreadsheet=rawspreadsheet;

% keep low speed and convert others to 0
for j=1:size(spreadsheet,2)
    for i=1:size(spreadsheet,1)
        if isnan(spreadsheet(i,j))||spreadsheet(i,j)>=eventspeed
            spreadsheet(i,j)=0;
        else 
        end
    end
end

% add row sum, event id and sequential label
columnsum=sum(spreadsheet,1);
label=(1:size(spreadsheet,2));
eventno=nan(1,size(spreadsheet,2));
xcoordinate=ones(1,size(spreadsheet,2));

eventno(1)=0;
for i=2:size(spreadsheet,2)
    if columnsum(i)>0 && columnsum(i-1)==0
        eventno(i)=eventno(i-1)+1;
    else eventno(i)=eventno(i-1);
    end
end
xcoordinate(columnsum==0)=1/eventamplifier;
xcoordinate=cumsum(xcoordinate);

spreadsheet=[spreadsheet;columnsum;eventno;label;xcoordinate];
spreadsheet1=spreadsheet;
spreadsheet2=spreadsheet;
spreadsheet2(:,spreadsheet2(end-3,:)==0)=[]; 
spreadsheet1(:,spreadsheet1(end-3,:)>0)=[]; 

% convert to cell format, events in separate cells
[~,~,uniqueIndex] = unique(spreadsheet2(end-2,:));
cellevent = mat2cell(spreadsheet2,size(spreadsheet2,1),accumarray(uniqueIndex(:),1));
[~,~,uniqueIndex] = unique(spreadsheet1(end-2,:));
cellnonevent = mat2cell(spreadsheet1,size(spreadsheet1,1),accumarray(uniqueIndex(:),1));



% meanspeed=nanmean(nanmean(TrafficData,1),3);
% meanvolume=nanmean(nanmean(volume,1),3);
volume=nanmean(volume,1);

actualspeed=TrafficData(1:end,:,:);
actualtime=0.1/actualspeed*60;
targettime=0.1/speedlimit*60*ones(size(actualspeed));
delay=actualtime-targettime;
delay=nansum(delay,1);  % in min
delay(delay<0)=0;
totalvolume=sum(nansum(nanmean(volume,1)));
totaldelay=sum(sum(nansum(delay.*volume/60)));   % veh-hours

reshape_delay = reshape(delay,[],1);
reshape_volume = reshape(volume,[],1);
nan_where = isnan(reshape_delay);
reshape_delay(nan_where)=[];
reshape_volume(nan_where)=[];
nan_where = isnan(reshape_volume);
reshape_delay(nan_where)=[];
reshape_volume(nan_where)=[];

%delay_percentile_all = wprctile(reshape_delay,[5 25 50 75 95],reshape_volume);

zero_where = reshape_delay==0;
reshape_delay(zero_where)=[];
reshape_volume(zero_where)=[];

%delay_percentile_isdelay = wprctile(reshape_delay,[5 25 50 75 95],reshape_volume);

avgdelay=totaldelay/totalvolume*60;   % min
maxdelay=max(max(nansum(delay,1))); % min
volume1=nanmean(volume,1);
percentvolumehighdelay5min=sum(nansum(volume1(nansum(delay,1)>5)))/totalvolume;
percentvolumehighdelay10min=sum(nansum(volume1(nansum(delay,1)>10)))/totalvolume;


%%
numberofdays=size(TrafficData,3);
numevent=size(cellevent,2);
numdayevent=0;
%numfilteredevent=0;


% round 1 find stats and apply filter
% lowestspeed <= 36
% Duration > 10min
% length_impact > 0.8
% Total vehicles >= 100

% initialize all containers
duration=       zeros(1,size(cellevent,2));
length_impact = zeros(1,size(cellevent,2));
total_veh =     zeros(1,size(cellevent,2));
lowest_speed =  zeros(1,size(cellevent,2));

avgmaxqueue=    zeros(1,size(cellevent,2));
numeventday=    nan(1,size(cellevent,2));     
queue=          cell(1,size(cellevent,2));   
queuedvolume=0;
queueddelay=0;
queuedvolumehighdelay5min=0;
queuedvolumehighdelay10min=0;



if ~isempty(cellevent)   

      
for i=1:size(cellevent,2)
    a=cell2mat(cellevent(i));
    time=mod(a(end-1,1),288);
    if time>=72 && time<=240
        numdayevent=numdayevent+1;
    end
    
    w=zeros(1,size(a,2));      % queue length container
    numeventday(i)=ceil(a(end-1,1)/size(TrafficData,2));  %days that have a event
    duration(i)=size(a,2);
    
    length_impact(i) = sum(sum(a(1:end-4,:)>0,2)>0);
    
    lowspeed = a(1:end-4,:);
    lowspeed(lowspeed==0) = 100;
    lowest_speed(i) = min(min(lowspeed));
    
    for j=1:size(a,2)
        w(j)=sum(a(1:end-4,j)>0); 
    end
    avgmaxqueue(i)=max(w);
    queue(i)={w};
    
    Subvolume=zeros(size(volume,1),size(a,2));
    Subdelay=zeros(size(volume,1),size(a,2));
    for ii=1:size(a,2)
        Subvolume(:,ii)=volume(:,mod(a(end-1,ii)-1,size(volume,2))+1,ceil(a(end-1,ii)/size(volume,2)));
        Subdelay(:,ii)=delay(:,mod(a(end-1,ii)-1,size(volume,2))+1,ceil(a(end-1,ii)/size(volume,2)));
%     Subvolume=volume(:,mod(a0(end,:)-1,size(volume,2))+1,ceil(a0(end,1)/size(volume,2)));  %(:,time of day, day)
%     Subdelay=delay(:,mod(a0(end,:)-1,size(volume,2))+1,ceil(a0(end,1)/size(volume,2)));
    end
    
    total_veh(i)=nansum(nanmean(Subvolume,1));
    
    queuedvolume=queuedvolume+nansum(nanmean(Subvolume,1));
    queueddelay=queueddelay+sum(nansum(Subvolume.*Subdelay/60));
    Subvolume1=nanmean(Subvolume,1);
    queuedvolumehighdelay5min=queuedvolumehighdelay5min+nansum(Subvolume1(nansum(Subdelay,1)>10));
    queuedvolumehighdelay10min=queuedvolumehighdelay10min+nansum(Subvolume1(nansum(Subdelay,1)>10));
end
% end
% % round 1 apply filters
% % lowest_speed <= 36
% % Duration > 10min
% % length_impact > 0.8
% % total_veh >= 100
% 
% filter = lowest_speed <= 36 & duration*timeinterval > 10 & length_impact*distanceinterval > 0.8 & total_veh >= 100;
% cellevent(~filter) = [];
% 
% % round 2 find filtered event stats
% numberofdays=size(TrafficData,3);
% numevent=size(cellevent,2);
% numdayevent=0;
% 
% duration=       zeros(1,size(cellevent,2));
% length_impact = zeros(1,size(cellevent,2));
% total_veh =     zeros(1,size(cellevent,2));
% lowest_speed =  zeros(1,size(cellevent,2));
% 
% avgmaxqueue=    zeros(1,size(cellevent,2));
% numeventday=    nan(1,size(cellevent,2));     
% queue=          cell(1,size(cellevent,2));   
% queuedvolume=0;
% queueddelay=0;
% queuedvolumehighdelay5min=0;
% queuedvolumehighdelay10min=0;
% 
% if ~isempty(cellevent)   
% 
%       
% for i=1:size(cellevent,2)
%     a=cell2mat(cellevent(i));
%     time=mod(a(end-1,1),288);
%     if time>=72 && time<=240
%         numdayevent=numdayevent+1;
%     end
%     
%     w=zeros(1,size(a,2));      % queue length container
%     numeventday(i)=ceil(a(end-1,1)/size(TrafficData,2));  %days that have a event
%     duration(i)=size(a,2);
%     
%     length_impact(i) = sum(sum(a(1:end-4,:)>0,2)>0);
%     
%     lowspeed = a(1:end-4,:);
%     lowspeed(lowspeed==0) = 100;
%     lowest_speed(i) = min(min(lowspeed));
%     
%     for j=1:size(a,2)
%         w(j)=sum(a(1:end-4,j)>0); 
%     end
%     avgmaxqueue(i)=max(w);
%     queue(i)={w};
%     
%     Subvolume=zeros(size(volume,1),size(a,2));
%     Subdelay=zeros(size(volume,1),size(a,2));
%     for ii=1:size(a,2)
%         Subvolume(:,ii)=volume(:,mod(a(end-1,ii)-1,size(volume,2))+1,ceil(a(end-1,ii)/size(volume,2)));
%         Subdelay(:,ii)=delay(:,mod(a(end-1,ii)-1,size(volume,2))+1,ceil(a(end-1,ii)/size(volume,2)));
% %     Subvolume=volume(:,mod(a0(end,:)-1,size(volume,2))+1,ceil(a0(end,1)/size(volume,2)));  %(:,time of day, day)
% %     Subdelay=delay(:,mod(a0(end,:)-1,size(volume,2))+1,ceil(a0(end,1)/size(volume,2)));
%     end
%     
%     total_veh(i)=nansum(nanmean(Subvolume,1));
%     
%     queuedvolume=queuedvolume+nansum(nanmean(Subvolume,1));
%     queueddelay=queueddelay+sum(nansum(Subvolume.*Subdelay/60));
%     Subvolume1=nanmean(Subvolume,1);
%     queuedvolumehighdelay5min=queuedvolumehighdelay5min+nansum(Subvolume1(nansum(Subdelay,1)>10));
%     queuedvolumehighdelay10min=queuedvolumehighdelay10min+nansum(Subvolume1(nansum(Subdelay,1)>10));
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%% end round 1 round 2

numeventday=length(unique(numeventday));
avgduration=mean(duration)*timeinterval;   % in  min
medianduration=median(duration)*timeinterval;
medianmaxqueue=median(avgmaxqueue)*distanceinterval;  % in mile
maxmaxqueue=max(avgmaxqueue)*distanceinterval;
avgmaxqueue=mean(avgmaxqueue)*distanceinterval;

totalqueuelength=0;
eventseverity=zeros(1,size(queue,2));
reshapedqueue=[];
for i=1:size(queue,2)    
    totalqueuelength=totalqueuelength+sum(cell2mat(queue(i)));
    eventseverity(i)=sum(cell2mat(queue(i)));
    reshapedqueue=[reshapedqueue cell2mat(queue(i))];        
end
avgqueue=totalqueuelength/sum(duration)*distanceinterval;
longqueuepercent=sum(reshapedqueue>10)/length(reshapedqueue);

avgqueueddelay=queueddelay/queuedvolume*60;
percentqueuedvolumehighdelay5min=queuedvolumehighdelay5min/queuedvolume;
percentqueuedvolumehighdelay10min=queuedvolumehighdelay10min/queuedvolume;

fprintf('1. number of days:                                            %f   \n',numberofdays);
fprintf('2. number of events:                                          %f   \n',numevent);
fprintf('3. number of daytime events:                                  %f   \n',numdayevent);
fprintf('4. number of days when events happened:                       %f   \n',numeventday);
fprintf('5. average duration of each event:                            %f  min \n',avgduration);
fprintf('6. median duration of each event:                             %f  min \n',medianduration);
fprintf('7. average queue length:                                      %f  mile \n',avgqueue);
fprintf('8. average maximum queue length of each event:                %f  mile \n',avgmaxqueue);
fprintf('9. median maximum queue length of each event:                 %f  mile \n',medianmaxqueue);
fprintf('10. max maximum queue length of each event:                   %f  mile \n',maxmaxqueue);
fprintf('11.percentage of queue > 1 mile:                              %f   \n',longqueuepercent);
fprintf('12.amount of traffic that encounters a queue:                 %f   \n',ceil(queuedvolume));
fprintf('13.total traffic:                                             %f   \n',ceil(totalvolume));
fprintf('14.percentage of traffic that encounters a queue:             %f   \n',queuedvolume/totalvolume);
fprintf('15.percentage of time that encounters a queue:                %f   \n',numevent*avgduration/numberofdays/24/60);
fprintf('16.total delay:                                               %f  veh*hour \n',totaldelay);
fprintf('17.total delay per day:                                       %f  veh*hour \n',totaldelay/numberofdays);
fprintf('18.average delay per vehicle:                                 %f  min/veh \n',avgdelay);
fprintf('19.maximum delay:                                             %f  min \n',maxdelay);
fprintf('20.total delay when queue is present:                         %f  veh*hour \n',queueddelay);
fprintf('21.percentage of delay caused by queue:                       %f   \n',queueddelay/totaldelay);
fprintf('22.avg delay when queue is present:                           %f  min/veh \n',avgqueueddelay);
fprintf('23.percent of vehicles experiencing delay > 5 min:            %f   \n',percentvolumehighdelay5min);
fprintf('24.percent of vehicles experiencing delay > 10 min:           %f   \n',percentvolumehighdelay10min);
fprintf('25.percent of vehicles in queue experiencing delay > 5 min:   %f   \n',percentqueuedvolumehighdelay5min);
fprintf('26.percent of vehicles in queue experiencing delay > 10 min:  %f   \n',percentqueuedvolumehighdelay10min);

%fprintf('27.95 percentile of delay for all times:                      %f   \n',delay_percentile_all(5));
%fprintf('28.95 percentile of delay when there is delay                 %f   \n',delay_percentile_isdelay(5));

performancemetrics=[                                
    numberofdays;                                   %1
    numevent;                                       %2
    numdayevent;                                    %3
    numeventday;                                    %4
    avgduration;                                    %5
    medianduration;                                 %6
    avgqueue;                                       %7
    avgmaxqueue;                                    %8
    medianmaxqueue;                                 %9
    maxmaxqueue;                                    %10
    longqueuepercent;                               %11
    ceil(queuedvolume);                             %12
    ceil(totalvolume);                              %13
    queuedvolume/totalvolume;                       %14
    numevent*avgduration/numberofdays/24/60;        %15
    totaldelay;                                     %16
    totaldelay/numberofdays;                        %17
    avgdelay;                                       %18
    maxdelay;                                       %19
    queueddelay;                                    %20
    queueddelay/totaldelay;                         %21
    avgqueueddelay;                                 %22
    percentvolumehighdelay5min;                     %23
    percentvolumehighdelay10min;                    %24
    percentqueuedvolumehighdelay5min;               %25
    percentqueuedvolumehighdelay10min];              %26
%    delay_percentile_all(5);                        %27
%    delay_percentile_isdelay(5)];                   %28
else
performancemetrics=[                                
    numberofdays;                                   %1
    0;                                       %2
    0;                                    %3
    0;                                    %4
    0;                                    %5
    0;                                 %6
    0;                                       %7
    0;                                    %8
    0;                                 %9
    0;                                    %10
    0;                               %11
    0;                             %12
    ceil(totalvolume);                              %13
    0;                       %14
    0;        %15
    totaldelay;                                     %16
    totaldelay/numberofdays;                        %17
    avgdelay;                                       %18
    maxdelay;                                       %19
    0;                                    %20
    0;                         %21
    0;                                 %22
    percentvolumehighdelay5min;                     %23
    percentvolumehighdelay10min;                    %24
    0;               %25
    0];                  %26
%    0;%27
%    0];  %28              

end