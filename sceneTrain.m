grassMat = matfile('grass.mat');
grassRange = grassMat.grassRange;

soilMat = matfile('soil.mat');
soilRange = soilMat.soilRange;

pitchingFiles = dir('pitching/*.jpg'); 
pitchingNumFiles = length(pitchingFiles);
pitchingFeatures = zeros(pitchingNumFiles, 12);
pitchingResponses = ones(pitchingNumFiles, 1);
for k = 1:pitchingNumFiles
    im = imread(strcat('pitching/', pitchingFiles(k).name));
    feature = sceneFeature(im, grassRange, soilRange);
    pitchingFeatures(k, :) = feature;
end

nonPitchingFiles = dir('nonpitching/*.jpg'); 
nonPitchingNumFiles = length(nonPitchingFiles);
nonPitchingFeatures = zeros(nonPitchingNumFiles, 12);
nonPitchingResponses = zeros(nonPitchingNumFiles, 1);
for k = 1:nonPitchingNumFiles
    im = imread(strcat('nonpitching/', nonPitchingFiles(k).name));
    feature = sceneFeature(im, grassRange, soilRange);
    nonPitchingFeatures(k, :) = feature;
end

features = vertcat(pitchingFeatures, nonPitchingFeatures);
responses = vertcat(pitchingResponses, nonPitchingResponses);
md = fitcknn(features,responses,'NumNeighbors',3);

test = imread('video1_1.png');
testFeature = sceneFeature(test, grassRange, soilRange);


