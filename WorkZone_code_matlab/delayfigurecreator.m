traveltimelose = totaldelaydata(:,:,12);
% traveltimelose = nanmean(totaldelaydata,3);
% traveltimelose = nanmean(totaldelaydata(:,:,[1:11,13,14]),3);
figurenum=figurenum+1;
scrsz=get(groot,'ScreenSize');
wd=figure('Name',num2str(figurenum),'Position',scrsz);
set(gcf, 'Color', [1,1,1]);
h=bar3(traveltimelose);
smax=max(max(max(traveltimelose)));
pmax=max(max(max(totaldelaydata)));
set(gca,'zlim',[0,70])
for k = 1:length(h)
    zdata = get(h(k),'ZData');
    set(h(k),'CData',zdata)
    set(h(k),'FaceColor','interp','EdgeColor','none')
end
caxis([0,70]);
colorbar
xlabel('Time of Day','FontWeight','bold','FontSize',15)
ylabel('Mile Marker','FontWeight','bold','FontSize',15)
zlabel('Delay (min)','FontWeight','bold','FontSize',15)

% MM={'118.12','120.8','122.45','129.7','131.8'};
% ind=[1,27.8,44.3,116.8,138];

MM={'139.35','140.2','146','148.48','149.52','151.58'};
ind=[1,9.5,67.5,92.3,102.7,124];
set(gca,'ylim',[0 ind(end)+1])
set(gca,'yTick',ind)
set(gca,'yTickLabel',MM)
set(gca,'xTick',[72 216])
set(gca,'xTickLabel',{'6am','6pm'})
set(gca,'FontWeight','bold','FontSize',12)



a = totaldelaydata(:,:,12);
b = nanmean(totaldelaydata(:,:,[1:11,13,14]),3);
(sum(nansum(a(:,144:end)))-sum(nansum(b(:,144:end))))/60
 %%
% figurenum=figurenum+1;
% scrsz=get(groot,'ScreenSize');
% wd=figure('Name',num2str(figurenum),'Position',scrsz);
% set(gcf, 'Color', [1,1,1]);
% for i=1:14
%     subplot(4,4,i);
%     traveltimelose = totaldelaydata(:,:,i);
%     % traveltimelose = nanmean(totaldelaydata,3);    
%     h=bar3(traveltimelose);
%     smax=max(max(max(traveltimelose)));
%     pmax=max(max(max(totaldelaydata)));
%     set(gca,'zlim',[0,pmax])
%     for k = 1:length(h)
%         zdata = get(h(k),'ZData');
%         set(h(k),'CData',zdata)
%         set(h(k),'FaceColor','interp','EdgeColor','none')
%     end
%     caxis([0,pmax]);
% %     colorbar
%     xlabel('timeofday')
%     ylabel('milemarker')
%     zlabel('delay')
% end



