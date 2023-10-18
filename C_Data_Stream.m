function C_out = C_Data_Stream()
%CAMSETTINGS_KINECT Summary of this function goes here
%   Detailed explanation goes here
C_out = M_Camera(58,58,512,512,461.836,461.836, @Init_Test_Cam, @getFrame_Test_Cam,@START,@START,@GetPointCloud);
end

function [camera_depth,camera_BGR] = Init_Test_Cam(obj)
        addpath("E:\Human Height Detector\Dataset\30_minutes\ForegroundCrossing_StaticScene_StationaryCamera");
    	s = strcat("E:\Human Height Detector\Dataset\30_minutes\ForegroundCrossing_StaticScene_StationaryCamera\depth_",'*.png');
        
        files = dir(s) ; 
        obj.frame_count = 1;
        obj.colourSource = 0;
        camera_depth = obj.depthSource;
        camera_BGR = obj.colourSource;

        for i = 0:size(files)-1
            file = dir(sprintf("E:\\Human Height Detector\\Dataset\\30_minutes\\ForegroundCrossing_StaticScene_StationaryCamera\\depth_%d.png",i));
            files(i+1) = file(1);
        end
        obj.depthSource = files;



        img = obj.depthSource(obj.frame_count).name;
        RangeFrame = imread(img);
        [height, width] = size(RangeFrame);
        obj.dim_x = width;
        obj.dim_y = height;
        obj.UpdatePixelAngles();
        obj.Intrinsics = cameraIntrinsics([obj.fx, obj.fy],[(width/2),(height/2)],[width,height]);   
        
end
%TODO step(vidobj)
function [RangeFrame, ColourFrame, PointCloud] = getFrame_Test_Cam(obj)
    disp(obj.frame_count);
    img = obj.depthSource(obj.frame_count).name; 
    RangeFrame = uint16(imread(img)) ; 
    ColourFrame = repmat(imread(img),1,1,3);
    PointCloud = pcfromdepth(RangeFrame,1000,obj.Intrinsics);
    obj.frame_count = obj.frame_count +1;
end

function START(~)
    
end
function PointCloud = GetPointCloud(obj,RangeFrame)
        frame_depth_abs = uint16(RangeFrame);
        PointCloud = pcfromdepth(frame_depth_abs,1000,obj.Intrinsics);
end
