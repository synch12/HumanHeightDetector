function [done] = main(CamSettings, BgMethod)
%% Created 18/03/23 By Malachi Wihongi
% V0.1 Set up basic framework for system execution

    active = Init();
    while active == true
        frame = true;  
    end
    ClosingBehaviour();
    done = true;
end