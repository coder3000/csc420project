function [xyif, preview] = findBall(dclip)
    mask = zeros(size(dclip));  % interest points storage
    xyif = zeros(0,4);
    
    % Parameters. TO BE ADJUSTED FURTHER
    area_min = 80; area_max = 300;
    ratio_max = 5;
    compactmin = 0.7;
    isoRange = 50;

    for f=1:size(dclip, 3)
        % Get properties of white connected regions
        stats = regionprops(dclip(:,:,f),'Centroid',...
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
				 % Check if isolated
                 iso = (nnz(neighborDist < isoRange) == 1);
				 xyif(end+1,:) = [x y iso f];
				 mask(round(y),round(x), f) = 1;
            end         
        end
    end
    % Dim original clip to display interest points
    preview = 0.2*255*dclip;  
    % Apply mask
    preview(mask==1)=255;
end
