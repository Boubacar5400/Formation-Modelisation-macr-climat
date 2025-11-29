function [T_order, T] = static_resid_tt(y, x, params, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 9
    T = [T; NaN(9 - size(T, 1), 1)];
end
T(1) = (1-y(5))^(1-params(5));
T(2) = y(1)^params(5);
T(3) = T(1)*T(2);
T(4) = params(5)*T(3)^(-params(3));
T(5) = y(1)^(params(5)-1);
T(6) = params(7)^(params(5)*(1-params(3))-1);
T(7) = y(9)*params(2)*T(6);
T(8) = x(1)*(y(3)/params(7))^params(1);
T(9) = y(5)^(1-params(1));
end
