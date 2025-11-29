%% =========================================
% compare_anticipated_vs_unanticipated_octave.m
% Objectif :
%   - Comparer choc de taxe anticipé vs non anticipé
%   - Niveaux non stationnaires (Y, C, K, E, S)
%   - BAU comme benchmark
%   - Export CSV pour graphiques en R
% ==========================================

clear; close all; clc;

%% ------------------------
% Paramètres globaux
% -------------------------
T_shock_calendar = 50;   % date à laquelle le choc est "révélé" (non anticipé)
T_sim_max        = 400;  % horizon max (pour limiter la simulation)
T_export_max     = 150;  % horizon max exporté pour comparaison

if ~exist('data_raw','dir')
    mkdir('data_raw');
end

%% Helper pour récupérer une variable endogène
getv = @(name, M, oo) oo.endo_simul(strcmp(cellstr(M.endo_names), name), :);

%% =========================================
% 1. Scénario BAU (sans choc)
%    -> mod file : basic_rbc_no_shock.mod
% =========================================
dynare basic_rbc_no_shock noclearall

M_bau  = M_;
oo_bau = oo_;

param_names = cellstr(M_bau.param_names);
gamma = M_bau.params(strcmp(param_names,'gamm'));   % = 1+g

Tlen_bau  = size(oo_bau.endo_simul, 2);    % t = 0..T
t_bau     = 0:(Tlen_bau-1);
trend_bau = gamma.^t_bau;

% Variables stationnarisées BAU
y_hat_bau = getv('y', M_bau, oo_bau);
c_hat_bau = getv('c', M_bau, oo_bau);
k_hat_bau = getv('k', M_bau, oo_bau);
e_hat_bau = getv('e', M_bau, oo_bau);
s_hat_bau = getv('s', M_bau, oo_bau);

% Niveaux non stationnaires BAU
Y_bau = y_hat_bau .* trend_bau;
C_bau = c_hat_bau .* trend_bau;
K_bau = k_hat_bau .* trend_bau;
E_bau = e_hat_bau .* trend_bau;
S_bau = s_hat_bau .* trend_bau;

%% =========================================
% 2. Scénario avec choc anticipé à t=1
%    -> mod file : basic_rbc_with_growth_and_ges.mod
% =========================================
dynare basic_rbc_with_growth_and_ges noclearall

M_tax  = M_;
oo_tax = oo_;

param_names2 = cellstr(M_tax.param_names);
gamma2 = M_tax.params(strcmp(param_names2,'gamm'));

if abs(gamma2 - gamma) > 1e-10
    warning('gamm diffère entre BAU et TAX, ce n’est pas attendu.');
end

Tlen_tax  = size(oo_tax.endo_simul, 2);   % t = 0..T2
t_tax     = 0:(Tlen_tax-1);
trend_tax = gamma.^t_tax;

% Variables stationnarisées sous choc anticipé
y_hat_tax = getv('y', M_tax, oo_tax);
c_hat_tax = getv('c', M_tax, oo_tax);
k_hat_tax = getv('k', M_tax, oo_tax);
e_hat_tax = getv('e', M_tax, oo_tax);
s_hat_tax = getv('s', M_tax, oo_tax);

% Niveaux non stationnaires (choc anticipé)
Y_tax = y_hat_tax .* trend_tax;
C_tax = c_hat_tax .* trend_tax;
K_tax = k_hat_tax .* trend_tax;
E_tax = e_hat_tax .* trend_tax;
S_tax = s_hat_tax .* trend_tax;

% Tronquer si trop long
Tlen_tax = min(Tlen_tax, T_sim_max+1);
Y_tax = Y_tax(1:Tlen_tax);
C_tax = C_tax(1:Tlen_tax);
K_tax = K_tax(1:Tlen_tax);
E_tax = E_tax(1:Tlen_tax);
S_tax = S_tax(1:Tlen_tax);
t_tax = t_tax(1:Tlen_tax);

%% =========================================
% 3. Construire le scénario "non anticipé"
%    - t = 0 .. T_shock_calendar-1 : BAU
%    - t = T_shock_calendar ..     : on colle la trajectoire TAX
% =========================================

