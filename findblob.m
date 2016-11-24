function [candidates, preview] = findBlob(clip, make_preview)
    candidates = zeros(10,3,size(clip,3));
    preview = 0.3*clip;  % Dim the original clip to display interest points
    mask = zeros(size(preview));  % Where interest points are
    [fx, fy, ~, fz] = size(clip);  %fz is number of frames
    
    % LoG filter sigmas
    smin = 10;
    smax = 15;
    k = 3;
    sigmas = smin:(smax-smin)/k:smax;

    for f=1:fz
        frame = clip(:,:,f);
        
        % LoG Convolution
        responseLoG = zeros(fx, fy,length(sigmas));
        for s=1:length(sigmas)
            sigma = sigmas(s);
            hs = floor(sigma*3);
            hl = -1*fspecial('log',[hs, hs],sigma);  % -1 so it detects white
            responseLoG(:,:,s) = sigma^2 * conv2(im2double(frame),hl,'same');
        end
        
        % Find idx of local maxima. Inspired by Wikipedia on imdilate.m &
        % https://www.mathworks.com/matlabcentral/fileexchange/17894-keypoint-extraction/content/keypointExtraction/kp_log.m
        response_dil = imdilate(responseLoG,ones(35,35));
        response_dil(response_dil<=0.1) = 255; % Threshold base value. black aren't interest points
        response_lmaxidx = find(response_dil == responseLoG); % Linear idx
        
        % Convert to xyz idx
        z = floor((response_lmaxidx-1) / (fx*fy)) + 1;
        xy = mod((response_lmaxidx-1), (fx*fy)) + 1;
        x = floor((xy-1) / fx) + 1;
        y = mod((xy-1), fx) + 1;
        
        % Record to output variables
        xyz = [x y z];
        candidates(1:size(xyz,1),:,f) = xyz;
        % preview(:,:,f) = insertShape(frame,'circle',[x y z],'LineWidth',5, 'Color','r');
        
        % Render to preview clip. This step slows down the process.
        if (make_preview)
            for j=1:size(xyz,1)
                mask(y(j),x(j),1, f) = 1;
            end
            mask(:,:,1,f) = imdilate(mask(:,:,1,f),ones(5,5));
        end
    end
    
    preview(mask==1) = 255;
end
    
    