function [g1, T_order, T] = dynamic_g1(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T_order, T)
if nargin < 9
    T_order = -1;
    T = NaN(12, 1);
end
[T_order, T] = damage_null.sparse.dynamic_g1_tt(y, x, params, steady_state, T_order, T);
g1_v = NaN(38, 1);
g1_v(1)=(-(T(10)*x(1)*1/params(7)*getPowerDeriv(y(3)/params(7),params(1),1)));
g1_v(2)=(1-params(4))/params(7);
g1_v(3)=(-((-(params(7)*params(1)*y(20)))/(y(3)*y(3))));
g1_v(4)=(-((1-params(8))/params(7)));
g1_v(5)=(-params(9));
g1_v(6)=(-(T(2)*(T(5)*params(5)*T(2)*getPowerDeriv(y(14),params(5),1)*T(11)+T(4)*getPowerDeriv(y(14),params(5)-1,1))));
g1_v(7)=(-((1-params(5))/params(5)/(1-y(18))));
g1_v(8)=(-1);
g1_v(9)=(-1);
g1_v(10)=1;
g1_v(11)=(-1);
g1_v(12)=1;
g1_v(13)=1;
g1_v(14)=(-(T(4)*T(5)*T(12)+T(2)*T(5)*params(5)*T(11)*T(1)*T(12)));
g1_v(15)=(-(y(14)*(1-params(5))/params(5)/((1-y(18))*(1-y(18)))));
g1_v(16)=(-(T(9)*getPowerDeriv(y(18),1-params(1),1)));
g1_v(17)=(-((-((1-params(1))*y(20)))/(y(18)*y(18))));
g1_v(18)=1;
g1_v(19)=1;
g1_v(20)=1;
g1_v(21)=(-(params(7)*params(1)/y(3)));
g1_v(22)=(-((1-params(1))/y(18)));
g1_v(23)=(-y(25));
g1_v(24)=1;
g1_v(25)=(-y(26));
g1_v(26)=1;
g1_v(27)=1;
g1_v(28)=1;
g1_v(29)=(-1);
g1_v(30)=(-(params(10)*(-params(11))*exp((-params(11))*(y(24)-params(12)))));
g1_v(31)=1;
g1_v(32)=1;
g1_v(33)=(-y(20));
g1_v(34)=1;
g1_v(35)=(-y(21));
g1_v(36)=(-T(7));
g1_v(37)=(-((1+y(32)-params(4))*params(2)*T(6)));
g1_v(38)=(-(T(8)*T(10)));
if ~isoctave && matlab_ver_less_than('9.8')
    sparse_rowval = double(sparse_rowval);
    sparse_colval = double(sparse_colval);
end
g1 = sparse(sparse_rowval, sparse_colval, g1_v, 13, 40);
end
