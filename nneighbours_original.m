function cout = nneighbours_original(candidates)
    c = candidates(candidates(:,3)==1, :);
    c(:, end+1) = 0;
    cout = zeros(0, size(c,2));
    group = 1; % Group id.
    maxdist = 140; % Max length of valid first segments.
    maxerror = 70; % Max error between prediction and actual
    maxguess = 3; % Max # guess in a row terminates curve
    straightness = 0.5; % Panalize best fit curvature. I got some...
                        % interesting results without this.
    
    for i=1:size(c,1)
        cp = c(i, :); 
        if cp(5) ~= 0  % Inner node of some curve is unlikely another start
            continue;
        end
        
        % Find first segment by linking to the closest point in next frame.
        targets = find(c(:,4)==cp(4)+1);
        [idx, d] = nearest(cp, c(targets,1:2));
        if d > maxdist
            continue;
        end
        cout(end+1,:) = [cp(1:4) group];
        cout(end+1,:) = [c(targets(idx),1:4) group];
        c(i, 5) = group;
        c(targets(idx), 5) = group;
        
        notfound = 0;
        while notfound < maxguess
            
            % Fit curve to current group
            ingroup = cout(cout(:,5)==group, :);
            framerange = sort(ingroup(:, 4));
            if size(ingroup, 1) <=2
                px = polyfit(ingroup(:,4),ingroup(:,1),1);
                py = polyfit(ingroup(:,4),ingroup(:,2),1);
            else
                px = polyfit(ingroup(:,4),ingroup(:,1),2);
                py = polyfit(ingroup(:,4),ingroup(:,2),2);
            end
            psx = polyfit(ingroup(:,4),ingroup(:,1),1);
            psy = polyfit(ingroup(:,4),ingroup(:,2),1);
            
            % Predict next point
            predictx = (1-straightness)*polyval(px, framerange(end)+1) +...
                straightness*polyval(psx, framerange(end)+1);
            predicty = (1-straightness)*polyval(py, framerange(end)+1) +...
                straightness*polyval(psy, framerange(end)+1);
            
            % See if next point has a match
            cnext = find(candidates(:,4)==framerange(end)+1);
            [idx, d] = nearest([predictx predicty], candidates(cnext,:));
            if d > maxerror  % If not, take predicted point as next
                cout(end+1,:) = [predictx predicty 1 framerange(end)+1 group];
                notfound = notfound + 1;
            else  % If yes, include the match
                match = candidates(cnext(idx),1:4);
                cout(end+1,:) = [match group];
                c(c(:,1)==match(1) & c(:,2)==match(2),5) = group;
                notfound = 0;
            end
            
        end
        group = group + 1;
        cout = cout(1:end-maxguess,:);  % Crop off last guesses.
    end
end

function [idx, distance] = nearest(target, candidates)
    % Find the one in candidates that is closest to target
    if isempty(candidates)
        idx = 0;
        distance = Inf;
        return;
    end
    candidates(:,end+1) = (target(1)-candidates(:,1)).^2 + (target(2)-candidates(:,2)).^2;
    [~,i] = sort(candidates(:,end));
    idx = i(1);
    distance = sqrt(candidates(idx,end));
end