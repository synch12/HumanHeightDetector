%% ave
%This takes a set amount of averages, it requires the kinect camera, the
%number of images to take, and the minimum time between images.
function [averaged_frame, frames] = getAverage(Kinect_depth_Camera,num_averages,frame_delay)
frames = int32(zeros(424,512,num_averages));
for ave = 1:1:num_averages
	frame = getsnapshot(Kinect_depth_Camera);
	frame = int32(frame);
	frames(:,:,ave) = frame;
	pause(frame_delay)
end

averaged_frame = int32(median(frames,3));
%Median is used as it should filter out anything that does not loiter in
%the same place for over half the images.

%Improvements could definitely be made. the first one is to change it from
%median to use a lower mark, i.e. upper quartile, or like the  0.90 margin,
%as stuff is more liekly to be added in front of the back ground, thus
%biasing towards further distances would be more reliable. 

%second change is to change the way it takes images, as setting the time
%space to something like 0.5 causes it too take much longer than expected,
%this is think is due to the getsnapshot() command