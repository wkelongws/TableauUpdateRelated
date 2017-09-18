% event plot
function [figurenum,cellevent,spreadsheetmax]...
    =eventplot(eventamplifier,TrafficData,volume,speed,figurenum,eventspeed,...
    timeinterval,distanceinterval,startdatenum,speedlimit,direction,milemarker,groupname,performancemetrics,y,reportstartday,reportendday)
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
speedspreadsheet=nan(size(speed,1),size(speed,3)*size(speed,2));
for i=1:size(TrafficData,3)
    rawspreadsheet(:,(i-1)*size(TrafficData,2)+1:i*size(TrafficData,2),:)=TrafficData(:,:,i);
    volumespreadsheet(:,(i-1)*size(volume,2)+1:i*size(volume,2),:)=volume(:,:,i);
    speedspreadsheet(:,(i-1)*size(speed,2)+1:i*size(speed,2),:)=speed(:,:,i);
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

spreadsheetmax=spreadsheet(end-1,end);
% convert to cell format, events in separate cells
[~,~,uniqueIndex] = unique(spreadsheet2(end-2,:));
cellevent = mat2cell(spreadsheet2,size(spreadsheet2,1),accumarray(uniqueIndex(:),1));
[~,~,uniqueIndex] = unique(spreadsheet1(end-2,:));
cellnonevent = mat2cell(spreadsheet1,size(spreadsheet1,1),accumarray(uniqueIndex(:),1));
numevent=size(cellevent,2);
numnonevent=size(cellnonevent,2);

% other parameter
n=0;    % top n events
COLOR={'green' 'red' 'yellow' 'blue'}; %{12am-6am/8pm-12am, 6am-10am, 10am-4pm, 4pm-8pm}
color=[0.8,0.8,0.8];%patch color
timelabelgaprate=50;
workzoneboundaryweight=1.2;
eventfrontierweight=1.5;
eventfrontiermarkersize=6;

duration=       zeros(1,size(cellevent,2));
avgmaxqueue=    zeros(1,size(cellevent,2));
numeventday=    nan(1,size(cellevent,2));
queue=          cell(1,size(cellevent,2));
spiltout=       zeros(1,size(cellevent,2));
queuedvolume=0;
queueddelay=0;
queuedvolumehighdelay=0;

%% write performance metrics
figurenum=figurenum+1;
scrsz=get(groot,'ScreenSize');
h=figure('Name',num2str(figurenum),'Position',scrsz);
set(gcf, 'Color', [1,1,1]);

comments={'1. number of days:','2. number of events:','3. number of daytime events:',...
    '4. number of days when events happened:',...
    '5. average duration of each event:','6. median duration of each event:',...
    '7. average queue length:','8. average maximum queue length of each event:',...
    '9. median maximum queue length of each event:','10. max maximum queue length of each event:',...
    '11.percentage of queue > 1 mile:','12.amount of traffic that encounters a queue:',...
    '13.total traffic:','14.percentage of traffic that encounters a queue:',...
    '15.percentage of time that encounters a queue:','16.total delay:','17.total delay per day:',...
    '18.average delay per vehicle:','19.maximum delay:','20.total delay when queue is present:',...
    '21.percentage of delay caused by queue:','22.avg delay when queue is present:',...
    '23.percent of vehicles experiencing delay > 5 min:','24.percent of vehicles experiencing delay > 10 min:',...
    '25.percent of vehicles in queue experiencing delay > 5 min:',...
    '26.percent of vehicles in queue experiencing delay > 10 min:'};
units={'','','','','min','min','mile','mile','mile','mile','','','','','','veh*hour','veh*hour'...
    ,'min/veh','min','veh*hour','','min/veh','','','',''};
fontsize = 15;
brk=round(size(comments,2)/2);

textlocation1 = fliplr(linspace(0+0.5/brk,1-0.5/brk,brk));
textlocation2 = fliplr(linspace(0+0.5/(size(comments,2)-brk),1-0.5/(size(comments,2)-brk),(size(comments,2)-brk)));

subplot(2,2,3);
set(gca,'visible','off');
for j=1:brk
    content = [comments{j} ' ' num2str(performancemetrics(j)) ' ' units{j}];   
    text(0,textlocation1(j),content,'FontSize',fontsize)
end

subplot(2,2,4);
set(gca,'visible','off');
for j=brk+1:size(comments,2)
    content = [comments{j} ' ' num2str(performancemetrics(j)) ' ' units{j}];   
    text(0,textlocation2(j-brk),content,'FontSize',fontsize)
end

subplot(2,1,1);
set(gca,'visible','off');
text(0.35,-0.2,[groupname ' Direction ' num2str(direction) ' performance metrics'],'FontWeight','bold','FontSize',12,'EdgeColor',[0 0 0])

export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_PerformanceMetrics.pdf'],'-append')


