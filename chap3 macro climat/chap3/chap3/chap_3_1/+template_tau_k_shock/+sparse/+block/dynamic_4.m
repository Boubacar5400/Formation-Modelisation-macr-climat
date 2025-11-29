function [y, T] = dynamic_4(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(26)=y(22)*y(27)+(1-params(8))/params(7)*y(11);
  y(25)=y(22)*y(27);
end
