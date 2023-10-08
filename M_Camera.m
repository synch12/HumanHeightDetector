classdef M_Camera < handle
    %CAMERASETTINGS Object to hold all camera settings
    %   Detailed explanation goes here

    properties
        frame_count;
        xFOV;
        yFOV;
        dim_x;
        dim_y;
        XdegPpx;
        YdegPpx;
        XpxPdeg;
        YpxPdeg;
        XradPpx;
        YradPpx;
        XpxPrad;
        YpxPrad;
        fx;
        fy;
        initialise;
        FrameMethod;
        StopMethod;
        depthSource;
        colourSource;
        StartMethod;
        Intrinsics;
        pcMethod;
        max_range
    end
    
    methods
        function obj = M_Camera(FOV_X, FOV_Y, DIM_X, DIM_Y,FOC_X,FOC_Y,INIT,GETFRAME,STOP,START,PCMETHOD)
            %CAMERASETTINGS Construct an instance of this class
            %   Detailed explanation goes here
            obj.xFOV = FOV_X;
            obj.yFOV = FOV_Y;
            obj.dim_x = DIM_X;
            obj.dim_y = DIM_Y;
            obj.UpdatePixelAngles();
            obj.fx = FOC_X;
            obj.fy = FOC_Y;
            obj.initialise = INIT;
            obj.FrameMethod = GETFRAME;
            obj.StopMethod = STOP;
            obj.StartMethod = START;
            obj.Intrinsics = cameraIntrinsics([obj.fx, obj.fy],[DIM_X/2,DIM_Y/2],[DIM_X,DIM_Y]);
            obj.pcMethod = PCMETHOD;
            obj.max_range = 10 * 1000;
        end

        function obj = UpdatePixelAngles(obj)
            obj.XdegPpx = obj.xFOV/obj.dim_x;
            obj.YdegPpx = obj.yFOV/obj.dim_y;
            obj.XpxPdeg = 1/obj.XdegPpx;
            obj.YpxPdeg = 1/obj.YdegPpx;
            obj.XradPpx = (obj.xFOV*(pi/180))/obj.dim_x;
            obj.YradPpx = (obj.yFOV*(pi/180))/obj.dim_y;
            obj.XpxPrad = 1/obj.XradPpx;
            obj.YpxPrad = 1/obj.YradPpx;
        end
        function [RangeFrame, ColourFrame] = GetFrame(obj)
            [RangeFrame, ColourFrame] = obj.FrameMethod(obj);
        end
        function obj = Init(obj)
            obj.initialise(obj);
        end
        function obj = Stop(obj)
            obj.StopMethod(obj);
        end
        function obj = Start(obj)
            obj.StartMethod(obj);
        end
        function PointCloud = GeneratePointCloud(obj,RangeFrame)
            PointCloud = obj.pcMethod(obj,RangeFrame);
        end
        function [RangeFrame, ColourFrame,PointCloud] = LoadData(obj)
            [RangeFrame, ColourFrame] = obj.GetFrame();
            PointCloud = obj.pcMethod(obj,RangeFrame);
        end
    end
end