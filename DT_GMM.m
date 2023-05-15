function GMM = DT_GMM()
%DT_GMM Gaussian Mixture Model foreground detector
%   Makes use of vision.ForegroundDetector from Computer Vision Toolbox
GMM = DetectionModule(@Init_GMM, @Update_GMM);
end

function obj = Init_GMM(obj,Camera)
    obj.detector = vision.ForegroundDetector('NumTrainingFrames', 60, 'InitialVariance', 30*5,'MinimumBackgroundRatio', 0.5);
    obj.camera = Camera;

end

function [RangeFrame, ColourFrame, Mask, PointCloud] = Update_GMM(obj)
    [RangeFrame, ColourFrame, PointCloud] = obj.camera.getFrame();
    Mask = obj.detector(uint8(bitshift(RangeFrame,-8)));
    
end