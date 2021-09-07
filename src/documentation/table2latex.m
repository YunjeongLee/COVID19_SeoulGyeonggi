function latex = table2latex(result_table, data_format)
% data
input.data = result_table;
% data format
input.dataFormat = data_format;
% generate latex
latex = latexTable_custom(input);
end