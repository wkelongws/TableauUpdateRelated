function totaldelaydata = TravelTimeDef(SpeedData,volumedata,speedlimit)



%volumedata = volumedata/12;
volumedata(volumedata==0)=nan;
for i=1:size(volumedata,1)
    for j=1:size(volumedata,2)
        for k=1:size(volumedata,3)
            if isnan(volumedata(i,j,k))
                volumedata(i,j,k)=nanmean(volumedata(:,j,k));
            end
        end
    end
end
% volumedata=nanmean(volumedata,1);

% volume = nansum(nansum (volumedata));
SpeedData(SpeedData==0)=nan;

delaydata = zeros(size(SpeedData));    %in min
for i=1:size(SpeedData,1)
j=1;
flag=0;
    while j<=size(speedlimit,1)
        if i<speedlimit(j,1)
            delaydata(i,:,:)=0.1./SpeedData(i,:,:)-0.1/speedlimit(j,2);
            flag=1;
            break
        else j=j+1;
        end
    end
    if flag==0
    delaydata(i,:,:)=0.1./SpeedData(i,:,:)-0.1/speedlimit(end,end);
    end
end

delaydata (delaydata<0) = 0;
% delaydata = nansum(delaydata,1);
totaldelaydata = delaydata*60.*volumedata;   %in veh*min
% totaldelay = nansum(nansum(delaydata.*volumedata));
% avgdelay = totaldelay/volume/size(SpeedData,1)/0.1*10;
% 
% fprintf('totalvehicle2week:     %f   \n',volume/1000);
% fprintf('averagedelay:          %f  min/veh/10mi \n',avgdelay);

end