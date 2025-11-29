function [T_order, T] = static_g1_tt(y, x, params, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = template_tau_k_shock.sparse.static_resid_tt(y, x, params, T_order, T);
T_order = 1;
if size(T, 1) < 11
    T = [T; NaN(11 - size(T, 1), 1)];
end
T(10) = getPowerDeriv(T(3),(-params(3)),1);
T(11) = (-(getPowerDeriv(1-y(5),1-params(5),1)));
end
