function [rawspreadsheet,cellspreadsheet,numevent,duration,queue,figurenum]=eventreduction(eventamplifier,TrafficData,volume,speed,figurenum,eventspeed,timeinterval,distanceinterval,startdatenum,speedlimit)

WZbound1=32;
WZbound2=99;
n=10;    % top n events

COLOR={'red' 'yellow' 'green' 'blue'};
rawspreadsheet=nan(size(TrafficData,1),size(TrafficData,3)*size(TrafficData,2));
volumespreadsheet=nan(size(volume,1),size(volume,3)*size(volume,2));
for i=1:size(TrafficData,3)
    rawspreadsheet(:,(i-1)*size(TrafficData,2)+1:i*size(TrafficData,2),:)=TrafficData(:,:,i);
    volumespreadsheet(:,(i-1)*size(volume,2)+1:i*size(volume,2),:)=volume(:,:,i);
end
speedspreadsheet=nan(size(speed,1),size(speed,3)*size(speed,2));
for i=1:size(TrafficData,3)
    rawspreadsheet(:,(i-1)*size(TrafficData,2)+1:i*size(TrafficData,2),:)=TrafficData(:,:,i);
    speedspreadsheet(:,(i-1)*size(speed,2)+1:i*size(speed,2),:)=speed(:,:,i);
end

%csvwrite('C:\Users\shuowang\Desktop\2014 Fall\Research Work\smart work zone\8_Traffic Critical Work Zone ITS\Detector Data\Hamilton County\HamiltonCountyRAW.csv',spreadsheet)
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
eventno(1)=0;
for i=2:size(spreadsheet,2)
    if columnsum(i)>0 && columnsum(i-1)==0
        eventno(i)=eventno(i-1)+1;
    else eventno(i)=eventno(i-1);
    end
end
spreadsheet=[spreadsheet;columnsum;eventno;label];
spreadsheet1=spreadsheet;
spreadsheet(:,spreadsheet(end-2,:)==0)=[];    

% convert to cell format, events in separate cells
[~,~,uniqueIndex] = unique(spreadsheet(end-1,:));
cellspreadsheet = mat2cell(spreadsheet,size(spreadsheet,1),accumarray(uniqueIndex(:),1));
numevent=size(cellspreadsheet,2);

%actualspeed=TrafficData(1:WZbound2,:,:);
actualspeed=TrafficData(WZbound1:end,:,:);
actualtime=0.1/actualspeed*60;
targettime=0.1/speedlimit*60*ones(size(actualspeed));
delay=actualtime-targettime;
delay(delay<0)=0;
delay=nansum(delay,1);  % in min

totaldelay=sum(nansum(delay.*volume/60));   % veh-hours
avgdelay=totaldelay/sum(nansum(volume))*60;   % min
maxdelay=max(max(delay)); % min
percentvolumehighdelay=sum(nansum(volume(delay>10)))/sum(nansum(volume));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

noneventtracker=0;

% plot highlighted events (queue frontier) through the report period
% step 1 plot non event period with gray shade

color=[0.7,0.7,0.7];
figurenum=figurenum+1;
figure(figurenum)
hold on

duration=zeros(1,size(cellspreadsheet,2));
avgmaxqueue=zeros(1,size(cellspreadsheet,2));
numeventday=nan(1,size(cellspreadsheet,2));
queue=cell(1,size(cellspreadsheet,2));
spiltout=zeros(1,size(cellspreadsheet,2));
queuedvolume=0;
queueddelay=0;
queuedvolumehighdelay=0;

