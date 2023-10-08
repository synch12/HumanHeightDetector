function Threshold = DT_Threshold()
%DT_Threshold Distance Threshold foreground detector
%   Detects all pixels that are within a certain distance from the camera
Threshold = DetectionModule(@Init_Threshold, @Update_Threshold,@Train_Threshold);
end

function obj = Init_Threshold(obj,Camera, params)
    obj.range_min = params(1)*1000;
    obj.range_max = params(2)*1000;
    obj.horizontal_cutoff_dividend = params(3)/100;
    obj.horizontal_cutoff_dividend
    obj.camera = Camera;
    obj.horizontal_cutoff = (obj.camera.dim_x/2)*obj.horizontal_cutoff_dividend;
    obj.horizontal_cutoff
end

function [RangeFrame, ColourFrame, Mask, PointCloud] = Update_Threshold(obj)
    [RangeFrame, ColourFrame, PointCloud] = obj.camera.getFrame();

    Mask = (RangeFrame < obj.range_max) & (RangeFrame > obj.range_min);
    Mask(:,1:obj.horizontal_cutoff) = 0;
    Mask(:,obj.camera.dim_x-obj.horizontal_cutoff:obj.camera.dim_x) = 0;
    
end

function [RangeFrame, ColourFrame, Mask, PointCloud] = Train_Threshold(obj)
    [RangeFrame, ColourFrame, PointCloud] = obj.camera.getFrame();
    Mask = obj.detector(uint8(bitshift(RangeFrame,-8)));
    
end