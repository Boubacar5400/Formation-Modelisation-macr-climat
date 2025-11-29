function [g1, T_order, T] = static_g1(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T_order, T)
if nargin < 8
    T_order = -1;
    T = NaN(11, 1);
end
[T_order, T] = template_tau_k_shock.sparse.static_g1_tt(y, x, params, T_order, T);
g1_v = NaN(44, 1);
g1_v(1)=(-(T(1)*(T(5)*params(5)*T(1)*getPowerDeriv(y(1),params(5),1)*T(10)+T(4)*getPowerDeriv(y(1),params(5)-1,1))));
g1_v(2)=(-1);
g1_v(3)=(-((1+x(2))*(1-params(5))/params(5)/(1-y(5))/(1-x(4))));
g1_v(4)=(-x(2));
g1_v(5)=(-1);
g1_v(6)=1;
g1_v(7)=(-x(3));
g1_v(8)=(-(T(9)*x(1)*1/params(7)*getPowerDeriv(y(3)/params(7),params(1),1)));
g1_v(9)=(-(1-(1-params(4))/params(7)));
g1_v(10)=(-((-(params(7)*y(7)*params(1)))/(y(3)*y(3))));
g1_v(11)=(-(y(6)*x(6)/params(7)));
g1_v(12)=(1+x(5))/(1-x(7));
g1_v(13)=1;
g1_v(14)=(-(y(5)*(x(5)+x(4))));
g1_v(15)=(-(T(4)*T(5)*T(11)+T(1)*T(5)*params(5)*T(10)*T(2)*T(11)));
g1_v(16)=(-(T(8)*getPowerDeriv(y(5),1-params(1),1)));
g1_v(17)=(-((-(y(7)*(1-params(1))))/(y(5)*y(5))));
g1_v(18)=(-((1+x(2))*y(1)*(1-params(5))/params(5)/((1-y(5))*(1-y(5)))/(1-x(4))));
g1_v(19)=(-(y(4)*(x(5)+x(4))));
g1_v(20)=(-(T(7)*(1-y(14))));
g1_v(21)=1/(1-x(7));
g1_v(22)=(-(y(3)*x(6)/params(7)));
g1_v(23)=1;
g1_v(24)=1;
g1_v(25)=(-(params(7)*params(1)/y(3)));
g1_v(26)=(-((1-params(1))/y(5)));
g1_v(27)=(-x(7));
g1_v(28)=(-y(12));
g1_v(29)=(-y(12));
g1_v(30)=1;
g1_v(31)=(1+x(3))/(1+x(2))-(y(6)*(1-y(14))+(1-params(4))*(1+y(15)))*T(6)*params(2)/(1+y(13));
g1_v(32)=(-1);
g1_v(33)=1;
g1_v(34)=1;
g1_v(35)=1-(1-params(8))/params(7);
g1_v(36)=(-y(7));
g1_v(37)=(-y(7));
g1_v(38)=1/y(12)-params(9)*1/y(12);
g1_v(39)=(-((y(6)*(1-y(14))+(1-params(4))*(1+y(15)))*T(6)*(-(y(8)*params(2)))/((1+y(13))*(1+y(13)))));
g1_v(40)=1;
g1_v(41)=(-(T(7)*(-y(6))));
g1_v(42)=1;
g1_v(43)=(-(T(7)*(1-params(4))));
g1_v(44)=1;
if ~isoctave && matlab_ver_less_than('9.8')
    sparse_rowval = double(sparse_rowval);
    sparse_colval = double(sparse_colval);
end
g1 = sparse(sparse_rowval, sparse_colval, g1_v, 15, 15);
end
