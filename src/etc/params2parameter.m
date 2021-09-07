function parameter = params2parameter(params)

names = params(:, 1);
for i = 1:size(params, 1)
    cmd_string = sprintf('parameter.%s = params{%d, 2};', names{i}, i);
    eval(cmd_string);
end

end