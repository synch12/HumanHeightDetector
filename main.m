function [done] = main(CamSettings, DtMethod,trainingFrames)
%% Created 18/03/23 By Malachi Wihongi

%   Init
camera = CamSettings;
camera.Init();
detector = DtMethod;
detector.Init(camera);
videoPlayer = vision.VideoPlayer();
Depth_videoPlayer = vision.VideoPlayer();
RGB_videoPlayer = vision.VideoPlayer();
%
try
    [frame_depth, frame_rgb, mask_fg, frame_PtCloud] = detector.Update();
    for i = 1:1:trainingFrames
        [frame_depth, frame_rgb, mask_fg, frame_PtCloud] = detector.Update();
    end
    [cam_height, cam_angle] = floorDetectMeasure(int32(frame_depth), frame_PtCloud);
    
    disp('Press a key !' ) % Press a key here
    pause;
    RGB_videoPlayer(frame_rgb);


    %   Main Loop

    while( isOpen(RGB_videoPlayer))
        %   obtain frame
        [frame_depth, frame_rgb, mask_fg, frame_PtCloud] = detector.Update();
        [alpha,frame_diff] = F_IsolatePeople(mask_fg,frame_depth);
        [heights,depthFrame] = F_MeasureHeights(int32(alpha),int32(frame_diff),int32(frame_depth),frame_PtCloud,cam_height, cam_angle);
        heights
       
        mag = max(size(frame_rgb,[1 2])./size(frame_diff));
        if(~isempty(heights))
		    for per = 1:1:size(heights,1)
			    text = sprintf('%0.2f',round(heights(per,1),2));
			    x = heights(per,2);%*mag;
			    y = heights(per,3);%*mag - 20*mag;
			    %Cap the y value to >1
			    if(y <= 0)
				    y = 1;
			    end
			    frame_rgb  = insertText(frame_rgb,[x,y],text,...
				    'FontSize',24,'BoxOpacity',0.5,'BoxColor','black','TextColor','red');
			    frame_diff  = insertText(frame_diff,[x,y],text,...
				    'FontSize',24,'BoxOpacity',0,'TextColor','white');
                frame_diff = frame_diff(:, :, 1);
		    end
        end
        size(frame_diff)
        %   Display captures 
        videoPlayer(frame_diff);
        Depth_videoPlayer(uint8(bitshift(frame_depth,-8)));
        RGB_videoPlayer(frame_rgb);
    end
catch e
    camera.Stop();

rethrow(e)	
end

camera.Stop()
%wrapUp()





% V0.1 Set up basic framework for system execution MW
% V0.2 