%% Preparations, read video, pack csv to struct.
filein = fopen('data4.csv');
s = textscan(filein, '%s %d %d %s %s %f %s %d', 500, 'Delimiter',',');
fclose(filein);

video(1) = VideoReader('MLB 2015-0821 - Blue Jays at Angels.mp4');
video(2) = VideoReader('MLB 2015-0822 - Blue Jays at Angels.mp4');
video(3) = VideoReader('MLB 2015-0823 - Blue Jays at Angels.mp4');

s2 = [s{1} num2cell(s{2}) num2cell(s{3}) s{4} s{5} num2cell(s{6}) s{7} num2cell(s{8})];
samples = cell2struct(s2, {'player', 'startf', 'endf', 'park_sv_id', ...
    'type', 'speed', 'throw_hand', 'video_num'}, 2);
numsamples = length(samples);

%% Colour definitions
colours.CH = [245 32 80] ./ 255; % Red
colours.CU = [249 119 0] ./ 255; % Orange
colours.FC = [229 229 65] ./ 255; % Yellow
colours.FF = [17 93 198] ./ 255; % Ocean Blue
colours.FT = [28 178 252] ./ 255; % Sky Blue
colours.KC = [146 41 97] ./ 255; % Wine red
colours.SI = [19 189 126] ./ 255; % Green
colours.SL = [216 117 202] ./ 255; % Violet
colour_space = fieldnames(colours);

%% Ready graphs
g.dataplotL = figure; axis([0 1080 0 720]); hold on;
title('Pitch Trajectories (Left Handed)'); 
g.dataplotR = figure; axis([0 1080 0 720]); hold on;
title('Pitch Trajectories (Right Handed)'); 

% Manually draw a legend
figure; hold on; axis off;
for i=1:8
    plot(0, 'color', colours.(colour_space{i}), 'Linewidth', 2);
end
legend('Change Up','Curve Ball','Cutter','Four-seam Fastball', ...
    'Two-seam Fastball','Knuckle-curve','Sinker','Slider');

g.CHL = figure; axis([0 1080 0 720]); hold on;
title('Change Up Pitch Trajectories (Left Handed)'); 
g.CHR = figure; axis([0 1080 0 720]); hold on;
title('Change Up Pitch Trajectories (Right Handed)'); 
g.CUL = figure; axis([0 1080 0 720]); hold on;
title('Curve Ball Pitch Trajectories (Left Handed)'); 
g.CUR = figure; axis([0 1080 0 720]); hold on;
title('Curve Ball Pitch Trajectories (Right Handed)'); 
g.FCL = figure; axis([0 1080 0 720]); hold on;
title('Cutter Pitch Trajectories (Left Handed)'); 
g.FCR = figure; axis([0 1080 0 720]); hold on;
title('Cutter Pitch Trajectories (Right Handed)'); 
g.FFL = figure; axis([0 1080 0 720]); hold on;
title('Four-seam Fastball Pitch Trajectories (Left Handed)'); 
g.FFR = figure; axis([0 1080 0 720]); hold on;
title('Four-seam Fastball Pitch Trajectories (Right Handed)'); 
g.FTL = figure; axis([0 1080 0 720]); hold on;
title('Two-seam Fastball Pitch Trajectories (Left Handed)'); 
g.FTR = figure; axis([0 1080 0 720]); hold on;
title('Two-seam Fastball Pitch Trajectories (Right Handed)'); 
g.KCL = figure; axis([0 1080 0 720]); hold on;
title('Knuckle-curve Pitch Trajectories (Left Handed)'); 
g.KCR = figure; axis([0 1080 0 720]); hold on;
title('Knuckle-curve Pitch Trajectories (Right Handed)'); 
g.SIL = figure; axis([0 1080 0 720]); hold on;
title('Sinker Pitch Trajectories (Left Handed)'); 
g.SIR = figure; axis([0 1080 0 720]); hold on;
title('Sinker-curve Pitch Trajectories (Right Handed)'); 
g.SLL = figure; axis([0 1080 0 720]); hold on;
title('Slider Pitch Trajectories (Left Handed)'); 
g.SLR = figure; axis([0 1080 0 720]); hold on;
title('Slider Pitch Trajectories (Right Handed)'); 

%% Process data
miss = 0;
for i=1:numsamples
    fprintf('\nProcessing %d/%d\n', i, numsamples);
%     clip = video(samples(i).video_num).read([samples(i).startf samples(i).endf]);
%     curve = processClip2(clip);
    curve = processClip2(video(samples(i).video_num), samples(i).startf, samples(i).endf);
    if isempty(curve)
        miss = miss+1;
        continue;
    end
    samples(i).candidates = curve.candidates;
    samples(i).px = curve.px;
    samples(i).py = curve.py;
    samples(i).length = curve.length;
    
    figure(g.(['dataplot' samples(i).throw_hand]));
    plot(curve.candidates(:,1), 720-curve.candidates(:,2), 'Color', ...
        colours.(samples(i).type));
    figure(g.([samples(i).type samples(i).throw_hand]));
    plot(curve.candidates(:,1), 720-curve.candidates(:,2), 'Color', ...
        colours.(samples(i).type));
    
    drawnow;
end
disp(miss);
save part4samples.mat samples;