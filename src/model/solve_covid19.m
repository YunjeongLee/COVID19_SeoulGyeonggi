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
sd_4th_ = parameter.sd_4th;
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
i = 0;
age_grp = {'0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70-79', '80+'};
fprintf('            |                     Susceptibles                    |                     1st Vaccinated\n');
fprintf('    Date    |  %s %s %s %s %s %s %s %s %s  |  %s %s %s %s %s %s %s %s %s \n', age_grp{:}, age_grp{:});
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
        % Initialize contact_temp
        contact_temp = contact_;
        % All merged contacts except school effect
        contact_temp = contact_temp .* delta_effect_t .* social_distance(t, sd_1st_, sd_2nd_, sd_3rd_, sd_4th_);
        % If full attendance & no mask, multiply different value
        if school_ ~= Inf
            contact_temp(2, 2) = contact_temp(2, 2) .* school_effect(t, school_);
        elseif (school_ == Inf) && (t >= 259)
            contact_temp(2, 2) = contact_temp(2, 2) * school_effect(t, 7.0721) ./ social_distance(t, sd_1st_, sd_2nd_, sd_3rd_, sd_4th_);
        end
        % Beta at time t
        beta_t = beta_ .* contact_temp;
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
        
        % Check if there are negative states
        if (any(S(in, :) < 0) || any(V1(in, :) < 0))
            neg_flag_S = (S(in, :) < 0);
            neg_flag_V1 = (V1(in, :) < 0);
            break
        end
    end
    % If there are negative states update vaccination number
    if (any(neg_flag_S) || any(neg_flag_V1))
        % Update vaccination number
        [vac_1st_, vac_2nd_, neg_flag_S_hist, neg_flag_V1_hist] = update_vaccine(vac_1st_, vac_2nd_, i, neg_flag_S, ...
            neg_flag_V1, neg_flag_S_hist, neg_flag_V1_hist);
        % Print current date and age group which have negative states
        current_date = datetime(2021, 2, 15, 'format', 'yyyy/MM/dd') + (i - 1);
        logical_str = {'X','O'};
        fprintf('%s  |   %s    %s     %s     %s     %s     %s     %s     %s    %s   |   %s    %s     %s     %s     %s     %s     %s     %s    %s\n', ...
            current_date, logical_str{neg_flag_S + 1}, logical_str{neg_flag_V1 + 1})
        % Reset flag
        neg_flag_S(:) = false;
        neg_flag_V1(:) = false;
        % Reset index
        i = i - 1;
        t = t - dt_ * j;
    end
end

%% Merge states
sol = [S, V1, V2, E, Ev1, Ev2, I, Iv1, Iv2, H, R];
end
