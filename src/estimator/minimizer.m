function [theta, cost_val, cal_time] = minimizer(data, cost, params, theta0, lb, ub, A, b)

options = optimset();
timerVal = tic;

if (isempty(lb) && isempty(ub)) && (isempty(A) && isempty(b))
    
    [theta, ~] = fminsearch(@(theta) cost(data, params, theta), theta0, options);
    
elseif isempty(A) && isempty(b)
    
    [theta, ~] = fminsearchbnd(@(theta) cost(data, params, theta), theta0, lb, ub, options);
    
else
    
    nonlcon = [];
    [theta, ~] = fminsearchcon(@(theta) cost(data, params, theta), theta0, lb, ub, A, b, nonlcon, options);
    
end

cost_val = cost(data, params, theta);
cal_time = toc(timerVal);

end