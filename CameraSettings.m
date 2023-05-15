classdef CameraSettings < handle
    %CAMERASETTINGS Object to hold all camera settings
    %   Detailed explanation goes here

    properties
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
        initialise;
        FrameMethod;
        StopMethod;
        depthSource;
        colourSource;
        StartMethod;
    end
    
    methods
        function obj = CameraSettings(FOV_X, FOV_Y, DIM_X, DIM_Y,INIT,GETFRAME,STOP,START)
            %CAMERASETTINGS Construct an instance of this class
            %   Detailed explanation goes here
            obj.xFOV = FOV_X;
            obj.yFOV = FOV_Y;
            obj.dim_x = DIM_X;
            obj.dim_y = DIM_Y;
            obj.UpdatePixelAngles();
            obj.initialise = INIT;
            obj.FrameMethod = GETFRAME;
            obj.StopMethod = STOP;
            obj.StartMethod = START;
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
        function [RangeFrame, ColourFrame, PointCloud] = getFrame(obj)
            [RangeFrame, ColourFrame, PointCloud] = obj.FrameMethod(obj);
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
    end
end