for i=1:size(cellspreadsheet,2)
    duration(i)=size(cell2mat(cellspreadsheet(i)),2);
    
    a0=cell2mat(cellspreadsheet(i));
    w=zeros(1,size(a0,2));
    ww=zeros(1,size(a0,2));
    for j=1:size(a0,2)
        w(j)=sum(a0(WZbound1:end-3,j)>0);    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%change for Hamiltoin county
        %w(j)=sum(a0(1:WZbound2,j)>0);
        if a0(end-4,j)>0
            ww(j)=1;
        else
        end
    end
    avgmaxqueue(i)=max(w);
    queue(i)={w};
    if max(ww)==1
        spiltout(i)=1;
    else
    end
    
    subvolume=volume(:,mod(a0(end,:),size(volume,2)),ceil(a0(end,1)/size(volume,2)));
    subdelay=delay(:,mod(a0(end,:),size(volume,2)),ceil(a0(end,1)/size(volume,2)));
    queuedvolume=queuedvolume+sum(nansum(subvolume));
    queueddelay=queueddelay+sum(nansum(subvolume.*subdelay/60));
    queuedvolumehighdelay=queuedvolumehighdelay+sum(nansum(subvolume(subdelay>10)));
      
    if i==1
        a=cell2mat(cellspreadsheet(i));
        lastnoneventduration=a(end,1)-1;
        noneventtracker=noneventtracker+lastnoneventduration;
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=a(end,:)-(eventamplifier-1)/eventamplifier*noneventtracker;
    %xvloume=volumespreadsheet(5,a(end,:));
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
    
    patch([0,y(1)-0.1,y(1)-0.1,0]',[0,0,size(TrafficData,1),size(TrafficData,1)]',color,'EdgeColor','none');
    %plot(xleft,y,'r','LineWidth',3,'Marker','.','MarkerSize',10)   
    ylast=y(end);     
        
    else a=cell2mat(cellspreadsheet(i));
        b=cell2mat(cellspreadsheet(i-1));
        lastnoneventduration=a(end,1)-b(end,end)-1;
        noneventtracker=noneventtracker+lastnoneventduration;
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=a(end,:)-(eventamplifier-1)/eventamplifier*noneventtracker;
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
    
    patch([ylast+0.1,y(1)-0.1,y(1)-0.1,ylast+0.1]',[0,0,size(TrafficData,1),size(TrafficData,1)]',color,'EdgeColor','none');  
    %plot(xleft,y,'r','LineWidth',3,'Marker','.','MarkerSize',10)  
    ylast=y(end);
    end
    numeventday(i)=ceil(a(end,1)/size(volume,2));
end

% plot highlighted events (queue frontier) through the report period
% step 2 plot the shockwave frontier

noneventtracker=0;

for i=1:size(cellspreadsheet,2)
    
    if i==1
        a=cell2mat(cellspreadsheet(i));
        lastnoneventduration=a(end,1)-1;
        noneventtracker=noneventtracker+lastnoneventduration;
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=a(end,:)-(eventamplifier-1)/eventamplifier*noneventtracker;
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
    
    %patch([0,size(TrafficData,2),size(TrafficData,2),0]',[0,0,y(1)-0.1,y(1)-0.1]',color,'EdgeColor','none');
    plot(y,xright,'r','LineWidth',3,'Marker','.','MarkerSize',10)

    ylast=y(end);     
        
    else a=cell2mat(cellspreadsheet(i));
        b=cell2mat(cellspreadsheet(i-1));
        lastnoneventduration=a(end,1)-b(end,end)-1;
        noneventtracker=noneventtracker+lastnoneventduration;
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=a(end,:)-(eventamplifier-1)/eventamplifier*noneventtracker;
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
     
    %patch([0,size(TrafficData,2),size(TrafficData,2),0]',[ylast+0.1,ylast+0.1,y(1)-0.1,y(1)-0.1]',color,'EdgeColor','none');  
    plot(y,xright,'r','LineWidth',3,'Marker','.','MarkerSize',10)

    ylast=y(end);
    end
end

plot(1:floor(ylast),ones(1,floor(ylast))*(WZbound1)); %%%%%% zork zone location change it
plot(1:floor(ylast),ones(1,floor(ylast))*(WZbound2)); %%%%%% zork zone location change it

set(gca,'YDir','Reverse')
ylim([0,size(TrafficData,1)]);
set(gca,'XTickLabel',{})
title('highlighted events (queue frontier) through the report period');

