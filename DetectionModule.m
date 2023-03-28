classdef DetectionModule
    %DETECTIONMODULE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

        initialise;
        Update;
        detector;
        camera;
        blob;
    end
    
    methods
        function obj = DetectionModule(init,update)
            %DETECTIONMODULE Construct an instance of this class
            %   Detailed explanation goes here
            obj.initialise = init;
            obj.Update = update;
        end
        
        function Init(Camera)
            obj.initialise(obj,Camera);
        end
    end
end

