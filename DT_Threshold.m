function Threshold = DT_Threshold()
%DT_Threshold Distance Threshold foreground detector
%   Detects all pixels that are within a certain distance from the camera
Threshold = M_Detector(@Init_Threshold, @Update_Threshold,@Train_Threshold);
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

function Mask = Update_Threshold(obj,RangeFrame, ~, ~,floor_cutoff)
    Mask = (RangeFrame < obj.range_max) & (RangeFrame > obj.range_min);
    Mask(:,1:obj.horizontal_cutoff) = 0;
    Mask(:,obj.camera.dim_x-obj.horizontal_cutoff:obj.camera.dim_x) = 0;
    Mask = Mask & ((RangeFrame<floor_cutoff));
    
end

function Mask = Train_Threshold(obj,RangeFrame, ~, ~)
    Mask = RangeFrame<obj.range_max;
end