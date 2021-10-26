clear; close all; clc;

%% Restore path
restoredefaultpath
addpath 'model' 'optimizer' 'estimator' 'documentation' 'etc'

%% Load data
[~, ~, delta_prop, ~, ~, ~, ...
    vaccine_1st, vaccine_2nd, vaccine_eff, ~, ~] = load_data();

%% Delete first 14 rows
vaccine_1st = vaccine_1st(15:end, :);
vaccine_2nd = vaccine_2nd(15:end, :);
vaccine_eff = vaccine_eff(15:end, :);

%% Load vaccination number
filename = '../data/vaccine/vaccination_number.xlsx';
vaccine_number = readtable(filename, 'PreserveVariableNames', true);
vaccine_number = vaccine_number{:, 2:end};

%% Generate results folder
results_path = '../results/data';
mkdir(results_path);

%% Plot vaccination number
n = length(date);

% Delta proportion
figure('pos', [10 10 1600 900]);
plot(date, delta_prop(1:n))
xlabel('Date')
ylabel('Percentage (%)')
title('Proportion of \delta-variant', 'fontsize', 20)
set(gca, 'fontsize', 15);
ax = get(gcf,'Children');
[ax.Children.Marker] = deal('.');
[ax.Children.MarkerSize] = deal(15);
saveas(gca, sprintf('%s/delta_proportion.eps', results_path), 'epsc');

% Vaccination number for all age
figure('pos', [10 10 1600 900]);
subplot(2, 1, 1)
plot(date, vaccine_number(1:n, 1));
xlabel('Date')
ylabel('No. vaccination');
title('Daily number of vaccination for all ages (1st dose)', 'fontsize', 20)
set(gca, 'fontsize', 15);
ax = gca;
[ax.Children.Marker] = deal('.');
[ax.Children.MarkerSize] = deal(15);

subplot(2, 1, 2);
plot(date, vaccine_number(1:n, 2));
xlabel('Date')
ylabel('No. vaccination');
title('Daily number of vaccination for all ages (2nd dose)', 'fontsize', 20)
set(gca, 'fontsize', 15);
ax = gca;
[ax.Children.Marker] = deal('.');
[ax.Children.MarkerSize] = deal(15);
saveas(gca, sprintf('%s/vaccine_number.eps', results_path), 'epsc');

% Vaccination number by age
ages = {'0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70-79', '80+'};
figure('pos', [10 10 1600 900]);
for i = 1:9
    subplot(3, 3, i);
    hold on;
    plot(date, vaccine_1st(1:n, i));
    hold off;
    ylim([0, 2.5e5]);
    xlabel('Date')
    ylabel('No. vaccination')
    title(ages{i});
    set(gca, 'fontsize', 15)
    ax = gca;
    [ax.Children.Marker] = deal('.');
    [ax.Children.MarkerSize] = deal(15);
end
sgtitle('Daily number of vaccination by age (1st dose)', 'fontsize', 20)
saveas(gca, sprintf('%s/vaccine_number_by_age_1st.eps', results_path), 'epsc');

figure('pos', [10 10 1600 900]);
for i = 1:9
    subplot(3, 3, i);
    hold on;
    plot(date, vaccine_2nd(1:n, i));
    hold off;
    ylim([0, 2e5]);
    xlabel('Date')
    ylabel('No. vaccination')
    title(ages{i});
    set(gca, 'fontsize', 15)
    ax = gca;
    [ax.Children.Marker] = deal('.');
    [ax.Children.MarkerSize] = deal(15);
end
sgtitle('Daily number of vaccination by age (2nd dose)', 'fontsize', 20)
saveas(gca, sprintf('%s/vaccine_number_by_age_2nd.eps', results_path), 'epsc');

% Vaccine efficacy
figure('pos', [10 10 1600 900]);
hold on;
plot(date, vaccine_eff(1:n, 1));
plot(date, vaccine_eff(1:n, 2));
hold off;
xlabel('Date')
ylabel('Efficacy (%)');
legend('1st Dose', '2nd Dose', 'location', 'northwest');
title('Daily vaccine efficacy', 'fontsize', 20)
set(gca, 'fontsize', 15);
ax = gca;
[ax.Children.Marker] = deal('.');
[ax.Children.MarkerSize] = deal(15);
saveas(gca, sprintf('%s/vaccine_efficacy.eps', results_path), 'epsc');
