function c = normalizeCurve(c, amount)
    % Compress curve
    frange = sort(c.candidates(:,4));
    tdf = (frange(end)-frange(1))/(amount-1);
    tfrange = transpose([0:amount-1]*tdf+frange(1));
    x = polyval(c.px, tfrange);
    y = polyval(c.py, tfrange);
    n_candidates = [x y];
    
    % Move to origin
    n_candidates = n_candidates - repmat(n_candidates(1,:),7,1);
    
    % Rotate so end point touches horizontal axis
    last = n_candidates(end,:);
    ang = -1 * atan2(last(2), last(1));
    R = [cos(ang) -sin(ang); sin(ang) cos(ang)];
    n_candidates = transpose(R * transpose(n_candidates));
    
    % Normalize length
    n_candidates = n_candidates/n_candidates(end,1);
    c.candidates = [n_candidates tfrange];
    c.length = amount;
end