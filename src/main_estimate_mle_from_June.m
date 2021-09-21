clear; close all; clc;

%% Restore path
restoredefaultpath
addpath 'model' 'optimizer' 'estimator' 'documentation' 'etc'

%% Load estimate of beta
load('../results/estimate_before_June/result.mat', 'theta_mle')
beta = theta_mle;

%% Load data
[data, date, delta_prop, contact, init_beta, y01, ...
    vaccine_1st, vaccine_2nd, vaccine_eff, cfr, severe] = load_data();

%% Define params
kappa = 1/4;
alpha = 1/4;
gamma = 1/14;

% Select subset of data (2021/02/15 ~ 2021/05/31, since delta stars from 2021/06/01
tspan = 0:size(data, 1)-1;

% Social distancing effect
sd_1st_val = 1 + 0.8322/2;
sd_2nd_val = [0.699 * 0.35, 0.699, 0.35, (0.699+0.35)/2];
sd_3rd_val = sd_2nd_val;

for i = 1:length(sd_1st_val)
    for j = 1:length(sd_2nd_val)
        params = {% Parameters to be estimated
            'beta', beta, false, '$\beta_1';
            'delta', 1, true, '$\delta$';
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
            'vac_eff', vaccine_eff, false, 'vaccine efficacy';
            % Hospitalization risk after each dose
            'hosp_1st', 1-0.75, false, 'hospitalization risk after 1st dose';
            'hosp_2nd', 1-0.94, false, 'hospitalization risk after 2nd dose';
            % Social distancing effect
            'sd_1st', sd_1st_val(i), false, '1st social distancing effect';
            'sd_2nd', sd_1st_val(i) * sd_2nd_val(j), false, '2nd social distancing effect'};
        
        %% Parameter estimation (2021/02/15 ~ 2021/05/31)
        isEstimated = cell2mat(params(:, 3));
        theta0 = cell2mat(params(isEstimated, 2));
        cost0 = cost_mle_covid19(data, params, theta0);
        
        lb = 1;
        ub = inf * ones(length(theta0), 1);
        
        [theta_mle, cost_mle, time_mle] = estimator_gls(data, @cost_mle_covid19, @cost_mle_covid19, params, theta0, 10, 1e-3, lb, ub);
        
        %% Generate params table
        results_path = sprintf('../results/estimate_sd_1st_%d_2nd_%d', i, j);
        mkdir(results_path);
        
        ROW = params(isEstimated, 4); ROW{end+1} = 'Cost'; ROW{end+1} = 'Time';
        mle_table = table([theta0; cost0; 0], [theta_mle; cost_mle; time_mle], 'RowNames', ROW, 'VariableNames', {'Initial', 'Estimate'})
        lt = table2latex(mle_table, {'%.4e', 2});
        save_document(lt, sprintf('%s/result.tex', results_path))
        
        %% Generate figure
        visualize_fit(data, params, theta_mle, date, cfr, severe, results_path);
        
        %% Save all variables
        save(sprintf('%s/result.mat', results_path))
    end
end