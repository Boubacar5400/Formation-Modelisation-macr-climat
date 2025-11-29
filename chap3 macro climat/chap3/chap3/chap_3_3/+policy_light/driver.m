%
% Status : main Dynare file
%
% Warning : this file is generated automatically by Dynare
%           from model file (.mod)

tic0 = tic;
% Define global variables.
global M_ options_ oo_ estim_params_ bayestopt_ dataset_ dataset_info estimation_info ys0_ ex0_
options_ = [];
M_.fname = 'policy_light';
M_.dynare_version = '5.3';
oo_.dynare_version = '5.3';
options_.dynare_version = '5.3';
%
% Some global variables initialization
%
global_initialization;
M_.exo_names = cell(3,1);
M_.exo_names_tex = cell(3,1);
M_.exo_names_long = cell(3,1);
M_.exo_names(1) = {'A'};
M_.exo_names_tex(1) = {'A'};
M_.exo_names_long(1) = {'A'};
M_.exo_names(2) = {'mu'};
M_.exo_names_tex(2) = {'mu'};
M_.exo_names_long(2) = {'mu'};
M_.exo_names(3) = {'tau_co2'};
M_.exo_names_tex(3) = {'tau\_co2'};
M_.exo_names_long(3) = {'tau_co2'};
M_.endo_names = cell(15,1);
M_.endo_names_tex = cell(15,1);
M_.endo_names_long = cell(15,1);
M_.endo_names(1) = {'c'};
M_.endo_names_tex(1) = {'c'};
M_.endo_names_long(1) = {'c'};
M_.endo_names(2) = {'invest'};
M_.endo_names_tex(2) = {'invest'};
M_.endo_names_long(2) = {'invest'};
M_.endo_names(3) = {'k'};
M_.endo_names_tex(3) = {'k'};
M_.endo_names_long(3) = {'k'};
M_.endo_names(4) = {'w'};
M_.endo_names_tex(4) = {'w'};
M_.endo_names_long(4) = {'w'};
M_.endo_names(5) = {'l'};
M_.endo_names_tex(5) = {'l'};
M_.endo_names_long(5) = {'l'};
M_.endo_names(6) = {'r'};
M_.endo_names_tex(6) = {'r'};
M_.endo_names_long(6) = {'r'};
M_.endo_names(7) = {'y'};
M_.endo_names_tex(7) = {'y'};
M_.endo_names_long(7) = {'y'};
M_.endo_names(8) = {'y_g'};
M_.endo_names_tex(8) = {'y\_g'};
M_.endo_names_long(8) = {'y_g'};
M_.endo_names(9) = {'muc'};
M_.endo_names_tex(9) = {'muc'};
M_.endo_names_long(9) = {'muc'};
M_.endo_names(10) = {'e'};
M_.endo_names_tex(10) = {'e'};
M_.endo_names_long(10) = {'e'};
M_.endo_names(11) = {'s'};
M_.endo_names_tex(11) = {'s'};
M_.endo_names_long(11) = {'s'};
M_.endo_names(12) = {'xi'};
M_.endo_names_tex(12) = {'xi'};
M_.endo_names_long(12) = {'xi'};
M_.endo_names(13) = {'d'};
M_.endo_names_tex(13) = {'d'};
M_.endo_names_long(13) = {'d'};
M_.endo_names(14) = {'psi'};
M_.endo_names_tex(14) = {'psi'};
M_.endo_names_long(14) = {'psi'};
M_.endo_names(15) = {'tr'};
M_.endo_names_tex(15) = {'tr'};
M_.endo_names_long(15) = {'tr'};
M_.endo_partitions = struct();
M_.param_names = cell(14,1);
M_.param_names_tex = cell(14,1);
M_.param_names_long = cell(14,1);
M_.param_names(1) = {'alf'};
M_.param_names_tex(1) = {'alf'};
M_.param_names_long(1) = {'alf'};
M_.param_names(2) = {'bet'};
M_.param_names_tex(2) = {'bet'};
M_.param_names_long(2) = {'bet'};
M_.param_names(3) = {'sig'};
M_.param_names_tex(3) = {'sig'};
M_.param_names_long(3) = {'sig'};
M_.param_names(4) = {'delt'};
M_.param_names_tex(4) = {'delt'};
M_.param_names_long(4) = {'delt'};
M_.param_names(5) = {'nu'};
M_.param_names_tex(5) = {'nu'};
M_.param_names_long(5) = {'nu'};
M_.param_names(6) = {'gbar'};
M_.param_names_tex(6) = {'gbar'};
M_.param_names_long(6) = {'gbar'};
M_.param_names(7) = {'gamm'};
M_.param_names_tex(7) = {'gamm'};
M_.param_names_long(7) = {'gamm'};
M_.param_names(8) = {'B'};
M_.param_names_tex(8) = {'B'};
M_.param_names_long(8) = {'B'};
M_.param_names(9) = {'Sbar_hat'};
M_.param_names_tex(9) = {'Sbar\_hat'};
M_.param_names_long(9) = {'Sbar_hat'};
M_.param_names(10) = {'rho_xi'};
M_.param_names_tex(10) = {'rho\_xi'};
M_.param_names_long(10) = {'rho_xi'};
M_.param_names(11) = {'xi_bar'};
M_.param_names_tex(11) = {'xi\_bar'};
M_.param_names_long(11) = {'xi_bar'};
M_.param_names(12) = {'phi'};
M_.param_names_tex(12) = {'phi'};
M_.param_names_long(12) = {'phi'};
M_.param_names(13) = {'deltae'};
M_.param_names_tex(13) = {'deltae'};
M_.param_names_long(13) = {'deltae'};
M_.param_names(14) = {'chi'};
M_.param_names_tex(14) = {'chi'};
M_.param_names_long(14) = {'chi'};
M_.param_partitions = struct();
M_.exo_det_nbr = 0;
M_.exo_nbr = 3;
M_.endo_nbr = 15;
M_.param_nbr = 14;
M_.orig_endo_nbr = 15;
M_.aux_vars = [];
M_ = setup_solvers(M_);
M_.Sigma_e = zeros(3, 3);
M_.Correlation_matrix = eye(3, 3);
M_.H = 0;
M_.Correlation_matrix_ME = 1;
M_.sigma_e_is_diagonal = true;
M_.det_shocks = [];
M_.surprise_shocks = [];
M_.heteroskedastic_shocks.Qvalue_orig = [];
M_.heteroskedastic_shocks.Qscale_orig = [];
options_.linear = false;
options_.block = false;
options_.bytecode = false;
options_.use_dll = false;
M_.orig_eq_nbr = 15;
M_.eq_nbr = 15;
M_.ramsey_eq_nbr = 0;
M_.set_auxiliary_variables = exist(['./+' M_.fname '/set_auxiliary_variables.m'], 'file') == 2;
M_.epilogue_names = {};
M_.epilogue_var_list_ = {};
M_.orig_maximum_endo_lag = 1;
M_.orig_maximum_endo_lead = 1;
M_.orig_maximum_exo_lag = 0;
M_.orig_maximum_exo_lead = 0;
M_.orig_maximum_exo_det_lag = 0;
M_.orig_maximum_exo_det_lead = 0;
M_.orig_maximum_lag = 1;
M_.orig_maximum_lead = 1;
M_.orig_maximum_lag_with_diffs_expanded = 1;
M_.lead_lag_incidence = [
 0 4 0;
 0 5 0;
 1 6 0;
 0 7 0;
 0 8 0;
 0 9 19;
 0 10 0;
 0 11 0;
 0 12 20;
 0 13 0;
 2 14 0;
 3 15 0;
 0 16 0;
 0 17 0;
 0 18 0;]';
