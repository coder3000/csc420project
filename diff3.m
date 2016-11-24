function greyclip = diff3(clip)
    epsilon = 0.02; % Threshold bias
    dclip0 = clip(:,:,:,2:end) - clip(:,:,:,1:end-1); % Positive difference
    % Otsu thresholding. Adapted from
    % https://www.mathworks.com/matlabcentral/answers/uploaded_files/6434/ExtractMovieAVIFrames.m
    greyclip = (dclip0(:,:,1,:)+dclip0(:,:,2,:)+dclip0(:,:,3,:))/3; % rgb2grey
    threshold = (graythresh(greyclip)+epsilon)*255; % Get threshold
    greyclip(greyclip<threshold) = 0; % Cut off
    greyclip(greyclip>=threshold) = 255; % Saturation
end