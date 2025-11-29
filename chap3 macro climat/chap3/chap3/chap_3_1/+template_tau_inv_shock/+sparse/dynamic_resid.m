function [residual, T_order, T] = dynamic_resid(y, x, params, steady_state, T_order, T)
if nargin < 6
    T_order = -1;
    T = NaN(11, 1);
end
[T_order, T] = template_tau_inv_shock.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
residual = NaN(15, 1);
    residual(1) = (y(23)) - (T(2)*T(4)*T(5));
    residual(2) = (y(23)*(1+x(3))/(1+x(2))) - (T(11)*(y(36)*(1-y(44))+(1-params(4))*(1+y(45))));
    residual(3) = (y(22)) - (T(8)*T(9));
    residual(4) = (y(22)) - (y(16)+y(17)+y(24));
    residual(5) = (y(17)) - (y(18)-y(3)*(1-params(4))/params(7));
    residual(6) = (y(21)/(1-x(7))) - (params(7)*y(22)*params(1)/y(3));
    residual(7) = (y(19)*(1+x(5))/(1-x(7))) - (y(22)*(1-params(1))/y(20));
    residual(8) = (y(19)) - ((1+x(2))*T(10)/(1-x(4)));
    residual(9) = (y(24)) - (y(16)*x(2)+x(3)*y(17)+y(20)*y(19)*(x(5)+x(4))+y(3)*y(21)*x(6)/params(7)+y(22)*x(7)+x(8));
    residual(10) = (y(25)) - (y(22)*y(27));
    residual(11) = (y(26)) - (y(22)*y(27)+(1-params(8))/params(7)*y(11));
    residual(12) = (log(y(27))) - ((1-params(9))*log(params(10))+params(9)*log(y(12)));
    residual(13) = (y(28)) - (x(2));
    residual(14) = (y(29)) - (x(6));
    residual(15) = (y(30)) - (x(3));
end
