clear; close all; clc;

%% Restore path
restoredefaultpath
addpath 'model' 'optimizer' 'estimator' 'documentation' 'etc'

%% Load delta proportion
filename = '../data/covid19/delta_nation.xlsx';
delta = readtable(filename);
delta = [delta.Timespan, delta.DeltaProportion___/100];

%% Interpolation
xq = delta(1, 1):delta(end, 1);
vq = interp1(delta(:, 1), delta(:, 2), xq', 'pchip');

%% Add delta proportion between 2021/06/01 and 2021/06/05
vq = [repmat(vq(1), caldays(between(datetime(2021, 6, 1), datetime(2021, 6, 5), 'Days')), 1); vq];

%% Add delta proportion before 2021/06/01
vq = [zeros(caldays(between(datetime(2021, 2, 15), datetime(2021, 6, 1), 'Days')), 1); vq];

%% Add delta proportion after 2021/09/04
vq = [vq; repmat(vq(end), caldays(between(datetime(2021, 9, 4), datetime(2021, 12, 31), 'Days')), 1)];

%% Generate table
A = array2table([1 - vq, vq], 'VariableNames', {'alpha', 'delta'});
A{:, 3} = (datetime(2021, 2, 15, 'format', 'yyyy/MM/dd'):datetime(2021, 12, 31, 'format', 'yyyy/MM/dd'))';
A.Properties.VariableNames(end) = {'date'};

% Rearrange variables
A = movevars(A, 'date', 'Before', 'alpha');

%% Save table as xlsx
filename = '../data/covid19/alpha_delta_effect.xlsx';
writetable(A, filename);