function ABL = DT_Adaptive_background_learning()
%DT_Adaptive_background_learning Gaussian Mixture Model foreground detector
%   Makes use of vision.ForegroundDetector from Computer Vision Toolbox
ABL = M_Detector(@Init_ABL, @Update_ABL,@Train_ABL);
end

function obj = Init_ABL(obj,Camera, param)
    obj.camera = Camera;
    obj.previous_frame = 0;
    obj.average = int32(zeros(obj.camera.dim_y,obj.camera.dim_x));
    obj.window_size = param(1);
    obj.previous_frame = obj.average;
    obj.threshold = param(2);
    obj.motion_threshold = param(3);

end

function Mask = Update_ABL(obj, RangeFrame, ~,~,~)
    frame = int32(RangeFrame);
    se = strel('disk',30);
    sd = strel('disk',100);
    motion = imerode(abs(frame - obj.previous_frame)> obj.motion_threshold,se);
    motion_mask = imdilate(motion,sd);
    weighted_average =  (frame.*int32((~motion_mask)) + ...
        obj.average.*int32(motion_mask));
    obj.average = obj.average + int32((weighted_average - obj.average))./obj.window_size;
    Mask = abs(frame - obj.average )>obj.threshold;
    obj.previous_frame = frame; 
end

function Mask = Train_ABL(obj,RangeFrame, ~,~)
    tempframe = int32((obj.average == 0));
    obj.average = obj.average + (tempframe .* int32(RangeFrame));
    Mask = abs(int32(RangeFrame)- obj.average )>100;
end
