function J = cost_mle_covid19(data, params, theta)
%% Replace Parameters
isEstimated = cell2mat(params(:, 3));
params(isEstimated, 2) = num2cell(theta);

% Generate structure
parameter = params2parameter(params);

%% Solve the Model
sol = solve_covid19(parameter);

%% Compute daily confirmed cases
prediction = compute_daily_confirmed(parameter, sol);

%% Compute Cost
prob = poisspdf(data, prediction);
prob(prob == 0) = realmin;
J = - sum(sum(log(prob), 'omitnan'), 'omitnan');

end

