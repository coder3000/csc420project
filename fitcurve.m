function curve = fitcurve(segments)
    min_length = 9;  % Min # frames required
    max_length = 26;  % Max ~
    max_avg_err = 50;  % Max average error of data from best fit curve

    all_groups = unique(segments(:,5));
    for g=transpose(all_groups)
        ingroup = segments(segments(:,5)==g, :);
        if size(ingroup, 1)<min_length || size(ingroup, 1)>max_length
            continue;
        end
        
        [framerange, idx] = sort(ingroup(:, 4));
        px = polyfit(ingroup(:,4),ingroup(:,1),2);
        py = polyfit(ingroup(:,4),ingroup(:,2),2);
        predictx = polyval(px, framerange);
        predicty = polyval(py, framerange);
        error = abs([predictx predicty]-ingroup(idx, 1:2));
        if sum(sum(error))/size(ingroup,1) > max_avg_err
            continue;
        end
        curve = [predictx predicty ingroup(idx,3:4)];  % Might need fix here. I am just overwriting curve
    end
end
        