function val = delta_effect(t, delta_prop, delta_effect)
val = 0;
tspan = [0:length(delta_prop)-1, Inf];
for i = 1:length(delta_prop)
    val = val + ((t >= tspan(i)) & (t < tspan(i+1))) * delta_prop(i);
end

% If delta proportion is 0, then multiply beta by 1. If not, multiply beta
% by `val`
if val == 0
    val = 1;
else
    val = val * delta_effect;
end

end