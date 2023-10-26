function [done] = main(CamSettings, DetectionMethod,training_frames, parameters)
%% Created 18/03/23 By Malachi Wihongi
%   Initialise camera and detector
camera = CamSettings;
detector = DetectionMethod;
training_frames = double(training_frames); 
camera.Init();
detector.Init(camera, parameters);
%   Initialise video players
video_player = vision.VideoPlayer();
rgb_video_player = vision.VideoPlayer("Name","Colour Feed");
stop = false;
cleanupObj = onCleanup(@cleanMeUp);
createFigureWithButton()
FloorChanged = false;
Check_Floor =  true;

try
    [frame_rgb, averaged_frame, point_cloud] = F_TrainBackgroundModel(camera, detector, training_frames);
    mag = max(size(zeros(1024,848),[1 2])./size(averaged_frame)); 
    camera.Start();

    while(~stop)
        disp("Calibrating Floor")
        [cam_height, cam_angle] = F_CalibrateFloor(averaged_frame, point_cloud,'',camera);
        [floor_cutoff, floor_params] = F_map_floor_mask(cam_height,cam_angle,camera,averaged_frame);
        FloorChanged = false;
        while(~stop & ~FloorChanged)
            [frame_depth, frame_rgb,frame_PtCloud] = camera.LoadData();
            mask_fg = detector.Update(frame_depth,frame_rgb,frame_PtCloud,floor_cutoff);
            heights = F_MeasureObjects(int32(frame_depth),int32(mask_fg),frame_PtCloud, cam_angle,cam_height);
            [visual_display, frame_diff] = F_AnnotateFrame(heights, mag,mask_fg,frame_rgb,21,frame_depth);
            video_player(visual_display);
            rgb_video_player(frame_diff);
            if(Check_Floor)
                FloorChanged = F_EvaluateFloor(floor_params,frame_depth);
            end
        end
    end
catch e
    camera.Stop();
    rethrow(e)	
end
camera.Stop()


function createFigureWithButton()
    % Create a figure
    fig = figure('Position', [100, 100, 400, 200], 'Name', 'Controls');
    
    % Create a panel for grouping UI elements
    p = uipanel(fig, 'Position', [0.1 0.1 0.8 0.8]);
    
    % Create the buttons for the UI panel
    btn = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Stop', ...
        'Position', [100, 30, 200, 40], 'Callback', @buttonCallback);
    
    btn3 = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Toggle Automatic Floor Recalibration', ...
        'Position', [100, 80, 200, 40], 'Callback', @haltFloorsCallback);

    % Create another button
    btn2 = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Manual Floor Recalibration', ...
        'Position', [100, 130, 200, 40], 'Callback', @resetFloorsCallback);
    
    
    % A callback function for the "Stop" button
    function buttonCallback(~, ~)
        % This function is executed when the button is clicked
        stop = true;
        disp('Stop Button Clicked!');
        delete(fig);
    end
    
    
    % A callback function for the "Manual Floor Recalibrate" button
    function resetFloorsCallback(~, ~)
        FloorChanged = true;
        disp('Manual Floor Recalibrate Button Clicked!');
    end
    % This function is executed when the "Toggle Automatic Floor Recalibration" button is clicked
    function haltFloorsCallback(~, ~)
        Check_Floor = ~Check_Floor;
        if(Check_Floor == true)
            disp('Automatic Floor Recalibration Enabled');
        else
            disp('Automatic Floor Recalibration Disabled');
        end
    end

end
function cleanMeUp()
    camera.Stop();
end
end



