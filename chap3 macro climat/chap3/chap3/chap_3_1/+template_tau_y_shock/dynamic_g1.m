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
    T = template_tau_y_shock.dynamic_g1_tt(T, y, x, params, steady_state, it_);
end
g1 = zeros(15, 31);
g1(1,4)=(-(T(2)*(T(5)*params(5)*T(2)*getPowerDeriv(y(4),params(5),1)*T(12)+T(4)*getPowerDeriv(y(4),params(5)-1,1))));
g1(1,8)=(-(T(4)*T(5)*T(13)+T(2)*T(5)*params(5)*T(12)*T(1)*T(13)));
g1(1,11)=1;
g1(2,19)=(-(T(11)*(1-y(22))));
g1(2,11)=(1+x(it_, 3))/(1+x(it_, 2));
g1(2,20)=(-((y(19)*(1-y(22))+(1-params(4))*(1+y(23)))*T(6)*params(2)/(1+y(21))));
g1(2,25)=(-(y(11)*(1+x(it_, 3))))/((1+x(it_, 2))*(1+x(it_, 2)));
g1(2,26)=y(11)/(1+x(it_, 2));
g1(2,21)=(-((y(19)*(1-y(22))+(1-params(4))*(1+y(23)))*T(6)*(-(params(2)*y(20)))/((1+y(21))*(1+y(21)))));
g1(2,22)=(-(T(11)*(-y(19))));
g1(2,23)=(-((1-params(4))*T(11)));
g1(3,1)=(-(T(9)*x(it_, 1)*1/params(7)*getPowerDeriv(y(1)/params(7),params(1),1)));
g1(3,8)=(-(T(8)*getPowerDeriv(y(8),1-params(1),1)));
g1(3,10)=1;
g1(3,24)=(-(T(7)*T(9)));
g1(4,4)=(-1);
g1(4,5)=(-1);
g1(4,10)=1;
g1(4,12)=(-1);
g1(5,5)=1;
g1(5,1)=(1-params(4))/params(7);
g1(5,6)=(-1);
g1(6,1)=(-((-(params(7)*y(10)*params(1)))/(y(1)*y(1))));
g1(6,9)=1/(1-x(it_, 7));
g1(6,10)=(-(params(7)*params(1)/y(1)));
g1(6,30)=y(9)/((1-x(it_, 7))*(1-x(it_, 7)));
g1(7,7)=(1+x(it_, 5))/(1-x(it_, 7));
g1(7,8)=(-((-(y(10)*(1-params(1))))/(y(8)*y(8))));
g1(7,10)=(-((1-params(1))/y(8)));
g1(7,28)=y(7)/(1-x(it_, 7));
g1(7,30)=y(7)*(1+x(it_, 5))/((1-x(it_, 7))*(1-x(it_, 7)));
g1(8,4)=(-((1+x(it_, 2))*(1-params(5))/params(5)/(1-y(8))/(1-x(it_, 4))));
g1(8,7)=1;
g1(8,8)=(-((1+x(it_, 2))*y(4)*(1-params(5))/params(5)/((1-y(8))*(1-y(8)))/(1-x(it_, 4))));
g1(8,25)=(-(T(10)/(1-x(it_, 4))));
g1(8,27)=(-((1+x(it_, 2))*T(10)/((1-x(it_, 4))*(1-x(it_, 4)))));
g1(9,4)=(-x(it_, 2));
g1(9,5)=(-x(it_, 3));
g1(9,1)=(-(y(9)*x(it_, 6)/params(7)));
g1(9,7)=(-(y(8)*(x(it_, 5)+x(it_, 4))));
g1(9,8)=(-(y(7)*(x(it_, 5)+x(it_, 4))));
g1(9,9)=(-(y(1)*x(it_, 6)/params(7)));
g1(9,10)=(-x(it_, 7));
g1(9,12)=1;
g1(9,25)=(-y(4));
g1(9,26)=(-y(5));
g1(9,27)=(-(y(8)*y(7)));
g1(9,28)=(-(y(8)*y(7)));
g1(9,29)=(-(y(1)*y(9)/params(7)));
g1(9,30)=(-y(10));
g1(9,31)=(-1);
g1(10,10)=(-y(15));
g1(10,13)=1;
g1(10,15)=(-y(10));
g1(11,10)=(-y(15));
g1(11,2)=(-((1-params(8))/params(7)));
g1(11,14)=1;
g1(11,15)=(-y(10));
g1(12,3)=(-(params(9)*1/y(3)));
g1(12,15)=1/y(15);
g1(13,25)=(-1);
g1(13,16)=1;
g1(14,29)=(-1);
g1(14,17)=1;
g1(15,26)=(-1);
g1(15,18)=1;

end
