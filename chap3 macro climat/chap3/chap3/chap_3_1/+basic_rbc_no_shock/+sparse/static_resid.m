function [residual, T_order, T] = static_resid(y, x, params, T_order, T)
if nargin < 5
    T_order = -1;
    T = NaN(9, 1);
end
[T_order, T] = basic_rbc_no_shock.sparse.static_resid_tt(y, x, params, T_order, T);
residual = NaN(15, 1);
    residual(1) = (y(8)) - (T(1)*T(4)*T(5));
    residual(2) = (y(8)*(1+x(3))/(1+x(2))) - (T(7)*(y(6)*(1-y(14))+(1-params(4))*(1+y(15))));
    residual(3) = (y(7)) - (T(8)*T(9));
    residual(4) = (y(7)) - (y(1)+y(2)+y(9));
    residual(5) = (y(2)) - (y(3)-y(3)*(1-params(4))/params(7));
    residual(6) = (y(6)/(1-x(7))) - (params(7)*y(7)*params(1)/y(3));
    residual(7) = (y(4)*(1+x(5))/(1-x(7))) - (y(7)*(1-params(1))/y(5));
    residual(8) = (y(4)) - ((1+x(2))*y(1)*(1-params(5))/params(5)/(1-y(5))/(1-x(4)));
    residual(9) = (y(9)) - (y(1)*x(2)+x(3)*y(2)+y(5)*y(4)*(x(5)+x(4))+y(3)*y(6)*x(6)/params(7)+y(7)*x(7)+x(8));
    residual(10) = (y(10)) - (y(7)*y(12));
    residual(11) = (y(11)) - (y(7)*y(12)+y(11)*(1-params(8))/params(7));
    residual(12) = (log(y(12))) - ((1-params(9))*log(params(10))+log(y(12))*params(9));
    residual(13) = (y(13)) - (x(2));
    residual(14) = (y(14)) - (x(6));
    residual(15) = (y(15)) - (x(3));
end
