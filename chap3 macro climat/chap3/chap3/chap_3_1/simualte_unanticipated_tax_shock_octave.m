%% =========================================
% simulate_unanticipated_tax_shock_octave.m
% Objectif :
%  - Construire un choc "non anticipé" à t = T_shock
%    à partir de deux simulations perfect foresight :
%    1) BAU (sans choc)
%    2) choc de taxe à t=1
%  - RECONSTRUIRE les niveaux non stationnaires directement
%    à partir de oo_.endo_simul
%  - Exporter les trajectoires en CSV pour faire les IRF dans R
% ==========================================

clear; close all; clc;

%-------------------------------------------
% 0. Paramètres de timing
%-------------------------------------------
T_shock   = 50;    % date à laquelle le choc SURPREND l’économie
T_sim     = 300;   % horizon max de simulation du scénario avec choc
T_irf_max = 150;   % horizon max exporté pour IRF

% Assurer que le répertoire de sortie existe
if ~exist('data_raw', 'dir')
    mkdir('data_raw');
end

%% Helper pour récupérer une variable endogène
getv = @(name, M, oo) oo.endo_simul(strcmp(cellstr(M.endo_names), name), :);

%% =========================================
% 1. Scénario BAU (sans choc)
%    -> mod file : basic_rbc_no_shock.mod
% =========================================
dynare basic_rbc_no_shock noclearall

% Paramètre de tendance
gamma = M_.params(strcmp(cellstr(M_.param_names),'gamm'));   % = 1+g

Tlen_bau   = size(oo_.endo_simul, 2);   % t=0..T
tgrid_bau  = 0:(Tlen_bau-1);
trend_bau  = gamma.^tgrid_bau;

% Variables stationnarisées
y_hat_bau  = getv('y', M_, oo_);
c_hat_bau  = getv('c', M_, oo_);
k_hat_bau  = getv('k', M_, oo_);
e_hat_bau  = getv('e', M_, oo_);
s_hat_bau  = getv('s', M_, oo_);

% Reconstitution des niveaux non stationnaires
Y_bau = y_hat_bau .* trend_bau;
C_bau = c_hat_bau .* trend_bau;
K_bau = k_hat_bau .* trend_bau;
E_bau = e_hat_bau .* trend_bau;
S_bau = s_hat_bau .* trend_bau;

% On ne garde que ce qu’il faut avant le choc pour construire le scénario "non anticipé"
T_bau = min(Tlen_bau, T_shock);    % nb de points BAU utilisés (0..T_bau-1)

Y_bau_cut = Y_bau(1:T_bau);
C_bau_cut = C_bau(1:T_bau);
K_bau_cut = K_bau(1:T_bau);
E_bau_cut = E_bau(1:T_bau);
S_bau_cut = S_bau(1:T_bau);

%% =========================================
% 2. Scénario avec choc anticipé à t=1
%    -> mod file : basic_rbc_with_growth_and_ges.mod
%       (même modèle mais AVEC bloc "shocks" sur la taxe)
% =========================================
dynare basic_rbc_with_growth_and_ges noclearall

% On récupère à nouveau gamma (même valeur normalement)
gamma2 = M_.params(strcmp(cellstr(M_.param_names),'gamm'));
if abs(gamma2 - gamma) > 1e-10
    warning('gamm diffère entre les deux runs, ce n’est pas attendu.');
end

Tlen_shock   = size(oo_.endo_simul, 2);  % t=0..T2
tgrid_shock  = 0:(Tlen_shock-1);
trend_shock  = gamma.^tgrid_shock;

% Variables stationnarisées
y_hat_shock  = getv('y', M_, oo_);
c_hat_shock  = getv('c', M_, oo_);
k_hat_shock  = getv('k', M_, oo_);
e_hat_shock  = getv('e', M_, oo_);
s_hat_shock  = getv('s', M_, oo_);

% Reconstitution des niveaux
Y_shock = y_hat_shock .* trend_shock;
C_shock = c_hat_shock .* trend_shock;
K_shock = k_hat_shock .* trend_shock;
E_shock = e_hat_shock .* trend_shock;
S_shock = s_hat_shock .* trend_shock;

