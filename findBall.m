function [xyif, preview] = findBall(dclip)
    mask = zeros(size(dclip));  % interest points storage
    xyif = zeros(0,4);
    
    % Parameters. TO BE ADJUSTED FURTHER
    area_min = 70; area_max = 300;
    ratio_max = 5;
    compactmin = 0.7;
    isoRange = 50;

    for f=1:size(dclip, 3)
        % Get properties of white connected regions
        stats = regionprops(dclip(:,:,f),'Centroid','BoundingBox','Area');
        centroids = cat(1, stats.Centroid);
        for c = 1:size(stats, 1)
            x = stats(c).Centroid(1);
            y = stats(c).Centroid(2);
            bbw = stats(c).BoundingBox(3);
            bbh = stats(c).BoundingBox(4);
            ratio = bbw/bbh;
            area = stats(c).Area;

            % Filters: area size, axis ratio, compactness
            if area < area_max && area > area_min && ratio > 1/ratio_max && ratio < ratio_max && area/(bbw*bbh) > compactmin
                 neighborDist = pdist2([x y], centroids);
				 % Check if isolated
                 iso = (nnz(neighborDist < isoRange) == 1);
				 xyif(end+1,:) = [x y iso f];
				 mask(round(y),round(x), f) = 1;
            end         
        end
    end
    % Dim original clip to display interest points
    preview = 0.3*255*uint8(dclip);  
    % Apply mask
    preview(mask==1)=255;
end
