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
    T = policy_light.dynamic_resid_tt(T, y, x, params, steady_state, it_);
end
residual = zeros(15, 1);
lhs = y(12);
rhs = T(2)*T(4)*T(5);
residual(1) = lhs - rhs;
lhs = y(12);
rhs = T(7)*(1+y(19)-params(4));
residual(2) = lhs - rhs;
lhs = y(7);
rhs = y(4)*(1-params(5))/params(5)/(1-y(8));
residual(3) = lhs - rhs;
lhs = y(11);
rhs = T(9)*T(10);
residual(4) = lhs - rhs;
lhs = y(16);
rhs = params(8)*exp((-params(12))*(y(14)-params(9)));
residual(5) = lhs - rhs;
lhs = y(10);
rhs = y(11)*y(16);
residual(6) = lhs - rhs;
lhs = y(15);
rhs = (1-x(it_, 2))*((1-params(10))*params(11)+params(10)*y(3));
residual(7) = lhs - rhs;
lhs = y(13);
rhs = y(10)*y(15);
residual(8) = lhs - rhs;
lhs = y(14);
rhs = y(13)+(1-params(13))/params(7)*y(2);
residual(9) = lhs - rhs;
lhs = y(18);
rhs = y(13)*x(it_, 3);
residual(10) = lhs - rhs;
lhs = y(17);
rhs = y(10)*T(11);
residual(11) = lhs - rhs;
lhs = y(10);
rhs = y(17)+y(4)+y(5);
residual(12) = lhs - rhs;
lhs = y(5);
rhs = y(6)-y(1)*(1-params(4))/params(7);
residual(13) = lhs - rhs;
lhs = y(9);
rhs = params(7)*params(1)*y(10)/y(1);
residual(14) = lhs - rhs;
lhs = y(7);
rhs = (1-params(1))*y(10)/y(8);
residual(15) = lhs - rhs;

end