%%
% plot highlighted events (queue frontier) through the report period
figurenum=figurenum+1;
scrsz=get(groot,'ScreenSize');
h=figure('Name',num2str(figurenum),'Position',scrsz);
set(gcf, 'Color', [1,1,1]);

% subplot
% plot nonevent patch
% plot event frontier
% plot workzone boundary
subplot(2,1,2) %top subplot
hold on
for i=1:numevent
    %%%%%% plot nonevent patch %%%%%%
    if i<=numnonevent
    nonevent=cell2mat(cellnonevent(i));
    patch([nonevent(end,1)+0.1-1/eventamplifier,nonevent(end,end)+0.9,nonevent(end,end)+0.9,nonevent(end,1)+0.1-1/eventamplifier]'...
        ,[0,0,size(TrafficData,1),size(TrafficData,1)]',color,'EdgeColor','none');
    end
    %%%%%% plot event frontier %%%%%%
    if ~isempty(cellevent)
        event=cell2mat(cellevent(i));
        xtop=nan(1,size(event,2));
        xbottom=nan(1,size(event,2));
        xtime=nan(1,size(event,2));
        for j=1:size(event,2)
            c=find(event(1:end-4,j)>0);
            xtop(j)=c(1);
            xbottom(j)=c(end);
            time=mod(event(end-1,j),288);
            if time<72 || time>240
            xtime(j)=1;
            else if time<120
                    xtime(j)=2;
                else if time<192
                        xtime(j)=3;
                    else xtime(j)=4;
                    end
                end
            end
        end
        if direction==1
            xedge=xtop;
        else xedge=xbottom;
        end
        plot(event(end,:),xedge,cell2mat(COLOR(xtime(1))),'LineWidth',eventfrontierweight,'Marker','.','MarkerSize',eventfrontiermarkersize)    
    end
end
if numnonevent>numevent
    nonevent=cell2mat(cellnonevent(end));
    patch([nonevent(end,1)+0.1-1/eventamplifier,nonevent(end,end)+0.9,nonevent(end,end)+0.9,nonevent(end,1)+0.1-1/eventamplifier]'...
        ,[0,0,size(TrafficData,1),size(TrafficData,1)]',color,'EdgeColor','none');
end
    %%%%%% plot work zone boundary %%%%%%

for j = 1:length(wzloc)
    plot([0 xcoordinate(end)+0.9],[wzloc(j) wzloc(j)],'blue--','linewidth',workzoneboundaryweight) 
end
xlim([0,xcoordinate(end)]+0.9);
set(gca,'YDir','Reverse')
ylim([0,size(TrafficData,1)+1]);
if size(TrafficData,1)==1
    set(gca,'YTick',[1])
    set(gca,'YTickLabel',{num2str(milemarker(1,end))});
else
set(gca,'YTick',[1,(size(TrafficData,1)-1)/4+1,(size(TrafficData,1)-1)*2/4+1,(size(TrafficData,1)-1)*3/4+1,size(TrafficData,1)])
set(gca,'YTickLabel',{num2str(milemarker(1,end)),num2str((milemarker(end,end)-milemarker(1,end))/4+milemarker(1,end)),...
    num2str((milemarker(end,end)-milemarker(1,end))*2/4+milemarker(1,end)),...
    num2str((milemarker(end,end)-milemarker(1,end))*3/4+milemarker(1,end)),num2str(milemarker(end,end))})
end
oneday=24*60/timeinterval;
days=floor((1:oneday:size(spreadsheet,2))/288)+startdatenum;
day=cellstr(datestr(days));
timetick=xcoordinate((1:oneday:size(spreadsheet,2)));
timeticklabel=day;
% labelgapref=timetick(1);
% for i=2:length(timetick)
%     if timetick(i)-labelgapref<xcoordinate(end)/timelabelgaprate
%         timeticklabel(i)={''};
%     else labelgapref=timetick(i);
%     end
% end
set(gca,'XTick',timetick)  % mark the start of each day
set(gca,'XTickLabel',timeticklabel)
set(gca,'xgrid','on')
subplot(2,1,1)
set(gca,'visible','off');
text(0.1,0.0,'highlighted events (queue frontier) through the report period (colored by time of day: green(8pm-6am),red(6am-10am),yellow(10am-4pm),blue(4pm-8pm))','FontWeight','bold','FontSize',12,'EdgeColor',[0 0 0])
text(0.2,-0.2,[groupname ' Direction ' num2str(direction) ' (smoothed)  timescale (event : nonevent = ' num2str(eventamplifier) ':1)'],'FontWeight','bold','FontSize',12,'EdgeColor',[0 0 0])
% % % % % % % % % % export_fig([y '\' groupname '\Shockwaves_' groupname '_' reportstartday '-' reportendday '.pdf'],'-append')

%%
% mark the start of all mondays

