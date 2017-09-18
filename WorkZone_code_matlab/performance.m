function [eventnum, maxduration, avgduration, maxlength, avglength,filteredeventnum]=performance(TrafficData)

%%%%%%filters%%%%%%
lowertime=60;%in 5min
uppertime=252;%in 5min
lowerlength=0.5;%in mile
lowerduration=20;%in min
%%%%%%%%%%%%%%%%%%%

maxduration = 0;
totalduration = 0;
maxlength = 0;
totallength = 0;
eventnum = 0;
filteredeventnum = 0;

for i=1:size(TrafficData,3)

    a=TrafficData(:,:,i);
    [x,y]=find(a<45);

    num=0;
    
    dailymaxduration=0;
    dailytotalduration=0;
    dailymaxlength=0;
    dailytotallength=0;
    if size(x,1)>0
        z=dbscan([x,y],1,1.1);
        clustereddata = [x,y,z'];
        clustereddata(clustereddata(:,end)<=0,:)=[];
        num=max(z);
        event = zeros(2,num);

        for j=1:num

            cluster = clustereddata(clustereddata(:,3)==j,1:2);
            duration = (max(cluster(:,2))-min(cluster(:,2))+1)*5;   % in min
            length = (max(cluster(:,1))-min(cluster(:,1))+1)*0.1;   % in mile
            event(1,j) = duration;
            event(2,j) = length;

        end

        dailymaxduration = max(event(1,:));
        dailytotalduration = sum(event(1,:));
        dailymaxlength = max(event(2,:));
        dailytotallength = sum(event(2,:));
    end

    allpoints=[x,y];
    daypoints=allpoints(x>=lowertime&x<=uppertime,:);
    fnum=0;
    if size(daypoints,1)>0
        z=dbscan(daypoints,1,1.1);
        clustereddata = [daypoints,z'];
        clustereddata(clustereddata(:,end)<=0,:)=[];
        
        for j=1:max(z)

            cluster = clustereddata(clustereddata(:,3)==j,1:2);
            duration = (max(cluster(:,2))-min(cluster(:,2))+1)*5;   % in min
            length = (max(cluster(:,1))-min(cluster(:,1))+1)*0.1;   % in mile
            if duration>=lowerduration&&length>=lowerlength
                fnum=fnum+1;
            end
        end
    end
    
    eventnum = eventnum+num;
    filteredeventnum = filteredeventnum+fnum;
    totalduration = totalduration+dailytotalduration;
    totallength = totallength+dailytotallength;
    if dailymaxduration > maxduration
       maxduration = dailymaxduration; 
    end
    if dailymaxlength > maxlength
       maxlength = dailymaxlength;
    end

end

avgduration = totalduration/eventnum;
avglength = totallength/eventnum;

fprintf('eventnum:          %f   \n',eventnum);
fprintf('filteredeventnum:  %f   \n',filteredeventnum);
fprintf('maxduration:       %f  min \n',maxduration);
fprintf('avgduration:       %f  min \n',avgduration);
fprintf('maxlength:         %f  mile \n',maxlength);
fprintf('avglength:         %f  mile \n',avglength);

end