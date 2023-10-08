classdef M_Detector < handle
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
        function obj = M_Detector(init,update,train)
            %DETECTIONMODULE Construct an instance of this class
            %   Detailed explanation goes here
            obj.initialise = init;
            obj.UpdateMethod = update;
            obj.trainMethod = train;
        end
        
        function Mask = Update(obj, RangeFrame, ColourFrame,  PointCloud)
            Mask = obj.UpdateMethod(obj, RangeFrame, ColourFrame,  PointCloud);
        end
        
        function obj = Init(obj, Camera, params)
            obj = obj.initialise(obj,Camera, params);
        end
        function Mask = Train(obj,RangeFrame, ColourFrame, PointCloud)
            Mask = obj.trainMethod(obj,RangeFrame, ColourFrame, PointCloud);
        end
    end
end

