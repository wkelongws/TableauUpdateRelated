function [WBspeed,EBspeed,WBvolume,EBvolume,WBissue,EBissue,startdatenum,...
    WBoff,WBfail,WBzerospeednonzerocount,WBmissingveh,WBclassmisscount,...
    EBoff,EBfail,EBzerospeednonzerocount,EBmissingveh,EBclassmisscount]...
    =SpeedMatrixReduction(speeddata,milemarker,timeinterval,WB,EB,reportstartday,reportendday)

milemarker = sortrows(milemarker,4);

WBDetectorID=milemarker(milemarker(:,1)==WB,3);
EBDetectorID=milemarker(milemarker(:,1)==EB,3);
% WBDetectorID=milemarker(:,WB);
% EBDetectorID=milemarker(:,EB);

bb=speeddata(speeddata(:,2)>0,:);
bb(:,2)=bb(:,2)+693960;
% fileter by the date range
bb(bb(:,2)<datenum(reportstartday),:)=[];
bb(bb(:,2)>datenum(reportendday),:)=[];

% grouping data by date
% bb=[bb floor(bb(:,2))];
bb=sortrows(bb,[2 3 4]);

startdatenum=bb(1,2);

[~,~,uniqueIndex] = unique(bb(:,2));
celldata = mat2cell(bb,accumarray(uniqueIndex(:),1),size(bb,2));

WBspeed=nan(24*60/timeinterval,length(WBDetectorID),size(celldata,1));
WBvolume=WBspeed;
WBissue=WBspeed;
WBoff=WBspeed;
WBfail=WBspeed;
WBzerospeednonzerocount=WBspeed;
WBmissingveh=WBspeed;
WBclassmisscount=WBspeed;

EBspeed=nan(24*60/timeinterval,length(EBDetectorID),size(celldata,1));
EBvolume=EBspeed;
EBissue=EBspeed;
EBoff=EBspeed;
EBfail=EBspeed;
EBzerospeednonzerocount=EBspeed;
EBmissingveh=EBspeed;
EBclassmisscount=EBspeed;
    