medianduration=median(duration)*timeinterval;
avgduration=mean(duration)*timeinterval;
medianmaxqueue=median(avgmaxqueue)*distanceinterval;
maxmaxqueue=max(avgmaxqueue)*distanceinterval;
avgmaxqueue=mean(avgmaxqueue)*distanceinterval;
numberofdays=size(TrafficData,3);
numeventday=length(unique(numeventday));
avgqueuelength=0;
avgqueuenumber=0;
eventseverity=zeros(1,size(queue,2));
reshapedqueue=[];
for i=1:size(queue,2)
    avgqueuenumber=avgqueuenumber+length(cell2mat(queue(i)));
    avgqueuelength=avgqueuelength+sum(cell2mat(queue(i)));
    eventseverity(i)=sum(cell2mat(queue(i)));
    reshapedqueue=[reshapedqueue cell2mat(queue(i))];
end
avgqueue=avgqueuelength/avgqueuenumber*distanceinterval;
numberofspiltout=sum(spiltout);
longqueuepercent=sum(reshapedqueue>10)/length(reshapedqueue);
totalvolume=sum(nansum(volume));
avgqueueddelay=queueddelay/queuedvolume*60;
percentqueuedvolumehighdelay=queuedvolumehighdelay/queuedvolume;

fprintf('number of days:                                    %f   \n',numberofdays);
fprintf('number of events:                                  %f   \n',numevent);
fprintf('number of days when events happened:               %f   \n',numeventday);
fprintf('average duration of each event:                    %f  min \n',avgduration);
fprintf('median duration of each event:                     %f  min \n',medianduration);
fprintf('average queue length:                              %f  mile \n',avgqueue);
fprintf('average maximum queue length of each event:        %f  mile \n',avgmaxqueue);
fprintf('median maximum queue length of each event:         %f  mile \n',medianmaxqueue);
fprintf('max maximum queue length of each event:            %f  mile \n',maxmaxqueue);
fprintf('times of queue exceeding farthest sensor:          %f   \n',numberofspiltout);
fprintf('percentage of queue > 1 mile:                      %f   \n',longqueuepercent);
fprintf('amount of traffic that encounters a queue:         %f   \n',queuedvolume);
fprintf('percentage of traffic that encounters a queue:     %f   \n',queuedvolume/totalvolume);
fprintf('percentage of time that encounters a queue:        %f   \n',numevent*avgduration/numberofdays/24/60);
fprintf('total delay:                                       %f  veh*hour \n',totaldelay);
fprintf('average delay:                                     %f  min/veh \n',avgdelay);
fprintf('maximum delay:                                     %f  min \n',maxdelay);
fprintf('total delay when queue is present:                 %f  veh*hour \n',queueddelay);
fprintf('avg delay when queue is present:                   %f  min/veh \n',avgqueueddelay);
fprintf('percent of vehicles experiencing delay > 10 min:   %f   \n',percentvolumehighdelay);
fprintf('percent of vehicles with delay > 10 min in queue:  %f   \n',percentqueuedvolumehighdelay);

noneventtracker=0;

% plot highlighted events (queue frontier) through the report period (colored by time of day)
% step 1 plot non event period with gray shade

color=[0.7,0.7,0.7];
figurenum=figurenum+1;
figure(figurenum)
hold on
newxpre=[spreadsheet1(end,:);zeros(1,size(spreadsheet1,2));ones(1,size(spreadsheet1,2))];
avgduration=zeros(1,size(cellspreadsheet,2));
avgmaxqueue=zeros(1,size(cellspreadsheet,2));

