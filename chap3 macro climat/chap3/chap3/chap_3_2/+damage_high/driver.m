%
% Status : main Dynare file
%
% Warning : this file is generated automatically by Dynare
%           from model file (.mod)

tic0 = tic;
% Define global variables.
global M_ options_ oo_ estim_params_ bayestopt_ dataset_ dataset_info estimation_info
options_ = [];
M_.fname = 'damage_high';
M_.dynare_version = '6.4';
oo_.dynare_version = '6.4';
options_.dynare_version = '6.4';
%
% Some global variables initialization
%
global_initialization;
M_.exo_names = cell(1,1);
M_.exo_names_tex = cell(1,1);
M_.exo_names_long = cell(1,1);
M_.exo_names(1) = {'A'};
M_.exo_names_tex(1) = {'A'};
M_.exo_names_long(1) = {'A'};
M_.endo_names = cell(13,1);
M_.endo_names_tex = cell(13,1);
M_.endo_names_long = cell(13,1);
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
M_.endo_partitions = struct();
M_.param_names = cell(13,1);
M_.param_names_tex = cell(13,1);
M_.param_names_long = cell(13,1);
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
M_.param_names(8) = {'deltae'};
M_.param_names_tex(8) = {'deltae'};
M_.param_names_long(8) = {'deltae'};
M_.param_names(9) = {'rho_xi'};
M_.param_names_tex(9) = {'rho\_xi'};
M_.param_names_long(9) = {'rho_xi'};
M_.param_names(10) = {'B'};
M_.param_names_tex(10) = {'B'};
M_.param_names_long(10) = {'B'};
M_.param_names(11) = {'phi'};
M_.param_names_tex(11) = {'phi'};
M_.param_names_long(11) = {'phi'};
M_.param_names(12) = {'Sbar_hat'};
M_.param_names_tex(12) = {'Sbar\_hat'};
M_.param_names_long(12) = {'Sbar_hat'};
M_.param_names(13) = {'xi_bar'};
M_.param_names_tex(13) = {'xi\_bar'};
M_.param_names_long(13) = {'xi_bar'};
M_.param_partitions = struct();
M_.exo_det_nbr = 0;
M_.exo_nbr = 1;
M_.endo_nbr = 13;
M_.param_nbr = 13;
M_.orig_endo_nbr = 13;
M_.aux_vars = [];
M_.Sigma_e = zeros(1, 1);
M_.Correlation_matrix = eye(1, 1);
M_.H = 0;
M_.Correlation_matrix_ME = 1;
M_.sigma_e_is_diagonal = true;
M_.det_shocks = [];
M_.surprise_shocks = [];
M_.learnt_shocks = [];
M_.learnt_endval = [];
M_.heteroskedastic_shocks.Qvalue_orig = [];
M_.heteroskedastic_shocks.Qscale_orig = [];
M_.matched_irfs = {};
M_.matched_irfs_weights = {};
options_.linear = false;
options_.block = false;
options_.bytecode = false;
options_.use_dll = false;
options_.ramsey_policy = false;
options_.discretionary_policy = false;
M_.eq_nbr = 13;
M_.ramsey_orig_eq_nbr = 0;
M_.ramsey_orig_endo_nbr = 0;
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
 0 9 17;
 0 10 0;
 0 11 0;
 0 12 18;
 0 13 0;
 2 14 0;
 3 15 0;
 0 16 0;]';
