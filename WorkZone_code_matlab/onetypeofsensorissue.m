function figurenum=onetypeofsensorissue(TrafficData,startdatenum,figurenum,milemarker,direction,groupname,reportstartday,sensornames,color,issue)

wzmarker = milemarker(milemarker(:,2)==1,4);

milemarker = sortrows(milemarker,4);
milemarker=milemarker(milemarker(:,1)==direction,:);

sensorID=sensornames{1};
sensornames=sensornames{2};
sensorname = sensornames(ismember(sensorID,milemarker(:,3)));  

milemarker=milemarker(milemarker(:,1)==direction,4);


wzloc = zeros(size(wzmarker,1),size(wzmarker,2));

for i = 1:length(wzmarker)
    if wzmarker(i)<milemarker(1)
        wzloc(i)=0.5;
    else wzloc(i)=find(milemarker<wzmarker(i), 1, 'last' )+0.5;
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%x1=ones(1,288)*(154-56);
%x2=ones(1,288)*(154-117);       % work zone location: change it
%y=1:288;
%linewidth=1.5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


firstday=[datenum('2015-01-01'),datenum('2015-02-01'),datenum('2015-03-01'),datenum('2015-04-01'),...
    datenum('2015-05-01'),datenum('2015-06-01'),datenum('2015-07-01'),datenum('2015-08-01'),...
    datenum('2015-09-01'),datenum('2015-10-01'),datenum('2015-11-01'),datenum('2015-12-01'),...
    datenum('2008-01-01'),datenum('2008-02-01'),datenum('2008-03-01'),datenum('2008-04-01'),...
    datenum('2008-05-01'),datenum('2008-06-01'),datenum('2008-07-01'),datenum('2008-08-01'),...
    datenum('2008-09-01'),datenum('2008-10-01'),datenum('2008-11-01'),datenum('2008-12-01')];

[DayNumber1,DayName1]=weekday(startdatenum,'long');
Daynum=startdatenum;
%figurenum=0;
figurenum=figurenum+1;
    %figure(figurenum);
    scrsz=get(groot,'ScreenSize');
    %figure('Position',[100 1 scrsz(3)/2 scrsz(4)/2])
    h=figure('Name',num2str(figurenum),'Position',scrsz);

    set(gcf, 'Color', [1,1,1]);
   
    
for i=1:size(TrafficData,3)
    if i<8
    order=i+startdatenum-datenum(reportstartday)+1;
    else order=i+startdatenum-datenum(reportstartday)+2;
    end
    subplot(2,8,order);
    %order=order+1;
    
    issuecolormap=  [255,255,255;color]/255;
    colormap(issuecolormap);
    image(TrafficData(:,:,i),'CDataMapping','scaled');
    caxis([0,1]);    
    
    hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%
    for j = 1:length(wzloc)
       plot([1,size(TrafficData,2)],[wzloc(j),wzloc(j)],'blue--','linewidth',2.5) ;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %plot(mainlineINCIDENT(find(mainlineINCIDENT(:,1)==Daynum+i-1),2),mainlineINCIDENT(find(mainlineINCIDENT(:,1)==Daynum+i-1),5),'b*','MarkerSize',8);
    %plot(OFFRAMP(find(OFFRAMP(:,1)==Daynum+i-1),2),OFFRAMP(find(OFFRAMP(:,1)==Daynum+i-1),5),'b+','MarkerSize',8);
    %plot(ONRAMP(find(ONRAMP(:,1)==Daynum+i-1),2),ONRAMP(find(ONRAMP(:,1)==Daynum+i-1),5),'bx','MarkerSize',8);
   
    title(datestr(Daynum+i-1));
    

    label = {'sensor1','sensor2','sensor3','sensor4','sensor5','sensor6',...
        'sensor7','sensor8','sensor9','sensor10','sensor11','sensor12',...
        'sensor13','sensor14','sensor15','sensor16','sensor17','sensor18',...
        'sensor19','sensor20','sensor21','sensor22','sensor23','sensor24','sensor25',...
        'sensor26','sensor27','sensor28','sensor29','sensor30','sensor31','sensor32',...
        'sensor33','sensor34','sensor35','sensor36','sensor37','sensor38','sensor39'};
    
set(gca,'YTick',1:size(TrafficData,1))
%set(gca,'YTickLabel',label(1:size(TrafficData,1)))

%set(gca,'YTick',[1,round(size(TrafficData,1)/4),round(size(TrafficData,1)*2/4),round(size(TrafficData,1)*3/4),size(TrafficData,1)])
%set(gca,'YTickLabel',{num2str(milemarker(1,end)),num2str(milemarker(round(size(TrafficData,1)/4),end)),num2str(milemarker(round(size(TrafficData,1)*2/4),end)),num2str(milemarker(round(size(TrafficData,1)*3/4),end)),num2str(milemarker(end,end))})

set(gca,'XTick',[72,216])
set(gca,'XTickLabel',{'6:00am','6:00pm'})
xlabel('time of day');
set(gca,'XGrid','on')

end

     subplot(2,8,1);
     set(gca,'visible','off');
     textlocation = fliplr(linspace(0+0.5/size(TrafficData,1),1-0.5/size(TrafficData,1),size(TrafficData,1)));
    fontsize = 6;
    for j=1:size(TrafficData,1)
     content = [num2str(j) '. ' sensorname{j}];   
    text(0,textlocation(j),content,'FontSize',fontsize)
    end
    x=[groupname ' Direction ' num2str(direction)]; 
    text(0,1.1,x,'FontWeight','bold','FontSize',10)
    
         subplot(2,8,9);
     set(gca,'visible','off');
     levels=2;
     textlocation = linspace(0+0.5/levels,1-0.5/levels,levels);
    issues={'normal',issue};
    for j=1:levels
     content = [num2str(j) '. ' issues{j}];   
    text(0,textlocation(j),content,'FontWeight','bold','FontSize',6)
    end
    caxis([0,1]);
    hcb=colorbar;
 set(hcb,'YTick',[0,1])
 set(hcb,'YTickLabel',{'',''})
 


% p=mtit(h,[groupname ' Direction ' num2str(direction)],'yoff',0);
% set(p.th,'edgecolor',.5*[1 1 1]);
% %colorbar;
% maxdata=max(max(max(TrafficData)));
% mindata=min(min(min(TrafficData)));

% fprintf('min speed:                                         %f mile  \n',mindata);
% fprintf('max speed:                                         %f mile  \n',maxdata);