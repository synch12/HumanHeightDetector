function [done] = main(CamSettings, DetectionMethod,training_frames, parameters)
%% Created 18/03/23 By Malachi Wihongi
%   Initialise camera and detector
[camera,detector] = F_ParseParameters(CamSettings, DetectionMethod);
training_frames = double(training_frames); 
camera.Init();
detector.Init(camera, parameters);

%   Initialise video players
video_player = vision.VideoPlayer();
depth_video_player = vision.VideoPlayer();
rgb_video_player = vision.VideoPlayer("Name","Colour Feed");

try
    [frame_rgb, averaged_frame, point_cloud] = F_TrainBackgroundModel(camera, detector, training_frames);
    [cam_height, cam_angle] = F_CalibrateFloor(averaged_frame, point_cloud,'',camera);
    % precalculate constants
    %[disp_col, disp_dis] = F_ConvDisplay(averaged_frame,frame_rgb,21,averaged_frame);
    mag = max(size(averaged_frame,[1 2])./size(averaged_frame)); %   used to overlay text at the correct location
    camera.Start();
    [floor_map, floor_mask,floor_cutoff] = f_map_floor_mask(cam_height,cam_angle,camera,averaged_frame);
    floor_variation = sum(floor_mask,"all")*45;
    floor_compare = uint16(floor_map .*  int32(floor_mask));
    imshow(floor_mask)
    assignin('base',"floor_map",floor_map);
    %floor_map(:,5)
    %   Main Loop
    while( 1)
        [frame_depth, frame_rgb, mask_fg, frame_PtCloud] = detector.Update();
        culled_frame = mask_fg & ((frame_depth<floor_cutoff));
        heights = F_DetectMeasure(int32(frame_depth),int32(mask_fg),frame_PtCloud, cam_angle,cam_height);
        %[disp_col, disp_dis] = F_ConvDisplay(mask_fg,frame_rgb,21,frame_depth);
        [visual_display, frame_diff] = F_OverlayText(heights, mag, frame_depth, frame_depth);
        video_player(visual_display);
        depth_video_player(mask_fg);
        rgb_video_player(culled_frame);
        floor_delta = sum(abs(floor_compare - frame_depth .* uint16(floor_mask)),"all");
        %disp(floor_delta)
        %floor_variation
        if(floor_delta > floor_variation)
            disp("need to recalibrate floor")
            [cam_height, cam_angle] = F_CalculateSetup(int32(frame_depth), frame_PtCloud,'',camera);
            [floor_map, floor_mask,floor_cutoff] = f_map_floor_mask(cam_height,cam_angle,camera,int32(frame_depth));
            
        end
        assignin('base',"floor_cutoff",floor_cutoff);
    end
catch e
    camera.Stop();
    rethrow(e)	
end
camera.Stop()