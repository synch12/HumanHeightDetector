function CS_out = CS_KinectV2_Snapshot()
%CAMSETTINGS_KINECT Summary of this function goes here
%   Detailed explanation goes here
CAM_FOV_X = 70.6;
CAM_FOV_Y = 60;
CAM_DIM_X = 512;
CAM_DIM_Y = 424;
CAM_FOCAL_X = 388.198;
CAM_FOCAL_Y = 389.033;
CS_out = M_Camera(CAM_FOV_X,CAM_FOV_Y,CAM_DIM_X,CAM_DIM_Y,CAM_FOCAL_X,CAM_FOCAL_Y, @Init_Kinect, @getFrame_Kinect,@STOP, @START,@GetPointCloud_Kinect);
end

function [camera_depth,camera_BGR] = Init_Kinect(obj)
        obj.depthSource = videoinput('kinect', 2, 'Depth_512x424');
        obj.colourSource = videoinput('kinect', 1, 'BGR_1920x1080');
        camera_depth = obj.depthSource;
        camera_BGR = obj.colourSource;
        src = getselectedsource(obj.depthSource);
        src.EnableBodyTracking = 'off';
        
        set(obj.colourSource,'FramesPerTrigger',1);
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
        triggerconfig(obj.depthSource,'manual')
        set(obj.depthSource,'TriggerRepeat',Inf)
        triggerconfig(obj.colourSource,'manual')
        set(obj.colourSource,'TriggerRepeat',Inf)
        obj.colourSource.Timeout = 15;
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
function [RangeFrame, ColourFrame] = getFrame_Kinect(obj)
        RangeFrame = getsnapshot(obj.depthSource);
        ColourFrame = getsnapshot(obj.colourSource);
        flushdata(obj.depthSource);
	    flushdata(obj.colourSource);
end

function PointCloud = GetPointCloud_Kinect(obj,RangeFrame)
        frame_depth_abs = uint16(RangeFrame);
        PointCloud = pcfromkinect(obj.depthSource, frame_depth_abs);
end