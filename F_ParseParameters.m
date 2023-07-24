function [camera,detector,params] = F_ParseParameters(CamSettings, DtMethod,parameters)
%F_PARSEPARAMETERS Summary of this function goes here
%   Detailed explanation goes here

switch CamSettings
    case {'kinect'}
        camera = CS_KinectV2_Snapshot;
    case {'v2', 'kinectv2'}
        camera = CS_KinectV2_Snapshot;
        disp('Using KinectV2')
    case {'avi', 'test'}
        camera = CS_DatasetFeed_AVI;
    otherwise
        camera = CS_KinectV2_Snapshot;
        disp('Defaulting to KinectV2')
end


switch DtMethod
    case {'gmm', 'gaussian'}
        detector = DT_GMM();
        disp('Using gaussian mixture model')
        params = 0;
    case {'codebook','cb'}
        detector = DT_CodeBook();
        disp('Using Codebook model')
    case 1
        detector = DT_PoseRecognition();
        params = 0;
    case {'thresh', 'threshold'}
        detector = DT_Threshold();
        params = [1,3,3];
    otherwise
        detector = DT_GMM();
        disp('Defaulting to Gaussian Mixture Model')
        params = 0;

end


