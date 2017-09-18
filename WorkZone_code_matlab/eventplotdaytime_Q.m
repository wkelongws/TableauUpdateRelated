% eventplot daytime

% event plot
function [figurenum,cellevent,spreadsheetmax]...
    =eventplotdaytime(eventamplifier,TrafficData,volume,speed,figurenum,eventspeed,...
    timeinterval,distanceinterval,startdatenum,speedlimit,direction,milemarker,groupname,y,reportstartday,reportendday)
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

%%%%%%%%%%%%%%%% remove nighttime events  %%%%%%%%%%%%%%%%
spreadsheet(end-3,logical((spreadsheet(end-3,:)>0) .* ((mod(spreadsheet(end-1,:),288)<72) + (mod(spreadsheet(end-1,:),288)>240))))=0;

for i=2:size(spreadsheet,2)
    if spreadsheet(end-3,i)>0 && spreadsheet(end-3,i-1)==0 && spreadsheet(end-2,i)==spreadsheet(end-2,i-1)
        spreadsheet(end-3,i)=0;
    end
end
eventno(1)=0;
for i=2:size(spreadsheet,2)
    if spreadsheet(end-3,i)>0 && spreadsheet(end-3,i-1)==0
        eventno(i)=eventno(i-1)+1;
    else eventno(i)=eventno(i-1);
    end
end
spreadsheet(end-2,:)=eventno;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

% other parameter
n=10;    % top n events
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

