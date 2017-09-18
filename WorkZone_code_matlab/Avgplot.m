function figurenum=Avgplot(AverageSpeed,minspeed,maxspeed,figurenum,reportstartday,reportendday,y)

figurenum=figurenum+1;
scrsz=get(groot,'ScreenSize');
wd=figure('Name',num2str(figurenum),'Position',scrsz);
set(gcf, 'Color', [1,1,1]);
    
for i=1:size(AverageSpeed,1)
    TrafficData=cell2mat(AverageSpeed(i,3));
    subplot(4,7,i);
    datadisplayspeed(TrafficData,minspeed,maxspeed); 
    hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%    
    wzmarker = cell2mat(AverageSpeed(i,6));
    wzmarker = wzmarker(wzmarker(:,2)==1,4);
    milemarker = cell2mat(AverageSpeed(i,5));
    milemarker = sortrows(milemarker,4);
    milemarker = milemarker(:,4);

    wzloc = zeros(size(wzmarker,1),size(wzmarker,2));

    for j = 1:length(wzmarker)
        if wzmarker(j)<milemarker(1)
            wzloc(j)=0.5;
        else wzloc(j)=find(milemarker<wzmarker(j), 1, 'last' )+0.5;
        end
    end
        
    for j = 1:length(wzloc)
       plot([1,size(TrafficData,2)],[wzloc(j),wzloc(j)],'blue--','linewidth',1.5) 
    end
        
    x=AverageSpeed(i,1); 
    title(x{1});
    
    label = {'sensor1','sensor2','sensor3','sensor4','sensor5','sensor6',...
        'sensor7','sensor8','sensor9','sensor10','sensor11','sensor12',...
        'sensor13','sensor14','sensor15','sensor16','sensor17','sensor18',...
        'sensor19','sensor20','sensor21','sensor22','sensor23','sensor24','sensor25',...
        'sensor26','sensor27','sensor28','sensor29','sensor30','sensor31','sensor32',...
        'sensor33','sensor34','sensor35','sensor36','sensor37','sensor38','sensor39'};
if size(TrafficData,1)<15    
    set(gca,'YTick',1:size(TrafficData,1))
    set(gca,'YTickLabel',label(1:size(TrafficData,1)))
else 
    set(gca,'YTick',1:2:size(TrafficData,1))
    set(gca,'YTickLabel',label(1:2:size(TrafficData,1)))
end
set(gca,'XTick',[72,216])
set(gca,'XTickLabel',{'6:00am','6:00pm'})
xlabel('time of day');
set(gca,'XGrid','on')

end

 subplot(4,7,27);
 set(gca,'visible','off');
 text(0,0.3,'\uparrow Direction 2','FontWeight','bold','FontSize',12)
 text(0,0.6,'\downarrow Direction 1','FontWeight','bold','FontSize',12)
 text(0,0.9,'Weekday Average Speed Heatmap - Raw','FontWeight','bold','FontSize',12)
 text(0,0,[reportstartday ' 00:00 - ' reportendday ' 23:59'],'FontWeight','bold','FontSize',12)
 
  subplot(4,7,28);
 set(gca,'visible','off');
 caxis([minspeed,maxspeed]);
 hcb=colorbar;
 set(hcb,'YTick',[0,10,20,30,40,50,60,70,80])
 set(hcb,'YTickLabel',{'missing speed','10 mph','20 mph','30 mph','40 mph','50 mph','60 mph','70 mph','80 mph'})
 
export_fig([y '\3.HeatmapSummary.pdf'],'-append')

figurenum=figurenum+1;
scrsz=get(groot,'ScreenSize');
we=figure('Name',num2str(figurenum),'Position',scrsz);
set(gcf, 'Color', [1,1,1]);
    
    
for i=1:size(AverageSpeed,1)
    TrafficData=cell2mat(AverageSpeed(i,4));
    subplot(4,7,i);
    datadisplayspeed(TrafficData,minspeed,maxspeed); 
    hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%    
    wzmarker = cell2mat(AverageSpeed(i,6));
    wzmarker = wzmarker(wzmarker(:,2)==1,4);
    milemarker = cell2mat(AverageSpeed(i,5));
    milemarker = sortrows(milemarker,4);
    milemarker = milemarker(:,4);

    wzloc = zeros(size(wzmarker,1),size(wzmarker,2));

    for j = 1:length(wzmarker)
        if wzmarker(j)<milemarker(1)
            wzloc(j)=0.5;
        else wzloc(j)=find(milemarker<wzmarker(j), 1, 'last' )+0.5;
        end
    end
        
    for j = 1:length(wzloc)
       plot([1,size(TrafficData,2)],[wzloc(j),wzloc(j)],'blue--','linewidth',1.5) 
    end
    x=AverageSpeed(i,1); 
    title(x{1});
    
    label = {'sensor1','sensor2','sensor3','sensor4','sensor5','sensor6',...
        'sensor7','sensor8','sensor9','sensor10','sensor11','sensor12',...
        'sensor13','sensor14','sensor15','sensor16','sensor17','sensor18',...
        'sensor19','sensor20','sensor21','sensor22','sensor23','sensor24','sensor25',...
        'sensor26','sensor27','sensor28','sensor29','sensor30','sensor31','sensor32',...
        'sensor33','sensor34','sensor35','sensor36','sensor37','sensor38','sensor39'};

if size(TrafficData,1)<15    
    set(gca,'YTick',1:size(TrafficData,1))
    set(gca,'YTickLabel',label(1:size(TrafficData,1)))
else 
    set(gca,'YTick',1:2:size(TrafficData,1))
    set(gca,'YTickLabel',label(1:2:size(TrafficData,1)))
end
set(gca,'XTick',[72,216])
set(gca,'XTickLabel',{'6:00am','6:00pm'})
xlabel('time of day');
set(gca,'XGrid','on')

end

 subplot(4,7,27);
 set(gca,'visible','off');
 text(0,0.3,'\uparrow Direction 2','FontWeight','bold','FontSize',12)
 text(0,0.6,'\downarrow Direction 1','FontWeight','bold','FontSize',12)
 text(0,0.9,'Weekend Average Speed Heatmap - Raw','FontWeight','bold','FontSize',12)
 text(0,0,[reportstartday ' 00:00 - ' reportendday ' 23:59'],'FontWeight','bold','FontSize',12)
 
  subplot(4,7,28);
 set(gca,'visible','off');
 caxis([minspeed,maxspeed]);
 hcb=colorbar;
 set(hcb,'YTick',[0,10,20,30,40,50,60,70,80])
 set(hcb,'YTickLabel',{'missing speed','10 mph','20 mph','30 mph','40 mph','50 mph','60 mph','70 mph','80 mph'})
 
export_fig([y '\3.HeatmapSummary.pdf'],'-append')

end


%p=mtit(h,[groupname ' Direction ' num2str(direction)],'yoff',0);
%set(p.th,'edgecolor',.5*[1 1 1]);

%colorbar;
