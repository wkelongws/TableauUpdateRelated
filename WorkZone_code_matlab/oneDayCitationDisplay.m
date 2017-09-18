function figurenum=oneDayCitationDisplay(TrafficData,startdatenum,minspeed,...
    maxspeed,figurenum,milemarker,direction,groupname,Citations,CitationInfo,reportstartday)

wzmarker = milemarker(milemarker(:,2)==1,4);
milemarker = sortrows(milemarker,4);
milemarker=milemarker(milemarker(:,1)==direction,4);
wzloc = zeros(size(wzmarker,1),size(wzmarker,2));

for i = 1:length(wzmarker)
    wzloc(i)=(wzmarker(i)-milemarker(1))/(milemarker(end)-milemarker(1))*(size(TrafficData,1)-1)+1;
end
%%%%%%%%%%%%%% crashes %%%%%%%%%%%%%%
Citations = Citations(Citations(:,2)==direction,:);
mm=round(milemarker(:,end)*100)/100;
distanceinterval=0.1;
if round(ceil(round(((mm(end)-mm(1))/distanceinterval)*1000)/1000)*1000)/1000==round((mm(end)-mm(1))/distanceinterval*1000)/1000; % if the total distance is times of idstanceinterval
    xxdistance=mm(1):distanceinterval:mm(end);  % interpolation locations
else 
    xxdistance=[mm(1):distanceinterval:mm(end),mm(end)];    % interpolation locations
end
xxdistance=xxdistance';
Citations(:,3)=Citations(:,3)-startdatenum+1;
Citations(:,4)=Citations(:,4)*12+Citations(:,5);
Citations(Citations(:,3)<1 | Citations(:,3)>size(TrafficData,3),:)=[];

%%%%%%%%%%%%%%%% DMS %%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% LC %%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 firstday=[datenum('2014-01-01'),datenum('2014-02-01'),datenum('2014-03-01'),datenum('2014-04-01'),...
    datenum('2014-05-01'),datenum('2014-06-01'),datenum('2014-07-01'),datenum('2014-08-01'),...
    datenum('2014-09-01'),datenum('2014-10-01'),datenum('2014-11-01'),datenum('2014-12-01'),...
    datenum('2015-01-01'),datenum('2015-02-01'),datenum('2015-03-01'),datenum('2015-04-01'),...
    datenum('2015-05-01'),datenum('2015-06-01'),datenum('2015-07-01'),datenum('2015-08-01'),...
    datenum('2015-09-01'),datenum('2015-10-01'),datenum('2015-11-01'),datenum('2015-12-01'),...
    datenum('2016-01-01'),datenum('2016-02-01'),datenum('2016-03-01'),datenum('2016-04-01'),...
    datenum('2016-05-01'),datenum('2016-06-01'),datenum('2016-07-01'),datenum('2016-08-01'),...
    datenum('2016-09-01'),datenum('2016-10-01'),datenum('2016-11-01'),datenum('2016-12-01')];


[DayNumber1,DayName1]=weekday(startdatenum,'long');
Daynum=startdatenum;
%figurenum=0;
figurenum=figurenum+1;
scrsz=get(groot,'ScreenSize');
    %figure('Position',[100 1 scrsz(3)/2 scrsz(4)/2])
    h=figure('Name',num2str(figurenum),'Position',scrsz);

    set(gcf, 'Color', [1,1,1]);
    textlocation_y = 1.3; 
    textlocation_x = -0.5;
    crashnumber=0;
    
    x=scrsz(3)/2;
    y=scrsz(4)/2;
    text(1,y,[groupname ' Direction ' num2str(direction)])
    MonSun = {'Mon','Tue','Wed','Thu','Fri','Sat','Sun'};
    
for i=1:size(TrafficData,3)
    
%     order=i+startdatenum-datenum(reportstartday);

%     subplot(2,8,order);
    subplot(2,1,1);
    datadisplayspeed(TrafficData(:,:,i),minspeed,maxspeed); 
    hold on;
    %%%%%%%%%%%% WZ boundary plot %%%%%%%%%%%%%
    for j = 1:length(wzloc)
       plot([1,size(TrafficData,2)],[wzloc(j),wzloc(j)],'blue--','linewidth',2.5) 
    end
    %%%%%%%%%%%%% Crash plot %%%%%%%%%%%%
    CitationToday=Citations(Citations(:,3)==i,:);
    if ~isempty(CitationToday)
        count=0;
        for kk=1:size(CitationToday,1)
            count = count + 1;
            textlocation_y=textlocation_y-0.1;
            if mod(count,10)-1==0
                textlocation_x=textlocation_x+1.5;
                textlocation_y=1.2;
            end
            crashnumber=crashnumber+1;
