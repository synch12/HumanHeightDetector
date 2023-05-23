classdef M_CodeBook < handle
    properties
        codebook;
        frame;
    end
    
    methods
        function obj = M_CodeBook(X, Y)
            % Initialize an empty codebook
            obj.codebook = cell(Y, X);
            obj.frame = 0;
        end
        
        function outputMask = update(obj, image)
            [rows, cols] = size(image);
            outputMask = zeros(rows, cols);
            % Iterate over each pixel in the image
            for i = 1:rows
                for j = 1:cols
                    pixel = image(i, j);
                    % Compare the pixel value with the codebook entries
                    matches = abs(pixel - cellfun(@(v)v(1),obj.codebook{i, j})) <= 10; % Adjust the threshold as needed
                    if any(matches)
                        % Update the codebook entry
                        outputMask(i, j) = 0; % Background
                    else
                        % No match found, pixel is foreground
                        outputMask(i, j) = 255; % Foreground
                    end
                end
            end

        end
        function outmask = train(obj,image)
            % Iterate over each pixel in the image
            obj.frame = obj.frame + 1;
            outmask = 0;
            [rows, cols] = size(image);
            for i = 1:rows
                for j = 1:cols
                    pixel = image(i, j);
                    % Check if the codebook is empty at the current pixel
                    if isempty(obj.codebook{i, j})
                        % Create a new codebook entry
                        obj.codebook{i, j} = {[pixel,pixel,pixel,1,obj.frame-1,obj.frame,obj.frame]};
                    else
                        % Compare the pixel value with the codebook entries
                        matches = abs(pixel - cellfun(@(v)v(1),obj.codebook{i, j})) <= 5; % Adjust the threshold as needed

                        if any(matches)
                            % Update the codebook entry
                            matches = find(matches);
                            row = obj.codebook{i, j}{matches(1)};
                            matchedValue = row(1);
                            tup = row(2:end);
                            F = tup(3);
                            value = (matchedValue*F+pixel)/(F+1);
                            obj.codebook{i, j}{matches(1)} = [value,[min(pixel,tup(1)),max(pixel,tup(2)),F+1,max(tup(4),obj.frame-tup(6)),tup(5),obj.frame]];
                        else
                            % Create a new codebook entry
                            obj.codebook{i, j}{end+1} = [pixel,pixel,pixel,1,obj.frame-1,obj.frame,obj.frame];
                        end
                    end
                end
            end
            
        end
    end
end
