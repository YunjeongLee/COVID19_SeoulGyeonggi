function val = social_distance(t, sd_1st, sd_2nd)
if t < 136
    val = 1;
elseif (t >= 136) && (t < 147)
    val = sd_1st;
elseif (t >= 147)
    val = sd_2nd;
end
end