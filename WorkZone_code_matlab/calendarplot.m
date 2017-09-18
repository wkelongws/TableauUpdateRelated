function figurenum=calendarplot(TrafficData,startdatenum,minspeed,maxspeed,figurenum,milemarker,direction)

milemarker = sortrows(milemarker,4);
milemarker=milemarker(milemarker(:,1)==direction,[3 4]);

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

order=DayNumber1;
for i=1:size(TrafficData,3)
    
if max(Daynum+i-1==firstday)
    figurenum=figurenum+1;
    figure(figurenum);
    order=weekday(Daynum+i-1);

    subplot(6,7,order);
    order=order+1;
    datadisplayspeed(TrafficData(:,:,i),minspeed,maxspeed); 
    hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %plot(y,x1,'LineWidth',linewidth);  % work zone 
    %plot(y,x2,'LineWidth',linewidth);
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %plot(mainlineINCIDENT(find(mainlineINCIDENT(:,1)==Daynum+i-1),2),mainlineINCIDENT(find(mainlineINCIDENT(:,1)==Daynum+i-1),5),'b*','MarkerSize',8);
    %plot(OFFRAMP(find(OFFRAMP(:,1)==Daynum+i-1),2),OFFRAMP(find(OFFRAMP(:,1)==Daynum+i-1),5),'b+','MarkerSize',8);
    %plot(ONRAMP(find(ONRAMP(:,1)==Daynum+i-1),2),ONRAMP(find(ONRAMP(:,1)==Daynum+i-1),5),'bx','MarkerSize',8);
    title(datestr(Daynum+i-1));
    

    
else figure(figurenum);
    
    subplot(6,7,order);
    order=order+1;
    datadisplayspeed(TrafficData(:,:,i),minspeed,maxspeed); 
    hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %plot(y,x1,'LineWidth',linewidth);  % work zone
    %plot(y,x2,'LineWidth',linewidth);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %plot(mainlineINCIDENT(find(mainlineINCIDENT(:,1)==Daynum+i-1),2),mainlineINCIDENT(find(mainlineINCIDENT(:,1)==Daynum+i-1),5),'b*','MarkerSize',8);
    %plot(OFFRAMP(find(OFFRAMP(:,1)==Daynum+i-1),2),OFFRAMP(find(OFFRAMP(:,1)==Daynum+i-1),5),'b+','MarkerSize',8);
    %plot(ONRAMP(find(ONRAMP(:,1)==Daynum+i-1),2),ONRAMP(find(ONRAMP(:,1)==Daynum+i-1),5),'bx','MarkerSize',8);
    title(datestr(Daynum+i-1));
    

    
end
set(gca,'YTick',[1,size(TrafficData,1)])
set(gca,'YTickLabel',{num2str(milemarker(1,end)),num2str(milemarker(end,end))})
set(gca,'XTick',[72,216])
set(gca,'XTickLabel',{'6:00am','6:00pm'})
set(gca,'XGrid','on')

end
%colorbar;
maxdata=max(max(max(TrafficData)));
mindata=min(min(min(TrafficData)));

fprintf('min speed:                                         %f mile  \n',mindata);
fprintf('max speed:                                         %f mile  \n',maxdata);