M_.nstatic = 8;
M_.nfwrd   = 2;
M_.npred   = 3;
M_.nboth   = 0;
M_.nsfwrd   = 2;
M_.nspred   = 3;
M_.ndynamic   = 5;
M_.dynamic_tmp_nbr = [10; 2; 0; 0; ];
M_.equations_tags = {
  1 , 'name' , 'muc' ;
  2 , 'name' , '2' ;
  3 , 'name' , 'w' ;
  4 , 'name' , 'y_g' ;
  5 , 'name' , 'd' ;
  6 , 'name' , 'y' ;
  7 , 'name' , '7' ;
  8 , 'name' , 'invest' ;
  9 , 'name' , 'r' ;
  10 , 'name' , '10' ;
  11 , 'name' , 'xi' ;
  12 , 'name' , 'e' ;
  13 , 'name' , 's' ;
};
M_.mapping.c.eqidx = [1 3 7 ];
M_.mapping.invest.eqidx = [7 8 ];
M_.mapping.k.eqidx = [4 8 9 ];
M_.mapping.w.eqidx = [3 10 ];
M_.mapping.l.eqidx = [1 3 4 10 ];
M_.mapping.r.eqidx = [2 9 ];
M_.mapping.y.eqidx = [6 7 9 10 12 ];
M_.mapping.y_g.eqidx = [4 6 ];
M_.mapping.muc.eqidx = [1 2 ];
M_.mapping.e.eqidx = [12 13 ];
M_.mapping.s.eqidx = [5 13 ];
M_.mapping.xi.eqidx = [11 12 ];
M_.mapping.d.eqidx = [5 6 ];
M_.mapping.A.eqidx = [4 ];
M_.static_and_dynamic_models_differ = false;
M_.has_external_function = false;
M_.block_structure.time_recursive = false;
M_.block_structure.block(1).Simulation_Type = 1;
M_.block_structure.block(1).endo_nbr = 1;
M_.block_structure.block(1).mfs = 1;
M_.block_structure.block(1).equation = [ 11];
M_.block_structure.block(1).variable = [ 12];
M_.block_structure.block(1).is_linear = true;
M_.block_structure.block(1).NNZDerivatives = 2;
M_.block_structure.block(1).bytecode_jacob_cols_to_sparse = [1 2 ];
M_.block_structure.block(2).Simulation_Type = 8;
M_.block_structure.block(2).endo_nbr = 12;
M_.block_structure.block(2).mfs = 9;
M_.block_structure.block(2).equation = [ 3 12 5 4 6 7 10 1 8 13 2 9];
M_.block_structure.block(2).variable = [ 4 10 13 5 8 2 7 1 3 11 9 6];
M_.block_structure.block(2).is_linear = false;
M_.block_structure.block(2).NNZDerivatives = 30;
M_.block_structure.block(2).bytecode_jacob_cols_to_sparse = [6 7 0 0 0 10 11 12 13 14 15 16 17 18 26 27 ];
M_.block_structure.block(1).g1_sparse_rowval = int32([]);
M_.block_structure.block(1).g1_sparse_colval = int32([]);
M_.block_structure.block(1).g1_sparse_colptr = int32([]);
M_.block_structure.block(2).g1_sparse_rowval = int32([1 6 9 7 1 4 5 1 2 3 6 2 3 4 7 9 3 4 5 6 2 7 5 8 9 8 8 ]);
M_.block_structure.block(2).g1_sparse_colval = int32([6 6 6 7 10 10 10 11 11 12 12 13 13 13 13 13 14 14 14 15 16 16 17 17 18 26 27 ]);
M_.block_structure.block(2).g1_sparse_colptr = int32([1 1 1 1 1 1 4 5 5 5 8 10 12 17 20 21 23 25 26 26 26 26 26 26 26 26 27 28 ]);
M_.block_structure.variable_reordered = [ 12 4 10 13 5 8 2 7 1 3 11 9 6];
M_.block_structure.equation_reordered = [ 11 3 12 5 4 6 7 10 1 8 13 2 9];
M_.block_structure.incidence(1).lead_lag = -1;
M_.block_structure.incidence(1).sparse_IM = [
 4 3;
 8 3;
 9 3;
 11 12;
 13 11;
];
M_.block_structure.incidence(2).lead_lag = 0;
M_.block_structure.incidence(2).sparse_IM = [
 1 1;
 1 5;
 1 9;
 2 9;
 3 1;
 3 4;
 3 5;
 4 5;
 4 8;
 5 11;
 5 13;
 6 7;
 6 8;
 6 13;
 7 1;
 7 2;
 7 7;
 8 2;
 8 3;
 9 6;
 9 7;
 10 4;
 10 5;
 10 7;
 11 12;
 12 7;
 12 10;
 12 12;
 13 10;
 13 11;
];
M_.block_structure.incidence(3).lead_lag = 1;
M_.block_structure.incidence(3).sparse_IM = [
 2 6;
 2 9;
];
M_.block_structure.dyn_tmp_nbr = 12;
M_.state_var = [12 3 11 ];
M_.maximum_lag = 1;
M_.maximum_lead = 1;
M_.maximum_endo_lag = 1;
M_.maximum_endo_lead = 1;
oo_.steady_state = zeros(13, 1);
M_.maximum_exo_lag = 0;
M_.maximum_exo_lead = 0;
oo_.exo_steady_state = zeros(1, 1);
M_.params = NaN(13, 1);
M_.endo_trends = struct('deflator', cell(13, 1), 'log_deflator', cell(13, 1), 'growth_factor', cell(13, 1), 'log_growth_factor', cell(13, 1));
M_.NNZDerivatives = [38; -1; -1; ];
M_.dynamic_g1_sparse_rowval = int32([4 8 9 13 11 1 3 7 7 8 8 3 10 1 3 4 10 9 6 7 9 10 12 4 6 1 2 12 13 5 13 11 12 5 6 2 2 4 ]);
M_.dynamic_g1_sparse_colval = int32([3 3 3 11 12 14 14 14 15 15 16 17 17 18 18 18 18 19 20 20 20 20 20 21 21 22 22 23 23 24 24 25 25 26 26 32 35 40 ]);
M_.dynamic_g1_sparse_colptr = int32([1 1 1 4 4 4 4 4 4 4 4 5 6 6 9 11 12 14 18 19 24 26 28 30 32 34 36 36 36 36 36 36 37 37 37 38 38 38 38 38 39 ]);
M_.lhs = {
'muc'; 
'muc'; 
'w'; 
'y_g'; 
'd'; 
'y'; 
'y'; 
'invest'; 
'r'; 
'w'; 
'xi'; 
'e'; 
's'; 
};
M_.static_tmp_nbr = [9; 2; 0; 0; ];
M_.block_structure_stat.block(1).Simulation_Type = 3;
M_.block_structure_stat.block(1).endo_nbr = 1;
M_.block_structure_stat.block(1).mfs = 1;
M_.block_structure_stat.block(1).equation = [ 11];
M_.block_structure_stat.block(1).variable = [ 12];
M_.block_structure_stat.block(2).Simulation_Type = 6;
M_.block_structure_stat.block(2).endo_nbr = 12;
M_.block_structure_stat.block(2).mfs = 12;
M_.block_structure_stat.block(2).equation = [ 2 3 4 5 6 7 8 9 10 1 12 13];
M_.block_structure_stat.block(2).variable = [ 9 5 8 11 13 2 3 6 4 1 7 10];
M_.block_structure_stat.variable_reordered = [ 12 9 5 8 11 13 2 3 6 4 1 7 10];
M_.block_structure_stat.equation_reordered = [ 11 2 3 4 5 6 7 8 9 10 1 12 13];
M_.block_structure_stat.incidence.sparse_IM = [
 1 1;
 1 5;
 1 9;
 2 6;
 2 9;
 3 1;
 3 4;
 3 5;
 4 3;
 4 5;
 4 8;
 5 11;
 5 13;
 6 7;
 6 8;
 6 13;
 7 1;
 7 2;
 7 7;
 8 2;
 8 3;
 9 3;
 9 6;
 9 7;
 10 4;
 10 5;
 10 7;
 11 12;
 12 7;
 12 10;
 12 12;
 13 10;
 13 11;
];
M_.block_structure_stat.tmp_nbr = 12;
M_.block_structure_stat.block(1).g1_sparse_rowval = int32([1 ]);
M_.block_structure_stat.block(1).g1_sparse_colval = int32([1 ]);
M_.block_structure_stat.block(1).g1_sparse_colptr = int32([1 2 ]);
M_.block_structure_stat.block(2).g1_sparse_rowval = int32([1 10 2 3 9 10 3 5 4 12 4 5 6 7 3 7 8 1 8 2 9 2 6 10 5 6 8 9 11 11 12 ]);
M_.block_structure_stat.block(2).g1_sparse_colval = int32([1 1 2 2 2 2 3 3 4 4 5 5 6 6 7 7 7 8 8 9 9 10 10 10 11 11 11 11 11 12 12 ]);
M_.block_structure_stat.block(2).g1_sparse_colptr = int32([1 3 7 9 11 13 15 18 20 22 25 30 32 ]);
M_.static_g1_sparse_rowval = int32([1 3 7 7 8 4 8 9 3 10 1 3 4 10 2 9 6 7 9 10 12 4 6 1 2 12 13 5 13 11 12 5 6 ]);
M_.static_g1_sparse_colval = int32([1 1 1 2 2 3 3 3 4 4 5 5 5 5 6 6 7 7 7 7 7 8 8 9 9 10 10 11 11 12 12 13 13 ]);
M_.static_g1_sparse_colptr = int32([1 4 6 9 11 15 17 22 24 26 28 30 32 34 ]);
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
M_.params(8) = 0.02;
deltae = M_.params(8);
M_.params(9) = 0.8;
rho_xi = M_.params(9);
M_.params(13) = 0.20;
xi_bar = M_.params(13);
M_.params(10) = 1.00;
B = M_.params(10);
M_.params(11) = 0.1;
phi = M_.params(11);
M_.params(12) = 0.0;
Sbar_hat = M_.params(12);
%
% INITVAL instructions
%
options_.initval_file = false;
oo_.exo_steady_state(1) = 1;
oo_.steady_state(5) = 0.33;
oo_.steady_state(3) = 12;
oo_.steady_state(13) = 0.98;
oo_.steady_state(8) = oo_.exo_steady_state(1)*(oo_.steady_state(3)/M_.params(7))^M_.params(1)*oo_.steady_state(5)^(1-M_.params(1));
oo_.steady_state(7) = oo_.steady_state(13)*oo_.steady_state(8);
oo_.steady_state(6) = M_.params(7)*M_.params(1)*oo_.steady_state(7)/oo_.steady_state(3);
oo_.steady_state(4) = (1-M_.params(1))*oo_.steady_state(7)/oo_.steady_state(5);
oo_.steady_state(2) = oo_.steady_state(3)-oo_.steady_state(3)*(1-M_.params(4))/M_.params(7);
oo_.steady_state(1) = oo_.steady_state(7)-oo_.steady_state(2);
oo_.steady_state(9) = (1-oo_.steady_state(5))^(1-M_.params(5))*M_.params(5)*(oo_.steady_state(1)^M_.params(5)*(1-oo_.steady_state(5))^(1-M_.params(5)))^(-M_.params(3))*oo_.steady_state(1)^(M_.params(5)-1);
oo_.steady_state(12) = M_.params(13);
oo_.steady_state(10) = oo_.steady_state(7)*oo_.steady_state(12);
oo_.steady_state(11) = M_.params(7)*oo_.steady_state(7)*oo_.steady_state(12)/(M_.params(6)+M_.params(8));
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
struct('exo_det',false,'exo_id',1,'type','level','periods',50:150,'value',1.1) ];
M_.det_shocks = [ M_.det_shocks;
struct('exo_det',false,'exo_id',1,'type','level','periods',151:200,'value',1) ];
M_.exo_det_length = 0;
options_.periods = 200;
oo_ = perfect_foresight_setup(M_, options_, oo_);
[oo_, Simulated_time_series] = perfect_foresight_solver(M_, options_, oo_);


oo_.time = toc(tic0);
disp(['Total computing time : ' dynsec2hms(oo_.time) ]);
if ~exist([M_.dname filesep 'Output'],'dir')
    mkdir(M_.dname,'Output');
end
save([M_.dname filesep 'Output' filesep 'damage_high_results.mat'], 'oo_', 'M_', 'options_');
if exist('estim_params_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'damage_high_results.mat'], 'estim_params_', '-append');
end
if exist('bayestopt_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'damage_high_results.mat'], 'bayestopt_', '-append');
end
if exist('dataset_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'damage_high_results.mat'], 'dataset_', '-append');
end
if exist('estimation_info', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'damage_high_results.mat'], 'estimation_info', '-append');
end
if exist('dataset_info', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'damage_high_results.mat'], 'dataset_info', '-append');
end
if exist('oo_recursive_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'damage_high_results.mat'], 'oo_recursive_', '-append');
end
if exist('options_mom_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'damage_high_results.mat'], 'options_mom_', '-append');
end
if ~isempty(lastwarn)
  disp('Note: warning(s) encountered in MATLAB/Octave code')
end
