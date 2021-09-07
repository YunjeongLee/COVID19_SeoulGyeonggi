function val = compute_daily_confirmed(parameter, sol)
%% Assign parameters
alpha_ = parameter.alpha;
dt_ = parameter.dt;
num_grp = size(parameter.contact, 1);
I = sol(:, 2*num_grp+1:3*num_grp);

%% Compute daily confirmed cases
dt_confirmed = alpha_ .* (I(1:end-1, :) + I(2:end, :))/2 * dt_;

num_days = length(dt_confirmed) * dt;
multiplier4year = kron(eye(num_days), ones(1, 1/dt));

val = multiplier4year * dt_confirmed;

end