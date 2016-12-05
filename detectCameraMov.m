% Detect and cut frames that are likely to involve camera movement
function out = detectCameraMov(dclip)
    thresh = 0.02;
    numAllPixels = numel(dclip(:,:,1));
    last = size(dclip, 3);
    first = round(0.5 * last); %cut only when it's near end of scene
    for k=first:last
        if nnz(dclip(:,:,k)) / numAllPixels > thresh
            break;
        end
    end
    out = dclip(:,:,1:k);
end