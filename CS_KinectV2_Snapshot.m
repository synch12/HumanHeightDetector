function CS_out = CS_KinectV2_Snapshot()
%CAMSETTINGS_KINECT Summary of this function goes here
%   Detailed explanation goes here

CS_out = CameraSettings(70.6,60,512,424, @Init_Kinect, @getFrame_Kinect);
end

function [camera_depth,camera_BGR] = Init_Kinect(obj)
        obj.camera_depth = videoinput('kinect', 2, 'Depth_512x424');
        obj.camera_BGR = videoinput('kinect', 1, 'BGR_1920x1080');
        camera_depth = obj.camera_depth;
        camera_BGR = obj.camera_BGR;
end
%TODO step(vidobj)
function [RangeFrame, ColourFrame, PointCloud] = getFrame_Kinect(obj)
        RangeFrame = getsnapshot(obj.depthSource);
        ColourFrame = getsnapshot(obj.depthSource);
        frame_depth_abs = int32(RangeFrame);
        PointCloud = pcfromkinect(camera_depth, frame_depth_abs);
end