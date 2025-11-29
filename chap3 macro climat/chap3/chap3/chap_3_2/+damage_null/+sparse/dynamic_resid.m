function [residual, T_order, T] = dynamic_resid(y, x, params, steady_state, T_order, T)
if nargin < 6
    T_order = -1;
    T = NaN(10, 1);
end
[T_order, T] = damage_null.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
residual = NaN(13, 1);
    residual(1) = (y(22)) - (T(2)*T(4)*T(5));
    residual(2) = (y(22)) - (T(7)*(1+y(32)-params(4)));
    residual(3) = (y(17)) - (y(14)*(1-params(5))/params(5)/(1-y(18)));
    residual(4) = (y(21)) - (T(9)*T(10));
    residual(5) = (y(26)) - (params(10)*exp((-params(11))*(y(24)-params(12))));
    residual(6) = (y(20)) - (y(21)*y(26));
    residual(7) = (y(20)) - (y(14)+y(15));
    residual(8) = (y(15)) - (y(16)-y(3)*(1-params(4))/params(7));
    residual(9) = (y(19)) - (params(7)*params(1)*y(20)/y(3));
    residual(10) = (y(17)) - ((1-params(1))*y(20)/y(18));
    residual(11) = (y(25)) - ((1-params(9))*params(13)+params(9)*y(12));
    residual(12) = (y(23)) - (y(20)*y(25));
    residual(13) = (y(24)) - (y(23)+(1-params(8))/params(7)*y(11));
end