T_bau_used = min(Tlen_bau, T_shock_calendar);
Y_bau_cut  = Y_bau(1:T_bau_used);
C_bau_cut  = C_bau(1:T_bau_used);
K_bau_cut  = K_bau(1:T_bau_used);
E_bau_cut  = E_bau(1:T_bau_used);
S_bau_cut  = S_bau(1:T_bau_used);

% Trajectoire non anticipée = BAU jusqu'au choc, puis trajectoire TAX
Y_unant = [Y_bau_cut, Y_tax];
C_unant = [C_bau_cut, C_tax];
K_unant = [K_bau_cut, K_tax];
E_unant = [E_bau_cut, E_tax];
S_unant = [S_bau_cut, S_tax];

L_unant = length(Y_unant);
t_unant = 0:(L_unant-1);

%% =========================================
% 4. Définir l'horizon exporté commun
% =========================================

T_export = min([T_export_max, Tlen_bau, Tlen_tax, L_unant]);

t_exp = 0:(T_export-1);

Y_bau_exp   = Y_bau(1:T_export);
C_bau_exp   = C_bau(1:T_export);
K_bau_exp   = K_bau(1:T_export);
E_bau_exp   = E_bau(1:T_export);
S_bau_exp   = S_bau(1:T_export);

Y_tax_exp   = Y_tax(1:T_export);
C_tax_exp   = C_tax(1:T_export);
K_tax_exp   = K_tax(1:T_export);
E_tax_exp   = E_tax(1:T_export);
S_tax_exp   = S_tax(1:T_export);

Y_unant_exp = Y_unant(1:T_export);
C_unant_exp = C_unant(1:T_export);
K_unant_exp = K_unant(1:T_export);
E_unant_exp = E_unant(1:T_export);
S_unant_exp = S_unant(1:T_export);

%% =========================================
% 5. Export CSV (format long) pour R
%     Colonnes :
%       scenario ∈ {baseline, anticipated, unanticipated}
%       variable ∈ {Y,C,K,E,S}
%       t
%       level          (niveau du scénario)
%       baseline_level (niveau BAU)
%       dev_pct        (écart % vs BAU)
% =========================================

outfile = 'data_raw/compare_anticipated_vs_unanticipated.csv';
fid = fopen(outfile, 'w');
if fid == -1
    error('Impossible de créer le fichier %s', outfile);
end

% En-tête
fprintf(fid, 'scenario,variable,t,level,baseline_level,dev_pct\n');

varnames = {'Y','C','K','E','S'};

for v = 1:numel(varnames)
    varname = varnames{v};
    
    switch varname
        case 'Y'
            bau_series   = Y_bau_exp;
            ant_series   = Y_tax_exp;
            unant_series = Y_unant_exp;
        case 'C'
            bau_series   = C_bau_exp;
            ant_series   = C_tax_exp;
            unant_series = C_unant_exp;
        case 'K'
            bau_series   = K_bau_exp;
            ant_series   = K_tax_exp;
            unant_series = K_unant_exp;
        case 'E'
            bau_series   = E_bau_exp;
            ant_series   = E_tax_exp;
            unant_series = E_unant_exp;
        case 'S'
            bau_series   = S_bau_exp;
            ant_series   = S_tax_exp;
            unant_series = S_unant_exp;
    end
    
    for k = 1:T_export
        tval = t_exp(k);
        bval = bau_series(k);
        
        % Baseline
        fprintf(fid, 'baseline,%s,%d,%.10g,%.10g,%.10g\n', ...
                varname, tval, bval, bval, 0);
        
        % Choc anticipé
        aval = ant_series(k);
        dev_ant = 100 * (aval - bval) ./ bval;
        fprintf(fid, 'anticipated,%s,%d,%.10g,%.10g,%.10g\n', ...
                varname, tval, aval, bval, dev_ant);
        
        % Choc non anticipé
        uval = unant_series(k);
        dev_unant = 100 * (uval - bval) ./ bval;
        fprintf(fid, 'unanticipated,%s,%d,%.10g,%.10g,%.10g\n', ...
                varname, tval, uval, bval, dev_unant);
    end
end

fclose(fid);

fprintf('Comparaison anticipé / non anticipé exportée dans %s\n', outfile);
