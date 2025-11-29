%% ============================================================
% Script : run_baseline_tax_BAU.m
% Objectif :
%   - simuler le modèle avec croissance + climat
%     SANS CHOC DE TAXE (baseline "BAU")
%   - reconstruire les variables non stationnaires
%   - sauvegarder dans baseline_tax_BAU.mat
% ============================================================

clear; close all; clc;

%mod_file = 'basic_rbc_with_growth_and_ges';  
mod_file = 'basic_rbc_no_shock';  

% --- Lancer Dynare sur le .mod de référence, SANS modifier le bloc shocks ---
dynare(mod_file, 'noclearall');

% ========= Reconstitution des niveaux non stationnaires =========
gamma = gamm;                             % paramètre du .mod : 1+g
T      = size(oo_.endo_simul, 2) - 1;     % colonnes = t=0..T
tgrid  = 0:T;
trend  = gamma.^tgrid;                    % (1+g)^t

getv = @(name) oo_.endo_simul(strcmp(cellstr(M_.endo_names), name), :);

% Stationnarisées (déjà "avec chapeau")
y_hat  = getv('y');
c_hat  = getv('c');
k_hat  = getv('k');
i_hat  = getv('invest');
g_hat  = getv('g');
e_hat  = getv('e');
s_hat  = getv('s');

% Niveau non stationnaire = chapeau * trend
Y_ns = y_hat .* trend;
C_ns = c_hat .* trend;
K_ns = k_hat .* trend;
I_ns = i_hat .* trend;
G_ns = g_hat .* trend;
E_ns = e_hat .* trend;
S_ns = s_hat .* trend;

% Stocker dans une structure baseline cohérente avec all_res
base_res = struct();
base_res.t      = tgrid;
base_res.y      = y_hat;
base_res.c      = c_hat;
base_res.k      = k_hat;
base_res.invest = i_hat;
base_res.g      = g_hat;
base_res.e      = e_hat;
base_res.s      = s_hat;

base_res.Y_ns = Y_ns;
base_res.C_ns = C_ns;
base_res.K_ns = K_ns;
base_res.I_ns = I_ns;
base_res.G_ns = G_ns;
base_res.E_ns = E_ns;
base_res.S_ns = S_ns;

base_res.tax_name = 'Baseline (sans choc de taxe)';

save('data_raw/baseline_tax_BAU.mat','base_res');

fprintf(' Baseline sauvegardée dans baseline_tax_BAU.mat\n');
