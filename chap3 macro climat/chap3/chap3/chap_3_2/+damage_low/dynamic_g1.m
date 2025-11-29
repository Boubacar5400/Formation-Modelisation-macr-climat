function g1 = dynamic_g1(T, y, x, params, steady_state, it_, T_flag)
% function g1 = dynamic_g1(T, y, x, params, steady_state, it_, T_flag)
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
%   g1
%

if T_flag
    T = damage_low.dynamic_g1_tt(T, y, x, params, steady_state, it_);
end
g1 = zeros(13, 19);
g1(1,4)=(-(T(2)*(T(5)*params(5)*T(2)*getPowerDeriv(y(4),params(5),1)*T(11)+T(4)*getPowerDeriv(y(4),params(5)-1,1))));
g1(1,8)=(-(T(4)*T(5)*T(12)+T(2)*T(5)*params(5)*T(11)*T(1)*T(12)));
g1(1,12)=1;
g1(2,17)=(-T(7));
g1(2,12)=1;
g1(2,18)=(-((1+y(17)-params(4))*params(2)*T(6)));
g1(3,4)=(-((1-params(5))/params(5)/(1-y(8))));
g1(3,7)=1;
g1(3,8)=(-(y(4)*(1-params(5))/params(5)/((1-y(8))*(1-y(8)))));
g1(4,1)=(-(T(10)*x(it_, 1)*1/params(7)*getPowerDeriv(y(1)/params(7),params(1),1)));
g1(4,8)=(-(T(9)*getPowerDeriv(y(8),1-params(1),1)));
g1(4,11)=1;
g1(4,19)=(-(T(8)*T(10)));
g1(5,14)=(-(params(10)*(-params(11))*exp((-params(11))*(y(14)-params(12)))));
g1(5,16)=1;
g1(6,10)=1;
g1(6,11)=(-y(16));
g1(6,16)=(-y(11));
g1(7,4)=(-1);
g1(7,5)=(-1);
g1(7,10)=1;
g1(8,5)=1;
g1(8,1)=(1-params(4))/params(7);
g1(8,6)=(-1);
g1(9,1)=(-((-(params(7)*params(1)*y(10)))/(y(1)*y(1))));
g1(9,9)=1;
g1(9,10)=(-(params(7)*params(1)/y(1)));
g1(10,7)=1;
g1(10,8)=(-((-((1-params(1))*y(10)))/(y(8)*y(8))));
g1(10,10)=(-((1-params(1))/y(8)));
g1(11,3)=(-params(9));
g1(11,15)=1;
g1(12,10)=(-y(15));
g1(12,13)=1;
g1(12,15)=(-y(10));
g1(13,13)=(-1);
g1(13,2)=(-((1-params(8))/params(7)));
g1(13,14)=1;

end
