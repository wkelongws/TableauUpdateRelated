function figurenum=performancetrend(test,figurenum)


scrsz=get(groot,'ScreenSize');
%wd=figure('Name',num2str(figurenum),'Position',[2,2,1080 1920]);
wd=figure('Name',num2str(figurenum),'Position',scrsz);
set(gcf, 'Color', [1,1,1]);
for i=1:14*6
    subplot(14,6,i)
    % erase 1st and 4th columns for IWZ LABELS
    if mod(i,3)==1 || i == 12*6+2 || i== 12*6+3 || i== 13*6+2 || i== 13*6+3
        set(gca,'visible','off'); 
    else if mod(i,3)==2 && i<3*26
                
            x = 1:size(test,3);
            y = permute(test(ceil(i/3),1,:),[1 3 2]);
            plot(x,y,'r','LineWidth',1.5)
        
        index = size(test,3);
        xcurrent = x(index);
        ycurrent = y(index);
        strcurrent = ['Current = ',num2str(ycurrent)];
        text(xcurrent,ycurrent,'\leftarrow');
        text(xcurrent-2.5,ycurrent,strcurrent,'HorizontalAlignment','left');
        
        
        else if mod(i,3)==0 && i<3*26
                
                x = 1:size(test,3);
                y = permute(test(ceil(i/3),2,:),[1 3 2]);
                plot(x,y,'g--','LineWidth',1.5)
        
        index = size(test,3);
        xcurrent = x(index);
        ycurrent = y(index);
        strcurrent = ['Current = ',num2str(ycurrent)];
        text(xcurrent,ycurrent,'\leftarrow');
        text(xcurrent-2.5,ycurrent,strcurrent,'HorizontalAlignment','left');
                
            end
        end
    end
    box on   
    % set X tick lable at bottom
    if i==11*6+2 || i==14*6-1
    set(gca,'xTick',[1 2 3])
    set(gca,'xTickLabel',{1, 2, 3})
    else if i==11*6+3 || i==14*6
            set(gca,'xTick',[1 2 3])
            set(gca,'xTickLabel',{11, 22, 33})
        else set(gca,'xTick',[])
        end 
    end
    % set y tick labels
    if mod(i,3)==2
        set(gca,'yTick',[0 1 2])
        set(gca,'yTickLabel',{1, 2, 3})
    else if mod(i,3)==0
            set(gca,'yTick',[0 1 2])
        set(gca,'yTickLabel',{11, 22, 33})
        end
    end
    %set titles
    if i==2 || i==5
        title('congestion hour','FontSize',15)
    end
    if i==3 || i==6
        title('queue length','FontSize',15)
    end
    %set IWZ LABELS
    roadways1={'Group.1 I80 EB (138.2-145.8)','Group.1 I80 WB (138.2-145.8)','Group.1 I80 EB (162.3-174.5)','Group.1 I80 WB (162.3-174.5)',...
        'Group.2 I-80 and I-235 EB','Group.2 I-80 and I-235 WB','Group.2 I-35 SB','Group.2 I-35 NB',...
        'Group.3 I-35 SB','Group.3 I-35 NB','Group.4 I-35 SB','Group.4 I-35 NB'};
    roadways2={'Group.5 I-29 SB','Group.5 I-29 NB','Group.5 I-80 EB','Group.5 I-80 WB',...
        'Group.6 I-29 SB','Group.6 I-29 NB','Group.6 US 20 EB','Group.6 US 20 WB',...
        'Group.7 US20 and I380 EB','Group.7 US20 and I380 WB','Group.8 I74 SB','Group.8 I74 NB',...
        'Group.9 I280 SB','Group.9 I280 NB'};    
    if mod(i,6)==1 && i<6*12
        text(0.2,0.5,roadways1(ceil(i/6)))
    end
    if mod(i,6)==4
        text(0.3,0.5,roadways2(ceil(i/6)))
    end
end
export_fig 'test1.pdf'
end