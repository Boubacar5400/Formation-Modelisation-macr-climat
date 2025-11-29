function [y, T] = dynamic_1(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(25)=(1-params(9))*params(13)+params(9)*y(12);
end
