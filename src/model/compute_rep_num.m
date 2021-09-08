function Rt = compute_rep_num(parameter, sol)
%% Assign parameters
beta_ = parameter.beta;
tspan_ = parameter.tspan;
contact_ = parameter.contact;
kappa_ = parameter.kappa;
alpha_ = parameter.alpha;
gamma_ = parameter.gamma;
delta_prop_ = parameter.delta_prop;
delta_ = parameter.delta_;
vac_eff_ = parameter.vac_eff;
dt_ = parameter.dt;

%% Find S and V
num_grp = size(contact_, 1);
S = sol(:, 1:num_grp);
V = sol(:, 5*num_grp:end);

%% Compute time-dependent reproduction number
Rt = zeros(length(tspan_)/dt_, 1);
t = 0;
for i = 1:length(tspan_)-1
    for j = 1:1/dt_
    % Time stamp
    t = t + dt_;
    % S and V at time t
    St = S(i, :);
    Vt = V(i, :);
    % Beta at time t
    beta_t = beta_ .* contact_ .* delta_effect(t, delta_prop_, delta_) .* social_distance(t);
    % Vaccine efficacy at time t
    vac_eff_t = vaccine_efficacy(t, vac_eff_);
    % Compute F
    F = [zeros(num_grp), beta_t .* (St' + (1-vac_eff_t(1))/vac_eff_t(2) * Vt'), zeros(num_grp); ...
        zeros(2*num_grp, 3*num_grp)];
    V = [kappa_ * eye(num_grp), zeros(num_grp, 2*num_grp); ...
        - kappa_ * eye(num_grp), alpha_ * eye(num_grp), zeros(num_grp); ...
        zeros(num_grp), - alpha_ * eye(num_grp), gamma_ * eye(num_grp)];
    % Compute reproduction number at time t
    Rt(i) = max(abs(eig(F/V)));
    end
end
end