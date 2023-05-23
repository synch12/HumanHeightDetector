function CS_out = CS_KinectV2_Snapshot()
%CAMSETTINGS_KINECT Summary of this function goes here
%   Detailed explanation goes here
CAM_FOV_X = 70.6;
CAM_FOV_Y = 60;
CAM_DIM_X = 512;
CAM_DIM_Y = 424;
CS_out = CameraSettings(CAM_FOV_X,CAM_FOV_Y,CAM_DIM_X,CAM_DIM_Y, @Init_Kinect, @getFrame_Kinect,@STOP, @START);
end

function [camera_depth,camera_BGR] = Init_Kinect(obj)
        obj.depthSource = videoinput('kinect', 2, 'Depth_512x424');
        obj.colourSource = videoinput('kinect', 1, 'BGR_1920x1080');
        camera_depth = obj.depthSource;
        camera_BGR = obj.colourSource;
        src = getselectedsource(obj.depthSource);
        src.EnableBodyTracking = 'off';
        
        set(obj.colourSource,'FramesPerTrigger',Inf);
        set(obj.colourSource,'TriggerRepeat',0);
        obj.colourSource.FrameGrabInterval = 1;
        
        set(obj.depthSource,'TimerPeriod',100);
        triggerconfig(obj.depthSource,'immediate')
        set(obj.depthSource,'TriggerRepeat',Inf)
        set(obj.depthSource,'FramesPerTrigger',1)
        set(obj.depthSource,'TriggerFrameDelay',2)
        
        set(obj.colourSource,'TimerPeriod',100);
        triggerconfig(obj.colourSource,'immediate')
        set(obj.colourSource,'TriggerRepeat',Inf)
        set(obj.colourSource,'FramesPerTrigger',30)
        set(obj.colourSource,'TriggerFrameDelay',5)
end

function START(obj)
        triggerconfig(obj.depthSource,'immediate')
        set(obj.depthSource,'TriggerRepeat',Inf)
        triggerconfig(obj.colourSource,'immediate')
        set(obj.colourSource,'TriggerRepeat',Inf)
        start(obj.depthSource);
        start(obj.colourSource);
end

function STOP(obj)
    stop(obj.depthSource);
    stop(obj.colourSource);
    triggerconfig(obj.depthSource,'manual')
    set(obj.depthSource,'TriggerRepeat',0)
    triggerconfig(obj.colourSource,'manual')
    set(obj.colourSource,'TriggerRepeat',0)
    stop(obj.depthSource);
    stop(obj.colourSource);
end
%TODO step(vidobj)
function [RangeFrame, ColourFrame, PointCloud] = getFrame_Kinect(obj)
        RangeFrame = getsnapshot(obj.depthSource);
        ColourFrame = getsnapshot(obj.colourSource);
        frame_depth_abs = uint16(RangeFrame);
        PointCloud = pcfromkinect(obj.depthSource , frame_depth_abs);
        flushdata(obj.depthSource);
	    flushdata(obj.colourSource);
end