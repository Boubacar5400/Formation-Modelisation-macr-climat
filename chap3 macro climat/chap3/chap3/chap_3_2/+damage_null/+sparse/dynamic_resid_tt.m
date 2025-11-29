function [T_order, T] = dynamic_resid_tt(y, x, params, steady_state, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 10
    T = [T; NaN(10 - size(T, 1), 1)];
end
T(1) = y(14)^params(5);
T(2) = (1-y(18))^(1-params(5));
T(3) = T(1)*T(2);
T(4) = params(5)*T(3)^(-params(3));
T(5) = y(14)^(params(5)-1);
T(6) = params(7)^(params(5)*(1-params(3))-1);
T(7) = params(2)*y(35)*T(6);
T(8) = (y(3)/params(7))^params(1);
T(9) = x(1)*T(8);
T(10) = y(18)^(1-params(1));
end
