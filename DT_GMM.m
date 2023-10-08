function GMM = DT_GMM()
%DT_GMM Gaussian Mixture Model foreground detector
%   Makes use of vision.ForegroundDetector from Computer Vision Toolbox
GMM = DetectionModule(@Init_GMM, @Update_GMM,@Train_GMM);
end

function obj = Init_GMM(obj,Camera, ~)
    obj.detector = vision.ForegroundDetector('NumTrainingFrames', 60, 'InitialVariance', 30*5,'MinimumBackgroundRatio', 0.5);
    obj.camera = Camera;

end

function Mask = Update_GMM(obj, RangeFrame, ~,  ~)
    Mask = obj.detector(uint8(bitshift(RangeFrame,-8)));
end

function Mask = Train_GMM(obj, RangeFrame, ~,  ~)
    Mask = obj.detector(uint8(bitshift(RangeFrame,-8)));
end