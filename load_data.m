%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: data.xlsx
%    Worksheet: Sheet2
%
function [topic, student, date] = load_data()
    %% Import the data, extracting spreadsheet dates in Excel serial date format
    [~, ~, raw, dates] = xlsread('data.xlsx', 'Sheet2', '', '', @convertSpreadsheetExcelDates);
    raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
    strVectors = string(raw(:, [1, 2]));
    strVectors(ismissing(strVectors)) = '';
    dates = dates(:, 3);

    %% Replace non-numeric cells with NaN
    R = cellfun(@(x) ~isnumeric(x) && ~islogical(x), raw); % Find non-numeric cells
    raw(R) = {NaN}; % Replace non-numeric cells
    R = cellfun(@(x) ~isnumeric(x) && ~islogical(x), dates); % Find non-numeric cells
    dates(R) = {NaN}; % Replace non-numeric Excel dates with NaN

    %% Allocate imported array to column variable names
    topic = strVectors(:, 1);
    student = strVectors(:, 2);
    date = datetime([dates{:, 1}].', 'ConvertFrom', 'Excel');

    %% Clear temporary variables
    clearvars data raw dates stringVectors R;
end