function [g1, T_order, T] = static_g1(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T_order, T)
if nargin < 8
    T_order = -1;
    T = NaN(11, 1);
end
[T_order, T] = damage_null.sparse.static_g1_tt(y, x, params, T_order, T);
g1_v = NaN(33, 1);
g1_v(1)=(-(T(1)*(T(5)*params(5)*T(1)*getPowerDeriv(y(1),params(5),1)*T(10)+T(4)*getPowerDeriv(y(1),params(5)-1,1))));
g1_v(2)=(-((1-params(5))/params(5)/(1-y(5))));
g1_v(3)=(-1);
g1_v(4)=(-1);
g1_v(5)=1;
g1_v(6)=(-(T(9)*x(1)*1/params(7)*getPowerDeriv(y(3)/params(7),params(1),1)));
g1_v(7)=(-(1-(1-params(4))/params(7)));
g1_v(8)=(-((-(params(7)*params(1)*y(7)))/(y(3)*y(3))));
g1_v(9)=1;
g1_v(10)=1;
g1_v(11)=(-(T(4)*T(5)*T(11)+T(1)*T(5)*params(5)*T(10)*T(2)*T(11)));
g1_v(12)=(-(y(1)*(1-params(5))/params(5)/((1-y(5))*(1-y(5)))));
g1_v(13)=(-(T(8)*getPowerDeriv(y(5),1-params(1),1)));
g1_v(14)=(-((-((1-params(1))*y(7)))/(y(5)*y(5))));
g1_v(15)=(-T(7));
g1_v(16)=1;
g1_v(17)=1;
g1_v(18)=1;
g1_v(19)=(-(params(7)*params(1)/y(3)));
g1_v(20)=(-((1-params(1))/y(5)));
g1_v(21)=(-y(12));
g1_v(22)=1;
g1_v(23)=(-y(13));
g1_v(24)=1;
g1_v(25)=1-(1+y(6)-params(4))*params(2)*T(6);
g1_v(26)=1;
g1_v(27)=(-1);
g1_v(28)=(-(params(10)*(-params(11))*exp((-params(11))*(y(11)-params(12)))));
g1_v(29)=1-(1-params(8))/params(7);
g1_v(30)=1-params(9);
g1_v(31)=(-y(7));
g1_v(32)=1;
g1_v(33)=(-y(8));
if ~isoctave && matlab_ver_less_than('9.8')
    sparse_rowval = double(sparse_rowval);
    sparse_colval = double(sparse_colval);
end
g1 = sparse(sparse_rowval, sparse_colval, g1_v, 13, 13);
end
