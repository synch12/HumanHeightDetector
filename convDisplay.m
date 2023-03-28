function [colour_out, depth_out] = convDisplay(frame_depth, frame_colour, mag_fact, det_frame)	
%this is for resizing the depth and colour images and superimposing them
%not for adding text
if(exist('det_frame', 'var') == 0)
	det_frame = zeros(size(frame_depth));
end

%% the aspect ratios of the different cameras
x_fact_depth = 53;
y_fact_depth = 64;
x_fact_colour = 36;
y_fact_colour = 64;

%% this multiplies the ratio by the magnification factor imputted.
% the depth camera is lower as it needs a different resolution than the
% colour
% the resizing is definitly not quite right, but it works well enough
xRanD = x_fact_depth*(mag_fact-5);
yRanD = y_fact_depth*(mag_fact-5);
xRanC = x_fact_colour*(mag_fact);
yRanC = y_fact_colour*(mag_fact);

a = abs(xRanC - xRanD);
b = abs(yRanC - yRanD);
c = round(a/2);
d = round(b/2);

%usally 21 is used for the input for this
%as that is a "good enough" number. 
%it does crash on other numbers

%One note about the kinect, the depth camera can see higher and lower than
%the colour camera, and the colour camera can see wider than the depth
%camera. i.e. the depth camera has a higher verticle FOV and a smaller
%horizontal FOV than the colour camera.
%So they dont quite match up. 
%%
colour_out = uint8(zeros(xRanD,yRanD,3));


col = imresize(frame_colour,[xRanC yRanC]);
dis = imresize(det_frame,[xRanD yRanD]);
%copy over a image res x3 of all three values, to make a greyscale RGB image
%that can be used for display
dis(:,:,1) = dis(:,:);
dis(:,:,2) = dis(:,:,1);
dis(:,:,3) = dis(:,:,1);

%This section maps the centre of the colour camera to the same postions in
%the depth FOV
colour_out(c:xRanD-c-1,:,:) = col(:,d:yRanC-d-1,:);
colour_out(1:c,:,:) = dis(1:c,:,:);
colour_out(xRanD-c:xRanD,:,:) = dis(xRanD-c:xRanD,:,:);

%This sets all 0 values to NaN, allowing min to work properly 
depth_col = zeros(size(frame_depth));
depth_col(frame_depth~=0) = frame_depth(frame_depth~=0);
depth_col(frame_depth==0) = NaN;

max_dist = max(depth_col,[],'all');
min_dist = min(depth_col,[],'all');

diff_dist = min_dist/max_dist;

%this converts the depth image into displayable form without using [] in
%imshow, i.e. it converts it to 0-1.00 values according to depth
dis_temp = (((depth_col+min_dist)./max_dist)-diff_dist);
dis_temp = dis_temp + double(det_frame);
depth_out = imresize(dis_temp,[xRanD yRanD]);




