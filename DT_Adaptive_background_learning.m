function ABL = DT_Adaptive_background_learning()
%DT_Adaptive_background_learning Gaussian Mixture Model foreground detector
%   Makes use of vision.ForegroundDetector from Computer Vision Toolbox
ABL = DetectionModule(@Init_ABL, @Update_ABL,@Train_ABL);
end

function obj = Init_ABL(obj,Camera, ~)
    obj.camera = Camera;
    obj.last_frame = 0;
    obj.average = uint16(zeros(obj.camera.dim_y,obj.camera.dim_x));
    obj.window_size = 20;
end

function Mask = Update_ABL(obj, RangeFrame, ~,~)
    motion_mask = (RangeFrame - obj.last_frame) > 20;
    weighted_average =  (RangeFrame.*uint16(~motion_mask) + obj.average.*uint16(motion_mask));
    obj.average = obj.average + (weighted_average - obj.average)./obj.window_size;
    Mask = abs(RangeFrame- obj.average )>50;
    
end

function [RangeFrame, ColourFrame, Mask] = Train_ABL(obj)
    [RangeFrame, ColourFrame] = obj.camera.getFrame();
    obj.detector.Camera.PassImage(RangeFrame, ColourFrame)
    tempframe = int32((obj.average == 0));
    obj.average = obj.average + (tempframe .* RangeFrame);
    Mask = abs(RangeFrame- obj.average )>50;
end
