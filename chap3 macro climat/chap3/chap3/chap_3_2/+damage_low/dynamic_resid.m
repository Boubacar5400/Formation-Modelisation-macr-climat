function residual = dynamic_resid(T, y, x, params, steady_state, it_, T_flag)
% function residual = dynamic_resid(T, y, x, params, steady_state, it_, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T             [#temp variables by 1]     double   vector of temporary terms to be filled by function
%   y             [#dynamic variables by 1]  double   vector of endogenous variables in the order stored
%                                                     in M_.lead_lag_incidence; see the Manual
%   x             [nperiods by M_.exo_nbr]   double   matrix of exogenous variables (in declaration order)
%                                                     for all simulation periods
%   steady_state  [M_.endo_nbr by 1]         double   vector of steady state values
%   params        [M_.param_nbr by 1]        double   vector of parameter values in declaration order
%   it_           scalar                     double   time period for exogenous variables for which
%                                                     to evaluate the model
%   T_flag        boolean                    boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   residual
%

if T_flag
    T = damage_low.dynamic_resid_tt(T, y, x, params, steady_state, it_);
end
residual = zeros(13, 1);
    residual(1) = (y(12)) - (T(2)*T(4)*T(5));
    residual(2) = (y(12)) - (T(7)*(1+y(17)-params(4)));
    residual(3) = (y(7)) - (y(4)*(1-params(5))/params(5)/(1-y(8)));
    residual(4) = (y(11)) - (T(9)*T(10));
    residual(5) = (y(16)) - (params(10)*exp((-params(11))*(y(14)-params(12))));
    residual(6) = (y(10)) - (y(11)*y(16));
    residual(7) = (y(10)) - (y(4)+y(5));
    residual(8) = (y(5)) - (y(6)-y(1)*(1-params(4))/params(7));
    residual(9) = (y(9)) - (params(7)*params(1)*y(10)/y(1));
    residual(10) = (y(7)) - ((1-params(1))*y(10)/y(8));
    residual(11) = (y(15)) - ((1-params(9))*params(13)+params(9)*y(3));
    residual(12) = (y(13)) - (y(10)*y(15));
    residual(13) = (y(14)) - (y(13)+(1-params(8))/params(7)*y(2));

end
