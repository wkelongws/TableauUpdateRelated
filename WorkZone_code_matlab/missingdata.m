function [missing,figurenum]=missingdata(TrafficData,figurenum,issue)

indicatorloseconnection = nan(size(TrafficData,1),size(TrafficData,3)*size(TrafficData,2));
rawspreadsheet=nan(size(TrafficData,1),size(TrafficData,3)*size(TrafficData,2));
for i=1:size(TrafficData,3)
    rawspreadsheet(:,(i-1)*size(TrafficData,2)+1:i*size(TrafficData,2))=TrafficData(:,:,i);
    indicatorloseconnection(:,(i-1)*size(TrafficData,2)+1:i*size(TrafficData,2))=issue(:,:,i);
end
rawspreadsheet(:,min(indicatorloseconnection==50))=[];
%%%%

%%%%

missing=zeros(size(rawspreadsheet,1),2);
for i=1:size(rawspreadsheet,1)
    missing(i,1)=sum(isnan(rawspreadsheet(i,:)))/size(rawspreadsheet,2);
    missing(i,2)=1-missing(i,1);
  
end

figurenum=figurenum+1;
figure(figurenum)
set(gcf, 'Color', [1,1,1]);

H=barh(missing,'stacked');
set(gca,'YDir','Reverse')
set(gca,'XTickLabel',{'0','10%','20%','30%','40%','50%','60%','70%','80%','90%','100%'})
xlabel('Time')
ylabel('detector number')
set(gca,'XGrid','on')
title('Missing data summary (red)');
myC= [1.0 0.0 0.0 
      0.0 1.0 0.0
      1.0 0.0 0.0
      1.0 0.5 0.0
      1.0 1.0 0.0
      0.6 1.0 0.3 
      0.0 0.9 0.0];
for k=1:2
  set(H(k),'facecolor',myC(k,:))
  set(H(k),'EdgeColor',myC(k,:))
end
figurenum=figurenum+1;