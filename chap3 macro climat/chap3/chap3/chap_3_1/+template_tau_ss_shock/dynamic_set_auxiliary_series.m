function ds = dynamic_set_auxiliary_series(ds, params)
%
% Computes auxiliary variables of the dynamic model
%
ds.AUX_EXO_LEAD_36=ds.tau_tva;
ds.AUX_EXO_LEAD_46=ds.tau_k;
ds.AUX_EXO_LEAD_51=ds.tau_inv;
end
