function C_out = C_KinectV2()
%CAMSETTINGS_KINECT Summary of this function goes here
%   Detailed explanation goes here

C_out = M_Camera(70.6,60,512,424, @Init_Kinect, @getFrame_Kinect);
end

function [camera_depth,camera_BGR] = Init_Kinect()
        camera_depth = videoinput('kinect', 2, 'Depth_512x424');
        camera_BGR = videoinput('kinect', 1, 'BGR_1920x1080');
        stop(camera_depth)
        flushdata(camera_depth);

        triggerconfig(camera_depth,'manual')
        set(camera_depth,'TimerPeriod',1);
        set(camera_depth,'TriggerRepeat',0)
        set(camera_depth,'FramesPerTrigger',1)
        set(camera_depth,'TriggerFrameDelay',2)
        set(camera_depth,'Timeout',10)
end
%TODO step(vidobj)
function [RangeFrame, ColourFrame] = getFrame_Kinect(obj)
    ColourFrame = [0,0,0];
    RangeFrame = [0,0];
end