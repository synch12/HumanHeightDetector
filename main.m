function [done] = main(CamSettings, DetectionMethod,training_frames, parameters)
%% Created 18/03/23 By Malachi Wihongi
%   Initialise camera and detector
camera = CamSettings;
detector = DetectionMethod;
training_frames = double(training_frames); 
camera.Init();
detector.Init(camera, parameters);
Meters = 1000;
%   Initialise video players
video_player = vision.VideoPlayer();
depth_video_player = vision.VideoPlayer();
rgb_video_player = vision.VideoPlayer("Name","Colour Feed");
stop = false;
max_range = 10*Meters;
cleanupObj = onCleanup(@cleanMeUp);
createFigureWithButton()
FloorChanged = false;

try
    [frame_rgb, averaged_frame, point_cloud] = F_TrainBackgroundModel(camera, detector, training_frames);
    mag = max(size(zeros(1024,848),[1 2])./size(averaged_frame)); 
    camera.Start();

    while(~stop)
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
    
            FloorChanged = F_EvaluateFloor(floor_params,frame_depth);
        end
    end
catch e
    camera.Stop();
    rethrow(e)	
end
camera.Stop()


function createFigureWithButton()
    % Create a figure
    fig = uifigure('Position', [100, 100, 400, 200], 'Name', 'Controls');
    
    % Create a panel for grouping UI elements
    p = uipanel(fig, 'Position', [0.1 0.1 0.8 0.8]);
    
    % Create a button
    btn = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Stop', ...
        'Position', [150, 80, 100, 40], 'Callback', @buttonCallback);
    
    % Create another button
    btn2 = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Manual Floor Recalibrate', ...
        'Position', [150, 30, 100, 40], 'Callback', @resetFloorsCallback);
    
    % Create a slider
    slider = uislider(fig, 'Position', [50, 150, 300, 3]);
    minVal = 0; % Minimum value
    maxVal = 15; % Maximum value
    slider.Limits = [minVal, maxVal];

    % Create a label to display the slider value
    label = uilabel(fig, 'Position', [50, 120, 300, 22]);
    label.Text = sprintf('Value: %.2f', slider.Value);
    
    % Define a callback function for the "Stop" button
    function buttonCallback(~, ~)
        % This function is executed when the button is clicked
        stop = true;
        disp('Stop Button Clicked!');
        delete(fig);
    end
    
    % Define a callback function for the slider
    slider.ValueChangedFcn = @(slider, event) updateLabel(slider, label);
    
    % Define a callback function for the "Manual Floor Recalibrate" button
    function resetFloorsCallback(~, ~)
        % This function is executed when the button is clicked
        nofloor = true;
        disp('Manual Floor Recalibrate Button Clicked!');
    end
    
    % Function to update the label text when the slider changes
    function updateLabel(slider, label)
        label.Text = sprintf('Value: %.2f', slider.Value);
        camera.max_range = slider.Value*Meters;
    end
end
function cleanMeUp()
    camera.Stop();
end
end



