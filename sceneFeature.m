function out = sceneFeature(im)
persistent grassRange soilRange;
if isempty(grassRange)
    load('grass.mat');
end
if isempty(soilRange)
    load('soil.mat');
end
im = rgb2ycbcr(im);
[h, w, ~] = size(im);
blockh = h/4;
blockw = w/4;
n = blockh * blockw;

blocks = mat2cell(im, ones(4,1)*blockh, ones(4,1)*blockw, 3);
blocks = blocks(2:4, :); % discard first row
blocks = reshape(blocks, 12, 1);
feature = zeros(1, 12);

for i=1:12
    block = blocks{i};
    
    grass = block(:,:,1) > grassRange(1,1) & block(:,:,1) < grassRange(1,2) ...
            & block(:,:,2) > grassRange(2,1) & block(:,:,2) < grassRange(2,2) ...
            & block(:,:,3) > grassRange(3,1) & block(:,:,3) < grassRange(3,2);
    grassRatio = sum(grass(:)) / n;
    
    soil = block(:,:,1) > soilRange(1,1) & block(:,:,1) < soilRange(1,2) ...
            & block(:,:,2) > soilRange(2,1) & block(:,:,2) < soilRange(2,2) ...
            & block(:,:,3) > soilRange(3,1) & block(:,:,3) < soilRange(3,2);
    soilRatio = sum(soil(:)) / n;

    other = ~(soil | grass);
    otherRatio = sum(other(:)) / n;

    b = [otherRatio>0.3, soilRatio>0.3, grassRatio>0.3];
    feature(1, i) = bi2de(b, 'left-msb');
end
out = feature;
end