for i=1:size(cellspreadsheet,2)
    avgduration(i)=size(cell2mat(cellspreadsheet(i)),2);
    
    a0=cell2mat(cellspreadsheet(i));
    w=zeros(1,size(a0,2));
    for j=1:size(a0,2)
        w(j)=sum(a0(:,j)>0);
    end
    avgmaxqueue(i)=max(w);
    
    newxpre(2,a0(end,:))=1;
    
    if i==1
        a=cell2mat(cellspreadsheet(i));
        lastnoneventduration=a(end,1)-1;
        noneventtracker=noneventtracker+lastnoneventduration;
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=a(end,:)-(eventamplifier-1)/eventamplifier*noneventtracker;
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
    
    patch([0,y(1)-0.1,y(1)-0.1,0]',[0,0,size(TrafficData,1)-2,size(TrafficData,1)-2]',color,'EdgeColor','none');
    %plot(xleft,y,'r','LineWidth',3,'Marker','.','MarkerSize',10)   
    ylast=y(end);     
        
    else a=cell2mat(cellspreadsheet(i));
        b=cell2mat(cellspreadsheet(i-1));
        lastnoneventduration=a(end,1)-b(end,end)-1;
        noneventtracker=noneventtracker+lastnoneventduration;
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=a(end,:)-(eventamplifier-1)/eventamplifier*noneventtracker;
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
     
    patch([ylast+0.1,y(1)-0.1,y(1)-0.1,ylast+0.1]',[0,0,size(TrafficData,1)-2,size(TrafficData,1)-2]',color,'EdgeColor','none');  
    %plot(xleft,y,'r','LineWidth',3,'Marker','.','MarkerSize',10)  
    ylast=y(end);
    end
end

% plot highlighted events (queue frontier) through the report period (colored by time of day)
% step 2 plot the shockwave frontier

noneventtracker=0;

for i=1:size(cellspreadsheet,2)
    
    if i==1
        a=cell2mat(cellspreadsheet(i));
        lastnoneventduration=a(end,1)-1;
        noneventtracker=noneventtracker+lastnoneventduration;
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    xtime=nan(1,size(a,2));
    y=a(end,:)-(eventamplifier-1)/eventamplifier*noneventtracker;
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
        time=mod(a(end,j),288);
        if time<72
        xtime(j)=1;
        else if time<144
                xtime(j)=2;
            else if time<216
                    xtime(j)=3;
                else xtime(j)=4;
                end
            end
        end
    end
    
    %patch([0,size(TrafficData,2),size(TrafficData,2),0]',[0,0,y(1)-0.1,y(1)-0.1]',color,'EdgeColor','none');
    plot(y,xright,cell2mat(COLOR(xtime(1))),'LineWidth',3,'Marker','.','MarkerSize',10)
    %plot(y(xtime==1),xright(xtime==1),'r.','MarkerSize',10)
    %plot(y(xtime==2),xright(xtime==2),'y.','MarkerSize',10)
    %plot(y(xtime==3),xright(xtime==3),'g.','MarkerSize',10)
    %plot(y(xtime==4),xright(xtime==4),'b.','MarkerSize',10)
    ylast=y(end);     
        
    else a=cell2mat(cellspreadsheet(i));
        b=cell2mat(cellspreadsheet(i-1));
        lastnoneventduration=a(end,1)-b(end,end)-1;
        noneventtracker=noneventtracker+lastnoneventduration;
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    xtime=nan(1,size(a,2));
    y=a(end,:)-(eventamplifier-1)/eventamplifier*noneventtracker;
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
        time=mod(a(end,j),288);
        if time<72
        xtime(j)=1;
        else if time<144
                xtime(j)=2;
            else if time<216
                    xtime(j)=3;
                else xtime(j)=4;
                end
            end
        end
    end
     
    %patch([0,size(TrafficData,2),size(TrafficData,2),0]',[ylast+0.1,ylast+0.1,y(1)-0.1,y(1)-0.1]',color,'EdgeColor','none');  
    plot(y,xright,cell2mat(COLOR(xtime(1))),'LineWidth',3,'Marker','.','MarkerSize',10)
    %plot(y(xtime==1),xright(xtime==1),'r.','MarkerSize',10)
    %plot(y(xtime==2),xright(xtime==2),'y.','MarkerSize',10)
    %plot(y(xtime==3),xright(xtime==3),'g.','MarkerSize',10)
    %plot(y(xtime==4),xright(xtime==4),'b.','MarkerSize',10)
    ylast=y(end);
    end
end

newxpre(3,newxpre(2,:)==0)=newxpre(3,newxpre(2,:)==0)/eventamplifier;
newx=cumsum(newxpre(3,:));
d=7-weekday(startdatenum)+1;
e=24*60/timeinterval;
days=floor(((d*e+1):(7*e):size(spreadsheet1,2))/288)+startdatenum;
day=cellstr(datestr(days));