% big 'for' loop to deal one day data at a time
for k=1:size(celldata,1)
    onedaydata=cell2mat(celldata(k));
    onedaydata=sortrows(onedaydata,1);
        
    % grouping data by detector
    [~,~,uniqueIndex] = unique(onedaydata(:,1));
    cellonedaydata = mat2cell(onedaydata,accumarray(uniqueIndex(:),1),size(onedaydata,2));
    
    % small 'for' loop to deal one detector data at a time
    for j=1:size(cellonedaydata,1)
        onedetectordata=cell2mat(cellonedaydata(j));
        onedetectordata=sortrows(onedetectordata,[2 3 4]);
        detecID=onedetectordata(1,1);
        datenumber=floor(onedetectordata(1,2));
        onedetectordata(:,2)=onedetectordata(:,3)*60+onedetectordata(:,4)*5+0.1;  % convert timestamp to number of 5 mins
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            onedetectordata(onedetectordata(:,5)<=0,[5 6 7])=nan;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tailmatrix=zeros(24*60/timeinterval, size(onedetectordata,2)); % incert break points, first colume = 0 is the marker
        tailmatrix(:,2)=[0:timeinterval:24*60-timeinterval]';
        onedetectordata=[onedetectordata;tailmatrix];
        onedetectordata=sortrows(onedetectordata,2);
                
        % grouping data by time interval
        onedetectordata=[onedetectordata,zeros(size(onedetectordata,1),1)]; % incert the key colume
        onedetectordata(1,end)=1;
        for i=2:size(onedetectordata,1)
            if   onedetectordata(i,1)==0
                 onedetectordata(i,end)=onedetectordata(i-1,end)+1;
            else onedetectordata(i,end)=onedetectordata(i-1,end);
            end
        end
        celltimedata = mat2cell(onedetectordata,accumarray(onedetectordata(:,end),1),size(onedetectordata,2));
    
        % creat an empty matrix, need to return it later
        timeintervaldata=zeros(size(celltimedata,1),5);
        issueindicator=zeros(size(celltimedata,1),5);

        % calculate the aggregated speed and volume one by one
        for i=1:size(celltimedata,1)
            avgtraffic=cell2mat(celltimedata(i));
            avgtraffic(1,:)=[];
            if size(avgtraffic,1)==0
                avgtraffic=[nan(1,2) 50];    % issue = 50 for losing connection
            else issues =   avgtraffic(:,8);                         % aggregation algorithm
                if max(issues == 10)%off
                    issueindicator(i,1)=1;
                end
                if max(issues == 20)%fail
                    issueindicator(i,2)=1;
                end
                if max(issues == 30)%zerospeednonzerocount
                    issueindicator(i,3)=1;
                end
                if max(issues == 40)%missingveh
                    issueindicator(i,4)=1;
                end
                if max(issues == 60)%classmisscount
                    issueindicator(i,5)=1;
                end
                %issues(issues==60)=0;
                avgtraffic=[nansum(avgtraffic(:,6)) ...                                     % sum the raw count
                    nansum(avgtraffic(:,6).*avgtraffic(:,5))/nansum(avgtraffic(:,6)) ...  % weighted average by raw count for speed
                    max(issues)]; 
                
            end
            
            timeintervaldata(i,:)=[detecID,(i-1)*timeinterval,avgtraffic];
        end
        
        if max(EBDetectorID==detecID)==1
            location=find(EBDetectorID==detecID);
            EBvolume(:,location,k)=timeintervaldata(:,3);
            EBspeed(:,location,k)=timeintervaldata(:,4);
            EBissue(:,location,k)=timeintervaldata(:,5);
            EBoff(:,location,k)=issueindicator(:,1);
            EBfail(:,location,k)=issueindicator(:,2);
            EBzerospeednonzerocount(:,location,k)=issueindicator(:,3);
            EBmissingveh(:,location,k)=issueindicator(:,4);
            EBclassmisscount(:,location,k)=issueindicator(:,5);
            
            
        else if max(WBDetectorID==detecID)==1
            location=find(WBDetectorID==detecID);
            WBvolume(:,location,k)=timeintervaldata(:,3);
            WBspeed(:,location,k)=timeintervaldata(:,4);
            WBissue(:,location,k)=timeintervaldata(:,5);
            WBoff(:,location,k)=issueindicator(:,1);
            WBfail(:,location,k)=issueindicator(:,2);
            WBzerospeednonzerocount(:,location,k)=issueindicator(:,3);
            WBmissingveh(:,location,k)=issueindicator(:,4);
            WBclassmisscount(:,location,k)=issueindicator(:,5);
            
            else
            end
            
        end
     
    end   
end

%%%% if no speed, give it losing connection %%%%
WBissue(isnan(WBspeed) & isnan(WBvolume) & isnan(WBissue))=50;
EBissue(isnan(EBspeed) & isnan(EBvolume) & isnan(EBissue))=50;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WBspeed=permute(WBspeed, [2 1 3]);
% WBspeed=flipdim(WBspeed,1);
WBvolume=permute(WBvolume, [2 1 3]);
% WBvolume=flipdim(WBvolume,1);
WBissue=permute(WBissue, [2 1 3]);
WBoff=permute(WBoff, [2 1 3]);
WBfail=permute(WBfail, [2 1 3]);
WBzerospeednonzerocount=permute(WBzerospeednonzerocount, [2 1 3]);
WBmissingveh=permute(WBmissingveh, [2 1 3]);
WBclassmisscount=permute(WBclassmisscount, [2 1 3]);

EBspeed=permute(EBspeed, [2 1 3]);
% EBspeed=flipdim(EBspeed,1);
EBvolume=permute(EBvolume, [2 1 3]);
% EBvolume=flipdim(EBvolume,1);
EBissue=permute(EBissue, [2 1 3]);
EBoff=permute(EBoff, [2 1 3]);
EBfail=permute(EBfail, [2 1 3]);
EBzerospeednonzerocount=permute(EBzerospeednonzerocount, [2 1 3]);
EBmissingveh=permute(EBmissingveh, [2 1 3]);
EBclassmisscount=permute(EBclassmisscount, [2 1 3]);

% WBspeed(WBspeed==0)=nan;
% EBspeed(EBspeed==0)=nan;
end