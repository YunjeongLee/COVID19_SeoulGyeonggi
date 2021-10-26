function val = social_distance(t, sd_1st, sd_2nd, sd_3rd, sd_4th)
if t < 136
    val = 1;
elseif (t >= 136) && (t < 147)
    val = sd_1st;
elseif (t >= 147) && (t < 259)
    val = sd_2nd;
else
    val = sd_3rd;
end
end