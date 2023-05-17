function [done] = main(CamSettings, DtMethod,training_frames)
%% Created 18/03/23 By Malachi Wihongi
%   Initialise camera and detector
camera = CamSettings;
detector = DtMethod;
camera.Init();
detector.Init(camera);

%   Initialise video players
video_player = vision.VideoPlayer();
depth_video_player = vision.VideoPlayer();
rgb_video_player = vision.VideoPlayer();

try
    [frame_rgb, averaged_frame, point_cloud] = F_TrainBackgroundModel(camera, detector, training_frames);
    [cam_height, cam_angle] = F_CalculateSetup(averaged_frame, point_cloud);
    rgb_video_player(frame_rgb);
    %   precalculate constants
    mag = max(size(frame_rgb,[1 2])./size(averaged_frame));
    camera.Start();

    %   Main Loop
    while( isOpen(rgb_video_player))
        [frame_depth, frame_rgb, mask_fg, frame_PtCloud] = detector.Update();
        heights = F_DetectMeasure(int32(frame_depth),int32(mask_fg),frame_PtCloud, cam_angle,cam_height);
        [frame_rgb, frame_diff] = F_OverlayText(heights, mag, frame_rgb, uint16(mask_fg));
        
        video_player(frame_diff);
        depth_video_player(mask_fg);
        rgb_video_player(frame_rgb);
    end
catch e
    camera.Stop();
    rethrow(e)	
end
camera.Stop()