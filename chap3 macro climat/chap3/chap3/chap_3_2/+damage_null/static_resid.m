function residual = static_resid(T, y, x, params, T_flag)
% function residual = static_resid(T, y, x, params, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T         [#temp variables by 1]  double   vector of temporary terms to be filled by function
%   y         [M_.endo_nbr by 1]      double   vector of endogenous variables in declaration order
%   x         [M_.exo_nbr by 1]       double   vector of exogenous variables in declaration order
%   params    [M_.param_nbr by 1]     double   vector of parameter values in declaration order
%                                              to evaluate the model
%   T_flag    boolean                 boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   residual
%

if T_flag
    T = damage_null.static_resid_tt(T, y, x, params);
end
residual = zeros(13, 1);
    residual(1) = (y(9)) - (T(1)*T(4)*T(5));
    residual(2) = (y(9)) - (T(7)*(1+y(6)-params(4)));
    residual(3) = (y(4)) - (y(1)*(1-params(5))/params(5)/(1-y(5)));
    residual(4) = (y(8)) - (T(8)*T(9));
    residual(5) = (y(13)) - (params(10)*exp((-params(11))*(y(11)-params(12))));
    residual(6) = (y(7)) - (y(8)*y(13));
    residual(7) = (y(7)) - (y(1)+y(2));
    residual(8) = (y(2)) - (y(3)-y(3)*(1-params(4))/params(7));
    residual(9) = (y(6)) - (params(7)*params(1)*y(7)/y(3));
    residual(10) = (y(4)) - ((1-params(1))*y(7)/y(5));
    residual(11) = (y(12)) - ((1-params(9))*params(13)+y(12)*params(9));
    residual(12) = (y(10)) - (y(7)*y(12));
    residual(13) = (y(11)) - (y(10)+y(11)*(1-params(8))/params(7));

end
