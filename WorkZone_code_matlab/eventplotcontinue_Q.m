% event plot continue
function [figurenum]...
    =eventplotcontinue(eventamplifier,TrafficData,volume,figurenum,eventspeed,...
    timeinterval,startdatenum,direction,milemarker,groupname,folder,reportstartday,reportendday)
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
numevent=size(cellevent,2);

% other parameter
n=10;    % top n events
COLOR={'green' 'red' 'yellow' 'blue'}; %{12am-6am/8pm-12am, 6am-10am, 10am-4pm, 4pm-8pm}
color=[0.8,0.8,0.8];%patch color
timelabelgaprate=50;
workzoneboundaryweight=1.2;
eventfrontierweight=1.5;
eventfrontiermarkersize=6;
%%
% plot events (queue frontier) overlaid by time of day through the report period
figurenum=figurenum+1;
scrsz=get(groot,'ScreenSize');
h=figure('Name',num2str(figurenum),'Position',scrsz);
set(gcf, 'Color', [1,1,1]);

% subplot(3,1,1)
% hold on
colorscale={'blue' 'green' 'green' 'green' 'green' 'red' 'blue'};
eventseverity=zeros(1,size(cellevent,2));
for i=1:size(cellevent,2)

        event=cell2mat(cellevent(i));
        eventseverity(i)=sum(sum(event(1:end-4,:)>0));
           
    xtop=nan(1,size(event,2));
    xbottom=nan(1,size(event,2));
    y=mod(event(end-1,:),24*60/timeinterval);
    % check whether event last overnight
    overnight=0;
    for k=1:length(y)-1
        if y(k)>y(k+1)
            overnight=1;
            brk=k;
        end
    end
    
    for j=1:size(event,2)
        c=find(event(1:end-4,j)>0);
        xtop(j)=c(1);
        xbottom(j)=c(end);
    end
    if direction==1
            xedge=xtop;
        else xedge=xbottom;
    end
    dayofweek=weekday(startdatenum+floor(event(end-1,1)/(24*60/timeinterval)));
    if overnight==0;
