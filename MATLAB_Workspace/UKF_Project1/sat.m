function satv = sat(v, minValue, maxValue)

satv = min(v, maxValue);
satv = max(satv, minValue);