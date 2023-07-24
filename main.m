function [done] = main(CamSettings, DetectionMethod,training_frames, parameters)
%% Created 18/03/23 By Malachi Wihongi
%   Initialise camera and detector
[camera,detector] = F_ParseParameters(CamSettings, DetectionMethod );
camera.Init();
detector.Init(camera,parameters);

%   Initialise video players
video_player = vision.VideoPlayer("Name","Mask Output");
depth_video_player = vision.VideoPlayer();
rgb_video_player = vision.VideoPlayer("Name","Colour Feed");

try
    [frame_rgb, averaged_frame, point_cloud] = F_TrainBackgroundModel(camera, detector, training_frames);
    [cam_height, cam_angle] = F_CalculateSetup(averaged_frame, point_cloud);
    rgb_video_player(frame_rgb);
    %   precalculate constants
    [disp_col, disp_dis] = F_ConvDisplay(averaged_frame,frame_rgb,21,averaged_frame);
    mag = max(size(disp_col,[1 2])./size(averaged_frame)); %   used to overlay text at the correct location
    camera.Start();

    %   Main Loop
    while( isOpen(rgb_video_player))
        [frame_depth, frame_rgb, mask_fg, frame_PtCloud] = detector.Update();
        heights = F_DetectMeasure(int32(frame_depth),int32(mask_fg),frame_PtCloud, cam_angle,cam_height);
        [disp_col, disp_dis] = F_ConvDisplay(mask_fg,frame_rgb,21,frame_depth);
        [visual_display, frame_diff] = F_OverlayText(heights, mag, disp_col, disp_dis);
        video_player(visual_display);
        depth_video_player(disp_dis);
        rgb_video_player(frame_rgb);
    end
catch e
    camera.Stop();
    rethrow(e)	
end
camera.Stop()