%         plot(y,xedge,cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
    else plot(y(1:brk),xedge(1:brk),cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
%         plot(y(brk+1:end),xedge(brk+1:end),cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
    end

end

for j = 1:length(wzloc)
%     plot([0 size(TrafficData,2)],[wzloc(j) wzloc(j)],'black--','linewidth',workzoneboundaryweight) 
end
% ylim([0,size(TrafficData,1)]);
% set(gca,'YDir','Reverse')
% xlim([0,size(TrafficData,2)]);
% 
% set(gca,'YTick',[1,(size(TrafficData,1)-1)/4+1,(size(TrafficData,1)-1)*2/4+1,(size(TrafficData,1)-1)*3/4+1,size(TrafficData,1)])
% set(gca,'YTickLabel',{num2str(milemarker(1,end)),num2str((milemarker(end,end)-milemarker(1,end))/4+milemarker(1,end)),...
%     num2str((milemarker(end,end)-milemarker(1,end))*2/4+milemarker(1,end)),...
%     num2str((milemarker(end,end)-milemarker(1,end))*3/4+milemarker(1,end)),num2str(milemarker(end,end))})
% set(gca,'XTick',[1/4*24*60/timeinterval,3/4*24*60/timeinterval])
% set(gca,'XTickLabel',{'6:00am','6:00pm'})
% set(gca,'XGrid','on')
% title('events overlaid by time of day through the report period (green:Mon-Thu/red:Fri/blue:Sat,Sun)');
%%
% select the top n biggest events and plot overlaid

colorscale={'blue' 'green' 'green' 'green' 'green' 'red' 'blue'};
selectscale=[1:size(cellevent,2);eventseverity];
selectscale=sortrows(selectscale',-2);

realn=0;
if n<size(cellevent,2)
    realn=n;
else realn=size(cellevent,2);
end

bigeventIDs=selectscale(1:realn,1);

% subplot(3,1,2)
subplot(2,1,1)
hold on

if realn>0
    
    topeventday=cell(realn,1);
    topeventstarttime=cell(realn,1);
    topeventendtime=cell(realn,1);
    
    for i=1:realn

        event=cell2mat(cellevent(bigeventIDs(i)));
        
        topeventday(i)={datestr(startdatenum+floor(event(end-1,1)/(24*60/timeinterval)))};
        starttime=mod(event(end-1,1),(24*60/timeinterval));
        endtime=mod(event(end-1,end),(24*60/timeinterval));
        starthour=floor(starttime/(60/timeinterval));
        startminute=mod(starttime,60/timeinterval)*timeinterval;     
        endhour=floor(endtime/(60/timeinterval));
        endminute=(mod(endtime,60/timeinterval)+1)*timeinterval;
        if starthour<10;SH = ['0' num2str(starthour)];else SH = num2str(starthour);end
        if startminute<10;SM = ['0' num2str(startminute)];else SM = num2str(startminute);end
        if endhour<10;EH = ['0' num2str(endhour)];else EH = num2str(endhour);end
        if endminute<10;EM = ['0' num2str(endminute)];else EM = num2str(endminute);end
        topeventstarttime(i)={[SH ':' SM]};
        topeventendtime(i)={[EH ':' EM]};
        
        xtop=nan(1,size(event,2));
        xbottom=nan(1,size(event,2));
        y=mod(event(end-1,:),24*60/timeinterval);
        % check whether event last overnight
        overnight=0;
        for k=1:length(y)-1
            if y(k)>y(k+1)
                overnight=1;
                brk=k;
            end
        end

        for j=1:size(event,2)
            c=find(event(1:end-4,j)>0);
            xtop(j)=c(1);
            xbottom(j)=c(end);
        end
        if direction==1
                xedge=xtop;                
            else xedge=xbottom;
        end
        dayofweek=weekday(startdatenum+floor(event(end-1,1)/(24*60/timeinterval)));
        if overnight==0;
            plot(y,xedge,cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
        else plot(y(1:brk),xedge(1:brk),cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
            plot(y(brk+1:end),xedge(brk+1:end),cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
        end
        if direction==1
                % number the events
                text(y(1),xedge(1)-0.022*size(TrafficData,1),num2str(i),'FontWeight','bold','Color','k');
            else 
                % number the events
                text(y(1),xedge(1)+0.022*size(TrafficData,1),num2str(i),'FontWeight','bold','Color','k');
        end
        
        
    end
end
for j = 1:length(wzloc)
    plot([0 size(TrafficData,2)],[wzloc(j) wzloc(j)],'black--','linewidth',workzoneboundaryweight) 
end

ylim([0,size(TrafficData,1)]);
set(gca,'YDir','Reverse')
xlim([0,size(TrafficData,2)]);
% plot the time for top events
YY=get(gca,'ylim');
textlocation = linspace(0+0.5/realn,1-0.5/realn,realn);
fontsize = 10;
for j=1:realn
    content = [num2str(j) '. ' topeventday{j} ' ' topeventstarttime{j} '-' topeventendtime{j}];   
    text(size(TrafficData,2),YY(2)*textlocation(j),content,'FontSize',fontsize,'FontWeight','bold')
end   

set(gca,'YTick',[1,(size(TrafficData,1)-1)/4+1,(size(TrafficData,1)-1)*2/4+1,(size(TrafficData,1)-1)*3/4+1,size(TrafficData,1)])
set(gca,'YTickLabel',{num2str(milemarker(1,end)),num2str((milemarker(end,end)-milemarker(1,end))/4+milemarker(1,end)),...
    num2str((milemarker(end,end)-milemarker(1,end))*2/4+milemarker(1,end)),...
    num2str((milemarker(end,end)-milemarker(1,end))*3/4+milemarker(1,end)),num2str(milemarker(end,end))})
set(gca,'XTick',[1/4*24*60/timeinterval,3/4*24*60/timeinterval])
set(gca,'XTickLabel',{'6:00am','6:00pm'})
set(gca,'XGrid','on')
title(['top ' num2str(realn) ' biggest events overlaid by time of day through the report period (green:Mon-Thu/red:Fri/blue:Sat,Sun)']);
%%
% top n biggest events plot separately

% subplot(3,1,3)
% hold on
tradeoffleft=0;
tradeoffright=0;

if realn>0
    
    topeventday=cell(realn,1);
    topeventstarttime=cell(realn,1);
    
    for i=1:realn

        event=cell2mat(cellevent(bigeventIDs(i)));
        topeventday(i)={datestr(startdatenum+floor(event(end-1,1)/(24*60/timeinterval)))};
        starttime=mod(event(end-1,1),(24*60/timeinterval));
        starthour=floor(starttime/(60/timeinterval));
        startminute=mod(starttime,60/timeinterval)*timeinterval;
        
        topeventstarttime(i)={[num2str(starthour) ':' num2str(startminute)]};
        
        xtop=nan(1,size(event,2));
        xbottom=nan(1,size(event,2));
        y=mod(event(end-1,:),24*60/timeinterval);
        % check whether event last overnight
        overnight=0;
        for k=1:length(y)-1
            if y(k)>y(k+1)
                overnight=1;
                brk=k;
            end
        end

        for j=1:size(event,2)
            c=find(event(1:end-4,j)>0);
            xtop(j)=c(1);
            xbottom(j)=c(end);
        end
        xtop=xtop-min(xtop)+tradeoffleft;
        xbottom=xbottom-min(xbottom)+tradeoffright;
        tradeoffleft=max(xtop);
        tradeoffright=max(xbottom);
        if direction==1
                xedge=xtop;
                tradeoff=tradeoffleft;
            else xedge=xbottom;
                tradeoff=tradeoffright;
        end
        dayofweek=weekday(startdatenum+floor(event(end-1,1)/(24*60/timeinterval)));
        if overnight==0;
%             plot(y,xedge,cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
        else plot(y(1:brk),xedge(1:brk),cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
%             plot(y(brk+1:end),xedge(brk+1:end),cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
        end

%     plot(1:24*60/timeinterval,ones(1,24*60/timeinterval)*tradeoff);
    end
    
    YY=get(gca,'ylim');
    textlocation = linspace(0+0.5/realn,1-0.5/realn,realn);
    fontsize = 10;
    for j=1:realn
    content = [num2str(j) '. ' topeventday{j} ' ' topeventstarttime{j}];   
%     text(290,YY(2)*textlocation(j),content,'FontSize',fontsize,'FontWeight','bold')
    end   
    
end
% xlim([0,320])
% set(gca,'YDir','Reverse')
% set(gca,'YTickLabel',{})
% set(gca,'XTick',[1/4*24*60/timeinterval,3/4*24*60/timeinterval])
% set(gca,'XTickLabel',{'6:00am','6:00pm'})
% set(gca,'XGrid','on')
% title(['top ' num2str(realn) ' biggest events separate plot (green:Mon-Thu/red:Fri/blue:Sat,Sun)']);

export_fig([folder '\' groupname '\' reportstartday '-' reportendday '_' groupname '_TopEvents.pdf'],'-append')

