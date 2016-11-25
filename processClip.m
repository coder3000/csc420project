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
clip0 = cat(4, videoStruct(first:last).data);

%% STEP 2: ball candidate detection
fprintf('Begin step 2..\n');
g = fspecial('gaussian', [5,5],1.6);
% Noise suppression
clip = imfilter(clip0, g);
% Get binary frame difference
dclip = diff3(clip);
% Filter ball candidates
[candidates, ~] = findBall(dclip);
% show scatter plots
figure; gscatter(candidates(:, 4), candidates(:, 1),candidates(:, 3), 'br', 'xo'); 
figure; gscatter(candidates(:, 4), candidates(:, 2),candidates(:, 3), 'br', 'xo'); 

%% STEP 3: ball trajectory extraction
fprintf('Begin step 3..\n');
segments = nneighbours(candidates);  % This is a modified version (v2). Panalty and iso points only.
% segments = nneighbours_original(candidates);  % This is from paper. No panalty and all points.
a = figure; gscatter(segments(:, 4), segments(:, 1),segments(:, 5)); hold on; 
b = figure; gscatter(segments(:, 4), segments(:, 2),segments(:, 5)); hold on; 
curve = fitcurve(segments);  % However, nneighbours (v2) makes this function hard to choose (no iso ratio)
figure(a); plot(curve(:, 4), curve(:, 1), 'b');
plot(curve(:, 4), curve(:, 1), 'bo'); 
figure(b); plot(curve(:, 4), curve(:, 2), 'b'); 
plot(curve(:, 4), curve(:, 2), 'bo'); 