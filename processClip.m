% clc; clear all; close all;

% !!! Current settings are only tested on one 720P hd video !!!
% We might need to shrink videos to a same smaller size

%% Load Pitch Clip (Assuming Step 1 done)
% clipname = input('Please enter clip name: ', 's');
clipname = 'MLB''s Fastest Pitch Ever Recorded.mp4';
fprintf('\nReading Clip...\n');
clip1 = VideoReader(clipname).read([650 670]); % Works 90% under current settings
% clip1 = VideoReader(clipname).read([1420 1470]); % Works 80%
% clip1 = VideoReader(clipname).read([1660 1740]); % Works 85%
% clip1 = VideoReader(clipname).read([2230 2280]); % Works 55% -> Tighten cage 


%% Noise suppression
g = fspecial('gaussian', [5,5],1.6);
bclip1 = imfilter(clip1, g);


%% Start of Step 2
%% Get binary frame difference (1 channel: 0 or 255)
disp('Calculating differences...');
dclip1 = diff3(bclip1);
% implay(dclip1);

%% Find and filter ball candidates
disp('Filtering candidates...');
[candidates, cclip1] = findball(dclip1);
implay(cclip1);


%% Start of Step 3
%% Trajectory extraction
disp('Fitting curves...');
segments = nneighbours(candidates, cclip1);

%% Under construction
bestfit = recfit(segments, cclip1);  % roughly tested, passed. parameters not tuned
disp([segments(:,5) bestfit(:,5)]);  % To be removed. Shows assignment diff
% Planned: figure out which group is most likely the curve and fit curves.