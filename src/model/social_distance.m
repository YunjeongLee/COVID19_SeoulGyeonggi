function val = social_distance(t)
if t < 136
    val = 1;
elseif (t >= 136) && (t < 147)
    val = 1.685;
elseif (t >= 147)
    val = 1.685 * 0.67 * 0.33;
end
end