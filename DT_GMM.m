function GMM = DT_GMM()
%DT_GMM Gaussian Mixture Model foreground detector
%   Makes use of vision.ForegroundDetector from Computer Vision Toolbox
GMM = DetectionModule(@Init_GMM, @Update_GMM);
end

function success = Init_GMM(obj,Camera)
    obj.detector = vision.ForegroundDetector('NumTrainingFrames', 5, 'InitialVariance', 30*30);
    obj.camera = Camera;
    success = true;

end

function [RangeFrame, ColourFrame,mask] = Update_GMM(obj)
    [RangeFrame, ColourFrame] = obj.camera.getFrame();
    mask = obj.detector(RangeFrame);
end