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
sd_1st_ = parameter.sd_1st;
sd_2nd_ = parameter.sd_2nd;
sd_3rd_ = parameter.sd_3rd;
school_ = parameter.school;

%% Find S and V
num_grp = size(contact_, 1);
S = sol(:, 1:num_grp);
V1 = sol(:, num_grp+1:2*num_grp);
V2 = sol(:, 2*num_grp+1:3*num_grp);

%% Compute time-dependent reproduction number
Rt = zeros(length(tspan_)/dt_, 1);
t = 0;
for i = 1:length(tspan_)
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
        % Current index
        ic = (i-1)/dt_ + j;
        % S and V at time t
        St = S(ic, :);
        V1t = V1(ic, :);
        V2t = V2(ic, :);
        % School effect
        contact_temp = contact_;
        contact_temp(2, 2) = contact_(2, 2) .* school_effect(t, school_);
        % Beta at time t
        beta_t = beta_ .* contact_temp .* delta_effect_t .* social_distance(t, sd_1st_, sd_2nd_, sd_3rd_);
        % Compute F
        F0_elm1 = beta_t .* St';
        F0_elm2 = (1 - vac_eff_t(1)) * beta_t .* V1t';
        F0_elm3 = (1 - vac_eff_t(2)) * beta_t .* V2t';
        F0 = [zeros(num_grp, 3*num_grp), F0_elm1, F0_elm1, F0_elm1, zeros(num_grp); ...
            zeros(num_grp, 3*num_grp), F0_elm2, F0_elm2, F0_elm2, zeros(num_grp); ...
            zeros(num_grp, 3*num_grp), F0_elm3, F0_elm3, F0_elm3, zeros(num_grp); ...
            zeros(4*num_grp, 7*num_grp)];
        V0 = [blkdiag(V0_elm1, V0_elm1, V0_elm1), zeros(3*num_grp, 4*num_grp); ...
            - blkdiag(V0_elm1, V0_elm1, V0_elm1), blkdiag(V0_elm2, V0_elm2, V0_elm2), zeros(3*num_grp, num_grp); ...
            zeros(num_grp, 3*num_grp), - alpha_ * eye(num_grp), - alpha_ * eye(num_grp), - alpha_ * eye(num_grp), gamma_ * eye(num_grp)];
        % Compute reproduction number at time t
        Rt(ic) = max(abs(eig(F0/V0)));
        % Time stamp
        t = t + dt_;
    end
end
end