 function [heights,depthFrame] = F_MeasureHeights(alpha,frame_diff,frame,framePtCloud,camElevationAngle,camHeight)
%F_MEASUREHEIGHTS Summary of this function goes here
%   Detailed explanation goes here
[dim_y,dim_x] = size(frame);
depthFrame = int32(zeros(dim_y,dim_x));
groups = bwlabel(alpha);

num_groups = max(groups(:));

%% preallocate
%person_save_mask = zero_arr;
%person_save_frame = zero_arr;
px_area = zeros(num_groups);
depth_av = zeros(num_groups);
real_area = zeros(num_groups);
heights = NaN(num_groups,3);


%%

for grp = 1:num_groups
	person_mask = (groups==grp);
	
	person = find(person_mask==1);
	
	%Extract the 'person' from the current image using the mask found from
	%the difference image
	person_dist = int32(frame_diff).*int32(person_mask);
	
	%Check it actually has values in it
	if not(isempty(person))
		%if it does, get the real area of the 'person'
		px_area(grp) = length(person);
		depth_av(grp) = double(median(frame(person)))/1000;
		real_area(grp) = int32(px_area(grp).*(depth_av(grp)).^2);
	else
		px_area(grp) = 0;
		depth_av(grp) = 0;
		real_area(grp) = 0;
	end
	
	%if the real area is big enough, then calculate height of 'person'
	if(real_area(grp)>10000)
		[y_indA,~] = find(person_dist);
		depthFrame = depthFrame + person_dist;
		loc_y = min(y_indA);
		[~, x_indB] = find(person_dist(loc_y,:));
		
		loc_x = round(median(x_indB));
		
		p3 = select(framePtCloud,loc_y,dim_x-loc_x).Location;
		y3 = p3(2);
		z3 = p3(3);
		camToPersonDist = (sqrt(y3^2+z3^2));
		heightAngleDeviation = atan(y3/z3)*-1;
		totalAngleDeviation = (sin(camElevationAngle+heightAngleDeviation));
		heightFromCamLevel = camToPersonDist*totalAngleDeviation;
		heights(grp,1) = heightFromCamLevel + camHeight;
        heights(grp,1)
		%For debugging, prints the heights and angles of each detected person
		% 						disp("grp: " + grp + " ,  height: " +  height(grp) + " p: " + p + " ,  L: " + L + " ,  thetaT: "...
		% 			+ rad2deg(theta_t) + " thetaP:  " + rad2deg(theta_d) + " ,  y3: " + y3 + " ,  z3: " + z3)
		
		heights(grp,2) = loc_x;
		heights(grp,3) = loc_y;
		
		%For debugging
		%disp("grp: " + grp + " ,  height: " +  height(grp) + " , disp H: " + text)		
		% 			text(rend_X(grp),rend_Y(grp)-.5,[num2str(height(grp),3),'m'], 'HorizontalAlignment','center','color',colors{2},...
		%           'VerticalAlignment','baseline', 'fontunits','normalized', FontSize',font_size,'backgroundcolor',colors{3})
		
	else
		%it it isnt high enough, set all to NaN
		heights(grp,1) = NaN;
		heights(grp,2) = NaN;
		heights(grp,3) = NaN;
	end
end

%Trim off all rows that have one or more NaN value. 
nanRows = any(isnan(heights), 2);
heights(nanRows,:) = [];

