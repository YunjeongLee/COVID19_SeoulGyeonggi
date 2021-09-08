function [] = visualize_fit(data, params, theta, date, cfr, severe, results_path)
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
plot(date, sum(data, 2), ':*');
hold off;
legend('Model', 'Data')
xlabel('Date');
ylabel('Cases');
sgtitle('Confirmed')
set(gca, 'fontsize', 12);

subplot(1, 3, 2)
plot(date, sum(daily_deaths, 2), 'linewidth', 2);
legend('Model')
xlabel('Date');
ylabel('Cases');
sgtitle('Deaths')
set(gca, 'fontsize', 12);

subplot(1, 3, 3)
plot(date, sum(daily_severe, 2), 'linewidth', 2);
legend('Model')
xlabel('Date');
ylabel('Cases');
sgtitle('Severe')
set(gca, 'fontsize', 12);
title('Daily severe cases for all ages')

saveas(gca, sprintf('%s/daily_confirmed_all_age.eps', results_path), 'epsc');

%% Visualize cumulative confirmed cases, deaths, severe cases
figure('pos', [10 10 1600 400]);
subplot(1, 3, 1)
hold on;
plot(date, cumsum(sum(daily_confirmed, 2)));
plot(date, cumsum(sum(data, 2)), ':*', 'linewidth', 2);
hold off;
legend('Model', 'Data')
xlabel('Date');
ylabel('Cases');
sgtitle('Confirmed')
set(gca, 'fontsize', 12);

subplot(1, 3, 2)
plot(date, cumsum(sum(daily_deaths, 2)), 'linewidth', 2);
legend('Model')
xlabel('Date');
ylabel('Cases');
sgtitle('Deaths')
set(gca, 'fontsize', 12);

subplot(1, 3, 3)
plot(date, cumsum(sum(daily_severe, 2)), 'linewidth', 2);
legend('Model')
xlabel('Date');
ylabel('Cases');
sgtitle('Severe')
set(gca, 'fontsize', 12);
title('Cumulative cases for all ages')

saveas(gca, sprintf('%s/cumul_confirmed_all_age.eps', results_path), 'epsc');

%% Visualize daily confirmed cases, deaths, and severe by age
ages = {'0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70-79', '80+'};
% Daily confirmed cases
figure('pos', [10 10 900 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    hold on;
    plot(date, daily_confirmed(:, i), 'linewidth', 1.5);
    plot(date, data(:, i), ':*', 'markersize', 1.5);
    hold off;
    legend('Model', 'Data')
    sgtitle(ages{i})
    set(gca, 'fontsize', 12);
end
title('Daily confirmed cases by age')
saveas(gca, sprintf('%s/daily_confirmed_by_age.eps', results_path), 'epsc');

% Cumulative confirmed cases
figure('pos', [10 10 900 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    hold on;
    plot(date, cumsum(daily_confirmed(:, i)), 'linewidth', 1.5);
    plot(date, cumsum(data(:, i)), ':*', 'markersize', 1.5);
    hold off;
    xlabel('Date');
    ylabel('Cases');
    legend('Model', 'Data')
    sgtitle(ages{i})
    set(gca, 'fontsize', 12);
end
title('Cumulative confirmed cases by age')
saveas(gca, sprintf('%s/cumul_confirmed_by_age.eps', results_path), 'epsc');

% Daily Deaths
figure('pos', [10 10 900 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    plot(date, daily_deaths(:, i), 'linewidth', 1.5);
    xlabel('Date');
    ylabel('Cases');
    legend('Model', 'Data')
    sgtitle(ages{i})
    set(gca, 'fontsize', 12);
end
title('Daily confirmed cases by age')
saveas(gca, sprintf('%s/daily_deaths_by_age.eps', results_path), 'epsc');

% Cumulative deaths
figure('pos', [10 10 900 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    plot(date, cumsum(daily_deaths(:, i)), 'linewidth', 1.5);
    xlabel('Date');
    ylabel('Cases');
    legend('Model', 'Data')
    sgtitle(ages{i})
    set(gca, 'fontsize', 12);
end
title('Cumulative confirmed cases by age')
saveas(gca, sprintf('%s/cumul_deaths_by_age.eps', results_path), 'epsc');

% Daily severe cases
figure('pos', [10 10 900 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    plot(date, daily_severe(:, i), 'linewidth', 1.5);
    xlabel('Date');
    ylabel('Cases');
    legend('Model', 'Data')
    sgtitle(ages{i})
    set(gca, 'fontsize', 12);
end
title('Daily confirmed cases by age')
saveas(gca, sprintf('%s/daily_severe_by_age.eps', results_path), 'epsc');

% Cumulative severe cases
figure('pos', [10 10 900 900]);
for i = 1:size(contact_, 1)
    subplot(3, 3, i)
    plot(date, cumsum(daily_severe(:, i)), 'linewidth', 1.5);
    xlabel('Date');
    ylabel('Cases');
    legend('Model', 'Data')
    sgtitle(ages{i})
    set(gca, 'fontsize', 12);
end
title('Cumulative confirmed cases by age')
saveas(gca, sprintf('%s/cumul_severe_by_age.eps', results_path), 'epsc');

%% Plot reproduction number
figure('pos', [10 10 1600 900]);
hold on;
plot(date, Rt(2:1/dt_:end), 'linewidth', 2);
yline(1, '-k');
hold off;
xlabel('Date')
ylabel('R_t')
title('Time-dependent reproduction number')
set(gca, 'fontsize', 12);
saveas(gca, sprintf('%s/rep_num.eps', results_path), 'epsc');