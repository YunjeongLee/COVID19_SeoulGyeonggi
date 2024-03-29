function [data, date, delta_prop, contact, init_beta, y0, vaccine_1st, vaccine_2nd, vaccine_eff, cfr, severe] = load_data()
%% Load daily incident confirmed data
filename = '../data/covid19/daily_confirmed_total.csv';
T_data = readtable(filename, 'PreserveVariableNames', true, 'ReadRowNames', true);
date = datetime(T_data.Properties.RowNames, 'format', 'yyyy/MM/dd');
data = T_data.Variables;

%% Load alpha and delta proportion
filename = '../data/covid19/alpha_delta_effect.xlsx';
delta_prop = readmatrix(filename, 'range', 'C2:C352');

%% Load contact matrix
filename = '../data/contact/[2020서울경기]contact_rate_matrix.csv';
contact = readmatrix(filename);

%% Load initial state
filename = '../data/initial_state/value_0215.mat';
load(filename, 'value_0215');
init_beta = value_0215{1}(end);
y0 = value_0215{2};

% Rearragne y0
y0 = reshape(reshape(y0, 5, 9).', 1, 45);

%% Load vaccination number
filename = '../data/vaccine/vaccination_number.xlsx';
vaccine_number = readtable(filename, 'PreserveVariableNames', true);
vaccine_number = vaccine_number{:, 2:end};

%% Load vaccination ratio by age
filename = '../data/vaccine/1st_dose_ratio_by_age.csv';
vaccine_1st = readmatrix(filename, 'range', 'B2:J352');
filename = '../data/vaccine/2nd_dose_ratio_by_age.csv';
vaccine_2nd = readmatrix(filename, 'range', 'B2:J352');

%% Compute the vaccination number by age
vaccine_1st = vaccine_number(:, 1) .* vaccine_1st;
vaccine_2nd = vaccine_number(:, 2) .* vaccine_2nd;

% Add two weeks in front of 2021/02/15
vaccine_1st = [zeros(14, size(vaccine_1st, 2)); vaccine_1st];
vaccine_2nd = [zeros(14, size(vaccine_2nd, 2)); vaccine_2nd];

%% Load vaccine efficacy
filename = '../data/vaccine/vaccine_efficacy.xlsx';
vaccine_eff = readmatrix(filename, 'range', 'B2:C352');

% Add two weeks in front of 2021/02/15
vaccine_eff = [zeros(14, size(vaccine_eff, 2)); vaccine_eff];

%% Load case fatality rate and proportion of severe illness
cfr = readmatrix('../data/covid19/case_fatality_rate.csv', 'range', 'A2:I2');
severe = readmatrix('../data/covid19/severe_illness.csv', 'range', 'A2:I2');

end