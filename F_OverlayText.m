function [frame_rgb, frame_diff] = F_OverlayText(heights,mag, frame_rgb, frame_diff)
%F_OVERLAYTEXT Summary of this function goes here
%   Detailed explanation goes here
if(~isempty(heights))
		    for per = 1:1:size(heights,1)
			    text = sprintf('%0.2f',round(heights(per,1),2));
			    x = heights(per,2);%*mag;
			    y = heights(per,3);%*mag - 20*mag;
                x_RGB = heights(per,2)*mag;
			    y_RGB = heights(per,3)*mag - 20*mag;
			    %Cap the y value to >1
			    if(y <= 0)
				    y = 1;
			    end
			    frame_rgb  = insertText(frame_rgb,[x_RGB,y_RGB],text,...
				    'FontSize',24,'BoxOpacity',0.5,'BoxColor','black','TextColor','red');
			    frame_diff  = insertText(frame_diff,[x,y],text,...
				    'FontSize',24,'BoxOpacity',0,'TextColor','white');
                frame_diff = frame_diff(:, :, 1);
		    end
end
end

