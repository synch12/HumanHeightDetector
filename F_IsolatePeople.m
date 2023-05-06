function [alpha,frame_diff] = F_IsolatePeople(mask_fg,frame_depth)
%F_ISOLATEPEOPLE Summary of this function goes here
%   Detailed explanation goes here

se = strel('disk', 1);
bw = bwareaopen(mask_fg, 500);
frame_dilated = imdilate(bw,se);
frame_min = imerode(frame_dilated,se);
frame_diff = frame_depth.*uint16(frame_min);
edge_bw = ((frame_depth-frame_diff)./frame_depth);
alpha = frame_diff & not(edge_bw);
alpha = bwareaopen(alpha,50);
end

