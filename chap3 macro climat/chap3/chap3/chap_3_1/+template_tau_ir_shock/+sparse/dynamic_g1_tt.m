function [T_order, T] = dynamic_g1_tt(y, x, params, steady_state, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = template_tau_ir_shock.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
T_order = 1;
if size(T, 1) < 13
    T = [T; NaN(13 - size(T, 1), 1)];
end
T(12) = getPowerDeriv(T(3),(-params(3)),1);
T(13) = (-(getPowerDeriv(1-y(20),1-params(5),1)));
end
