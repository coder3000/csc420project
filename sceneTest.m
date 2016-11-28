load('sceneModel.mat', 'sceneModel');
files = dir('test/*.jpg'); 
numFiles = length(files);
result = zeros(1, numFiles);
for k = 1:numFiles
    display(files(k).name);
    im = imread(strcat('test/', files(k).name));
    feature = sceneFeature(im);
    gg = predict(sceneModel, feature);
    result(k) = gg;
end
display(result);
