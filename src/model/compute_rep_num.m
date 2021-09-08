function Rt = compute_rep_num(parameter, sol)
%% Assign parameters
beta_ = parameter.beta;
tspan_ = parameter.tspan;
contact_ = parameter.contact;
kappa_ = parameter.kappa;
alpha_ = parameter.alpha;
gamma_ = parameter.gamma;
delta_prop_ = parameter.delta_prop;
delta_ = parameter.delta;
vac_eff_ = parameter.vac_eff;
dt_ = parameter.dt;

%% Find S and V
num_grp = size(contact_, 1);
S = sol(:, 1:num_grp);
V = sol(:, 5*num_grp+1:end);

%% Compute time-dependent reproduction number
Rt = zeros(length(tspan_)/dt_+1, 1);
t = 0;
for i = 1:length(tspan_)-1
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
        % Current index
        ic = (i-1)/dt_ + j;
        % S and V at time t
        St = S(ic, :);
        Vt = V(ic, :);
        % Beta at time t
        beta_t = beta_ .* contact_ .* delta_effect_t .* social_distance(t);
        % Compute F
        F0 = [zeros(num_grp), beta_t .* (St' + vac_1st_fail * Vt'), zeros(num_grp); ...
            zeros(2*num_grp, 3*num_grp)];
        V0 = [kappa_ * eye(num_grp), zeros(num_grp, 2*num_grp); ...
            - kappa_ * eye(num_grp), alpha_ * eye(num_grp), zeros(num_grp); ...
            zeros(num_grp), - alpha_ * eye(num_grp), gamma_ * eye(num_grp)];
        % Compute reproduction number at time t
        Rt(ic) = max(abs(eig(F0/V0)));
    end
end
end