function [xyf, preview] = findBall(clip)
    preview = 0.3*clip;  % Dim original clip to display interest points
    mask = zeros(size(preview));  % interest points storage
    xyf = zeros(0,3);
    
    % Parameters. TO BE ADJUSTED FURTHER
    area_min = 120; area_max = 300;
    ratio_max = 3;
    compactmin = 0.7;
    vdialate = 4;
    
    % Dialate image vertically to recover some unclear ball stamps.
    clip = logical(imdilate(clip,ones(vdialate, 1)));

    for f=1:size(clip, 4)
        % Get properties of white connected regions
        stats = regionprops(clip(:,:,f),'Centroid',...
            'MajorAxisLength','MinorAxisLength','Area');
        
        for c = 1:size(stats, 1)
            area = stats(c).Area;
            a = stats(c).MajorAxisLength;
            b = stats(c).MinorAxisLength;
            
            % Filters: area size, axis ratio, compactness
            if area < area_max && area > area_min && a/b < ratio_max ...
                    && area/(a*b) > compactmin
                
                % Record to outputs
                x = stats(c).Centroid(1);
                y = stats(c).Centroid(2);
                xyf(end+1,:) = [x y f];
                mask(round(y),round(x), 1, f) = 1;
            end
        end
        % Enlarge interest plots
        mask(:,:,1,f) = imdilate(mask(:,:,1,f),ones(5,5));
    end
    % Apply mask
    preview(mask==1) = 255;
end
