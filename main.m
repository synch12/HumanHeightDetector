function [done] = main(CamSettings, DtMethod)
%% Created 18/03/23 By Malachi Wihongi

%   Init

    camera = CamSettings.Init();
    Detector.Init(camera)

%   Main Loop

%     active = Init();
%     while active == true
%         frame = true;  
%     end
%     ClosingBehaviour();
    done = true;
end

% V0.1 Set up basic framework for system execution MW
% V0.2 