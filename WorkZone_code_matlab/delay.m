function [volumedaily,avgdelay] = delay(TrafficData,volumedata,refspeed,reportstartday,reportendday)

%volumedata = volumedata/12;
volumedata(volumedata==0 | volumedata>1000)=nan;
volumedata=nanmean(volumedata,1);

volume = nansum(nansum (volumedata));
TrafficData(TrafficData==0)=nan;
delaydata = (0.1./TrafficData-0.1/refspeed)*60;    %in min
delaydata (delaydata<0) = 0;
delaydata = nansum(delaydata,1);
totaldelay = nansum(nansum(delaydata.*volumedata));
avgdelay = totaldelay/volume/(size(TrafficData,1)*0.1/10);

fprintf('totalvehicle2week:     %f   \n',volume/1000);
fprintf('averagedelay:          %f  min/veh/10mi \n',avgdelay);

volumedaily=volume/(datenum(reportendday)-datenum(reportstartday)+1);%ADT(1000 veh)
end