%             subplot(2,8,order);
            subplot(2,1,1);
            plot(CitationToday(kk,4),CitationToday(kk,end),'*','MarkerSize',10,'MarkerFaceColor','none','MarkerEdgeColor','k')
            text(CitationToday(kk,4)-2,CitationToday(kk,end)-0.02*length(xxdistance),num2str(crashnumber),'FontWeight','bold','Color','k');
            hh=subplot(2,8,9);      
            set(hh,'Visible','off')
            
            message=[num2str(crashnumber) '. ID:' CitationInfo{CitationToday(kk,1),7}];
            text(textlocation_x,textlocation_y,message);
            
%             message=[num2str(crashnumber) '. Location:(' CitationInfo{CitationToday(kk,1),5} ',' CitationInfo{CitationToday(kk,1),6} ')'...
%                 '; Age:' CitationInfo{CitationToday(kk,1),1} ...
%                 '; Gender:' CitationInfo{CitationToday(kk,1),2} ...
%                 '; Citation(s):'];
%             descriptions = ['1. ' CitationInfo{CitationToday(kk,1),3} '; 2. ' CitationInfo{CitationToday(kk,1),4}];
%             prelength=length(message);
%             wraplength=250;
%             if length(descriptions)+prelength<=wraplength
%                 text(-0.5,textlocation_y,[message descriptions]);
%             else Info=descriptions;
%                 text(-0.5,textlocation_y,[message Info(1:wraplength-prelength) '-']);
%                 textlocation_y=textlocation_y-0.1;
%                 if length(['              -' Info(wraplength-prelength+1:end)])<=wraplength
%                     text(-0.5,textlocation_y,['              -' Info(wraplength-prelength+1:end)]);
%                 else lll=length('              -');
%                     text(-0.5,textlocation_y,['              -' Info(wraplength-prelength+1:2*wraplength-prelength-lll) '-']);
%                     textlocation_y=textlocation_y-0.1;
%                     text(-0.5,textlocation_y,['              -' Info(2*wraplength-prelength-lll+1:end)]);
%                 end
%             end
        end
    end
    %%%%%%%%%%%%% DMS plot %%%%%%%%%%%%%%
    
    %%%%%%%%%%%%% LC plot %%%%%%%%%%%%%%

%     subplot(2,8,order);
    subplot(2,1,1);
    set(gca,'YTick',[1,(size(TrafficData,1)-1)/4+1,(size(TrafficData,1)-1)*2/4+1,(size(TrafficData,1)-1)*3/4+1,size(TrafficData,1)])
    set(gca,'YTickLabel',{num2str(milemarker(1,end)),num2str((milemarker(end,end)-milemarker(1,end))/4+milemarker(1,end)),num2str((milemarker(end,end)-milemarker(1,end))*2/4+milemarker(1,end)),num2str((milemarker(end,end)-milemarker(1,end))*3/4+milemarker(1,end)),num2str(milemarker(end,end))})
    set(gca,'XTick',[72,216])
    set(gca,'XTickLabel',{'6:00am','6:00pm'})

    title([MonSun{i} ' (' datestr(Daynum+i-1) ') ' groupname ' Direction ' num2str(direction)]);

%     order=order+1;
end
% subplot(2,8,4);
% subplot(2,1,1);
% tt=text(.05, -15,[groupname ' Direction ' num2str(direction)]);
% set(tt,'edgecolor',.5*[1 1 1]);

% subplot(2,8,8);
subplot(2,1,1);
 hold on
%       set(gca,'visible','off');
 caxis([minspeed,maxspeed]);
 hcb=colorbar;
%  set(hcb, 'Position', [.15 .11 .01 .35]);
 set(hcb,'YTick',[0,10,20,30,40,50,60,70,80])
 set(hcb,'YTickLabel',{'missing speed','10 mph','20 mph','30 mph','40 mph','50 mph','60 mph','70 mph','80 mph'})

p1 = [300 140];                         % First Point
p2 = [300 1];                         % Second Point
dp = p2-p1;                         % Difference
if direction==1
    quiver(p1(1),p1(2),dp(1),dp(2),0);
else
    quiver(p2(1),p2(2),-dp(1),-dp(2),0);
end
