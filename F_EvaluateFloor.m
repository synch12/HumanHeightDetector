function [recalibrate] = F_EvaluateFloor(floor_params,frame_depth)
%F_EVALUATEFLOOR Summary of this function goes here
%   Detailed explanation goes here

frame_depth(~floor_params{Floor.Mask}) = 0;

floor_delta = sum(abs(floor_params{Floor.Compare} - frame_depth)>100,"all");
recalibrate = floor_delta > floor_params{Floor.Variation} | floor_params{Floor.NoFloor};
%figure(3);
%imshow(floor_delta);
end

