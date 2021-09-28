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
sd_1st_ = parameter.sd_1st;
sd_2nd_ = parameter.sd_2nd;
sd_3rd_ = parameter.sd_3rd;
school_ = parameter.school;

%% Solve model using difference equation
% Define the number of groups
num_grp = size(contact_, 1);

% Memory allocation
S = zeros(length(tspan_)/dt_+1, num_grp);
V1 = zeros(length(tspan_)/dt_+1, num_grp);
V2 = zeros(length(tspan_)/dt_+1, num_grp);
E = zeros(length(tspan_)/dt_+1, num_grp);
Ev1 = zeros(length(tspan_)/dt_+1, num_grp);
Ev2 = zeros(length(tspan_)/dt_+1, num_grp);
I = zeros(length(tspan_)/dt_+1, num_grp);
Iv1 = zeros(length(tspan_)/dt_+1, num_grp);
Iv2 = zeros(length(tspan_)/dt_+1, num_grp);
H = zeros(length(tspan_)/dt_+1, num_grp);
R = zeros(length(tspan_)/dt_+1, num_grp);

% Initial state
S(1, :) = y0_(1:num_grp); E(1, :) = y0_(num_grp+1:2*num_grp);
I(1, :) = y0_(2*num_grp+1:3*num_grp); H(1, :) = y0_(3*num_grp+1:4*num_grp);
R(1, :) = y0_(4*num_grp+1:5*num_grp);
V1(1, :) = zeros(1, num_grp); V2(1, :) = zeros(1, num_grp);
Ev1(1, :) = zeros(1, num_grp); Ev2(1, :) = zeros(1, num_grp);
Iv1(1, :) = zeros(1, num_grp); Iv2(1, :) = zeros(1, num_grp);
t = 0;

% History of negative flag
neg_flag_S_hist = false(1, num_grp);
neg_flag_V1_hist = false(1, num_grp);
neg_flag_S = false(1, num_grp);
neg_flag_V1 = false(1, num_grp);
while i < length(tspan_)
    % Update loop counter
    i = i + 1;
    % Number of doses for 1st and 2nd vaccination at time t
    num_dose1 = vac_1st_(i, :);
    num_dose2 = vac_2nd_(i, :);
    % Vaccine efficacy at time t
    vac_eff_t = vac_eff_(i, :);
    % Delta effect at time t
    delta_prop_t = delta_prop_(i);
    if delta_prop_t == 0
        delta_effect_t = 1;
    else
        delta_effect_t = 1 - delta_prop_t + delta_prop_t * delta_;
    end
    for j = 1:1/dt_
        % Time stamp
        t = t + dt_;
        % School effect
        contact_temp = contact_;
        contact_temp(2, 2) = contact_(2, 2) .* school_effect(t, school_);
        % Beta at time t
        beta_t = beta_ .* contact_temp .* delta_effect_t .* social_distance(t, sd_1st_, sd_2nd_, sd_3rd_);
        % Current index and next index
        ic = (i-1)/dt_ + j;
        in = ic + 1;
        % FOI at time t for I and V
        FOI = (beta_t * (I(ic, :) + Iv1(ic, :) + Iv2(ic, :))')';
        % Update states
        S(in, :) = S(ic, :) + dt_ * (- FOI .* S(ic, :) - num_dose1);
        V1(in, :) = V1(ic, :) + dt_ * (num_dose1 - (1 - vac_eff_t(1)) * FOI .* V1(ic, :) - num_dose2);
        V2(in, :) = V2(ic, :) + dt_ * (num_dose2 - (1 - vac_eff_t(2)) * FOI .* V2(ic, :));
        E(in, :) = E(ic, :) + dt_ * (FOI .* S(ic, :) - kappa_ .* E(ic, :));
        Ev1(in, :) = Ev1(ic, :) + dt_ * ((1 - vac_eff_t(1)) * FOI .* V1(ic, :) - kappa_ .* Ev1(ic, :));
        Ev2(in, :) = Ev2(ic, :) + dt_ * ((1 - vac_eff_t(2)) * FOI .* V2(ic, :) - kappa_ .* Ev2(ic, :));
        I(in, :) = I(ic, :) + dt_ * (kappa_ .* E(ic, :) - alpha_ .* I(ic, :));
        Iv1(in, :) = Iv1(ic, :) + dt_ * (kappa_ .* Ev1(ic, :) - alpha_ .* Iv1(ic, :));
        Iv2(in, :) = Iv2(ic, :) + dt_ * (kappa_ .* Ev2(ic, :) - alpha_ .* Iv2(ic, :));
        H(in, :) = H(ic, :) + dt_ * (alpha_ .* (I(ic, :) + Iv1(ic, :) + Iv2(ic, :)) - gamma_ .* H(ic, :));
        R(in, :) = R(ic, :) + dt_ * (gamma_ .* H(ic, :));
    end
end

%% Merge states
sol = [S, V1, V2, E, Ev1, Ev2, I, Iv1, Iv2, H, R];
end
