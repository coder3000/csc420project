function bwdclip = diff3(clip)
    epsilon = 0.02; % Threshold bias
    dclip = clip(:,:,:,2:end) - clip(:,:,:,1:end-1); % Positive difference
    % Otsu thresholding. Adapted from
    % https://www.mathworks.com/matlabcentral/answers/uploaded_files/6434/ExtractMovieAVIFrames.m
    graydclip = (dclip(:,:,1,:)+dclip(:,:,2,:)+dclip(:,:,3,:))/3; % rgb2grey
    threshold = (graythresh(graydclip)+epsilon)*255; % Get threshold
    graydclip(graydclip<threshold) = 0; % Cut off
    bwdclip = (graydclip > 0);
    bwdclip = squeeze(bwdclip);
end