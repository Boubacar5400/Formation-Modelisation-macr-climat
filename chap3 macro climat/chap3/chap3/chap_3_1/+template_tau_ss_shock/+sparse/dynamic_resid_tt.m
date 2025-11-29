function [T_order, T] = dynamic_resid_tt(y, x, params, steady_state, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 11
    T = [T; NaN(11 - size(T, 1), 1)];
end
T(1) = y(16)^params(5);
T(2) = (1-y(20))^(1-params(5));
T(3) = T(1)*T(2);
T(4) = params(5)*T(3)^(-params(3));
T(5) = y(16)^(params(5)-1);
T(6) = params(7)^(params(5)*(1-params(3))-1);
T(7) = (y(3)/params(7))^params(1);
T(8) = x(1)*T(7);
T(9) = y(20)^(1-params(1));
T(10) = y(16)*(1-params(5))/params(5)/(1-y(20));
T(11) = T(6)*params(2)*y(38)/(1+y(43));
end
