function [figurenum,capacity,volumegreen,volumered,volumeblue]=trafficplots(figurenum,fontsize,updetID,downdetID,SBspeed,SBvolume,SBoccupancy,startdatenum,linewidth)
% the closest upstream detector plots
%updetID=4;
%fontsize=14;
dayofweek=startdatenum:startdatenum+size(SBvolume,3)-1;
dayofweek=weekday(dayofweek);
volume=reshape(SBvolume(updetID,:,:),1,[]);
speed=reshape(SBspeed(updetID,:,:),1,[]);
capacity=volume(speed>40);
capacity=prctile(capacity,99.9,2);
volumegreen=sum(nanmean(SBvolume(updetID,:,dayofweek>1 & dayofweek<6),3))*size(SBvolume(updetID,:,dayofweek>1 & dayofweek<6),3);
volumered=sum(nanmean(SBvolume(updetID,:,dayofweek==6),3))*size(SBvolume(updetID,:,dayofweek==6),3);
volumeblue=sum(nanmean(SBvolume(updetID,:,dayofweek==1 | dayofweek==7),3))*size(SBvolume(updetID,:,dayofweek==1 | dayofweek==7),3);

figurenum=figurenum+1;
figure(figurenum);
plot(reshape(SBvolume(updetID,:,:),1,[]),reshape(SBspeed(updetID,:,:),1,[]),'.');
hold on
plot ([capacity,capacity],[0,70],'black','LineWidth',linewidth)
xlabel('volume','FontSize',fontsize,'FontWeight','bold')
ylabel('speed','FontSize',fontsize,'FontWeight','bold')
set(gca,'Fontsize',fontsize,'FontWeight','bold')
title('speed vs volume plot (the closest upstream detector)','FontSize',fontsize,'FontWeight','bold') 
%
figurenum=figurenum+1;
figure(figurenum);
plot(reshape(SBoccupancy(updetID,:,:),1,[]),reshape(SBspeed(updetID,:,:),1,[]),'.');
xlabel('occupancy','FontSize',fontsize,'FontWeight','bold')
ylabel('speed','FontSize',fontsize,'FontWeight','bold')
set(gca,'Fontsize',fontsize,'FontWeight','bold')
title('speed vs occupancy plot (the closest upstream detector)','FontSize',fontsize,'FontWeight','bold')    
%
figurenum=figurenum+1;
figure(figurenum);
plot(1:size(SBvolume,2),nanmean(SBvolume(updetID,:,dayofweek>1 & dayofweek<6),3),'green','LineWidth',linewidth);
hold on
plot(1:size(SBvolume,2),nanmean(SBvolume(updetID,:,dayofweek==6),3),'red','LineWidth',linewidth);
plot(1:size(SBvolume,2),nanmean(SBvolume(updetID,:,dayofweek==1 | dayofweek==7),3),'blue','LineWidth',linewidth);
xlabel('time of day','FontSize',fontsize,'FontWeight','bold')
ylabel('volume','FontSize',fontsize,'FontWeight','bold')
set(gca,'XTick',[72,216])
set(gca,'XTickLabel',{'6:00am','6:00pm'})
set(gca,'XGrid','on')
set(gca,'Fontsize',fontsize,'FontWeight','bold')
title('avg volume plot of the closest upstream detector (green:Mon-Thu/ red:Fri/ blue:Sat,Sun)','FontSize',fontsize,'FontWeight','bold') 

%SVOup=[reshape(SBspeed(updetID,:,:),1,[]);reshape(SBvolume(updetID,:,:),1,[]);reshape(SBoccupancy(updetID,:,:),1,[])]';
%xlswrite('C:\Users\shuowang\Desktop\2014 Fall\Research Work\smart work zone\8_Traffic Critical Work Zone ITS\Detector Data\SVOup.xlsx',SVOup);


% the closest downstream detector plots
%downdetID=5;

figurenum=figurenum+1;
figure(figurenum);
plot(reshape(SBvolume(downdetID,:,:),1,[]),reshape(SBspeed(downdetID,:,:),1,[]),'.');
xlabel('volume','FontSize',fontsize,'FontWeight','bold')
ylabel('speed','FontSize',fontsize,'FontWeight','bold')
set(gca,'Fontsize',fontsize,'FontWeight','bold')
title('speed vs volume plot (the closest downstream detector)','FontSize',fontsize,'FontWeight','bold')    
%
figurenum=figurenum+1;
figure(figurenum);
plot(reshape(SBoccupancy(downdetID,:,:),1,[]),reshape(SBspeed(downdetID,:,:),1,[]),'.');
xlabel('occupancy','FontSize',fontsize,'FontWeight','bold')
ylabel('speed','FontSize',fontsize,'FontWeight','bold')
set(gca,'Fontsize',fontsize,'FontWeight','bold')
title('speed vs occupancy plot (the closest downstream detector)','FontSize',fontsize,'FontWeight','bold')    
%
figurenum=figurenum+1;
figure(figurenum);
plot(1:size(SBvolume,2),nanmean(SBvolume(downdetID,:,dayofweek>1 & dayofweek<6),3),'green','LineWidth',linewidth);
hold on
plot(1:size(SBvolume,2),nanmean(SBvolume(downdetID,:,dayofweek==6),3),'red','LineWidth',linewidth);
plot(1:size(SBvolume,2),nanmean(SBvolume(downdetID,:,dayofweek==1 | dayofweek==7),3),'blue','LineWidth',linewidth);
xlabel('time of day','FontSize',fontsize,'FontWeight','bold')
ylabel('volume','FontSize',fontsize,'FontWeight','bold')
set(gca,'XTick',[72,216])
set(gca,'XTickLabel',{'6:00am','6:00pm'})
set(gca,'XGrid','on')
set(gca,'Fontsize',fontsize,'FontWeight','bold')
title('avg volume plot of the closest downstream detector (green:Mon-Thu/ red:Fri/ blue:Sat,Sun)','FontSize',fontsize,'FontWeight','bold')  

%SVOdown=[reshape(SBspeed(downdetID,:,:),1,[]);reshape(SBvolume(downdetID,:,:),1,[]);reshape(SBoccupancy(downdetID,:,:),1,[])]';
%xlswrite('C:\Users\shuowang\Desktop\2014 Fall\Research Work\smart work zone\8_Traffic Critical Work Zone ITS\Detector Data\SVOdown.xlsx',SVOdown);

% WBMAYTT85=prctile(WBMAYTT,85,3);

fprintf('capacity:                                          %f  veh/hour/lane   \n',capacity);
