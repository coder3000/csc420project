function curve = filtercurve(segments)
    minlen = 9;
    maxlen = 22;
    maxerr = 50;
    minisoratio = 0.5;
    
    curve = [];
    maxisoratio = 0;
    
    for i=1:length(segments)
        s = segments(i);
        
        % Length filter
        if (s.length < minlen || s.length > maxlen)
            continue;
        end
        
        % Prediction error
        framerange = s.candidates(:,4);
        predictx = polyval(s.px, framerange);
        predicty = polyval(s.py, framerange);
        error = abs([predictx predicty]-s.candidates(:, 1:2));
        if sum(sum(error.^2))/s.length > maxerr^2
            continue;
        end
        
        % ratio of isolated components
        isoratio = nnz(s.candidates(:,3));
        if isoratio < minisoratio
            continue;
        end
        
        % choose the one with most isolated components
        if isoratio > maxisoratio
            curve = s;
            maxisoratio = isoratio;
        end
    end
end
    