M_.nstatic = 10;
M_.nfwrd   = 2;
M_.npred   = 3;
M_.nboth   = 0;
M_.nsfwrd   = 2;
M_.nspred   = 3;
M_.ndynamic   = 5;
M_.dynamic_tmp_nbr = [11; 2; 0; 0; ];
M_.model_local_variables_dynamic_tt_idxs = {
};
M_.equations_tags = {
  1 , 'name' , 'muc' ;
  2 , 'name' , '2' ;
  3 , 'name' , 'w' ;
  4 , 'name' , 'y_g' ;
  5 , 'name' , 'd' ;
  6 , 'name' , 'y' ;
  7 , 'name' , 'xi' ;
  8 , 'name' , 'e' ;
  9 , 'name' , 's' ;
  10 , 'name' , 'tr' ;
  11 , 'name' , 'psi' ;
  12 , 'name' , '12' ;
  13 , 'name' , 'invest' ;
  14 , 'name' , 'r' ;
  15 , 'name' , '15' ;
};
M_.mapping.c.eqidx = [1 3 12 ];
M_.mapping.invest.eqidx = [12 13 ];
M_.mapping.k.eqidx = [4 13 14 ];
M_.mapping.w.eqidx = [3 15 ];
M_.mapping.l.eqidx = [1 3 4 15 ];
M_.mapping.r.eqidx = [2 14 ];
M_.mapping.y.eqidx = [6 8 11 12 14 15 ];
M_.mapping.y_g.eqidx = [4 6 ];
M_.mapping.muc.eqidx = [1 2 ];
M_.mapping.e.eqidx = [8 9 10 ];
M_.mapping.s.eqidx = [5 9 ];
M_.mapping.xi.eqidx = [7 8 ];
M_.mapping.d.eqidx = [5 6 ];
M_.mapping.psi.eqidx = [11 12 ];
M_.mapping.tr.eqidx = [10 ];
M_.mapping.A.eqidx = [4 ];
M_.mapping.mu.eqidx = [7 11 ];
M_.mapping.tau_co2.eqidx = [10 ];
M_.static_and_dynamic_models_differ = false;
M_.has_external_function = false;
M_.state_var = [3 11 12 ];
M_.exo_names_orig_ord = [1:3];
M_.maximum_lag = 1;
M_.maximum_lead = 1;
M_.maximum_endo_lag = 1;
M_.maximum_endo_lead = 1;
oo_.steady_state = zeros(15, 1);
M_.maximum_exo_lag = 0;
M_.maximum_exo_lead = 0;
oo_.exo_steady_state = zeros(3, 1);
M_.params = NaN(14, 1);
M_.endo_trends = struct('deflator', cell(15, 1), 'log_deflator', cell(15, 1), 'growth_factor', cell(15, 1), 'log_growth_factor', cell(15, 1));
M_.NNZDerivatives = [46; -1; -1; ];
M_.static_tmp_nbr = [10; 2; 0; 0; ];
M_.model_local_variables_static_tt_idxs = {
};
M_.params(1) = 0.33;
alf = M_.params(1);
M_.params(2) = 0.95;
bet = M_.params(2);
M_.params(4) = 0.025;
delt = M_.params(4);
M_.params(3) = 3;
sig = M_.params(3);
M_.params(5) = 0.5;
nu = M_.params(5);
M_.params(6) = 0.02;
gbar = M_.params(6);
M_.params(7) = 1+M_.params(6);
gamm = M_.params(7);
M_.params(8) = 1.00;
B = M_.params(8);
M_.params(9) = 0.0;
Sbar_hat = M_.params(9);
M_.params(10) = 0.9;
rho_xi = M_.params(10);
M_.params(11) = 0.25;
xi_bar = M_.params(11);
M_.params(12) = 0.001;
phi = M_.params(12);
M_.params(13) = 0.01;
deltae = M_.params(13);
M_.params(14) = 0.5;
chi = M_.params(14);
%
% INITVAL instructions
%
options_.initval_file = false;
oo_.exo_steady_state(1) = 1;
oo_.exo_steady_state(2) = 0;
oo_.exo_steady_state(3) = 0;
if M_.exo_nbr > 0
	oo_.exo_simul = ones(M_.maximum_lag,1)*oo_.exo_steady_state';
