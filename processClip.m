% works better with hd videos; ball has too few pixels in lower resolution
video = VideoReader('video2.mp4');
videoh = video.Height;
videow = video.Width;
videoStruct = struct('data',zeros(videoh,videow,3,'uint8'));

%% STEP 1: scene classification
fprintf('Begin step 1..\n');
load('sceneModel.mat', 'sceneModel');
k = 1;
while hasFrame(video)
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
xdi = figure; gscatter(candidates(:, 4), candidates(:, 1),candidates(:, 3), 'br', 'xo');
title('X distribution'); 
ydi = figure; gscatter(candidates(:, 4), candidates(:, 2),candidates(:, 3), 'br', 'xo');
title('Y distribution'); axis ij;

%% STEP 3: ball trajectory extraction
fprintf('Begin step 3..\n');
segments = findTrajectory(candidates);
% draw curves on scatter plots
figure(xdi); hold on;
for i=1:size(segments,2)
    cans = segments(i).candidates;
    plot(cans(:,4), cans(:,1), 'Color', 'k');
end
figure(ydi); hold on;
for i=1:size(segments,2)
    cans = segments(i).candidates;
    plot(cans(:,4), cans(:,2), 'Color', 'k');
end

curve = filterCurve(segments);
if isempty(curve)
    fprintf('No trajectory found.\n');
    return;
else
    figure(xdi); 
    plot(curve.candidates(:,4), curve.candidates(:,1), 'Color', 'g', 'LineWidth',2);
    figure(ydi); 
    plot(curve.candidates(:,4), curve.candidates(:,2), 'Color', 'g', 'LineWidth',2);

    balls = curve.candidates;
    firstBallFrame = balls(1,4);
    balls = balls(balls(:,5)==1, 1:2); % take out predicted ones
    circles = [balls 2*ones(size(balls,1),1)]; % circle radius 2
    screenshot = clip(:,:,:,firstBallFrame);

    screenshotResult = insertShape(screenshot,'circle',circles,'LineWidth',5);
    figure;imshow(screenshotResult);
    % calculate speed (km/h)
    fps = round(video.FrameRate);
    speed = 18.44 / (curve.length / fps) * 60 * 60 / 1000;
    fprintf('speed estimation: %.2f km/h\n', speed);
end

%% Step 4: Classification
%% STEP 4.1 Normalization
fprintf('Begin step 4..\n');
% Plot before normalization
figure; axis([0 1080 0 720]); hold on;
plot(curve.candidates(:,1), 720-curve.candidates(:,2), 'Linewidth', 2); 

curve = normalizeCurve(curve, 7);

% Plot after normalization
figure; axis([-0.5 1.5 -0.5 0.85]); hold on;
plot(curve.candidates(:,1), -curve.candidates(:,2), 'Linewidth', 2);

%% STEP 4.2: Classification
features = transpose([curve.candidates(:,1); curve.candidates(:,2)]);

% KNN
pitchClassModelKNN = [];
load pitchClassModelKNN.mat pitchClassModelKNN;
fprintf('\nPrediction of KNN classifier:');
disp(predict(pitchClassModelKNN, features));

%multi SVM
pitchClassModelSVM = [];
load pitchClassModelSVM.mat pitchClassModelSVM;
fprintf('Prediction of multi-class SVM classifier:');
disp(predict(pitchClassModelSVM, features));

% correct answer: FF
fprintf('Correct Answer:   ''FF''\n\n');