plot(1:floor(ylast),ones(1,floor(ylast))*(WZbound1)); %%%%%% zork zone location change it
plot(1:floor(ylast),ones(1,floor(ylast))*(WZbound2)); %%%%%% zork zone location change it

set(gca,'YDir','Reverse')
ylim([0,size(TrafficData,1)]);
set(gca,'XTick',newx((d*e+1):(7*e):size(spreadsheet1,2)))
set(gca,'XTickLabel',day)
set(gca,'XGrid','on')
xlabel('time (event : nonevent = 50:1)')
ylabel('distance (0.1mile)')
title('highlighted events (queue frontier) through the report period (colored by time of day: red,yellow,green,blue every 6 hours)');

%fprintf('12:00am - 6:00am     red \n');
%fprintf('6:00am - 12:00pm     yellow \n');
%fprintf('12:00pm - 6:00pm     green \n');
%fprintf('6:00pm - 12:00am     blue \n');

% plot corresponding volume curve
figurenum=figurenum+1;
figure(figurenum)
hold on
meanvolume=nanmean(nanmean(volume,1),3);
noneventtracker=0;
for i=1:size(cellspreadsheet,2)
    avgduration(i)=size(cell2mat(cellspreadsheet(i)),2);
    
    a0=cell2mat(cellspreadsheet(i));
    w=zeros(1,size(a0,2));
    for j=1:size(a0,2)
        w(j)=sum(a0(:,j)>0);
    end
    avgmaxqueue(i)=max(w);
      
    if i==1
        a=cell2mat(cellspreadsheet(i));
        lastnoneventduration=a(end,1)-1;
        noneventtracker=noneventtracker+lastnoneventduration;
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=a(end,:)-(eventamplifier-1)/eventamplifier*noneventtracker;
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
    
    patch([0,y(1)-0.1,y(1)-0.1,0]',[0,0,1000,1000]',color,'EdgeColor','none');
    %plot(xleft,y,'r','LineWidth',3,'Marker','.','MarkerSize',10)   
    ylast=y(end);     
        
    else a=cell2mat(cellspreadsheet(i));
        b=cell2mat(cellspreadsheet(i-1));
        lastnoneventduration=a(end,1)-b(end,end)-1;
        noneventtracker=noneventtracker+lastnoneventduration;
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=a(end,:)-(eventamplifier-1)/eventamplifier*noneventtracker;
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
     
    patch([ylast+0.1,y(1)-0.1,y(1)-0.1,ylast+0.1]',[0,0,1000,1000]',color,'EdgeColor','none');  
    %plot(xleft,y,'r','LineWidth',3,'Marker','.','MarkerSize',10)  
    ylast=y(end);
    end
end


noneventtracker=0;
for i=1:size(cellspreadsheet,2)

    if i==1
        a=cell2mat(cellspreadsheet(i));
        lastnoneventduration=a(end,1)-1;
        noneventtracker=noneventtracker+lastnoneventduration;
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=a(end,:)-(eventamplifier-1)/eventamplifier*noneventtracker;
    xvolume=nanmean(volumespreadsheet(:,a(end,:)),1);
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
    
    %patch([0,y(1)-0.1,y(1)-0.1,0]',[0,0,size(TrafficData,1),size(TrafficData,1)]',color,'EdgeColor','none');
    plot(y,xvolume,'r','LineWidth',1.2,'Marker','.','MarkerSize',2)
    plot(y,meanvolume(mod(a(end,:),size(volume,2))),'LineWidth',1.1)
    ylast=y(end);     
        
    else a=cell2mat(cellspreadsheet(i));
        b=cell2mat(cellspreadsheet(i-1));
        lastnoneventduration=a(end,1)-b(end,end)-1;
        noneventtracker=noneventtracker+lastnoneventduration;
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=a(end,:)-(eventamplifier-1)/eventamplifier*noneventtracker;
    xvolume=nanmean(volumespreadsheet(:,a(end,:)),1);
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
     
    %patch([ylast+0.1,y(1)-0.1,y(1)-0.1,ylast+0.1]',[0,0,size(TrafficData,1),size(TrafficData,1)]',color,'EdgeColor','none');  
    plot(y,xvolume,'r','LineWidth',1.2,'Marker','.','MarkerSize',2)  
    plot(y,meanvolume(mod(a(end,:),size(volume,2))),'LineWidth',1.1)
    ylast=y(end);
    end
