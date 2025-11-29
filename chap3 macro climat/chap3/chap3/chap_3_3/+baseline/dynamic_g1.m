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
    T = baseline.dynamic_g1_tt(T, y, x, params, steady_state, it_);
end
g1 = zeros(15, 23);
g1(1,4)=(-(T(2)*(T(5)*params(5)*T(2)*getPowerDeriv(y(4),params(5),1)*T(12)+T(4)*getPowerDeriv(y(4),params(5)-1,1))));
g1(1,8)=(-(T(4)*T(5)*T(13)+T(2)*T(5)*params(5)*T(12)*T(1)*T(13)));
g1(1,12)=1;
g1(2,19)=(-T(7));
g1(2,12)=1;
g1(2,20)=(-((1+y(19)-params(4))*params(2)*T(6)));
g1(3,4)=(-((1-params(5))/params(5)/(1-y(8))));
g1(3,7)=1;
g1(3,8)=(-(y(4)*(1-params(5))/params(5)/((1-y(8))*(1-y(8)))));
g1(4,1)=(-(T(10)*x(it_, 1)*1/params(7)*getPowerDeriv(y(1)/params(7),params(1),1)));
g1(4,8)=(-(T(9)*getPowerDeriv(y(8),1-params(1),1)));
g1(4,11)=1;
g1(4,21)=(-(T(8)*T(10)));
g1(5,14)=(-(params(8)*(-params(12))*exp((-params(12))*(y(14)-params(9)))));
g1(5,16)=1;
g1(6,10)=1;
g1(6,11)=(-y(16));
g1(6,16)=(-y(11));
g1(7,3)=(-((1-x(it_, 2))*params(10)));
g1(7,15)=1;
g1(7,22)=(1-params(10))*params(11)+params(10)*y(3);
g1(8,10)=(-y(15));
g1(8,13)=1;
g1(8,15)=(-y(10));
g1(9,13)=(-1);
g1(9,2)=(-((1-params(13))/params(7)));
g1(9,14)=1;
g1(10,13)=(-x(it_, 3));
g1(10,18)=1;
g1(10,23)=(-y(13));
g1(11,10)=(-T(11));
g1(11,17)=1;
g1(11,22)=(-(y(10)*0.5*params(14)*2*x(it_, 2)));
g1(12,4)=(-1);
g1(12,5)=(-1);
g1(12,10)=1;
g1(12,17)=(-1);
g1(13,5)=1;
g1(13,1)=(1-params(4))/params(7);
g1(13,6)=(-1);
g1(14,1)=(-((-(params(7)*params(1)*y(10)))/(y(1)*y(1))));
g1(14,9)=1;
g1(14,10)=(-(params(7)*params(1)/y(1)));
g1(15,7)=1;
g1(15,8)=(-((-((1-params(1))*y(10)))/(y(8)*y(8))));
g1(15,10)=(-((1-params(1))/y(8)));

end
