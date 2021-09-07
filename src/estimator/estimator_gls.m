function [theta, cost_val, cal_time] = estimator_gls(data, cost_ols, cost_gls, params, theta0, MaxIter, tol, lb, ub, A, b)
cal_time = [];
if nargin < 7
    tol = 1e-3;
    lb = [];
    ub = [];
    A = [];
    b = [];
elseif nargin < 8
    lb = [];
    ub = [];
    A = [];
    b = [];
elseif nargin < 10
    A = [];
    b = [];
end
[theta_p, old_cost_p, cal_time(end+1)] = estimator_ols(data, cost_ols, params, theta0, lb, ub, A, b);
fprintf('%04d iteration | %5.4e | %4.3f[sec]\n', 0, nan, cal_time(end));
old_theta_p = theta_p;
for p = 1:MaxIter
    idx = find(cell2mat(params(:,3)));
    for i = 1:length(idx)
        params{idx(i), 2} = old_theta_p(i);
    end
    % WLS
    [theta_p, cost_p, cal_time(end+1)] = minimizer(data, cost_gls, params, old_theta_p, lb, ub, A, b);
    fprintf('%04d iteration | %5.4e | %4.1f[sec]\n', p, cost_p, cal_time(end));
    if  abs(old_cost_p - cost_p) / cost_p < tol
        break;
    end
    old_theta_p = theta_p;
    old_cost_p = cost_p;
end
theta = theta_p;
cost_val = cost_p;
cal_time = sum(cal_time);