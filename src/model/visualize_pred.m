function [] = visualize_pred(data, params, theta, date, results_path)
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
daily_deaths = daily_confirmed .* cfr;
daily_severe = daily_confirmed .* severe;

%% Compute time-dependent reproduction number
Rt = compute_rep_num(parameter, sol);

%% Visualize daily confirmed cases, deaths, severe cases
figure('pos', [10 10 1600 400]);
subplot(1, 3, 1)
hold on;
plot(date, sum(daily_confirmed, 2), 'linewidth', 2);
plot(date(1:length(data)), sum(data, 2), ':*', 'markersize', 1.5);
hold off;
legend('Model', 'Data', 'location', 'northwest')
xlabel('Date');
ylabel('Cases');
title('Confirmed')
set(gca, 'fontsize', 15);

subplot(1, 3, 2)
plot(date, sum(daily_deaths, 2), 'linewidth', 2);
legend('Model', 'location', 'northwest')
xlabel('Date');
ylabel('Cases');
title('Deaths')
set(gca, 'fontsize', 15);

subplot(1, 3, 3)
plot(date, sum(daily_severe, 2), 'linewidth', 2);
legend('Model', 'location', 'northwest')
xlabel('Date');
ylabel('Cases');
title('Severe')
set(gca, 'fontsize', 15);
sgtitle('Daily incident cases for all ages', 'fontsize', 20)

saveas(gca, sprintf('%s/daily_all_age_pred.eps', results_path), 'epsc');

%% Visualize cumulative confirmed cases, deaths, severe cases
figure('pos', [10 10 1600 400]);
subplot(1, 3, 1)
hold on;
plot(date, cumsum(sum(daily_confirmed, 2)), 'linewidth', 2);
plot(date(1:length(data)), cumsum(sum(data, 2)), ':*', 'linewidth', 2, 'markersize', 1.5);
hold off;
legend('Model', 'Data', 'location', 'northwest')
xlabel('Date');
ylabel('Cases');
title('Confirmed')
set(gca, 'fontsize', 15);

subplot(1, 3, 2)
plot(date, cumsum(sum(daily_deaths, 2)), 'linewidth', 2);
legend('Model', 'location', 'northwest')
xlabel('Date');
ylabel('Cases');
title('Deaths')
set(gca, 'fontsize', 15);

subplot(1, 3, 3)
plot(date, cumsum(sum(daily_severe, 2)), 'linewidth', 2);
legend('Model', 'location', 'northwest')
xlabel('Date');
ylabel('Cases');
title('Severe')
set(gca, 'fontsize', 15);
sgtitle('Cumulative cases for all ages', 'fontsize', 20)

saveas(gca, sprintf('%s/cumul_all_age_pred.eps', results_path), 'epsc');

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
    legend('Model', 'Data', 'location', 'northwest')
    title(ages{i})
    set(gca, 'fontsize', 15);
end
sgtitle('Daily confirmed cases by age', 'fontsize', 20)
saveas(gca, sprintf('%s/daily_confirmed_by_age_pred.eps', results_path), 'epsc');

% Cumulative confirmed cases
figure('pos', [10 10 1400 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    hold on;
    plot(date, cumsum(daily_confirmed(:, i)), 'linewidth', 1.5);
    plot(date(1:length(data)), cumsum(data(:, i)), ':*', 'markersize', 1.5);
    hold off;
    xlabel('Date');
    ylabel('Cases');
    legend('Model', 'Data', 'location', 'northwest')
    title(ages{i})
    set(gca, 'fontsize', 15);
end
sgtitle('Cumulative confirmed cases by age', 'fontsize', 20)
saveas(gca, sprintf('%s/cumul_confirmed_by_age_pred.eps', results_path), 'epsc');

% Daily Deaths
figure('pos', [10 10 1400 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    plot(date, daily_deaths(:, i), 'linewidth', 1.5);
    xlabel('Date');
    ylabel('Cases');
    title(ages{i})
    set(gca, 'fontsize', 15);
end
sgtitle('Daily deaths by age', 'fontsize', 20)
saveas(gca, sprintf('%s/daily_deaths_by_age_pred.eps', results_path), 'epsc');

% Cumulative deaths
figure('pos', [10 10 1400 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    plot(date, cumsum(daily_deaths(:, i)), 'linewidth', 1.5);
    xlabel('Date');
    ylabel('Cases');
    title(ages{i})
    set(gca, 'fontsize', 15);
end
sgtitle('Cumulative deaths by age', 'fontsize', 20)
saveas(gca, sprintf('%s/cumul_deaths_by_age_pred.eps', results_path), 'epsc');

% Daily severe cases
figure('pos', [10 10 1400 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    plot(date, daily_severe(:, i), 'linewidth', 1.5);
    xlabel('Date');
    ylabel('Cases');
    title(ages{i})
    set(gca, 'fontsize', 15);
end
sgtitle('Daily severe cases by age', 'fontsize', 20)
saveas(gca, sprintf('%s/daily_severe_by_age_pred.eps', results_path), 'epsc');

% Cumulative severe cases
figure('pos', [10 10 1400 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    plot(date, cumsum(daily_severe(:, i)), 'linewidth', 1.5);
    xlabel('Date');
    ylabel('Cases');
    title(ages{i})
    set(gca, 'fontsize', 15);
end
sgtitle('Cumulative severe cases by age', 'fontsize', 20)
saveas(gca, sprintf('%s/cumul_severe_by_age_pred.eps', results_path), 'epsc');

%% Plot reproduction number
figure('pos', [10 10 1600 900]);
hold on;
plot(date, Rt(1:1/dt_:end-1), 'linewidth', 2);
yline(1, '-k');
hold off;
xlabel('Date')
ylabel('R_t')
ylim([0, 5])
title('Time-dependent reproduction number')
set(gca, 'fontsize', 20);
saveas(gca, sprintf('%s/rep_num_pred.eps', results_path), 'epsc');