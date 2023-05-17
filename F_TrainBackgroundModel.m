function [frame_rgb,averaged_frame, PointCloud] = F_TrainBackgroundModel(camera, detector, trainingFrames)
%F_TRAINBACKGROUNDMODEL Summary of this function goes here
%   Detailed explanation goes here

Averaging_Frames = int32(zeros(camera.dim_y,camera.dim_x,trainingFrames));
camera.Start();
[frame_depth, frame_rgb, mask_fg, frame_PtCloud] = detector.Update();
for i = 1:1:trainingFrames
    [frame_depth, frame_rgb, mask_fg, frame_PtCloud] = detector.Update();
    ave_frame = int32(frame_depth);
    Averaging_Frames(:,:,i) = ave_frame;
end
camera.Stop();
averaged_frame = int32(median(Averaging_Frames,3));
backgroundPtGen = uint16(averaged_frame);
PointCloud = pcfromkinect(camera.depthSource, backgroundPtGen);
end

