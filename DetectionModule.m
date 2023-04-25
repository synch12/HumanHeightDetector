classdef DetectionModule < handle
    %DETECTIONMODULE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

        initialise;
        UpdateMethod;
        detector;
        camera;
        blob;
    end
    
    methods
        function obj = DetectionModule(init,update)
            %DETECTIONMODULE Construct an instance of this class
            %   Detailed explanation goes here
            obj.initialise = init;
            obj.UpdateMethod = update;
        end
        
        function [RangeFrame, ColourFrame] = Update(obj)
            [RangeFrame, ColourFrame] = obj.UpdateMethod(obj);
        end
        
        function obj = Init(obj, Camera)
            obj = obj.initialise(obj,Camera);
        end
    end
end

