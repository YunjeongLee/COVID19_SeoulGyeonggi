clear; close all; clc;

%% Restore path
restoredefaultpath
addpath 'model' 'optimizer' 'estimator' 'documentation' 'etc'

%% Load data
[data, date, delta_prop, contact, init_beta, y01, ...
    vaccine_1st, vaccine_2nd, vaccine_eff, cfr, severe] = load_data();

%% Define params
kappa = 1/4;
alpha = 1/4;
gamma = 1/14;

% Select subset of data (2021/02/15 ~ 2021/05/31, since delta stars from 2021/06/01
tspan = 0:size(data, 1)-1;

params = {% Parameters to be estimated
          'beta', init_beta, true, '$\beta_1';
          'delta', 1, false, '$\delta$';
          % Initial state, time stamp and contact matrix
          'y0', y01, false, '$y_0$';
          'tspan', tspan, false, 'time stamp';
          'dt', 0.001, false, '$\Delta t$';
          'contact', contact, false, 'contact';
          % Epidemiological parameters (fixed)
          'kappa', kappa, false, '$\kappa$';
          'alpha', alpha, false, '$\alpha$';
          'gamma', gamma, false, '$\gamma$';
          'delta_prop', delta_prop, false, '$\delta$ proportion';
          % Vaccination (fixed)
          'vac_1st', vaccine_1st, false, '1st dose';
          'vac_2nd', vaccine_2nd, false, '2nd dose';
          'vac_eff', vaccine_eff, false, 'vaccine efficacy'};

%% Parameter estimation (2021/02/15 ~ 2021/05/31)
isEstimated = cell2mat(params(:, 3));
theta0 = cell2mat(params(isEstimated, 2));
cost0 = cost_mle_covid19(data, params, theta0);

lb = zeros(length(theta0), 1);
ub = inf * ones(length(theta0), 1);

[theta_mle, cost_mle, time_mle] = estimator_gls(data, @cost_mle_covid19, @cost_mle_covid19, params, theta0, 10, 1e-3, lb, ub);

%% Generate params table
results_path = '../results/estimate_from_June';
mkdir(results_path);

ROW = params(isEstimated, 4); ROW{end+1} = 'Cost'; ROW{end+1} = 'Time';
mle_table = table([theta0; cost0; 0], [theta_mle; cost_mle; time_mle], 'RowNames', ROW, 'VariableNames', {'Initial', 'Estimate'})
lt = table2latex(mle_table, {'%.4e', 2});
save_document(lt, sprintf('%s/result.tex', results_path))

%% Generate figure
visualize_fit(data, params, theta_mle, date, cfr, severe, results_path);

%% Save all variables
save(sprintf('%s/result.mat', results_path))
