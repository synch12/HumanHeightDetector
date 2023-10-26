classdef M_Detector < handle
    % M_Detector The framework for detection methods.
    %   Detailed explanation goes here
    %   
    %   
    properties
        initialise;
        UpdateMethod;
        detector;
        camera;
        blob;
        trainMethod;
        range_min;
        range_max;
        horizontal_cutoff_dividend;
        horizontal_cutoff;
        previous_frame;
        average;
        window_size;
        threshold;
        motion_threshold;
    end
    
    methods
        function obj = M_Detector(init,update,train)
            %DETECTIONMODULE Construct an instance of this class
            %   Detailed explanation goes here
            obj.initialise = init;
            obj.UpdateMethod = update;
            obj.trainMethod = train;
        end
        
        function Mask = Update(obj, RangeFrame, ColourFrame,  PointCloud,floor_cutoff)
            Mask = obj.UpdateMethod(obj, RangeFrame, ColourFrame,  PointCloud,floor_cutoff);
        end
        
        function obj = Init(obj, Camera, params)
            obj = obj.initialise(obj,Camera, params);
        end
        function Mask = Train(obj,RangeFrame, ColourFrame, PointCloud)
            Mask = obj.trainMethod(obj,RangeFrame, ColourFrame, PointCloud);
        end
    end
end

