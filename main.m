function [done] = main(CamSettings, DtMethod)
%% Created 18/03/23 By Malachi Wihongi

%   Init
camera = CamSettings;
camera.Init();
detector = DtMethod;
detector.Init(camera);

%
[cam_height, cam_angle] = F_FloorDetectMeasure(detector.Update());

%   Main Loop
active = true;
while active
    [frame_depth, frame_rgb, mask_fg, frame_PtCloud] = detector.Update();
    
    F_DetectMeasure(frame_depth, mask_fg, frame_PtCloud, cam_angle, cam_height);


    done = true;
end

%wrapUp()

% V0.1 Set up basic framework for system execution MW
% V0.2 