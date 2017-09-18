topheader={'IWZ','Direction','1. number of days','2. number of events','3. number of daytime events','4. number of days when events happened',...
    '5. average duration of each event','6. median duration of each event','7. average queue length',...
    '8. average maximum queue length of each event','9. median maximum queue length of each event',...
    '10. max maximum queue length of each event','11.percentage of queue > 1 mile','12.amount of traffic that encounters a queue',...
    '13.total traffic per day','14.percentage of traffic that encounters a queue','15.percentage of time that encounters a queue',...
    '16.total delay','17.total delay per day','18.average delay per vehicle','19.maximum delay','20.total delay when queue is present',...
    '21.percentage of delay caused by queue','22.avg delay when queue is present','23.percent of vehicles experiencing delay > 5 min',...
    '24.percent of vehicles experiencing delay > 10 min','25.percent of vehicles in queue experiencing delay > 5 min',...
    '26.percent of vehicles in queue experiencing delay > 10 min'};
%% performance summary
fid = fopen('S:\(S) SHARE\_project CTRE\1_Active Research Projects\Iowa DOT OTO Support\14_Traffic Critical Projects 2\2016\IWZ Data for Tableau\CSV Tableau All in One\performance_table.csv');
% fid = fopen('S:\(S) SHARE\_project CTRE\1_Active Research Projects\Iowa DOT OTO Support\14_Traffic Critical Projects 2\2016\Weekly Reports\performance_table.csv');
C = textscan(fid, '%s %s %s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter',',','HeaderLines', 1);
fclose(fid);
period=C{2};
[~,~,uniqueindex]=unique(period);
currentperiod=uniqueindex==max(uniqueindex);
name=C{3};
name(currentperiod)=[];
dir=C{4};
dir(currentperiod)=[];
IDs=cell(size(name,1),1);
for i=1:size(IDs,1)
    IDs{i}=[name{i} dir{i}];
end
Cdata=[C{5} C{6} C{7} C{8} C{9} C{10} C{11} C{12} C{13} C{14} C{15} C{16} C{17} C{18} C{19} C{20} C{21} C{22} C{23} C{24} C{25} C{26} C{27} C{28} C{29} C{30}];
Cdata(currentperiod,:)=[];
[~,~,uniqueindex]=unique(IDs);
header=topheader(3:end);

% fid1 = fopen('S:\(S) SHARE\_project CTRE\1_Active Research Projects\Iowa DOT OTO Support\14_Traffic Critical Projects 2\2016\IWZ Data for Tableau\performance_table_summary.csv','w');
% fprintf(fid1,'%s,%s,%s,','ID','IWZ','Direction');
% for i=1:numel(header)
%     fprintf(fid1,'%s,%s,%s,%s,%s,%s,',['min_' header{i}],['max_' header{i}],...
%         ['mean_' header{i}],['std_' header{i}],['15prctile_' header{i}],['85prctile_' header{i}]);
% end
% fprintf(fid1,'\r\n');
% for i=1:max(uniqueindex)
%     data=Cdata(uniqueindex==i,:);
%     sensorname=unique(name(uniqueindex==i));
%     sensordir=unique(dir(uniqueindex==i));
%     fprintf(fid1,'%f,%s,%s,',i,sensorname{:},sensordir{:});
%     data_min=min(data);
%     data_max=max(data);
%     data_mean=nanmean(data,1);
%     data_std=nanstd(data,1);
%     data_15=prctile(data,15,1);
%     data_85=prctile(data,85,1);
%     for k=1:numel(data_min)
%         fprintf(fid1,'%f,%f,%f,%f,%f,%f,',data_min(k),data_max(k),data_mean(k),...
%             data_std(k),data_15(k),data_85(k));
%     end
%     fprintf(fid1,'\r\n');
% end
% fclose(fid1);

fid1 = fopen('S:\(S) SHARE\_project CTRE\1_Active Research Projects\Iowa DOT OTO Support\14_Traffic Critical Projects 2\2016\IWZ Data for Tableau\CSV Tableau All in One\performance_table_summary.csv','w');
% fid1 = fopen('S:\(S) SHARE\_project CTRE\1_Active Research Projects\Iowa DOT OTO Support\14_Traffic Critical Projects 2\2016\Weekly Reports\performance_table_summary.csv','w');
fprintf(fid1,'%s,%s,%s,','ID','IWZ','Direction');
for i=1:numel(header)
    fprintf(fid1,'%s,%s,%s,%s,%s,%s,',['min_' header{i}],['max_' header{i}],...
        ['mean_' header{i}],['std_' header{i}],['15prctile_' header{i}],['85prctile_' header{i}]);
end
fprintf(fid1,'\r\n');
for i=1:max(uniqueindex)
    data=Cdata(uniqueindex==i,:);
    sensorname=unique(name(uniqueindex==i));
    sensordir=unique(dir(uniqueindex==i));
    fprintf(fid1,'%f,%s,%s,',i,sensorname{:},sensordir{:});
    data_min=min(data);
    data_max=max(data);
    data_mean=nanmean(data,1);
    data_std=nanstd(data,1);
    data_15=prctile(data,15,1);
    data_85=prctile(data,85,1);
    for k=1:numel(data_min)
        fprintf(fid1,'%f,%f,%f,%f,%f,%f,',data_min(k),data_max(k),data_mean(k),...
            data_std(k),data_15(k),data_85(k));
    end
    fprintf(fid1,'\r\n');
end
fclose(fid1);
