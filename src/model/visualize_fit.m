function [] = visualize_fit(data, params, theta, date, results_path)
%% Assign Parameters
names = params(:, 1);
isEstimated = cell2mat(params(:, 3));
params(isEstimated, 2) = num2cell(theta);
for i = 1:size(params, 1)
    cmd_string = sprintf('%s_ = params{%d, 2};', names{i}, i);
    eval(cmd_string);
end

%% Solve the Model
parameter = params2parameter(params);
sol = solve_covid19(parameter);

daily_confirmed = compute_daily_confirmed(parameter, sol);
% daily_deaths = compute_daily_death(parameter, sol);
daily_severe = compute_daily_hospitalized(parameter, sol);

%% Compute time-dependent reproduction number
% Rt = compute_rep_num(parameter, sol);

%% Load Seoul, Gyeonggi confirmed cases
filename = '../data/covid19/total_confirmed_case_seoul_gyeonggi.csv';
data_after_Sep = readmatrix(filename, 'Delimiter', ',', 'range', 'D2:D247');

%% Visualize daily confirmed cases, deaths, severe cases
figure('pos', [10 10 1100 900]);
hold on;
plot(date, sum(daily_confirmed, 2), 'linewidth', 2);
plot(date(1:length(data)), sum(data, 2), ':*');
if length(date) > 199
    plot(date(length(data)+1:length(data_after_Sep)), data_after_Sep(length(data)+1:end), ':*')
    legend('Model', 'Data (before 9/1)', 'Data (after 9/1)', 'location', 'northwest')
else
    legend('Model', 'Data', 'location', 'northwest')
end
hold off;
ylim([0, inf]);
xlabel('Date');
ylabel('Cases');
title('Confirmed')
set(gca, 'fontsize', 15);

subplot(1, 3, 2)
plot(date, sum(daily_deaths, 2), 'linewidth', 2);
ylim([0, inf]);
legend('Model', 'location', 'northwest')
xlabel('Date');
ylabel('Cases');
title('Deaths')
set(gca, 'fontsize', 15);

subplot(1, 3, 3)
plot(date, sum(daily_severe, 2), 'linewidth', 2);
ylim([0, inf]);
legend('Model', 'location', 'northwest')
xlabel('Date');
ylabel('Cases');
title('Severe')
set(gca, 'fontsize', 15);
sgtitle('Daily incident cases for all ages', 'fontsize', 20)

saveas(gca, sprintf('%s/daily_all_age.eps', results_path), 'epsc');

%% Visualize cumulative confirmed cases, deaths, severe cases
figure('pos', [10 10 1600 400]);
subplot(1, 3, 1)
hold on;
plot(date, cumsum(sum(daily_confirmed, 2)), 'linewidth', 2);
plot(date(1:length(data)), cumsum(sum(data, 2)), ':*', 'linewidth', 2);
if length(date) > 199
    plot(date(length(data)+1:length(data_after_Sep)), sum(data, 'all') + cumsum(data_after_Sep(length(data)+1:end)), ':*')
    legend('Model', 'Data (before 9/1)', 'Data (after 9/1)', 'location', 'northwest')
else
    legend('Model', 'Data', 'location', 'northwest')
end
hold off;
ylim([0, inf]);
xlabel('Date');
ylabel('Cases');
title('Confirmed')
set(gca, 'fontsize', 15);

subplot(1, 3, 2)
plot(date, cumsum(sum(daily_deaths, 2)), 'linewidth', 2);
ylim([0, inf]);
legend('Model', 'location', 'northwest')
xlabel('Date');
ylabel('Cases');
title('Deaths')
set(gca, 'fontsize', 15);

subplot(1, 3, 3)
plot(date, cumsum(sum(daily_severe, 2)), 'linewidth', 2);
ylim([0, inf]);
legend('Model', 'location', 'northwest')
xlabel('Date');
ylabel('Cases');
title('Severe')
set(gca, 'fontsize', 15);
sgtitle('Cumulative cases for all ages', 'fontsize', 20)

saveas(gca, sprintf('%s/cumul_all_age.eps', results_path), 'epsc');

