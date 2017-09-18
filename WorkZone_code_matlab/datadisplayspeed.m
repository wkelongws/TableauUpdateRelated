function  datadisplayspeed(final3D,minspeed,maxspeed)
%DATADISPLAY display the speed matrix with color
%   Create a colored map of speed on target roadway during the time of
%   day. The color bar on the right shows relation ship between color and 
%   speed. Generally the darker the color is, the lower the speed is. And 
%   the white color mean the coresponding cell contains NaN value.

% calculate the averge speed ignoring the NaN values
meanspeed=nanmean(final3D,3);

% Create a new colormap with 140 index where index 40 represents RGB value 
% (165,0,0), index 80 represents (255,0,0), index 120 represents
% (255,255,0) index 140 represents (0,255,255) and the other indexes are
% linearly mapped.
speedcolormap=zeros(160,3);
for i=1:20
    speedcolormap(i,:)=[i*165/20,0,0];
end
for i=21:40
    speedcolormap(i,:)=[(i-20)*(255-165)/20+165,0,0];
end
for i=41:90
    speedcolormap(i,:)=[255,(i-40)*255/50,0];
end
for i=91:160
    speedcolormap(i,:)=[(i-90)*(0-255)/70+255,255,0];
end

% Add the white color to the very left of the colormap for NaN values
speedcolormap=[255,255,255;speedcolormap]/255;

% cutoff=round(65/75*160);
% speedcolormap(cutoff:end,:)=ones(size(speedcolormap(cutoff:end,:)));

colormap(speedcolormap);

% Create image
image(meanspeed,'CDataMapping','scaled');

% Map speed value to the colormap: index 2n maps to speed n mph. 
% e.g. 70 mph matches index 140; 40 mph matches index 80.

%maxspeed=max(max(meanspeed));
caxis([minspeed,maxspeed]);


end