% Tronquer à T_sim si besoin (t=0..T_sim => longueur T_sim+1)
T2 = min(Tlen_shock, T_sim+1);

Y_shock = Y_shock(1:T2);
C_shock = C_shock(1:T2);
K_shock = K_shock(1:T2);
E_shock = E_shock(1:T2);
S_shock = S_shock(1:T2);

%% =========================================
% 3. Construction du scénario "non anticipé"
%    Interprétation :
%    - t=0 .. T_shock-1 : on suit BAU
%    - t=T_shock        : on branche sur la trajectoire "choc à t=1"
%      du second scénario.
% =========================================

L1 = T_bau;               % longueur du segment BAU utilisé
L2 = length(Y_shock);     % longueur de la trajectoire choc

t_full = 0:(L1 + L2 - 1); % vecteur temps aligné avec les séries concaténées

Y_full = [Y_bau_cut, Y_shock];
C_full = [C_bau_cut, C_shock];
K_full = [K_bau_cut, K_shock];
E_full = [E_bau_cut, E_shock];
S_full = [S_bau_cut, S_shock];

% Horizon IRF exporté : on ne va pas au-delà de ce qu’on a pour la BAU
T_irf = min([T_irf_max, length(t_full), length(Y_bau)]);

t_irf = t_full(1:T_irf);
Y_irf = Y_full(1:T_irf);
C_irf = C_full(1:T_irf);
K_irf = K_full(1:T_irf);
E_irf = E_full(1:T_irf);
S_irf = S_full(1:T_irf);

% BAU sur le même horizon (t=0..T_irf-1)
Y_bau_irf = Y_bau(1:T_irf);
C_bau_irf = C_bau(1:T_irf);
K_bau_irf = K_bau(1:T_irf);
E_bau_irf = E_bau(1:T_irf);
S_bau_irf = S_bau(1:T_irf);

%% =========================================
% 4. Export CSV pour IRF dans R
%     Format long :
%       scenario,variable,t,level,baseline_level,dev_pct
%     scenario ∈ {baseline, unanticipated}
% =========================================

outfile = 'data_raw/unanticipated_tax_irf.csv';
fid = fopen(outfile, 'w');
if fid == -1
    error('Impossible de créer le fichier %s', outfile);
end

% En-tête
fprintf(fid, 'scenario,variable,t,level,baseline_level,dev_pct\n');

% ---- Variables que l'on exporte ----
varnames = {'Y','C','K','E','S'};

for v = 1:numel(varnames)
    varname = varnames{v};
    
    % Choix des séries selon la variable
    switch varname
        case 'Y'
            bau_series = Y_bau_irf;
            irf_series = Y_irf;
        case 'C'
            bau_series = C_bau_irf;
            irf_series = C_irf;
        case 'K'
            bau_series = K_bau_irf;
            irf_series = K_irf;
        case 'E'
            bau_series = E_bau_irf;
            irf_series = E_irf;
        case 'S'
            bau_series = S_bau_irf;
            irf_series = S_irf;
    end
    
    % --- Lignes pour la baseline ---
    for k = 1:T_irf
        tval = t_irf(k);
        level_bau = bau_series(k);
        fprintf(fid, 'baseline,%s,%d,%.10g,%.10g,%.10g\n', ...
                varname, tval, level_bau, level_bau, 0);
    end
    
    % --- Lignes pour le scénario non anticipé ---
    for k = 1:T_irf
        tval = t_irf(k);
        level_scen = irf_series(k);
        level_bau = bau_series(k);
        dev_pct = 100 * (level_scen - level_bau) ./ level_bau;
        
        fprintf(fid, 'unanticipated,%s,%d,%.10g,%.10g,%.10g\n', ...
                varname, tval, level_scen, level_bau, dev_pct);
    end
end

fclose(fid);

fprintf('IRF "non anticipé" exportées dans %s\n', outfile);
