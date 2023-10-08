function C_out = C_Data_Stream()
%CAMSETTINGS_KINECT Summary of this function goes here
%   Detailed explanation goes here
C_out = M_Camera(58,58,512,512,461.8,461.8, @Init_Test_Cam, @getFrame_Test_Cam,@START,@START,@GetPointCloud);
end

function [camera_depth,camera_BGR] = Init_Test_Cam(obj)
        addpath("C:\Users\Malachi\WorkDesktop\ENGEN582\dataset\25fps\");
    	s = strcat("C:\Users\Malachi\WorkDesktop\ENGEN582\dataset\25fps\depth_",'*.png');
        
        files = dir(s) ; 
        obj.frame_count = 1;
        obj.colourSource = 0;
        camera_depth = obj.depthSource;
        camera_BGR = obj.colourSource;

        for i = 0:size(files)-1
            file = dir(sprintf("C:\\Users\\Malachi\\WorkDesktop\\ENGEN582\\dataset\\25fps\\depth_%d.png",i));
            files(i+1) = file(1);
        end
        obj.depthSource = files;
end
%TODO step(vidobj)
function [RangeFrame, ColourFrame, PointCloud] = getFrame_Test_Cam(obj)
    disp(obj.frame_count);
    ColourFrame = 0;
    img = obj.depthSource(obj.frame_count).name; 
    RangeFrame = uint16(imread(img)) ; 
    PointCloud = pcfromdepth(RangeFrame,1000,obj.Intrinsics);
    obj.frame_count = obj.frame_count +1;
end

function START(obj)
    
end
function PointCloud = GetPointCloud(obj,RangeFrame)
        frame_depth_abs = uint16(RangeFrame);
        PointCloud = pcfromdepth(frame_depth_abs,1000,obj.Intrinsics);
end
