function [data,csvdata] = IWZread(filename)

fid = fopen(filename);
if fid < 0

    data=0;
%     sensorname=0;
%     sensorID=0;
  return
end

C = textscan(fid, '%s %f %f %f %f %s %s %s %s %f %f %f %s %f %f %s %s %s %f %f %f %f %f %f', 'Delimiter','\t','HeaderLines', 0);
fclose(fid);

data=[C{10},datenum(C{18})-693960,C{19},C{20},C{21},C{22},C{23},C{24}];

csvdata=[C{17},C{18},num2cell(C{19}),num2cell(C{20}),num2cell(C{21}),num2cell(C{22}),num2cell(C{23}),num2cell(C{24})];
%data=[ID(~strcmp(timestamp,'')),datenum(timestamp(~strcmp(timestamp,'')))-693960,count(~strcmp(timestamp,'')),speed(~strcmp(timestamp,'')),occupancy(~strcmp(timestamp,''))];
% sensorname=C{1};
% sensorID=C{2};
% 
% [~,y,~]=unique(sensorID);
% 
% sensorID=sensorID(y);
% sensorname=sensorname(y);

end