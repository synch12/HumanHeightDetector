%% Function to measure the floor provided a frame and its point cloud
%If it returns NaN that means the method input is likely wrong
function [camera_height,elevation_angle] = F_FloorDetectMeasure(frame,framePtCloud,method)

if(exist('method', 'var') == 0)
	method = 'Area';
end
%%
filt_gen = strel('disk', 4);
[dim_y,dim_x] = size(frame);

frame = imclose(frame,strel('disk', 3));

%% gradient
%does generic processing methods first, mostly the same as the detect
%function
border = size(frame);
frames_bin = zeros(size(frame));
frame_min = imerode(frame,filt_gen);
edge_bw = ((frame-frame_min)./frame);
edge_bw = edge_bw>=0.25;

test_vals = zeros(1,3);

median_vals = 10;
threshhold = 10;

for L=1:1:border(2)
	for H=border(1):-1:(1+median_vals)
		test_a = frame(H,L);
		for b = 1:1:median_vals
			test_vals(b) = frame(H-b,L);
		end
		test_b = median(test_vals);
		test = test_a - test_b;
		%i.e. it has to be a higher gradient value than the one specified,
		%however it also cannot be obsurdly higher.
		if((test<-threshhold)&&(test>-(threshhold*60)))
			frames_bin(H,L)=1;
		else
			frames_bin(H,L)=0;
		end
	end
end

%% grouping

frames_bin = (frames_bin>=1)&~edge_bw;

levels = imopen(frames_bin(:,:),filt_gen);
levels = bwlabel(levels(:,:));

Floor = zeros(size(frame));

%% Group Area
%This is the default method, it just selects the group based off of how
%many pixels are in it, basic, but works
if(strcmp(method,'Area'))
	lrgst_area = 0;	
	num_groups = max(levels(:,:),[],'all');
	for grp = 1:num_groups
		level = zeros(424,512);
		level(levels(:,:)==grp) = 1;
		area = sum(level,'all');
		if(area>lrgst_area)
			lrgst_area = area;
			Floor(:,:) = level;
		end
	end
	
	
	%% reclose group
	Floor(:,:) = imclose(Floor(:,:),strel('disk', 2));
	
%This is the other method, it goes off gradient with a small area check,
%the area check is smaller than the above method.
%This method has a problem that a lot of small detected areas have a very
%high gradient, casue of miss measurements, or small problems with the
%detection mask
elseif(strcmp(method,'Gradient'))
	%% group gradients
	stpest_grad = 0;
	border_allowance = 3;
	
	num_groups = max(levels(:,:),[],'all');
	for grp = 1:num_groups
		level = zeros(424,512);
		level(levels(:,:)==grp) = 1;
		vert = sum(level);
		[vert_max,vert_inc] = max(vert);
		%vert_quart = vert_max/4;
		layer = double(frame(:,:)).*(level);
		line = layer(:,vert_inc);
		line_diff = zeros(424,1);
		for b = 424:-1:border_allowance
			if((line(b)~=0)&&(line(b-border_allowance)~=0))
				line_diff(b) = double(line(b))-double(line(b-1));
			end
		end
		
		vals = find(line_diff~=0);
		grad = median(double(line_diff(vals)));%mean seems to work better
		if((grad<stpest_grad*1.02)&&(length(vals)>20))
			stpest_grad = grad;
			Floor(:,:) = level;
		end
		
	end
end

%% filter floor detection
%Currently using largest group, could also use the steepest, though could
%cause issues, combination of both could be best.
floor_bin = Floor>0;
floor_bin = imopen(floor_bin,strel('disk', 8));

%% convert point cloud to usable XYZ
framePts = zeros([size(frame),3]);

for column = 0:1:dim_x-1
	startidx = (column)*dim_y +1 ;
	stopidx = (column+1)*dim_y;
	indc = startidx:stopidx;
	sel = select(framePtCloud,indc).Location;
	framePts(:,dim_x-column,:) = sel;
end

%% Get line values/group then get height
%this is where the height and angle of the camera is calculated, there are
%a few assumptions in it, they are detailed in the thesis and manuscipt
%that were completed with this project. 

%Currently calculating the angle value off the height value for that
%column, could be agood idea to change it so it uses the height value after
%the median, but then the calculation for loops would have to run twice.

column_tots = sum(floor_bin,1);

%number of pixels to select from edge at the minimum, it will aim for a
%quarter from the edges though
dis_from_edge = 10;
%minimum number of pixels needed in the column of the detected height mask
%for the calculation to occur, if none meet this criteria no height is
%calculated.
min_col_height = 40;

measured_heights = zeros(dim_x,1);
measured_angles = zeros(dim_x,1);
for col = 1:1:dim_x
	if(column_tots(col)>min_col_height)
		[valsX, ~] = find(floor_bin(:,col)>0);
		
		sample_low = min(valsX)+dis_from_edge;
		sample_high = max(valsX)-dis_from_edge;
		
		y1 = framePts(sample_low,col,2);
		z1 = framePts(sample_low,col,3);
		y2 = framePts(sample_high,col,2);
		z2 = framePts(sample_high,col,3);
		
		numer = (z2*y1 - y2*z1)^2;
		denom = (y2-y1)^2+(z2-z1)^2;
		
		H = sqrt(numer/denom);
		measured_heights(col) = H;
		
		theta_e = atan(y2/z2) - asin(H/(sqrt(y2^2+z2^2)));
		measured_angles(col) = theta_e;
	else
		measured_heights(col) = NaN;
		measured_angles(col) = NaN;
	end
end
cam_height_med = median(measured_heights,'omitnan');
%cam_height_mean = mean(measured_heights,'omitnan');

cam_angle_med = median(measured_angles,'omitnan');
%cam_angle_mean = mean(measured_angles,'omitnan');

camera_height = cam_height_med;
elevation_angle = cam_angle_med;