% %%
% % plot highlighted events (queue frontier) through the report period
% figurenum=figurenum+1;
% scrsz=get(groot,'ScreenSize');
% h=figure('Name',num2str(figurenum),'Position',scrsz);
% set(gcf, 'Color', [1,1,1]);
% 
% breakpoint1=xcoordinate(end)/3;
% breakpoint2=xcoordinate(end)*2/3;
% breakeventID1=max(spreadsheet(end-2,(spreadsheet(end,:)<breakpoint1)));
% breakeventID2=max(spreadsheet(end-2,(spreadsheet(end,:)<breakpoint2)));
% if breakeventID1==0
%     breakeventID1=1;
% end
% if breakeventID2==0
%     breakeventID2=1;
% end
% % subplot
% % plot nonevent patch
% % plot event frontier
% % plot workzone boundary
% subplot(4,1,2) %top subplot
% hold on
% for i=1:breakeventID1
%     %%%%%% plot nonevent patch %%%%%%
%     nonevent=cell2mat(cellnonevent(i));
%     patch([nonevent(end,1)+0.1-1/eventamplifier,nonevent(end,end)+0.9,nonevent(end,end)+0.9,nonevent(end,1)+0.1-1/eventamplifier]'...
%         ,[0,0,size(TrafficData,1),size(TrafficData,1)]',color,'EdgeColor','none');
%     if i==breakeventID1
%         xbreak1=nonevent(end,end);
%     end
%     %%%%%% plot event frontier %%%%%%
%     if ~isempty(cellevent)
%         event=cell2mat(cellevent(i));
%         xtop=nan(1,size(event,2));
%         xbottom=nan(1,size(event,2));
%         xtime=nan(1,size(event,2));
%         for j=1:size(event,2)
%             c=find(event(1:end-4,j)>0);
%             xtop(j)=c(1);
%             xbottom(j)=c(end);
%             time=mod(event(end-1,j),288);
%             if time<72 || time>240
%             xtime(j)=1;
%             else if time<120
%                     xtime(j)=2;
%                 else if time<192
%                         xtime(j)=3;
%                     else xtime(j)=4;
%                     end
%                 end
%             end
%         end
%         if direction==1
%             xedge=xtop;
%         else xedge=xbottom;
%         end
%         plot(event(end,:),xedge,cell2mat(COLOR(xtime(1))),'LineWidth',eventfrontierweight,'Marker','.','MarkerSize',eventfrontiermarkersize)    
%     end
% end
%     %%%%%% plot work zone boundary %%%%%%
% for j = 1:length(wzloc)
%     plot([0 xbreak1],[wzloc(j) wzloc(j)],'blue--','linewidth',workzoneboundaryweight) 
% end
% xlim([0,xbreak1]);
% set(gca,'YDir','Reverse')
% ylim([0,size(TrafficData,1)]);
% set(gca,'YTick',[1,(size(TrafficData,1)-1)/4+1,(size(TrafficData,1)-1)*2/4+1,(size(TrafficData,1)-1)*3/4+1,size(TrafficData,1)])
% set(gca,'YTickLabel',{num2str(milemarker(1,end)),num2str((milemarker(end,end)-milemarker(1,end))/4+milemarker(1,end)),...
%     num2str((milemarker(end,end)-milemarker(1,end))*2/4+milemarker(1,end)),...
%     num2str((milemarker(end,end)-milemarker(1,end))*3/4+milemarker(1,end)),num2str(milemarker(end,end))})
% startcheck=[2 1;3 7;4 6;5 5;6 4;7 3;1 2];
% firstmonday=startcheck(startcheck(:,1)==weekday(startdatenum),2);
% oneweek=24*60/timeinterval;
% days=floor((((firstmonday-1)*oneweek+1):(7*oneweek):size(spreadsheet1,2))/288)+startdatenum;
% day=cellstr(datestr(days));
% % timetick=xcoordinate((firstmonday*oneweek+1):(7*oneweek):size(spreadsheet1,2));
% % timeticklabel=day;
% % labelgapref=timetick(1);
% % for i=2:length(timetick)
% %     if timetick(i)-labelgapref<xcoordinate(end)/timelabelgaprate
% %         timeticklabel(i)={''};
% %     else labelgapref=timetick(i);
% %     end
% % end
% % set(gca,'XTick',timetick)  % mark one day every week
% % set(gca,'XTickLabel',timeticklabel)
% 
% subplot(4,1,3) %middle subplot
% hold on
% for i=breakeventID1:breakeventID2
%     nonevent=cell2mat(cellnonevent(i));
%     patch([nonevent(end,1)+0.1-1/eventamplifier,nonevent(end,end)+0.9,nonevent(end,end)+0.9,nonevent(end,1)+0.1-1/eventamplifier]'...
%         ,[0,0,size(TrafficData,1),size(TrafficData,1)]',color,'EdgeColor','none');
%     if i==breakeventID2
%         xbreak2=nonevent(end,end);
%     end
%     %%%%%% plot event frontier %%%%%%
%     if ~isempty(cellevent)
%         event=cell2mat(cellevent(i));
%         xtop=nan(1,size(event,2));
%         xbottom=nan(1,size(event,2));
%         xtime=nan(1,size(event,2));
%         for j=1:size(event,2)
%             c=find(event(1:end-4,j)>0);
%             xtop(j)=c(1);
%             xbottom(j)=c(end);
%             time=mod(event(end-1,j),288);
%             if time<72 || time>240
%             xtime(j)=1;
%             else if time<120
%                     xtime(j)=2;
%                 else if time<192
%                         xtime(j)=3;
%                     else xtime(j)=4;
%                     end
%                 end
%             end
%         end
%         if direction==1
%             xedge=xtop;
%         else xedge=xbottom;
%         end
%         plot(event(end,:),xedge,cell2mat(COLOR(xtime(1))),'LineWidth',eventfrontierweight,'Marker','.','MarkerSize',eventfrontiermarkersize)
%     end
% end
% %%%%%% plot work zone boundary %%%%%%
% for j = 1:length(wzloc)
%     plot([xbreak1 xbreak2],[wzloc(j) wzloc(j)],'blue--','linewidth',workzoneboundaryweight) 
% end
% if xbreak1<xbreak2
% xlim([xbreak1,xbreak2]);
% else xlim([0,xbreak2]);
% end
% set(gca,'YDir','Reverse')
% ylim([0,size(TrafficData,1)]);
% ylabel('Mile Marker')
% set(gca,'YTick',[1,(size(TrafficData,1)-1)/4+1,(size(TrafficData,1)-1)*2/4+1,(size(TrafficData,1)-1)*3/4+1,size(TrafficData,1)])
% set(gca,'YTickLabel',{num2str(milemarker(1,end)),num2str((milemarker(end,end)-milemarker(1,end))/4+milemarker(1,end)),...
%     num2str((milemarker(end,end)-milemarker(1,end))*2/4+milemarker(1,end)),...
%     num2str((milemarker(end,end)-milemarker(1,end))*3/4+milemarker(1,end)),num2str(milemarker(end,end))})
% startcheck=[2 1;3 7;4 6;5 5;6 4;7 3;1 2];
% firstmonday=startcheck(startcheck(:,1)==weekday(startdatenum),2);
% oneweek=24*60/timeinterval;
% days=floor((((firstmonday-1)*oneweek+1):(7*oneweek):size(spreadsheet1,2))/288)+startdatenum;
% day=cellstr(datestr(days));
% % timetick=xcoordinate((firstmonday*oneweek+1):(7*oneweek):size(spreadsheet1,2));
% % timeticklabel=day;
% % labelgapref=timetick(1);
% % for i=2:length(timetick)
% %     if timetick(i)-labelgapref<xcoordinate(end)/timelabelgaprate
% %         timeticklabel(i)={''};
% %     else labelgapref=timetick(i);
% %     end
% % end
% % set(gca,'XTick',timetick)  % mark one day every week
% % set(gca,'XTickLabel',timeticklabel)
% 
% subplot(4,1,4) %bottom subplot
% hold on
% for i=breakeventID2:size(cellnonevent,2)
%     nonevent=cell2mat(cellnonevent(i));
%     patch([nonevent(end,1)+0.1-1/eventamplifier,nonevent(end,end)+0.9,nonevent(end,end)+0.9,nonevent(end,1)+0.1-1/eventamplifier]'...
%         ,[0,0,size(TrafficData,1),size(TrafficData,1)]',color,'EdgeColor','none');
%     if i>size(cellevent,2)
%         break
%     end
%     %%%%%% plot event frontier %%%%%%
%     if ~isempty(cellevent)
%         event=cell2mat(cellevent(i));
%         xtop=nan(1,size(event,2));
%         xbottom=nan(1,size(event,2));
%         xtime=nan(1,size(event,2));
%         for j=1:size(event,2)
%             c=find(event(1:end-4,j)>0);
%             xtop(j)=c(1);
%             xbottom(j)=c(end);
%             time=mod(event(end-1,j),288);
%             if time<72 || time>240
%             xtime(j)=1;
%             else if time<120
%                     xtime(j)=2;
%                 else if time<192
%                         xtime(j)=3;
%                     else xtime(j)=4;
%                     end
%                 end
%             end
%         end
%         if direction==1
%             xedge=xtop;
%         else xedge=xbottom;
%         end
%         plot(event(end,:),xedge,cell2mat(COLOR(xtime(1))),'LineWidth',eventfrontierweight,'Marker','.','MarkerSize',eventfrontiermarkersize)
%     end
% end
% %%%%%% plot work zone boundary %%%%%%
% for j = 1:length(wzloc)
%     plot([xbreak2 xcoordinate(end)],[wzloc(j) wzloc(j)],'blue--','linewidth',workzoneboundaryweight) 
% end
% if xbreak2 == xcoordinate(end)
%     if xbreak1 == xbreak2
%         xlim([0,xcoordinate(end)]);
%     else xlim([xbreak1,xcoordinate(end)]);
%     end
% else xlim([xbreak2,xcoordinate(end)]);
% end
% 
% set(gca,'YDir','Reverse')
% ylim([0,size(TrafficData,1)]);
% xlabel('time (marked by 12:00am on Mondays)')
% set(gca,'YTick',[1,(size(TrafficData,1)-1)/4+1,(size(TrafficData,1)-1)*2/4+1,(size(TrafficData,1)-1)*3/4+1,size(TrafficData,1)])
% set(gca,'YTickLabel',{num2str(milemarker(1,end)),num2str((milemarker(end,end)-milemarker(1,end))/4+milemarker(1,end)),...
%     num2str((milemarker(end,end)-milemarker(1,end))*2/4+milemarker(1,end)),...
%     num2str((milemarker(end,end)-milemarker(1,end))*3/4+milemarker(1,end)),num2str(milemarker(end,end))})
% startcheck=[2 1;3 7;4 6;5 5;6 4;7 3;1 2];
% firstmonday=startcheck(startcheck(:,1)==weekday(startdatenum),2);
% oneweek=24*60/timeinterval;
% days=floor((((firstmonday-1)*oneweek+1):(7*oneweek):size(spreadsheet1,2))/288)+startdatenum;
% day=cellstr(datestr(days));
% % timetick=xcoordinate((firstmonday*oneweek+1):(7*oneweek):size(spreadsheet1,2));
% % timeticklabel=day;
% % labelgapref=timetick(1);
% % for i=2:length(timetick)
% %     if timetick(i)-labelgapref<xcoordinate(end)/timelabelgaprate
% %         timeticklabel(i)={''};
% %     else labelgapref=timetick(i);
% %     end
% % end
% % set(gca,'XTick',timetick)  % mark one day every week
% % set(gca,'XTickLabel',timeticklabel)
% 
% subplot(4,1,1)
% set(gca,'visible','off');
% text(0.1,0.0,'highlighted daytime events (queue frontier) through the report period (colored by time of day: red(6am-10am),yellow(10am-4pm),blue(4pm-8pm))','FontWeight','bold','FontSize',12,'EdgeColor',[0 0 0])
% text(0.2,-0.2,[groupname ' Direction ' num2str(direction) ' (smoothed)  timescale (event : nonevent = ' num2str(eventamplifier) ':1)'],'FontWeight','bold','FontSize',12,'EdgeColor',[0 0 0])
% export_fig([y '\' groupname '\PerformanceMetrics.pdf'],'-append')
% 
% %%
% % mark the start of all mondays
% %%
% % plot events (queue frontier) overlaid by time of day through the report period
% figurenum=figurenum+1;
% scrsz=get(groot,'ScreenSize');
% h=figure('Name',num2str(figurenum),'Position',scrsz);
% set(gcf, 'Color', [1,1,1]);
% 
% subplot(3,1,1)
% hold on
% colorscale={'blue' 'green' 'green' 'green' 'green' 'red' 'blue'};
% eventseverity=zeros(1,size(cellevent,2));
% for i=1:size(cellevent,2)
% 
%         event=cell2mat(cellevent(i));
%         eventseverity(i)=sum(sum(event(1:end-4,:)>0));
%            
%     xtop=nan(1,size(event,2));
%     xbottom=nan(1,size(event,2));
%     y=mod(event(end-1,:),24*60/timeinterval);
%     % check whether event last overnight
%     overnight=0;
%     for k=1:length(y)-1
%         if y(k)>y(k+1)
%             overnight=1;
%             brk=k;
%         end
%     end
%     
%     for j=1:size(event,2)
%         c=find(event(1:end-4,j)>0);
%         xtop(j)=c(1);
%         xbottom(j)=c(end);
%     end
%     if direction==1
%             xedge=xtop;
%         else xedge=xbottom;
%     end
%     dayofweek=weekday(startdatenum+floor(event(end-1,1)/(24*60/timeinterval)));
%     if overnight==0;
%         plot(y,xedge,cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
%     else plot(y(1:brk),xedge(1:brk),cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
%         plot(y(brk+1:end),xedge(brk+1:end),cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
%     end
% 
% end
% 
% for j = 1:length(wzloc)
%     plot([0 size(TrafficData,2)],[wzloc(j) wzloc(j)],'black--','linewidth',workzoneboundaryweight) 
% end
% % plot(1:24*60/timeinterval,ones(1,24*60/timeinterval)*(WZbound1)); %%%%%% zork zone location change it
% % plot(1:24*60/timeinterval,ones(1,24*60/timeinterval)*(WZbound2)); %%%%%% zork zone location change it
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
% title('daytime events overlaid by time of day through the report period (green:Mon-Thu/red:Fri/blue:Sat,Sun)');
% %%
% % select the top n biggest events and plot overlaid
% 
% colorscale={'blue' 'green' 'green' 'green' 'green' 'red' 'blue'};
% selectscale=[1:size(cellevent,2);eventseverity];
% %for i=1:size(cellspreadsheet,2)
% %    selectscale(2,i)=size(cell2mat(cellspreadsheet(i)),2);
% %end
% selectscale=sortrows(selectscale',-2);
% 
% realn=0;
% if n<size(cellevent,2)
%     realn=n;
% else realn=size(cellevent,2);
% end
% 
% bigeventIDs=selectscale(1:realn,1);
% 
% subplot(3,1,2)
% hold on
% 
% if realn>0
%     for i=1:realn
% 
%         event=cell2mat(cellevent(bigeventIDs(i)));
%         xtop=nan(1,size(event,2));
%         xbottom=nan(1,size(event,2));
%         y=mod(event(end-1,:),24*60/timeinterval);
%         % check whether event last overnight
%         overnight=0;
%         for k=1:length(y)-1
%             if y(k)>y(k+1)
%                 overnight=1;
%                 brk=k;
%             end
%         end
% 
%         for j=1:size(event,2)
%             c=find(event(1:end-4,j)>0);
%             xtop(j)=c(1);
%             xbottom(j)=c(end);
%         end
%         if direction==1
%                 xedge=xtop;
%             else xedge=xbottom;
%         end
%         dayofweek=weekday(startdatenum+floor(event(end-1,1)/(24*60/timeinterval)));
%         if overnight==0;
%             plot(y,xedge,cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
%         else plot(y(1:brk),xedge(1:brk),cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
%             plot(y(brk+1:end),xedge(brk+1:end),cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
%         end
% 
%     end
% end
% for j = 1:length(wzloc)
%     plot([0 size(TrafficData,2)],[wzloc(j) wzloc(j)],'black--','linewidth',workzoneboundaryweight) 
% end
% % plot(1:24*60/timeinterval,ones(1,24*60/timeinterval)*(WZbound1)); %%%%%% zork zone location change it
% % plot(1:24*60/timeinterval,ones(1,24*60/timeinterval)*(WZbound2)); %%%%%% zork zone location change it
% 
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
% title(['top ' num2str(realn) ' biggest daytime events overlaid by time of day through the report period (green:Mon-Thu/red:Fri/blue:Sat,Sun)']);
% %%
% % top n biggest events plot separately
% 
% subplot(3,1,3)
% hold on
% tradeoffleft=0;
% tradeoffright=0;
% 
% if realn>0
%     
%     topeventday=cell(realn,1);
%     topeventtime=cell(realn,1);
%     
%     for i=1:realn
% 
%         event=cell2mat(cellevent(bigeventIDs(i)));
%         topeventday(i)={datestr(startdatenum+floor(event(end-1,1)/(24*60/timeinterval)))};
%         time=mod(event(end-1,1),(24*60/timeinterval));
%         hour=floor(time/(60/timeinterval));
%         minute=mod(time,60/timeinterval)*timeinterval;
%         
%         topeventtime(i)={[num2str(hour) ':' num2str(minute)]};
%         
%         xtop=nan(1,size(event,2));
%         xbottom=nan(1,size(event,2));
%         y=mod(event(end-1,:),24*60/timeinterval);
%         % check whether event last overnight
%         overnight=0;
%         for k=1:length(y)-1
%             if y(k)>y(k+1)
%                 overnight=1;
%                 brk=k;
%             end
%         end
% 
%         for j=1:size(event,2)
%             c=find(event(1:end-4,j)>0);
%             xtop(j)=c(1);
%             xbottom(j)=c(end);
%         end
%         xtop=xtop-min(xtop)+tradeoffleft;
%         xbottom=xbottom-min(xbottom)+tradeoffright;
%         tradeoffleft=max(xtop);
%         tradeoffright=max(xbottom);
%         if direction==1
%                 xedge=xtop;
%                 tradeoff=tradeoffleft;
%             else xedge=xbottom;
%                 tradeoff=tradeoffright;
%         end
%         dayofweek=weekday(startdatenum+floor(event(end-1,1)/(24*60/timeinterval)));
%         if overnight==0;
%             plot(y,xedge,cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
%         else plot(y(1:brk),xedge(1:brk),cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
%             plot(y(brk+1:end),xedge(brk+1:end),cell2mat(colorscale(dayofweek)),'LineWidth',3,'Marker','.','MarkerSize',10)
%         end
% 
%     plot(1:24*60/timeinterval,ones(1,24*60/timeinterval)*tradeoff);
%     end
%     
% % subplot(2,8,1);
% %      set(gca,'visible','off');
%     YY=get(gca,'ylim');
%     textlocation = linspace(0+0.5/realn,1-0.5/realn,realn);
%     fontsize = 10;
%     for j=1:realn
%     content = [num2str(j) '. ' topeventday{j} ' ' topeventtime{j}];   
%     text(290,YY(2)*textlocation(j),content,'FontSize',fontsize,'FontWeight','bold')
%     end   
%     
% end
% xlim([0,320])
% set(gca,'YDir','Reverse')
% %ylim([0,size(TrafficData,1)]);
% set(gca,'YTickLabel',{})
% set(gca,'XTick',[1/4*24*60/timeinterval,3/4*24*60/timeinterval])
% set(gca,'XTickLabel',{'6:00am','6:00pm'})
% set(gca,'XGrid','on')
% title(['top ' num2str(realn) ' biggest daytime events separate plot (green:Mon-Thu/red:Fri/blue:Sat,Sun)']);
% 
% export_fig([y '\' groupname '\PerformanceMetrics.pdf'],'-append')

%%
linewidth=3;
fontsize=20;
dayofweek=startdatenum:startdatenum+size(volume,3)-1;
dayofweek=weekday(dayofweek);

figurenum=figurenum+1;
scrsz=get(groot,'ScreenSize');
h=figure('Name',num2str(figurenum),'Position',scrsz);
set(gcf, 'Color', [1,1,1]);
hold on
plot(1:size(volume,2),12*nanmean(nanmean(volume(:,:,dayofweek>1 & dayofweek<6),1),3),'green','LineWidth',linewidth);
plot(1:size(volume,2),12*nanmean(nanmean(volume(:,:,dayofweek==6),1),3),'red','LineWidth',linewidth);
plot(1:size(volume,2),12*nanmean(nanmean(volume(:,:,dayofweek==1 | dayofweek==7),1),3),'blue','LineWidth',linewidth);
xlabel('time of day','FontSize',fontsize,'FontWeight','bold')
ylabel('volume (veh/hour)','FontSize',fontsize,'FontWeight','bold')
set(gca,'XTick',[72,216])
set(gca,'XTickLabel',{'6:00am','6:00pm'})
set(gca,'XGrid','on')
set(gca,'Fontsize',fontsize,'FontWeight','bold')
YY=get(gca,'ylim');
title(['Average Daily Volume Plot of ' groupname ' Direction ' num2str(direction)],'FontSize',fontsize,'FontWeight','bold') 
text(10,0.9*YY(2),'(green:Mon-Thu/ red:Fri/ blue:Sat,Sun)','FontWeight','bold','FontSize',12,'EdgeColor',[0 0 0])

export_fig([y '\' groupname '\' reportstartday '-' reportendday '_' groupname '_Volume.pdf'],'-append')
