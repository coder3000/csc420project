function c = nneighbours(c, clip)
    % Image origin is top left. We want bottom left so invert y
    x = figure;plot(c(:, 4), c(:, 1), 'k.'); hold on;
    y = figure;plot(c(:, 4), size(clip,1)-c(:, 2), 'k.'); hold on;
    c = [c zeros(size(c,1), 1)];
    group = 1; % Connected points share a same group id.
    maxdist = 2600; % Max neighbour distance between frames.
    
    for p=1:size(c, 1)
        cp = c(p, :); 
        targets = find(ismember(c(:,4), cp(4)+1:cp(4)+2)); % All entries from following 2 frames
        for tidx=transpose(targets)
            tp = c(tidx, :);
            if (cp(1)-tp(1))^2 + (cp(2)-tp(2))^2 < maxdist
                % Plot segment
                segment = [cp; tp];
                figure(x); plot(segment(:,4), segment(:,1), 'k');
                figure(y); plot(segment(:,4), size(clip,1)-segment(:,2), 'k');
                
                % Assign group id
                if cp(5) ~= 0 
                    c(tidx, 5) = cp(5);
                else
                    c(p, 5) = group;
                    c(tidx, 5) = group;
                    group = group +1;
                end
                break; % We want the nearest one so stop
            end
        end
    end
    figure(x); gscatter(c(:, 4), c(:, 1), c(:, 5)); 
    figure(y); gscatter(c(:, 4), size(clip,1)-c(:, 2), c(:, 5));
end
                
            