end
if M_.exo_det_nbr > 0
	oo_.exo_det_simul = ones(M_.maximum_lag,1)*oo_.exo_det_steady_state';
end
steady;
oo_.dr.eigval = check(M_,options_,oo_);
%
% SHOCKS instructions
%
M_.det_shocks = [ M_.det_shocks;
struct('exo_det',0,'exo_id',1,'multiplicative',0,'periods',1:240,'value',1.1) ];
M_.det_shocks = [ M_.det_shocks;
struct('exo_det',0,'exo_id',2,'multiplicative',0,'periods',1:239,'value',0.200) ];
M_.det_shocks = [ M_.det_shocks;
struct('exo_det',0,'exo_id',2,'multiplicative',0,'periods',240:240,'value',0) ];
M_.det_shocks = [ M_.det_shocks;
struct('exo_det',0,'exo_id',3,'multiplicative',0,'periods',1:240,'value',0.000) ];
M_.exo_det_length = 0;
options_.periods = 240;
perfect_foresight_setup;
perfect_foresight_solver;


oo_.time = toc(tic0);
disp(['Total computing time : ' dynsec2hms(oo_.time) ]);
if ~exist([M_.dname filesep 'Output'],'dir')
    mkdir(M_.dname,'Output');
end
save([M_.dname filesep 'Output' filesep 'policy_light_results.mat'], 'oo_', 'M_', 'options_');
if exist('estim_params_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'policy_light_results.mat'], 'estim_params_', '-append');
end
if exist('bayestopt_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'policy_light_results.mat'], 'bayestopt_', '-append');
end
if exist('dataset_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'policy_light_results.mat'], 'dataset_', '-append');
end
if exist('estimation_info', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'policy_light_results.mat'], 'estimation_info', '-append');
end
if exist('dataset_info', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'policy_light_results.mat'], 'dataset_info', '-append');
end
if exist('oo_recursive_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'policy_light_results.mat'], 'oo_recursive_', '-append');
end
if ~isempty(lastwarn)
  disp('Note: warning(s) encountered in MATLAB/Octave code')
end
