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
    T = damage_high.static_g1_tt(T, y, x, params);
end
g1 = zeros(13, 13);
g1(1,1)=(-(T(1)*(T(5)*params(5)*T(1)*getPowerDeriv(y(1),params(5),1)*T(10)+T(4)*getPowerDeriv(y(1),params(5)-1,1))));
g1(1,5)=(-(T(4)*T(5)*T(11)+T(1)*T(5)*params(5)*T(10)*T(2)*T(11)));
g1(1,9)=1;
g1(2,6)=(-T(7));
g1(2,9)=1-(1+y(6)-params(4))*params(2)*T(6);
g1(3,1)=(-((1-params(5))/params(5)/(1-y(5))));
g1(3,4)=1;
g1(3,5)=(-(y(1)*(1-params(5))/params(5)/((1-y(5))*(1-y(5)))));
g1(4,3)=(-(T(9)*x(1)*1/params(7)*getPowerDeriv(y(3)/params(7),params(1),1)));
g1(4,5)=(-(T(8)*getPowerDeriv(y(5),1-params(1),1)));
g1(4,8)=1;
g1(5,11)=(-(params(10)*(-params(11))*exp((-params(11))*(y(11)-params(12)))));
g1(5,13)=1;
g1(6,7)=1;
g1(6,8)=(-y(13));
g1(6,13)=(-y(8));
g1(7,1)=(-1);
g1(7,2)=(-1);
g1(7,7)=1;
g1(8,2)=1;
g1(8,3)=(-(1-(1-params(4))/params(7)));
g1(9,3)=(-((-(params(7)*params(1)*y(7)))/(y(3)*y(3))));
g1(9,6)=1;
g1(9,7)=(-(params(7)*params(1)/y(3)));
g1(10,4)=1;
g1(10,5)=(-((-((1-params(1))*y(7)))/(y(5)*y(5))));
g1(10,7)=(-((1-params(1))/y(5)));
g1(11,12)=1-params(9);
g1(12,7)=(-y(12));
g1(12,10)=1;
g1(12,12)=(-y(7));
g1(13,10)=(-1);
g1(13,11)=1-(1-params(8))/params(7);

end
