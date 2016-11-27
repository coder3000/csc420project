function bwdclip = diff3new(clip)
    h = size(clip,1); w = size(clip,2);
    sumClip = sum(clip, 3);
    sumClip = sum(sum(sumClip,1),2);
    sumClip = squeeze(sumClip);
    
     % 50 percent of average intensity per frame
    avgInt = sumClip / (2*3*h*w);
    
    dclip = clip(:,:,:,2:end) - clip(:,:,:,1:end-1); % Positive difference
    graydclip = (dclip(:,:,1,:)+dclip(:,:,2,:)+dclip(:,:,3,:))/3; % rgb2grey
    graydclip = squeeze(graydclip);
    bwdclip = false(size(graydclip));
    for i=1:size(graydclip,3)
        frame = graydclip(:,:,i);
        bw = frame > avgInt(i+1);
        bwdclip(:, :, i) = bw;
    end
    bwdclip = squeeze(bwdclip);
end