end
set(gca,'XTickLabel',{})
xlabel('time (event : nonevent = 50:1)')
ylabel('volume')
title('corresponding volume plot when events happen');

% plot corresponding speed curve
figurenum=figurenum+1;
figure(figurenum)
hold on
meanspeed=nanmean(nanmean(speed,1),3);
noneventtracker=0;
for i=1:size(cellspreadsheet,2)
    avgduration(i)=size(cell2mat(cellspreadsheet(i)),2);
    
    a0=cell2mat(cellspreadsheet(i));
    w=zeros(1,size(a0,2));
    for j=1:size(a0,2)
        w(j)=sum(a0(:,j)>0);
    end
    avgmaxqueue(i)=max(w);
      
    if i==1
        a=cell2mat(cellspreadsheet(i));
        lastnoneventduration=a(end,1)-1;
        noneventtracker=noneventtracker+lastnoneventduration;
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=a(end,:)-(eventamplifier-1)/eventamplifier*noneventtracker;
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
    
    patch([0,y(1)-0.1,y(1)-0.1,0]',[0,0,90,90]',color,'EdgeColor','none');
    %plot(xleft,y,'r','LineWidth',3,'Marker','.','MarkerSize',10)   
    ylast=y(end);     
        
    else a=cell2mat(cellspreadsheet(i));
        b=cell2mat(cellspreadsheet(i-1));
        lastnoneventduration=a(end,1)-b(end,end)-1;
        noneventtracker=noneventtracker+lastnoneventduration;
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=a(end,:)-(eventamplifier-1)/eventamplifier*noneventtracker;
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
     
    patch([ylast+0.1,y(1)-0.1,y(1)-0.1,ylast+0.1]',[0,0,90,90]',color,'EdgeColor','none');  
    %plot(xleft,y,'r','LineWidth',3,'Marker','.','MarkerSize',10)  
    ylast=y(end);
    end
end


noneventtracker=0;
for i=1:size(cellspreadsheet,2)

    if i==1
        a=cell2mat(cellspreadsheet(i));
        lastnoneventduration=a(end,1)-1;
        noneventtracker=noneventtracker+lastnoneventduration;
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=a(end,:)-(eventamplifier-1)/eventamplifier*noneventtracker;
    xspeed=nanmean(speedspreadsheet(:,a(end,:)),1);
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
    
    %patch([0,y(1)-0.1,y(1)-0.1,0]',[0,0,size(TrafficData,1),size(TrafficData,1)]',color,'EdgeColor','none');
    plot(y,xspeed,'r','LineWidth',1.2,'Marker','.','MarkerSize',2)
    plot(y,meanspeed(mod(a(end,:),size(speed,2))),'LineWidth',1.1)
    ylast=y(end);     
        
    else a=cell2mat(cellspreadsheet(i));
        b=cell2mat(cellspreadsheet(i-1));
        lastnoneventduration=a(end,1)-b(end,end)-1;
        noneventtracker=noneventtracker+lastnoneventduration;
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=a(end,:)-(eventamplifier-1)/eventamplifier*noneventtracker;
    xspeed=nanmean(speedspreadsheet(:,a(end,:)),1);
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
     
    %patch([ylast+0.1,y(1)-0.1,y(1)-0.1,ylast+0.1]',[0,0,size(TrafficData,1),size(TrafficData,1)]',color,'EdgeColor','none');  
    plot(y,xspeed,'r','LineWidth',1.2,'Marker','.','MarkerSize',2)  
    plot(y,meanspeed(mod(a(end,:),size(speed,2))),'LineWidth',1.1)
    ylast=y(end);
    end
end
set(gca,'XTickLabel',{})
xlabel('time (event : nonevent = 50:1)')
ylabel('speed')
title('corresponding speed plot when events happen');


