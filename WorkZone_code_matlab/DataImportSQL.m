% Make connection to database. 
% Using ODBC driver.
conn = database.ODBCConnection('shuowang','sa','w1231212s');

% timeandspeed=['select a,b, c from incident.dbo.test'];
% create cursor.
% e = exec(conn,timeandspeed);

% get data
% e = fetch(e);
% close(e)

% Assign data to output variable.
% test = e.Data;
% A=[1,2,3;1,2,3];
colnames={'detector_name','coded_detectorID','latitude','longitude','old_groupID','detector_direction','trivialnumber'...
    ,'detector_name1','date','hour','min_5','lane_number','speed','count'};

list1 = dir('C:\Users\shuowang\Desktop\Projects & Papers\IWZ bi-weekly report\IWZ_DATA_txt\*.txt');
for i = 1:length(list1)
filename=['C:\Users\shuowang\Desktop\Projects & Papers\IWZ bi-weekly report\IWZ_DATA_txt\' list1(i).name];
fid = fopen(filename);
C = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s', 'Delimiter','\t','HeaderLines', 0);
raw = [C{1},C{2},C{3},C{4},C{5},C{6},C{7},C{8},C{9},C{10},C{11},C{12},C{13},C{14}];
%data_table = cell2table(raw,'VariableNames',colnames);
fastinsert(conn,'IWZ.dbo.aggregated_5min_data',colnames,raw);

end

colnames={'Direction','coded_direction','IWZ','Latitude','Longitude','Name','ID'...
    ,'Order_','Ramp','Route','Linear_Reference'};

close(conn)

%%%%%%%%%%%%%%%%%%

% conn = database.ODBCConnection('shuowang','sa','w1231212s');
% 
% list3 = dir('C:\Users\shuowang\Desktop\Projects & Papers\IWZ bi-weekly report\MileMarkers\*.csv');
% for i = 1:length(list3)
% filename=['C:\Users\shuowang\Desktop\Projects & Papers\IWZ bi-weekly report\MileMarkers\' list3(i).name];
% fid = fopen(filename);
% C = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s', 'Delimiter',',','HeaderLines', 1);
% raw = [C{1},C{2},C{3},C{4},C{5},C{6},C{7},C{8},C{9},C{10},C{11}];
% %data_table = cell2table(raw,'VariableNames',colnames);
% fastinsert(conn,'IWZ.dbo.detectorlist',colnames,raw);
% 
% end
% 
% 
% close(conn)



