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
    T = template_tau_k_shock.dynamic_resid_tt(T, y, x, params, steady_state, it_);
end
residual = zeros(15, 1);
    residual(1) = (y(11)) - (T(2)*T(4)*T(5));
    residual(2) = (y(11)*(1+x(it_, 3))/(1+x(it_, 2))) - (T(11)*(y(19)*(1-y(22))+(1-params(4))*(1+y(23))));
    residual(3) = (y(10)) - (T(8)*T(9));
    residual(4) = (y(10)) - (y(4)+y(5)+y(12));
    residual(5) = (y(5)) - (y(6)-y(1)*(1-params(4))/params(7));
    residual(6) = (y(9)/(1-x(it_, 7))) - (params(7)*y(10)*params(1)/y(1));
    residual(7) = (y(7)*(1+x(it_, 5))/(1-x(it_, 7))) - (y(10)*(1-params(1))/y(8));
    residual(8) = (y(7)) - ((1+x(it_, 2))*T(10)/(1-x(it_, 4)));
    residual(9) = (y(12)) - (y(4)*x(it_, 2)+x(it_, 3)*y(5)+y(8)*y(7)*(x(it_, 5)+x(it_, 4))+y(1)*y(9)*x(it_, 6)/params(7)+y(10)*x(it_, 7)+x(it_, 8));
    residual(10) = (y(13)) - (y(10)*y(15));
    residual(11) = (y(14)) - (y(10)*y(15)+(1-params(8))/params(7)*y(2));
    residual(12) = (log(y(15))) - ((1-params(9))*log(params(10))+params(9)*log(y(3)));
    residual(13) = (y(16)) - (x(it_, 2));
    residual(14) = (y(17)) - (x(it_, 6));
    residual(15) = (y(18)) - (x(it_, 3));

end
