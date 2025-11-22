%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main.m — lance 2 runs Dynare + export CSV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc; close all;

% Si besoin : ajouter dynare au path ici
% addpath('/chemin/vers/dynare/matlab');

outdir = 'data_raw';

%% 1) Run 1 : basic_rbc2.mod
disp('=== Run 1 : basic_rbc2.mod ===');
dynare basic_rbc2.mod noclearall

% À ce stade, les globales M_, oo_ contiennent le run basic_rbc2
export_dynare_run('basic_rbc2', outdir, 'simulation_basic_rbc2.csv');


%% 2) Run 2 : basic_rbc_endo_L.mod
disp('=== Run 2 : basic_rbc_endo_L.mod ===');
dynare basic_rbc_endo_L.mod noclearall

% Maintenant M_, oo_ contiennent le run basic_rbc_endo_L
export_dynare_run('basic_rbc_endo_L', outdir, 'simulation_basic_rbc_endo_L.csv');

disp('=== Tout est terminé. Deux CSV générés dans data_raw ===');
