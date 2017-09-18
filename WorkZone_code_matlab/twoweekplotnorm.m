function figurenum=twoweekplotnorm(TrafficData,startdatenum,minspeed,maxspeed,figurenum,milemarker,direction,groupname,reportstartday)

wzmarker = milemarker(milemarker(:,2)==1,4);

milemarker = sortrows(milemarker,4);
milemarker=milemarker(milemarker(:,1)==direction,4);


wzloc = zeros(size(wzmarker,1),size(wzmarker,2));

for i = 1:length(wzmarker)
    wzloc(i)=(wzmarker(i)-milemarker(1))/(milemarker(end)-milemarker(1))*(size(TrafficData,1)-1)+1;
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
scrsz=get(groot,'ScreenSize');
    %figure('Position',[100 1 scrsz(3)/2 scrsz(4)/2])
    h=figure('Name',num2str(figurenum),'Position',scrsz);

    set(gcf, 'Color', [1,1,1]);
    
    x=scrsz(3)/2;
    y=scrsz(4)/2;
    text(1,y,[groupname ' Direction ' num2str(direction)])
    
for i=1:size(TrafficData,3)
    
    order=i+startdatenum-datenum(reportstartday);

    subplot(2,7,order);
    order=order+1;
    datadisplayspeed(TrafficData(:,:,i),minspeed,maxspeed); 
    hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%
    for j = 1:length(wzloc)
       plot([1,size(TrafficData,2)],[wzloc(j),wzloc(j)],'blue--','linewidth',2.5) 
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %plot(mainlineINCIDENT(find(mainlineINCIDENT(:,1)==Daynum+i-1),2),mainlineINCIDENT(find(mainlineINCIDENT(:,1)==Daynum+i-1),5),'b*','MarkerSize',8);
    %plot(OFFRAMP(find(OFFRAMP(:,1)==Daynum+i-1),2),OFFRAMP(find(OFFRAMP(:,1)==Daynum+i-1),5),'b+','MarkerSize',8);
    %plot(ONRAMP(find(ONRAMP(:,1)==Daynum+i-1),2),ONRAMP(find(ONRAMP(:,1)==Daynum+i-1),5),'bx','MarkerSize',8);
    if order~=5
    title(datestr(Daynum+i-1));
    end
    
    

set(gca,'YTick',[1,(size(TrafficData,1)-1)/4+1,(size(TrafficData,1)-1)*2/4+1,(size(TrafficData,1)-1)*3/4+1,size(TrafficData,1)])
set(gca,'YTickLabel',{num2str(milemarker(1,end)),num2str((milemarker(end,end)-milemarker(1,end))/4+milemarker(1,end)),num2str((milemarker(end,end)-milemarker(1,end))*2/4+milemarker(1,end)),num2str((milemarker(end,end)-milemarker(1,end))*3/4+milemarker(1,end)),num2str(milemarker(end,end))})
set(gca,'XTick',[72,216])
set(gca,'XTickLabel',{'6:00am','6:00pm'})
xlabel('time of day');
set(gca,'XGrid','on')

end

p=mtit(h,[groupname ' Direction ' num2str(direction)],'yoff',0);
set(p.th,'edgecolor',.5*[1 1 1]);

caxis([minspeed,maxspeed]);
 hcb=colorbar;
 set(hcb, 'Position', [.05 .11 .01 .35]);
 set(hcb,'YTick',[0,10,20,30,40,50,60,70,80])
 set(hcb,'YTickLabel',{'missing speed','10 mph','20 mph','30 mph','40 mph','50 mph','60 mph','70 mph','80 mph'})