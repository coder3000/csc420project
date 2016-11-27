function out = findTrajectory(candidates)
maxdist = 150;
maxguess = 4;
maxerror = 30;

% convert to cell array for easier manipulation
maxFrame = max(candidates(:, 4));
candis = cell(1, maxFrame);
for key = unique(candidates(:,4)')
    ndx = candidates(:,4) == key;
    candis{key} = candidates(ndx,:);
end

group_id = 1;

for frame=1:maxFrame-2
    origins = candis{frame};
    next_balls = candis{frame+1};
    next_next_balls= candis{frame+2};
    
    % pass if we can't connect three.
    if isempty(next_balls) || isempty(next_next_balls)
        continue;
    end
    
    for i=1:size(origins, 1)
        origin = origins(i, :);
        
        [next_idx, d1] = knnsearch(next_balls(:,1:2), origin(1:2));
        next_ball = next_balls(next_idx, :);
        
        [next_next_idx, d2] = knnsearch(next_next_balls(:,1:2), next_ball(1:2));
        next_next_ball = next_next_balls(next_next_idx, :);
        
        % three are connected, but too far away each other.
        if d1 > maxdist || d2 > maxdist
            continue;
        end
        
        % 1 is flag for being real (not predicted) ball
        group = [origin 1; next_ball 1; next_next_ball 1];
        
        p_xdi = polyfit(group(:,4), group(:,1),1);
        p_ydi = polyfit(group(:,4), group(:,2),2);
        
        y_xdi = polyval(p_xdi,group(:,4));
        if sumabs(y_xdi - group(:,1)) > 3 * maxerror
            continue;
        end
        
        curFrame = frame+3; 
        notfoundcount = 0; % consecutive not found count
        while curFrame <= maxFrame
            curBalls = candis{curFrame};
            predicted_xdi = polyval(p_xdi, curFrame);
            predicted_ydi = polyval(p_ydi, curFrame);
            prediction_met = false;
            for k=1:size(curBalls, 1)
                % check if any ball pos is close to our prediction
                if abs(predicted_xdi - curBalls(k, 1)) < maxerror && abs(predicted_ydi - curBalls(k, 2)) < maxerror
                    group(end+1,:) = [curBalls(k, :) 1]; 
                    p_xdi = polyfit(group(:,4), group(:,1),1);
                    p_ydi = polyfit(group(:,4), group(:,2),2);
                    prediction_met = true;
                    notfoundcount = 0;
                    break;
                end
            end
            
            if ~prediction_met
                notfoundcount = notfoundcount + 1;
                if notfoundcount == maxguess
                    break;
                end
                group(end+1,:) = [predicted_xdi, predicted_ydi, 0, curFrame, 0];
            end
            curFrame = curFrame + 1;
        end
        
        % cut last few predicted points
        length = size(group, 1);
        for j=0:2
            if group(length-j, 5) == 0
                group = group(1:length-j-1,:);
            end
        end
        
        group(:,end+1) = group_id;
        out(group_id).candidates = group;
        out(group_id).length = size(group, 1);
        out(group_id).px = p_xdi;
        out(group_id).py = p_ydi;
        group_id = group_id + 1;
    end
end
end