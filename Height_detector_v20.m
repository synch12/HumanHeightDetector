%% this is the height detector version with most thing in functions
%This, at the point of time, Will be the version that I display at the 2020
%EDS, supposidly this is the final version for my honours project. 
%clearvars
%disp("paused");pause();
%% Camera consts
%Some of these are used ,some arent
xFOV = 70.6;
yFOV = 60;

dim_x = 512;
dim_y = 424;

XdegPpx = xFOV/dim_x;%in degrees, probably want in radians
YdegPpx = yFOV/dim_y;

XpxPdeg = 1/XdegPpx;
YpxPdeg = 1/YdegPpx;

XradPpx = (xFOV*(pi/180))/dim_x;
YradPpx = (yFOV*(pi/180))/dim_y;

XpxPrad = 1/XradPpx;
YpxPrad = 1/YradPpx;

zero_arr = zeros(dim_y,dim_x);


%% init
camera_depth = videoinput('kinect', 2, 'Depth_512x424');
camera_BGR = videoinput('kinect', 1, 'BGR_1920x1080');

stop(camera_depth)
flushdata(camera_depth);

triggerconfig(camera_depth,'manual')
set(camera_depth,'TimerPeriod',1);
set(camera_depth,'TriggerRepeat',0)
set(camera_depth,'FramesPerTrigger',1)
set(camera_depth,'TriggerFrameDelay',2)
set(camera_depth,'Timeout',10)


%% 
background = F_GetAverage(camera_depth,10,0.1);
col_img = getsnapshot(camera_BGR);

%%
backgroundPtGen = uint16(background);
backgroundPtCloud = pcfromkinect(camera_depth, backgroundPtGen);

[cam_height, cam_elevation] = F_FloorDetectMeasure(background,backgroundPtCloud);


%% setup camera and images
set(camera_depth,'TimerPeriod',100);
triggerconfig(camera_depth,'immediate')
set(camera_depth,'TriggerRepeat',Inf)
set(camera_depth,'FramesPerTrigger',1)
set(camera_depth,'TriggerFrameDelay',2)

set(camera_BGR,'TimerPeriod',100);
triggerconfig(camera_BGR,'immediate')
set(camera_BGR,'TriggerRepeat',Inf)
set(camera_BGR,'FramesPerTrigger',1)
set(camera_BGR,'TriggerFrameDelay',5)


[disp_col, disp_dis] = F_ConvDisplay(background,col_img,21);

figure(1),clf;
displayImCol = imshow(disp_col);
figure(2),clf;
displayImBin = imshow(disp_dis);

%This is to save images to allow call back, only really needed if you want
%to save images for display for like presentations and posters and stuff
save_col = uint8(zeros([size(disp_col),250]));
save_dis = int32(zeros([size(background),250]));
i = 1;
try
	%this creates a message box that is used to stop the program, this is
	%needed as if ctrl-c is used the camera does not stop, and will
	%overflow an internal buffer and need the camera, matlab, or both
	%restarted to get it working again.
running = msgbox("Close to stop camera and stop program");

start(camera_depth);
flushdata(camera_depth);
start(camera_BGR);
flushdata(camera_BGR);
pause(0.5)
while(1)
	if ~ishandle(running)
        % Stop the if cancel button was pressed
		stop(camera_depth)
		stop(camera_BGR)
        disp('Stopped by user');
        break;
	end	
	
	%this loop takes the data the is currently avaible, then flushes the
	%data. this means that it will be slightly behind on the information
	%that it presents, may be a way to change that. 
	%If it is flushed then retreived it crashes as there's nothing to
	%retrieve. Also this would cause crashing if the loop can run faster
	%than the kinects 30 fps. 
	frameSaveDis = getdata(camera_depth);
	frameCol = getdata(camera_BGR);
	frame = int32(frameSaveDis);
	flushdata(camera_depth);
	flushdata(camera_BGR);
	
	framePtGenDis = uint16(frame);
	framePtCloud = pcfromkinect(camera_depth, framePtGenDis);
	[heights,detframe] = F_DetectMeasure(frame,background,framePtCloud,cam_elevation,cam_height);
	disp(heights)
	
	%upscales the iamge, use 21, most others dont work
	[disp_col, disp_dis] = F_ConvDisplay(frame,frameCol,21,detframe);
	
	%Magnitude scale of the resizing
	mag = max(size(disp_col,[1 2])./size(frame));
	
	%This prints on the text numbers for the height values.
	if(~isempty(heights))
		for per = 1:1:size(heights,1)
			text = sprintf('%0.2f',round(heights(per,1),2));
			x = heights(per,2)*mag;
			y = heights(per,3)*mag - 20*mag;
			%Cap the y value to >1
			if(y <= 0)
				y = 1;
			end
			disp_col  = insertText(disp_col,[x,y],text,...
				'FontSize',24,'BoxOpacity',0.5,'BoxColor','black','TextColor','red');
			disp_dis  = insertText(disp_dis,[x,y],text,...
				'FontSize',24,'BoxOpacity',0,'TextColor','red');
		end
	end
	save_col(:,:,:,i) = disp_col(:,:,:);
	save_dis(:,:,i) = frame(:,:);
	i = i + 1;
	if i > 250
		i = 1;
	end
	disp(i)
	%above is for saving frames
	
	%These display the images
	set(displayImCol,'CData',disp_col);
	set(displayImBin,'CData',disp_dis);
	drawnow
end

%If it crashes this stops the camera and stops a afore-mentioned overflow
%problem, then will rethrow the error so you can see the error
catch e
stop(camera_depth);
stop(camera_BGR);
triggerconfig(camera_depth,'manual')
set(camera_depth,'TriggerRepeat',0)
triggerconfig(camera_BGR,'manual')
set(camera_BGR,'TriggerRepeat',0)
stop(camera_depth);
stop(camera_BGR);

rethrow(e)	
end