%% Visualize daily confirmed cases, deaths, and severe by age
ages = {'0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70-79', '80+'};
% Daily confirmed cases
figure('pos', [10 10 1400 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    hold on;
    plot(date, daily_confirmed(:, i), 'linewidth', 1.5);
    plot(date(1:length(data)), data(:, i), ':*', 'markersize', 1.5);
    hold off;
    ylim([0, inf]);
    legend('Model', 'Data', 'location', 'northwest')
    title(ages{i})
    set(gca, 'fontsize', 15);
end
sgtitle('Daily confirmed cases by age', 'fontsize', 20)
saveas(gca, sprintf('%s/daily_confirmed_by_age.eps', results_path), 'epsc');

% Cumulative confirmed cases
figure('pos', [10 10 1400 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    hold on;
    plot(date, cumsum(daily_confirmed(:, i)), 'linewidth', 1.5);
    plot(date(1:length(data)), cumsum(data(:, i)), ':*', 'markersize', 1.5);
    hold off;
    ylim([0, inf]);
    xlabel('Date');
    ylabel('Cases');
    legend('Model', 'Data', 'location', 'northwest')
    title(ages{i})
    set(gca, 'fontsize', 15);
end
sgtitle('Cumulative confirmed cases by age', 'fontsize', 20)
saveas(gca, sprintf('%s/cumul_confirmed_by_age.eps', results_path), 'epsc');

% Daily Deaths
figure('pos', [10 10 1400 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    plot(date, daily_deaths(:, i), 'linewidth', 1.5);
    ylim([0, inf]);
    xlabel('Date');
    ylabel('Cases');
    title(ages{i})
    set(gca, 'fontsize', 15);
end
sgtitle('Daily deaths by age', 'fontsize', 20)
saveas(gca, sprintf('%s/daily_deaths_by_age.eps', results_path), 'epsc');

% Cumulative deaths
figure('pos', [10 10 1400 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    plot(date, cumsum(daily_deaths(:, i)), 'linewidth', 1.5);
    ylim([0, inf]);
    xlabel('Date');
    ylabel('Cases');
    title(ages{i})
    set(gca, 'fontsize', 15);
end
sgtitle('Cumulative deaths by age', 'fontsize', 20)
saveas(gca, sprintf('%s/cumul_deaths_by_age.eps', results_path), 'epsc');

% Daily severe cases
figure('pos', [10 10 1400 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    plot(date, daily_severe(:, i), 'linewidth', 1.5);
    ylim([0, inf]);
    xlabel('Date');
    ylabel('Cases');
    title(ages{i})
    set(gca, 'fontsize', 15);
end
sgtitle('Daily severe cases by age', 'fontsize', 20)
saveas(gca, sprintf('%s/daily_severe_by_age.eps', results_path), 'epsc');

% Cumulative severe cases
figure('pos', [10 10 1400 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    plot(date, cumsum(daily_severe(:, i)), 'linewidth', 1.5);
    ylim([0, inf]);
    xlabel('Date');
    ylabel('Cases');
    title(ages{i})
    set(gca, 'fontsize', 15);
end
sgtitle('Cumulative severe cases by age', 'fontsize', 20)
saveas(gca, sprintf('%s/cumul_severe_by_age.eps', results_path), 'epsc');

%% Plot reproduction number
figure('pos', [10 10 1600 900]);
hold on;
plot(date, Rt(1:1/dt_:end-1), 'linewidth', 2);
yline(1, '-k');
hold off;
xlabel('Date')
ylabel('R_t')
ylim([0, 3])
title('Time-dependent reproduction number')
set(gca, 'fontsize', 20);
saveas(gca, sprintf('%s/rep_num.eps', results_path), 'epsc');

%% Find the scaling factor k of number of severe illness to compare with used proportion of the number of beds
used_beds = readmatrix('../data/covid19/covid19_beds.xlsx', 'range', 'H2:H40');
date_beds = datetime(2021, 9, 4):datetime(2021, 10, 12);
start_day = caldays(between(datetime(2021, 2, 15), datetime(2021, 9, 4), 'Days'));
final_day = caldays(between(datetime(2021, 2, 15), datetime(2021, 10, 12), 'Days'));
day_beds = start_day:final_day;
pred = sum(daily_severe(day_beds+1, :), 2);
model = @(k, x) k .* x;
k = nlinfit(pred, used_beds, model, 0.01);

%% Plot the predicted proportion of the number of beds
figure('pos', [10 10 1600 900]);
hold on;
plot(date, k * sum(daily_severe, 2), 'linewidth', 2);
plot(date_beds, used_beds, ':*');
hold off;
xlabel('Date')
ylabel('Proportion')
ylim([0, 1])
legend('Model', 'Data')
title('Proportion of used beds')
set(gca, 'fontsize', 20);
saveas(gca, sprintf('%s/prop_beds.eps', results_path), 'epsc');
