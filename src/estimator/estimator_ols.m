function [theta, cost_val, cal_time] = estimator_ols(data, cost_ols, params, theta0, lb, ub, A, b)

if nargin < 5
    
    lb = [];
    ub = [];
    A = [];
    b = [];
    
elseif nargin < 7
    
    A = [];
    b = [];
    
end

[theta, cost_val, cal_time] = minimizer(data, cost_ols, params, theta0, lb, ub, A, b);

end