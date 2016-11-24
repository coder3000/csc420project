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
dclip = diff3(clip);
% Filter ball candidates
[candidates, cclip] = findBall(dclip);
% show scatter plots HERE

%% STEP 3: ball trajectory extractionfprintf('Begin step 3..\n');
segments = nneighbours(candidates, cclip);

%% Under construction
bestfit = recfit(segments, cclip1);  % roughly tested, passed. parameters not tuned
disp([segments(:,5) bestfit(:,5)]);  % To be removed. Shows assignment diff
% Planned: figure out which group is most likely the curve and fit curves.