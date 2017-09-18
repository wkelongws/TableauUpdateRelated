function MM = LL2MM (LL,milemarker,distanceinterval)
% know ordered sensor list, given lat and long of DMS or Crash, return the
% mile marker and location index on heatmap of DMS or Crash
innerdis=zeros(size(milemarker,1),1);
for i=1:size(milemarker,1)-1
innerdis(i+1)=deg2sm(distance('rh',milemarker(i+1,3:4),milemarker(i,3:4)));
end
dis=cumsum(innerdis);

LLloc=zeros(size(LL,1),1);
for i=1:size(LL,1)
    NN=[milemarker dis deg2sm(distance('rh',milemarker(:,3:4),LL(i,2:3)))];
    NN=sortrows(NN,size(milemarker,2)+2);
    NN2=NN(1:2,:);
    if NN2(1,end-1)<NN2(2,end-1)
        if NN2(2,end)>NN2(2,end-1)-NN2(1,end-1)
            LLloc(i,1)=NN2(1,end-1)-NN2(1,end);
        else
            LLloc(i,1)=NN2(1,end-1)+NN2(1,end);
        end
    else
        if NN2(2,end)>NN2(1,end-1)-NN2(2,end-1)
            LLloc(i,1)=NN2(1,end-1)+NN2(2,end);
        else
            LLloc(i,1)=NN2(1,end-1)-NN2(1,end);
        end
    end
end
MM=interp1(dis,milemarker(:,end),LLloc,'linear','extrap');

mm=round(milemarker(:,end)*100)/100;
if round(ceil(round(((mm(end)-mm(1))/distanceinterval)*1000)/1000)*1000)/1000==round((mm(end)-mm(1))/distanceinterval*1000)/1000; % if the total distance is times of idstanceinterval
    xxdistance=mm(1):distanceinterval:mm(end);  % interpolation locations
else 
    xxdistance=[mm(1):distanceinterval:mm(end),mm(end)];    % interpolation locations
end
xxdistance=xxdistance';
heatmaploc=interp1(xxdistance,1:length(xxdistance),MM,'linear','extrap');
MM=[LL MM heatmaploc];

