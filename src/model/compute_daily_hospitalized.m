function val = compute_daily_hospitalized(parameter, sol)
%% Assign parameters
alpha_ = parameter.alpha;
dt_ = parameter.dt;
severe_ = parameter.severe;
hosp_1st_ = parameter.hosp_1st;
hosp_2nd_ = parameter.hosp_2nd;
num_grp = size(parameter.contact, 1);
I = sol(:, 6*num_grp+1:7*num_grp);
Iv1 = sol(:, 7*num_grp+1:8*num_grp);
Iv2 = sol(:, 8*num_grp+1:9*num_grp);

%% Compute daily confirmed cases
dt_confirmed_I = alpha_ .* (I(1:end-1, :) + I(2:end, :))/2 * dt_;
dt_confirmed_Iv1 = alpha_ .* (Iv1(1:end-1, :) + Iv1(2:end, :))/2 * dt_;
dt_confirmed_Iv2 = alpha_ .* (Iv2(1:end-1, :) + Iv2(2:end, :))/2 * dt_;

num_days = length(dt_confirmed) * dt_;
multiplier4year = kron(eye(num_days), ones(1, 1/dt_));

val = multiplier4year * dt_confirmed;

end