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
Rt = compute_rep_num(parameter, sol);

%% Load Seoul, Gyeonggi confirmed cases
filename = '../data/covid19/total_confirmed_case_seoul_gyeonggi.csv';
data_after_Sep = readmatrix(filename, 'Delimiter', ',', 'range', 'D2:D247');

%% Visualize daily confirmed cases, deaths, severe cases
figure('pos', [10 10 1000 600]);
hold on;
plot(date, sum(daily_confirmed, 2), 'linewidth', 2);
plot(date(1:length(data)), sum(data, 2), ':*');
if length(date) > 260
    plot(date(length(data)+1:length(data_after_Sep)), data_after_Sep(length(data)+1:end), ':*')
    legend('Model', 'Data (before 9/1)', 'Data (after 9/1)', 'location', 'northwest')
else
    legend('Model', 'Data', 'location', 'northwest')
end
hold off;
ylim([0, inf]);
xlabel('Date');
ylabel('Cases');
set(gca, 'fontsize', 40);

saveas(gca, sprintf('%s/incident_confirmed_all_age.eps', results_path), 'epsc');

%% Visualize cumulative confirmed cases, deaths, severe cases
figure('pos', [10 10 1000 600]);
hold on;
plot(date, cumsum(sum(daily_confirmed, 2)), 'linewidth', 2);
plot(date(1:length(data)), cumsum(sum(data, 2)), ':*', 'linewidth', 2);
if length(date) > 260
    plot(date(length(data)+1:length(data_after_Sep)), sum(data, 'all') + cumsum(data_after_Sep(length(data)+1:end)), ':*')
    legend('Model', 'Data (before 9/1)', 'Data (after 9/1)', 'location', 'northwest')
else
    legend('Model', 'Data', 'location', 'northwest')
end
hold off;
ylim([0, inf]);
xlabel('Date');
ylabel('Cases');
set(gca, 'fontsize', 40);
saveas(gca, sprintf('%s/cumul_confirmed_all_age.eps', results_path), 'epsc');

figure('pos', [10 10 1000 600]);
plot(date, cumsum(sum(daily_severe, 2)), 'linewidth', 2);
ylim([0, inf]);
legend('Model', 'location', 'northwest')
xlabel('Date');
ylabel('Cases');
set(gca, 'fontsize', 40);
saveas(gca, sprintf('%s/cumul_severe_all_age.eps', results_path), 'epsc');

%% Find the scaling factor k of number of severe illness to compare with used proportion of the number of beds
used_beds = readmatrix('../data/covid19/covid19_beds.xlsx', 'range', 'G2:G40');
date_beds = datetime(2021, 9, 4):datetime(2021, 10, 12);
start_day = caldays(between(datetime(2021, 2, 15), datetime(2021, 9, 4), 'Days'));
final_day = caldays(between(datetime(2021, 2, 15), datetime(2021, 10, 12), 'Days'));
day_beds = start_day:final_day;
pred = sum(daily_severe(day_beds+1, :), 2);
model = @(k, x) k .* x;
k = nlinfit(pred, used_beds, model, 0.01);

%% Plot the predicted proportion of the number of beds
figure('pos', [10 10 1000 600]);
hold on;
plot(date, k * sum(daily_severe, 2), 'linewidth', 2);
plot(date_beds, used_beds, ':*');
hold off;
ylim([0 inf]);
xlabel('Date')
ylabel('No. used beds')
legend('Model', 'Data', 'location', 'northwest')
set(gca, 'fontsize', 40);
saveas(gca, sprintf('%s/num_beds.eps', results_path), 'epsc');

%% Plot reproduction number
figure('pos', [10 10 1000 600]);
hold on;
plot(date, Rt(1:1/dt_:end-1), 'linewidth', 2);
yline(1, '-k');
hold off;
xlabel('Date')
ylabel('R_t')
ylim([0, 3])
set(gca, 'fontsize', 40);
saveas(gca, sprintf('%s/rep_num.eps', results_path), 'epsc');