% plot events (queue frontier) overlaid by time of day through the report period

figurenum=figurenum+1;
figure(figurenum)
hold on
colorscale={'blue' 'green' 'green' 'green' 'green' 'red' 'blue'};
for i=1:size(cellspreadsheet,2)

        a=cell2mat(cellspreadsheet(i));
           
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=mod(a(end,:),24*60/timeinterval);
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
    dayofweek=weekday(startdatenum+floor(a(end,1)/(24*60/timeinterval)));
plot(y,xright,cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)

end

plot(1:24*60/timeinterval,ones(1,24*60/timeinterval)*(WZbound1)); %%%%%% zork zone location change it
plot(1:24*60/timeinterval,ones(1,24*60/timeinterval)*(WZbound2)); %%%%%% zork zone location change it

set(gca,'YDir','Reverse')
ylim([0,size(TrafficData,1)]);
set(gca,'XTick',[1/4*24*60/timeinterval,3/4*24*60/timeinterval])
set(gca,'XTickLabel',{'6:00am','6:00pm'})
set(gca,'XGrid','on')
title('events overlaid by time of day through the report period (green:Mon-Thu/red:Fri/blue:Sat,Sun)');

% select the top n biggest events and plot overlaid

colorscale={'blue' 'green' 'green' 'green' 'green' 'red' 'blue'};
selectscale=[1:size(cellspreadsheet,2);eventseverity];
%for i=1:size(cellspreadsheet,2)
%    selectscale(2,i)=size(cell2mat(cellspreadsheet(i)),2);
%end
selectscale=sortrows(selectscale',-2);
bigeventIDs=selectscale(1:n,1);

figurenum=figurenum+1;
figure(figurenum)
hold on

for i=1:n

        a=cell2mat(cellspreadsheet(bigeventIDs(i)));
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=mod(a(end,:),24*60/timeinterval);
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
    dayofweek=weekday(startdatenum+floor(a(end,1)/(24*60/timeinterval)));
plot(y,xright,'Color',cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)

end

plot(1:24*60/timeinterval,ones(1,24*60/timeinterval)*(WZbound1)); %%%%%% zork zone location change it
plot(1:24*60/timeinterval,ones(1,24*60/timeinterval)*(WZbound2)); %%%%%% zork zone location change it

set(gca,'YDir','Reverse')
ylim([0,size(TrafficData,1)]);
set(gca,'XTick',[1/4*24*60/timeinterval,3/4*24*60/timeinterval])
set(gca,'XTickLabel',{'6:00am','6:00pm'})
set(gca,'XGrid','on')
title('top n biggest events overlaid by time of day through the report period (green:Mon-Thu/red:Fri/blue:Sat,Sun)');

% top n biggest events plot separately

figurenum=figurenum+1;
figure(figurenum)
hold on
tradeoffleft=0;
tradeoffright=0;
for i=1:n

    a=cell2mat(cellspreadsheet(bigeventIDs(i)));
    xleft=nan(1,size(a,2));
    xright=nan(1,size(a,2));
    y=mod(a(end,:),24*60/timeinterval);
    for j=1:size(a,2)
        c=find(a(1:end-3,j)>0);
        xleft(j)=c(1);
        xright(j)=c(end);
    end
    xleft=xleft-min(xleft)+tradeoffleft;
    xright=xright-min(xright)+tradeoffright;
    tradeoffleft=max(xleft);
    tradeoffright=max(xright);
    dayofweek=weekday(startdatenum+floor(a(end,1)/(24*60/timeinterval)));
plot(y,xright,'Color',cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
plot(1:24*60/timeinterval,ones(1,24*60/timeinterval)*tradeoffright);
end

set(gca,'YDir','Reverse')
%ylim([0,size(TrafficData,1)]);
set(gca,'YTickLabel',{})
set(gca,'XTick',[1/4*24*60/timeinterval,3/4*24*60/timeinterval])
set(gca,'XTickLabel',{'6:00am','6:00pm'})
set(gca,'XGrid','on')
title('top n longest events overlaid by time of day through the report period (green:Mon-Thu/red:Fri/blue:Sat,Sun)');

