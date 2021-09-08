function sol = solve_covid19(parameter)
%% Assign parameters
y0_ = parameter.y0;
beta_ = parameter.beta;
tspan_ = parameter.tspan;
contact_ = parameter.contact;
kappa_ = parameter.kappa;
alpha_ = parameter.alpha;
gamma_ = parameter.gamma;
delta_prop_ = parameter.delta_prop;
delta_ = parameter.delta;
vac_1st_ = parameter.vac_1st;
vac_2nd_ = parameter.vac_2nd;
vac_eff_ = parameter.vac_eff;
dt_ = parameter.dt;

%% Solve model using difference equation
% Define the number of groups
num_grp = size(contact_, 1);

% Memory allocation
S = zeros(length(tspan_)+1, num_grp);
E = zeros(length(tspan_)+1, num_grp);
I = zeros(length(tspan_)+1, num_grp);
H = zeros(length(tspan_)+1, num_grp);
R = zeros(length(tspan_)+1, num_grp);
V = zeros(length(tspan_)+1, num_grp);

% Initial state
S(1, :) = y0_(1:num_grp); E(1, :) = y0_(num_grp+1:2*num_grp);
I(1, :) = y0_(2*num_grp+1:3*num_grp); H(1, :) = y0_(3*num_grp+1:4*num_grp);
R(1, :) = y0_(4*num_grp+1:5*num_grp); V(1, :) = zeros(1, num_grp);
t = 0;
for i = 1:length(tspan_)
    % Number of doses for 1st and 2nd vaccination at time t
    num_dose1 = vac_1st_(i, :);
    num_dose2 = vac_2nd_(i, :);
    % Vaccine efficacy at time t
    vac_eff_t = vac_eff_(i, :);
    if vac_eff_t(2) == 0
        vac_1st_fail = 0;
    else
        vac_1st_fail = (1 - vac_eff_t(1))/vac_eff_t(2);
    end
    % Delta effect at time t
    delta_prop_t = delta_prop_(i);
    if delta_prop_t == 0
        delta_effect_t = 1;
    else
        delta_effect_t = delta_prop_t * delta_;
    end
    for j = 1:1/dt_
        % Time stamp
        t = t + dt_;
        % Beta at time t
        beta_t = beta_ .* contact_ .* delta_effect_t .* social_distance(t);
        % FOI at time t for I and V
        FOI_I = (beta_t * I(i, :)')';
        FOI_V = (beta_t * V(i, :)')';
        % Current index and next index
        ic = (i-1)/dt_ + j;
        in = ic + 1;
        % Update states
        S(in, :) = S(ic, :) + dt_ * (- FOI_I .* S(ic, :) - num_dose1 .* vac_eff_t(2));
        E(in, :) = E(ic, :) + dt_ * (FOI_I .* S(ic, :) + vac_1st_fail * FOI_V .* V(ic, :) - kappa_ .* E(ic, :));
        I(in, :) = I(ic, :) + dt_ * (kappa_ .* E(ic, :) - alpha_ .* I(ic, :));
        H(in, :) = H(ic, :) + dt_ * (alpha_ .* I(ic, :) - gamma_ .* H(ic, :));
        R(in, :) = R(ic, :) + dt_ * (gamma_ .* H(ic, :) + num_dose2 .* vac_eff_t(2));
        V(in, :) = V(ic, :) + dt_ * (num_dose1 .* vac_eff_t(2) - vac_1st_fail * FOI_V .* V(ic, :) - num_dose2 .* vac_eff_t(2));
    end
end

%% Merge states
sol = [S, E, I, H, R, V];
end
