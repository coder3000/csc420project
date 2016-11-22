function s = recfit(s, clip)
    maxframe = 20; % Search within this frame range away from group boundries
    tolarancex = 120; % Size of capture cage expanded from group fit x direction
    tolarancey = 70; % ~ y direction
    confidence = 0.7; % Portion of second group capture required to merge groups
    straightness = 0.7; % Panalize best fit curvature
    
    x = figure;plot(s(:, 4), s(:, 1), 'k.'); hold on;
    y = figure;plot(s(:, 4), size(clip,1)-s(:, 2), 'k.'); hold on;
    
    % Recursive search algorithm with push pop queue
    s_nonzero = s(s(:,5)~=0, :);
    all_groups = transpose(unique(s_nonzero(:,5)));
    queue = all_groups;
    
    while ~isempty(queue)
        cg = queue(1); % Current Group
        queue(1) = []; % Pop queue
        cp = s(s(:,5)==cg,:); % Current/Selected Points
        deg = 1;
        if(size(cp, 1))>2
            deg = 2;
        elseif (size(cp, 1))<2
            continue;
        end
        psx = polyfit(cp(:,4),cp(:,1),1); % Best fit x straight
        psy = polyfit(cp(:,4),cp(:,2),1); % ~ y straight
        px = polyfit(cp(:,4),cp(:,1),deg); % ~ x quad/straight
        py = polyfit(cp(:,4),cp(:,2),deg); % ~ y quad/straight
        
        for g = all_groups
            if g==cg 
                continue; 
            end
            target_points = s(s(:,5)==g,:);
            
            % Find targets that are within search range, no overlapping
            % This is the point I read partner's code and felt shame and
            % started naming variables properly. Codes get longer
            frame_range = sort(cp(:, 4));
            tgframes = target_points(:,4);
            target_inrange = target_points(...
                (tgframes>frame_range(end)...
                & tgframes<=frame_range(end)+maxframe)...
                | (tgframes<frame_range(1)...
                & tgframes>=frame_range(1)-maxframe),:);
            
            % Project onto best fit p, count # points captured in cage
            gframes = target_inrange(:,4);
            cage_centersx = straightness*polyval(psx, gframes)+ ...
                (1-straightness)*polyval(px, gframes);
            cage_centersy = straightness*polyval(psy, gframes)+ ...
                (1-straightness)*polyval(py, gframes);
            in_cagex = abs(cage_centersx - target_inrange(:,1))<tolarancex;
            in_cagey = abs(cage_centersy - target_inrange(:,2))<tolarancey;
            in_cage = in_cagex & in_cagey;
            in_cage(in_cage==0) = [];
            
            if length(in_cage)/size(target_points, 1) >= confidence
                % Merge group
                s(s(:,5)==g,5) = cg; % Assign new group id = cg
                queue(end+1) = cg;  % Push cg to queue
                all_groups(all_groups==g) = []; % Update meta
            end
        end
    end
    figure(x); gscatter(s(:, 4), s(:, 1), s(:, 5)); 
    figure(y); gscatter(s(:, 4), size(clip,1)-s(:, 2), s(:, 5));
end
            
            