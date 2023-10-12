function Detector = DT_CodeBook()
%DT_GMM Gaussian Mixture Model foreground detector
%   Makes use of vision.ForegroundDetector from Computer Vision Toolbox
Detector = DetectionModule(@Init_Codebook, @Update_Codebook, @Train_Codebook);
end

function obj = Init_Codebook(obj,Camera)
    obj.detector = M_CodeBook(Camera.dim_x,Camera.dim_y);
    obj.camera = Camera;

end

function [RangeFrame, ColourFrame, Mask, PointCloud] = Update_Codebook(obj)
    [RangeFrame, ColourFrame, PointCloud] = obj.camera.getFrame();
    Mask = obj.detector.update(uint8(bitshift(RangeFrame,-8)));
end

function [RangeFrame, ColourFrame, Mask, PointCloud] = Train_Codebook(obj)
    [RangeFrame, ColourFrame, PointCloud] = obj.camera.getFrame();
    Mask = obj.detector.train(uint8(bitshift(RangeFrame,-8)));
end