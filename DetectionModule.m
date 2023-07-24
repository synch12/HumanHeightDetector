classdef DetectionModule < handle
    %DETECTIONMODULE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

        initialise;
        UpdateMethod;
        detector;
        camera;
        blob;
        trainMethod;
        range_min
        range_max
        horizontal_cutoff_dividend
        horizontal_cutoff
    end
    
    methods
        function obj = DetectionModule(init,update,train)
            %DETECTIONMODULE Construct an instance of this class
            %   Detailed explanation goes here
            obj.initialise = init;
            obj.UpdateMethod = update;
            obj.trainMethod = train;
        end
        
        function [RangeFrame, ColourFrame, Mask, PointCloud] = Update(obj)
            [RangeFrame, ColourFrame, Mask, PointCloud] = obj.UpdateMethod(obj);
        end
        
        function obj = Init(obj, Camera, params)
            obj = obj.initialise(obj,Camera, params);
        end
        function [RangeFrame, ColourFrame, Mask, PointCloud] = Train(obj)
            [RangeFrame, ColourFrame, Mask, PointCloud] = obj.trainMethod(obj);
        end
    end
end

