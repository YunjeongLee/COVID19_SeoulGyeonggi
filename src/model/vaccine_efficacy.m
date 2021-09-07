function val = vaccine_efficacy(t, vacc_eff)
val = zeros(1, 2);
tspan = [0:length(vacc_eff)-1, Inf];
for i = 1:length(vacc_eff)
    val = val + ((t >= tspan(i)) & (t < tspan(i+1))) * vacc_eff(i, :);
end
end