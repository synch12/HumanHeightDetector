function Processed_Mask = F_ProcessMask(mask,frame_depth)
%F_PROCESSMASK Summary of this function goes here
%   Detailed explanation goes here
se = strel('disk', 1);
bw = bwareaopen(mask, 50);
frame_dilated = imdilate(bw,se);
frame_min = imerode(frame_dilated,se);
frame_min = imerode(frame_min,se);



%se = strel('disk', 1);
diff_bw = bwareaopen(mask, 50);
frame_diff = int32(frame_depth).*int32(diff_bw);
frame_min = imerode(frame_depth,strel('disk', 1));
edge_bw = ((frame_depth-frame_min)./frame_depth);
alpha = frame_diff & not(edge_bw);
alpha = bwareaopen(alpha,50);

Processed_Mask = alpha;
diff_bw = bwareaopen(mask, 500);

end

