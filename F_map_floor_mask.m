function [floor_cutoff, floor_params] = F_map_floor_mask(height,angle,camera,reference_frame)
%F_MAP_FLOOR_MASK Summary of this function goes here
%   Detailed explanation goes here

center_pixel = int32(camera.dim_y/2);
pixel_delta = camera.YradPpx;
step_vector = double([-center_pixel+2:1:center_pixel+1]');
angle_vector = step_vector * pixel_delta + abs(angle);
angle_vector(angle_vector < 0) = 0;
cutoff_vector = ((height-0.35)*1000)./sin(angle_vector);
floor_vector = ((height)*1000)./sin(angle_vector);
floor_params = {};

floor_plane = int32(abs(floor_vector * ones(1,camera.dim_x)));

cutoff_map = int32(abs(cutoff_vector * ones(1,camera.dim_x)));
% size(reference_frame);
% size(floor_plane);
diff = abs(reference_frame - floor_plane);
floor_params{Floor.Mask} = diff < 500;
floor_cutoff = cutoff_map;
floor_params{Floor.Compare} = uint16(reference_frame .*  int32(floor_params{Floor.Mask}));
floor_params{Floor.NoFloor} = sum(floor_params{Floor.Mask},"all")<50|any(isnan([height, angle]));
floor_params{Floor.Variation} = sum(floor_params{Floor.Mask},"all")/2;
figure(2);
imshow(floor_params{Floor.Compare});
%floor_cutoff = reference_frame <= cutoff_map;
