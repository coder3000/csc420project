function curve = processClip2(video, startf, endf)
% Special version of processClip for part4 input data processing
    curve = [];
    try
        videoh = video.Height;
        videow = video.Width;
        videoStruct = struct('data',zeros(videoh,videow,3,'uint8'));
        video.currentTime = double(startf)/video.frame;

        % STEP 1: scene classification
        fprintf('Begin step 1..\n');
        load('sceneModel.mat', 'sceneModel');
        k = 1;
        while hasFrame(video) && k <= endf-startf
            frame = readFrame(video);
            videoStruct(k).data = frame;
            feature = sceneFeature(frame);
            videoStruct(k).isPitching = predict(sceneModel, feature);
            k = k+1;
        end
        % find first and last and take frames in between.
        result = horzcat(videoStruct(:).isPitching);
        first = find(result==1,1);
        last = find(result==1,1,'last');
        clip = cat(4, videoStruct(first:last).data);
        if isempty(clip)
            fprintf('No trajectory found\n');
            return;
        end

        %% STEP 2: ball candidate detection
        fprintf('Begin step 2..\n');
        g = fspecial('gaussian', [5,5],1.6);
        % Noise suppression
        clip = imfilter(clip, g);
        % Get binary frame difference
        dclip = diff3new(clip);
        % IDEA: detect and cut camera movement
        dclip = detectCameraMov(dclip);
        % Filter ball candidates
        [candidates, cclip] = findBall(dclip);
        % show scatter plots
        % xdi = figure; gscatter(candidates(:, 4), candidates(:, 1),candidates(:, 3), 'br', 'xo');
        % title('X distribution'); 
        % ydi = figure; gscatter(candidates(:, 4), candidates(:, 2),candidates(:, 3), 'br', 'xo');
        % title('Y distribution'); axis ij;

        %% STEP 3: ball trajectory extraction
        fprintf('Begin step 3..\n');
        segments = findTrajectory(candidates);
        % draw curves on scatter plots
        % figure(xdi); hold on;
        % for i=1:size(segments,2)
        %     cans = segments(i).candidates;
        %     plot(cans(:,4), cans(:,1), 'Color', 'k');
        % end
        % figure(ydi); hold on;
        % for i=1:size(segments,2)
        %     cans = segments(i).candidates;
        %     plot(cans(:,4), cans(:,2), 'Color', 'k');
        % end
        if isempty(segments)
            fprintf('No trajectory found\n');
            return;
        end
        curve = filterCurve(segments);
        if isempty(curve)
            fprintf('No trajectory found\n');
    %     else
        %     figure(xdi); 
        %     plot(curve.candidates(:,4), curve.candidates(:,1), 'Color', 'g', 'LineWidth',2);
        %     figure(ydi); 
        %     plot(curve.candidates(:,4), curve.candidates(:,2), 'Color', 'g', 'LineWidth',2);

        %     balls = curve.candidates;
        %     firstBallFrame = balls(1,4);
        %     balls = [balls(:, 1:2) 2*ones(size(balls,1),1)]; % circle radius 2
        %     screenshot = clip(:,:,:,firstBallFrame);
        % 
        %     screenshotResult = insertShape(screenshot,'circle', balls,'LineWidth',5);
        %     figure;imshow(screenshotResult);
        end
    catch ME
        fprintf('Error: %s, skipping.\n', ME.identifier);
    end

end