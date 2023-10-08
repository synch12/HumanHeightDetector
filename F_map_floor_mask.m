function [floor_map, floor_mask, floor_cutoff] = F_map_floor_mask(height,angle,camera,reference_frame)
%F_MAP_FLOOR_MASK Summary of this function goes here
%   Detailed explanation goes here

center_pixel = int32(camera.dim_y/2);
pixel_delta = camera.YradPpx;
step_vector = double([-center_pixel+2:1:center_pixel+1]');
angle_vector = step_vector * pixel_delta + abs(angle) ;
cutoff_vector = ((height-0.35)*1000)./sin(angle_vector);
floor_vector = ((height)*1000)./sin(angle_vector);


floor_map = int32(abs(floor_vector * ones(1,camera.dim_y)));
cutoff_map = int32(abs(cutoff_vector * ones(1,camera.dim_y)));
size(floor_map)
size(reference_frame)
diff = abs(reference_frame - floor_map);
floor_mask = diff < 100;
floor_cutoff = cutoff_map;
%floor_cutoff = reference_frame <= cutoff_map;
