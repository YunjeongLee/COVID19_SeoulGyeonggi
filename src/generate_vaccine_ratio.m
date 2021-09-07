clear; close all; clc;

%% Read population data
filename = "../data/demographic/population_capital_2020.xlsx";
pop = sum(xlsread(filename), 2);

%% Compute ratio of population
% 65+
pop_65more = pop(14:end);
pop_ratio_65more = pop_65more/sum(pop_65more);

% 50-64
pop_50_64 = pop(11:13);
pop_ratio_50_64 = pop_50_64/sum(pop_50_64);

% 65-74
pop_65_74 = pop(14:15);
pop_ratio_65_74 = pop_65_74/sum(pop_65_74);

% 75+
pop_75more = pop(16:end);
pop_ratio_75_more = pop_75more/sum(pop_75more);

% 30-49
pop_30_49 = pop(7:10);
pop_ratio_30_49 = pop_30_49/sum(pop_30_49);

% 50-74
pop_50_74 = pop(11:15);
pop_ratio_50_74 = pop_50_74/sum(pop_50_74);

%% Read vaccination data (before 2021/05/08)
filename = "../data/vaccine/vaccination_total_dose_0508.xlsx";
vaccine_before_0508 = xlsread(filename);

%% Before 2021/03/27
% Split vaccination of 65+ into 65-69, 70-74, 75-79, ...
vaccine_before_0327 = vaccine_before_0508(1, :);
vaccine_65more = round(pop_ratio_65more' * vaccine_before_0327(end));

% Merge 80+
vaccine_65more = [vaccine_65more(1:3), sum(vaccine_65more(4:end))];
vaccine_before_0327 = [vaccine_before_0327(1:end-1), vaccine_65more];

% Change into 10 year interval
vaccine_before_0327 = [vaccine_before_0327(1:4), vaccine_before_0327(5:2:end-1) + vaccine_before_0327(6:2:end-1), vaccine_before_0327(end)];

% Compute ratio
vaccine_before_0327 = vaccine_before_0327/sum(vaccine_before_0327);

% Generate total vaccine ratio
rownames = datetime(2021, 2, 25):datetime(2021, 3, 27);
vaccine_1st = repmat(vaccine_before_0327, length(rownames), 1);
vaccine_2nd = repmat(vaccine_before_0327, length(rownames), 1);

%% 2021/03/28 to 2021/05/01
for i = 1:5
    vaccine_temp = vaccine_before_0508(2*i+2, :);
    
    % Split vaccination of 50+ into 50-54, 55-59, ...
    vaccine_50_64 = round(pop_ratio_50_64' .* vaccine_temp(4));
    vaccine_65_74 = round(pop_ratio_65_74' .* vaccine_temp(5));
    vaccine_75more = round(pop_ratio_75_more' .* vaccine_temp(6));
    
    % Merge 80+
    vaccine_75more = [vaccine_75more(1), sum(vaccine_75more(2:end))];
    temp = [vaccine_temp(1:3), vaccine_50_64, vaccine_65_74, vaccine_75more];
    
    % Change into 10 year interval
    temp = [temp(1:3), temp(4:2:end-1) + temp(5:2:end-1), temp(end)];
    
    % Compute ratio
    temp = temp/sum(temp);
    
    vaccine_1st = [vaccine_1st; repmat(temp, 7, 1)];
    vaccine_2nd = [vaccine_2nd; repmat(temp, 7, 1)];
end

%% 2021/05/02 to 2021/08/31 (1st dose)
filename = "../data/vaccine/vaccination_12dose_05030830.xlsx";
vaccine_after_0503 = readmatrix(filename, 'sheet', '1st dose', 'range', 'B2:H19');

% Change into weekly incident vaccination
vaccine_after_0503 = vaccine_after_0503(2:end, :) - vaccine_after_0503(1:end-1, :);

% Change into ratio
vaccine_after_0503 = vaccine_after_0503 ./ sum(vaccine_after_0503, 2);

% Extend to matrix using repmat
for i = 1:size(vaccine_after_0503, 1)
    if i == 1
        num_to_repeat = 9;
    elseif i == size(vaccine_after_0503, 1)
        num_to_repeat = 8;
    else
        num_to_repeat = 7;
    end
    
    vaccine_1st = [vaccine_1st; repmat(vaccine_after_0503(i, :), num_to_repeat, 1)];
    
end

% Add vaccination rate for 0-9 and 10-19
vaccine_1st = [zeros(size(vaccine_1st, 1), 2), vaccine_1st];

%% 2021/05/02 to 2021/06/28 (2nd dose)
filename = "../data/vaccine/vaccination_12dose_05170628.xlsx";
vaccine_before_0628 = readmatrix(filename, 'sheet', '2nd dose', 'range', 'B2:E8');

% Change into weekly incident vacccination
vaccine_before_0628 = vaccine_before_0628(2:end, :) - vaccine_before_0628(1:end-1, :);

for i = 1:size(vaccine_before_0628, 1)
    if i == 1
        num_to_repeat = 23;
    else
        num_to_repeat = 7;
    end
    
    vaccine_temp = vaccine_before_0628(i, :);
    
    % Split 30-49, 50-74 and 75+ into 30-34, 35-39, ...
    vaccine_30_49 = round(pop_ratio_30_49' * vaccine_temp(2));
    vaccine_50_74 = round(pop_ratio_50_74' * vaccine_temp(3));
    vaccine_75more = round(pop_ratio_75_more' * vaccine_temp(4));
    
    % Merge 80+
    vaccine_75more = [vaccine_75more(1), sum(vaccine_75more(2:end))];
    temp = [vaccine_temp(1), vaccine_30_49, vaccine_50_74, vaccine_75more];
    
    % Change into 10 year interval
    temp = [temp(1), temp(2:2:end-1) + temp(3:2:end-1), temp(end)];
    
    % Add new row to vaccine_2nd
    vaccine_2nd = [vaccine_2nd; repmat(temp, num_to_repeat, 1)];
end

%% 2021/06/29 to 2021/08/31 (2nd dose)
filename = "../data/vaccine/vaccination_12dose_05030830.xlsx";
vaccine_after_0503 = readmatrix(filename, 'sheet', '2nd dose', 'range', 'B11:H19');

% Change into weekly incident vaccination
vaccine_after_0503 = vaccine_after_0503(2:end, :) - vaccine_after_0503(1:end-1, :);

% Change into ratio
vaccine_after_0503 = vaccine_after_0503 ./ sum(vaccine_after_0503, 2);

% Extend to matrix using repmat
for i = 1:size(vaccine_after_0503, 1)
    if i == 1
        num_to_repeat = 14;
    elseif i == size(vaccine_after_0503, 1)
        num_to_repeat = 8;
    else
        num_to_repeat = 7;
    end
    
    vaccine_2nd = [vaccine_2nd; repmat(vaccine_after_0503(i, :), num_to_repeat, 1)];
    
end

% Add vaccination rate for 0-9 and 10-19
vaccine_2nd = [zeros(size(vaccine_2nd, 1), 2), vaccine_2nd];

%% Generate csv file
rownames = cellstr(datetime(2021, 2, 15, 'format', 'yyyy/MM/dd'):datetime(2021, 8, 31, 'format', 'yyyy/MM/dd'));
varnames = {'0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70-79', '80+'};

% Add zeros in front of 2021/02/25
vaccine_1st = [zeros(10, size(vaccine_1st, 2)); vaccine_1st];
vaccine_2nd = [zeros(10, size(vaccine_2nd, 2)); vaccine_2nd];

% Change into table
vaccine_1st = array2table(vaccine_1st, 'RowNames', rownames, 'VariableNames', varnames);
vaccine_2nd = array2table(vaccine_2nd, 'RowNames', rownames, 'VariableNames', varnames);

filename1 = "../data/vaccine/1st_dose_ratio_by_age.csv";
filename2 = "../data/vaccine/2nd_dose_ratio_by_age.csv";
writetable(vaccine_1st, filename1,'WriteRowNames',true);
writetable(vaccine_2nd, filename2,'WriteRowNames',true);