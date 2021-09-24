clear; close all; clc;

%% Restore path
restoredefaultpath
addpath 'model' 'optimizer' 'estimator' 'documentation' 'etc'

%% Load data
[data, delta_prop, contact, init_beta, y0, vaccine_1st, vaccine_2nd, vaccine_eff, cfr, severe] = load_data_pred();

%% Load estimate of beta
load('../results/estimate_before_June/result.mat', 'theta_mle')
beta = theta_mle;

%% Load estimate of delta
results_path = '../results/estimate_sd_1st_2_2nd_2';
load(sprintf('%s/result.mat', results_path), 'theta_mle')

%% Generate date and update params
% Epidemiological parameters
kappa = 1/4;
alpha = 1/4;
gamma = 1/14;

% Dates
date = datetime(2021, 2, 15):datetime(2021, 12, 31);
tspan = 0:length(date)-1;

% Social distancing effect
sd_1st_val = 1 + 0.8322/2;
sd_2nd_val = [0.35, (0.699+0.35)/2];
sd_3rd_val = [1, 1/0.699, 1/0.35];
school = [1, 1 + 0.8322/2, (1 + 0.8322/2)^2];

for k = 1:length(sd_2nd_val)
for i = 1:length(sd_3rd_val)
    for j = 1:length(school)
        params = {% Parameters to be estimated
                  'beta', beta, false, '$\beta_1';
                  'delta', theta_mle, true, '$\delta$';
                  % Initial state, time stamp and contact matrix
                  'y0', y0, false, '$y_0$';
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
                  'sd_1st', sd_1st_val, false, '1st social distancing effect';
                  'sd_2nd', sd_1st_val * sd_2nd_val, false, '2nd social distancing effect';
                  'sd_3rd', sd_1st_val * sd_2nd_val(k) * sd_3rd_val(i), false, '3rd social distancing effect';
                  % School effect
                  'school', school(j), false, 'School effect';
                  % CFR or severeness
                  'cfr', cfr, false, 'case fatality rate';
                  'severe', severe, false, 'severity'};
        
        %% Visualize prediction
        results_path = sprintf('../results/predict_exp_%d_%d', k, (i-1)*length(school)+j);
        mkdir(results_path)
        visualize_pred(data, params, theta_mle, date, cfr, severe, results_path);
    end
end
end