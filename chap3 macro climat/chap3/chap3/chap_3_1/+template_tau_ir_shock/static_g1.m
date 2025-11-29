function g1 = static_g1(T, y, x, params, T_flag)
% function g1 = static_g1(T, y, x, params, T_flag)
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
%   g1
%

if T_flag
    T = template_tau_ir_shock.static_g1_tt(T, y, x, params);
end
g1 = zeros(15, 15);
g1(1,1)=(-(T(1)*(T(5)*params(5)*T(1)*getPowerDeriv(y(1),params(5),1)*T(10)+T(4)*getPowerDeriv(y(1),params(5)-1,1))));
g1(1,5)=(-(T(4)*T(5)*T(11)+T(1)*T(5)*params(5)*T(10)*T(2)*T(11)));
g1(1,8)=1;
g1(2,6)=(-(T(7)*(1-y(14))));
g1(2,8)=(1+x(3))/(1+x(2))-(y(6)*(1-y(14))+(1-params(4))*(1+y(15)))*T(6)*params(2)/(1+y(13));
g1(2,13)=(-((y(6)*(1-y(14))+(1-params(4))*(1+y(15)))*T(6)*(-(y(8)*params(2)))/((1+y(13))*(1+y(13)))));
g1(2,14)=(-(T(7)*(-y(6))));
g1(2,15)=(-(T(7)*(1-params(4))));
g1(3,3)=(-(T(9)*x(1)*1/params(7)*getPowerDeriv(y(3)/params(7),params(1),1)));
g1(3,5)=(-(T(8)*getPowerDeriv(y(5),1-params(1),1)));
g1(3,7)=1;
g1(4,1)=(-1);
g1(4,2)=(-1);
g1(4,7)=1;
g1(4,9)=(-1);
g1(5,2)=1;
g1(5,3)=(-(1-(1-params(4))/params(7)));
g1(6,3)=(-((-(params(7)*y(7)*params(1)))/(y(3)*y(3))));
g1(6,6)=1/(1-x(7));
g1(6,7)=(-(params(7)*params(1)/y(3)));
g1(7,4)=(1+x(5))/(1-x(7));
g1(7,5)=(-((-(y(7)*(1-params(1))))/(y(5)*y(5))));
g1(7,7)=(-((1-params(1))/y(5)));
g1(8,1)=(-((1+x(2))*(1-params(5))/params(5)/(1-y(5))/(1-x(4))));
g1(8,4)=1;
g1(8,5)=(-((1+x(2))*y(1)*(1-params(5))/params(5)/((1-y(5))*(1-y(5)))/(1-x(4))));
g1(9,1)=(-x(2));
g1(9,2)=(-x(3));
g1(9,3)=(-(y(6)*x(6)/params(7)));
g1(9,4)=(-(y(5)*(x(5)+x(4))));
g1(9,5)=(-(y(4)*(x(5)+x(4))));
g1(9,6)=(-(y(3)*x(6)/params(7)));
g1(9,7)=(-x(7));
g1(9,9)=1;
g1(10,7)=(-y(12));
g1(10,10)=1;
g1(10,12)=(-y(7));
g1(11,7)=(-y(12));
g1(11,11)=1-(1-params(8))/params(7);
g1(11,12)=(-y(7));
g1(12,12)=1/y(12)-params(9)*1/y(12);
g1(13,13)=1;
g1(14,14)=1;
g1(15,15)=1;

end
