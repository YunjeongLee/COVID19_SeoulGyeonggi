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
rownames = datetime(2021, 2, 26):datetime(2021, 3, 27);
vaccine_1st = repmat(vaccine_before_0327, length(rownames), 1);

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
end

%% Add vaccination dose for 0-9 and 10-19 for 1st dose
vaccine_1st = [zeros(size(vaccine_1st, 1), 2), vaccine_1st];

%% Generate 2nd doses
vaccine_2nd = [zeros(7*4, size(vaccine_1st, 2)-2); vaccine_1st(1:length(vaccine_1st)-14, 3:end)];

%% 2021/05/02 to 2021/12/31 (1st dose)
filename = "../data/vaccine/vaccination_12dose_05031031.xlsx";
vaccine_after_0503 = readmatrix(filename, 'sheet', '1st dose', 'range', 'B2:J39');

% Change into weekly incident vaccination
vaccine_after_0503 = vaccine_after_0503(2:end, :) - vaccine_after_0503(1:end-1, :);

% Change into ratio
vaccine_after_0503 = vaccine_after_0503 ./ sum(vaccine_after_0503, 2);

% Extend to matrix using repmat
for i = 1:size(vaccine_after_0503, 1)
    if i == 1
        num_to_repeat = 8;
    elseif i == 26
        num_to_repeat = 6;
    elseif any(vaccine_after_0503(i, :) < 0)
        vaccine_1st = [vaccine_1st; repmat(vaccine_after_0503(i-1, :), 7, 1)];
        continue
    elseif i == size(vaccine_after_0503, 1)
        num_to_repeat = caldays(between(datetime(2022, 1, 8), datetime(2022, 5, 31), 'Days'));
    else
        num_to_repeat = 7;
    end
    
    vaccine_1st = [vaccine_1st; repmat(vaccine_after_0503(i, :), num_to_repeat, 1)];
    
end

%% 2021/05/16 to 2021/06/27 (2nd dose)
filename = "../data/vaccine/vaccination_12dose_05170628.xlsx";
vaccine_before_0628 = readmatrix(filename, 'sheet', '2nd dose', 'range', 'B2:E8');

% Change into weekly incident vacccination
vaccine_before_0628 = vaccine_before_0628(2:end, :) - vaccine_before_0628(1:end-1, :);

for i = 1:size(vaccine_before_0628, 1)
    if i == 1
        num_to_repeat = 8;
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
    
    % Compute ratio
    temp = temp/sum(temp);
    
    % Add new row to vaccine_2nd
    vaccine_2nd = [vaccine_2nd; repmat(temp, num_to_repeat, 1)];
end

%% Add vaccination dose for 0-9 and 10-19 for 2nd dose
vaccine_2nd = [zeros(size(vaccine_2nd, 1), 2), vaccine_2nd];

%% 2021/06/28 to 2022/01/15 (2nd dose)
filename = "../data/vaccine/vaccination_12dose_05031031.xlsx";
vaccine_after_0503 = readmatrix(filename, 'sheet', '2nd dose', 'range', 'B11:J39');

% Change into weekly incident vaccination
vaccine_after_0503 = vaccine_after_0503(2:end, :) - vaccine_after_0503(1:end-1, :);

% Change into ratio
vaccine_after_0503 = vaccine_after_0503 ./ sum(vaccine_after_0503, 2);

% Extend to matrix using repmat
for i = 1:size(vaccine_after_0503, 1)
    if i == 1
        num_to_repeat = 14;
    elseif i == 17
        num_to_repeat = 6;
    elseif any(vaccine_after_0503(i, :) < 0)
        vaccine_2nd = [vaccine_2nd; repmat(vaccine_after_0503(i-1, :), 7, 1)];
        continue
    else
        num_to_repeat = 7;
    end
    
    vaccine_2nd = [vaccine_2nd; repmat(vaccine_after_0503(i, :), num_to_repeat, 1)];
    
end

%% 2022/01/16 to 2022/05/31 (2nd dose)
% Get 1st dose ratio by age between 2021/12/19 and 2022/05/03
start = caldays(between(datetime(2021, 2, 26), datetime(2021, 12, 19)+1, 'Days'));
final = caldays(between(datetime(2021, 2, 26), datetime(2022, 5, 3)+1, 'Days'));
temp = vaccine_1st(start:final, :);

% Paste it to vaccine_2nd
vaccine_2nd = [vaccine_2nd; temp];

%% 3rd dose (2021/02/26 ~ 2022/05/31)
filename = "../data/vaccine/vaccination_12dose_05031031.xlsx";
vaccine_after_0503 = readmatrix(filename, 'sheet', '3rd dose', 'range', 'B2:J9');

% Change into weekly incident vaccination
vaccine_after_0503 = vaccine_after_0503(2:end, :) - vaccine_after_0503(1:end-1, :);

% Change into ratio
vaccine_after_0503 = vaccine_after_0503 ./ sum(vaccine_after_0503, 2);

vaccine_3rd = zeros(length(datetime(2021, 2, 26):datetime(2021, 10, 24)), size(vaccine_after_0503, 2));

% Extend to matrix using repmat
for i = 1:size(vaccine_after_0503, 1)
    if i == 1
        num_to_repeat = 41;
    else
        num_to_repeat = 7;
    end
    
    vaccine_3rd = [vaccine_3rd; repmat(vaccine_after_0503(i, :), num_to_repeat, 1)];
    
end

%% 2022/01/16 to 2022/05/31 (3rd dose)
% Get 2nd dose ratio by age between 2021/12/19 and 2022/05/03
start = caldays(between(datetime(2021, 10, 25), datetime(2022, 1, 16)+1, 'Days'));
final = caldays(between(datetime(2021, 10, 25), datetime(2022, 5, 31)+1, 'Days'));
temp = vaccine_2nd(start:final, :);

% Paste it to vaccine_3rd
vaccine_3rd = [vaccine_3rd; temp];

%% Generate csv file
rownames = cellstr(datetime(2021, 2, 15, 'format', 'yyyy/MM/dd'):datetime(2022, 5, 31, 'format', 'yyyy/MM/dd'));
varnames = {'0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70-79', '80+'};

% Add zeros in front of 2021/02/26
vaccine_1st = [zeros(11, size(vaccine_1st, 2)); vaccine_1st];
vaccine_2nd = [zeros(11, size(vaccine_2nd, 2)); vaccine_2nd];
vaccine_3rd = [zeros(11, size(vaccine_3rd, 2)); vaccine_3rd];

% Change into table
vaccine_1st = array2table(vaccine_1st, 'RowNames', rownames, 'VariableNames', varnames);
vaccine_2nd = array2table(vaccine_2nd, 'RowNames', rownames, 'VariableNames', varnames);

filename1 = "../data/vaccine/1st_dose_ratio_by_age.csv";
filename2 = "../data/vaccine/2nd_dose_ratio_by_age.csv";
writetable(vaccine_1st, filename1,'WriteRowNames',true);
writetable(vaccine_2nd, filename2,'WriteRowNames',true);