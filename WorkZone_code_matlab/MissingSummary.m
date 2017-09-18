function figurenum=MissingSummary(MissingData,figurenum,reportstartday,reportendday,y)



figurenum=figurenum+1;
scrsz=get(groot,'ScreenSize');
figure('Name',num2str(figurenum),'Position',scrsz);
set(gcf, 'Color', [1,1,1]);
    
for i=1:size(MissingData,1)
    missing=cell2mat(MissingData(i,2));
    subplot(4,7,i);
   
    H=barh(missing,'stacked');
    
    set(gca,'YDir','Reverse')

    set(gca,'YTick',1:size(missing,1))

    set(gca,'XTick',[0 0.25 0.5 0.75 1])
    set(gca,'XTickLabel',{'0%','25%','50%','75%','100%'},'FontSize',5)
    xlabel('Time of missing data')
    ylabel('sensor number')
    set(gca,'XGrid','on')
    
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
        
    x=MissingData(i,1); 
    title(x{1},'FontSize', 8);   
    
end

 subplot(4,7,27);
 set(gca,'visible','off');
 text(0,0.7,'IWZ Sensor Missing Data Summary','FontWeight','bold','FontSize',12)
 text(0,0.2,[reportstartday '-' reportendday],'FontWeight','bold','FontSize',12)

export_fig([y '\MissingDataSummary.pdf'],'-append')



figurenum=figurenum+1;
scrsz=get(groot,'ScreenSize');
figure('Name',num2str(figurenum),'Position',scrsz);
set(gcf, 'Color', [1,1,1]);
    
for i=1:size(MissingData,1)
    missing=cell2mat(MissingData(i,2));
    subplot(4,7,i);
    set(gca,'visible','off');
    
    sensorID=cell2mat(MissingData(i,4));
    sensorname=MissingData(i,5);
    sensorname=sensorname{:};    
    milemarker = cell2mat(MissingData(i,3));
    milemarker = sortrows(milemarker,4);
    sensorname = sensorname(ismember(sensorID,milemarker(:,3)));  
    
    textlocation = fliplr(linspace(0,1,size(missing,1)));
    fontsize = 5;
    for j=1:size(missing,1)
     content = [num2str(j) '. ' sensorname{j}];   
    text(0,textlocation(j),content,'FontSize',fontsize)
    end
    x=MissingData(i,1); 
    text(0,1.1,x{1},'FontWeight','bold','FontSize',8)
       
    
end

 subplot(4,7,27);
 set(gca,'visible','off');
 text(0,0.7,'IWZ Sensor Name Lists','FontWeight','bold','FontSize',12)
 text(0,0.2,[reportstartday '-' reportendday],'FontWeight','bold','FontSize',12)

export_fig([y '\MissingDataSummary.pdf'],'-append')

 
