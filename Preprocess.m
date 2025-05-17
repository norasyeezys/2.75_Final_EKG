% Preprocessing script for Arduino CSV ECG data
inputFile = 'avx.csv';          % Input file
outputFile = 'avx_processed.csv'; % Output file

% Load CSV
data = readtable(inputFile);

% Rename column if needed (depends on import behavior)
if any(strcmp(data.Properties.VariableNames, 'Time_s_'))
    time_col = 'Time_s_';
elseif any(strcmp(data.Properties.VariableNames, 'Time_s'))
    time_col = 'Time_s';
elseif any(strcmp(data.Properties.VariableNames, 'Time'))
    time_col = 'Time';
elseif any(strcmp(data.Properties.VariableNames, 'Time_(s)'))
    time_col = 'Time_(s)';
else
    time_col = 'Time_x'; % Default fallback
end

% Process Time column
raw_time = data.(time_col);
scaled_time = raw_time / 1000;
adjusted_time = scaled_time - scaled_time(1); % Start from 0

% Replace original time column with adjusted one
data.(time_col) = adjusted_time;

% Save to new CSV
writetable(data, outputFile);

fprintf('Preprocessing complete. Saved to %s\n', outputFile);
