function [xyaf, preview] = findBall(clip)
    preview = 0.3*clip;  % Dim original clip to display interest points
    mask = zeros(size(preview));  % interest points storage
    xyaf = zeros(0,4);
    
    % Parameters. TO BE ADJUSTED FURTHER
    area_min = 120; area_max = 300;
    ratio_max = 3;
    compactmin = 0.7;
    isoRange = 50;
    vdialate = 4;
    
    % Dialate image vertically to recover some unclear ball stamps.
    clip = logical(imdilate(clip,ones(vdialate, 1)));

    for f=1:size(clip, 3)
        % Get properties of white connected regions
        stats = regionprops(clip(:,:,f),'Centroid',...
            'MajorAxisLength','MinorAxisLength','Area');
        centroids = cat(1, stats.Centroid);
        for c = 1:size(stats, 1)
            x = stats(c).Centroid(1);
            y = stats(c).Centroid(2);
            a = stats(c).MajorAxisLength;
            b = stats(c).MinorAxisLength;
            area = stats(c).Area;

            % Filters: area size, axis ratio, compactness
            if area < area_max && area > area_min && a/b < ratio_max && area/(a*b) > compactmin
                 neighborDist = pdist2([x y], centroids);
                 nnn = nnz(neighborDist < isoRange);
                 % Check if isolated
                 if nnn == 1
                    % Record to outputs
                    xyaf(end+1,:) = [x y area f];
                    mask(round(y),round(x), f) = 1;
                 end
            end            
        end
        % Enlarge interest plots
        mask(:,:,f) = imdilate(mask(:,:,f),ones(5,5));
    end
    % Apply mask
    preview(mask==1) = 255;
end
