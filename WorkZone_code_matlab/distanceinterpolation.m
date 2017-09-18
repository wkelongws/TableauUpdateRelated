function [speednorm]=distanceinterpolation(speed,milemarker,distanceinterval,method,direction)

if size(speed,1)==1
    speednorm=speed;
else

    milemarker = sortrows(milemarker,4);
    milemarker=milemarker(milemarker(:,1)==direction,[3 4]);
    mm=round(milemarker(:,end)*1000)/1000;

    %speednorm=nan(size(speed,1),ceil((mm(end)-mm(1))/distanceinterval)+1,size(speed,3));

    xdistance=mm; % detector locations
    if round(ceil((mm(end)-mm(1))/distanceinterval)*10)/10==round((mm(end)-mm(1))/distanceinterval*10)/10; % if the total distance is times of distanceinterval
        xxdistance=mm(1):distanceinterval:mm(end);  % interpolation locations
    else 
        xxdistance=[mm(1):distanceinterval:mm(end),mm(end)];    % interpolation locations
    end
    xxdistance=xxdistance';
    speednorm=nan(length(xxdistance),size(speed,2),size(speed,3));
    for k=1:size(speed,3)  % per day
        for i=1:size(speed,2)   % per time

            ydata=speed(:,i,k); % speed along the road
            if sum(1-isnan(ydata))>1    % need to have two readings at least
            y=ydata(logical(1-isnan(ydata)));   % find the readings
            x=xdistance(logical(1-isnan(ydata)));
            xx=xxdistance(xxdistance>=x(1)&xxdistance<=x(end));
            yy=interp1(x,y,xx,method);
            speednorm(xxdistance>=x(1)&xxdistance<=x(end),i,k)=yy;
    %         speednorm(:,i,k)=speednorm(:,i,k);
            else
            end
        end
    end
end