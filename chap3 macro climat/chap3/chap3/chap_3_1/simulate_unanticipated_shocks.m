%% =========================================
% simulate_unanticipated_tax_shock.m
% Objectif :
%  - Construire un choc "non anticipé" à t = T_shock
%    à partir de deux simulations perfect foresight :
%    1) BAU (sans choc)
%    2) choc de taxe à t=1
%  - RECONSTRUIRE les niveaux non stationnaires directement
%    à partir de oo_.endo_simul (pas de oo_.nonstationary)
% ==========================================

clear; close all; clc;

%-------------------------------------------
% 0. Paramètres de timing
%-------------------------------------------
T_shock = 50;    % date à laquelle le choc SURPREND l’économie
T_sim   = 300;   % horizon max de simulation du scénario avec choc
T_plot  = 150;   % nb max de périodes affichées sur le graphique

%% Helper pour récupérer une variable endogène
getv = @(name, M, oo) oo.endo_simul(strcmp(cellstr(M.endo_names), name), :);

%% =========================================
% 1. Scénario BAU (sans choc)
%    -> mod file : basic_rbc_with_growth_noshock.mod
%       (même modèle mais SANS bloc "shocks; ... end;")
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

% On ne garde que ce qu’il faut avant le choc
T_bau = min(Tlen_bau, T_shock);    % nb de points BAU utilisés (0..T_bau-1)

Y_bau_cut = Y_bau(1:T_bau);
C_bau_cut = C_bau(1:T_bau);
K_bau_cut = K_bau(1:T_bau);
E_bau_cut = E_bau(1:T_bau);
S_bau_cut = S_bau(1:T_bau);

%% =========================================
% 2. Scénario avec choc (anticipé à t=1 dans ce modèle)
%    -> mod file : basic_rbc_with_growth_tax.mod
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

% Tronquer à T_sim si besoin
T2 = min(Tlen_shock, T_sim+1);   % si t=0..T_sim => longueur T_sim+1

Y_shock = Y_shock(1:T2);
C_shock = C_shock(1:T2);
K_shock = K_shock(1:T2);
E_shock = E_shock(1:T2);
S_shock = S_shock(1:T2);

%% =========================================
% 3. Re-calage en "non anticipé"
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

% Option : limiter la fenêtre de tracé
T_plot = min(T_plot, length(t_full));
t_plot = t_full(1:T_plot);

Y_plot = Y_full(1:T_plot);
C_plot = C_full(1:T_plot);
K_plot = K_full(1:T_plot);
E_plot = E_full(1:T_plot);
S_plot = S_full(1:T_plot);

%% =========================================
% 4. Graphiques en niveaux : BAU vs choc non anticipé
% =========================================

figure('Position',[100 100 1400 900]);

subplot(2,3,1); hold on; box on; grid on;
plot(t_plot, Y_plot, 'LineWidth',2);
yline(Y_bau(1), '--k','BAU','LineWidth',1.2);
xline(T_shock, ':r','Choc','LineWidth',1.2);
title('PIB (niveau)'); xlabel('t'); ylabel('Y');

subplot(2,3,2); hold on; box on; grid on;
plot(t_plot, C_plot, 'LineWidth',2);
yline(C_bau(1), '--k','BAU','LineWidth',1.2);
xline(T_shock, ':r','Choc','LineWidth',1.2);
title('Consommation'); xlabel('t');

subplot(2,3,3); hold on; box on; grid on;
plot(t_plot, K_plot, 'LineWidth',2);
yline(K_bau(1), '--k','BAU','LineWidth',1.2);
xline(T_shock, ':r','Choc','LineWidth',1.2);
title('Capital'); xlabel('t');

subplot(2,3,4); hold on; box on; grid on;
plot(t_plot, E_plot, 'LineWidth',2);
yline(E_bau(1), '--k','BAU','LineWidth',1.2);
xline(T_shock, ':r','Choc','LineWidth',1.2);
title('Émissions'); xlabel('t');

subplot(2,3,5); hold on; box on; grid on;
plot(t_plot, S_plot, 'LineWidth',2);
yline(S_bau(1), '--k','BAU','LineWidth',1.2);
xline(T_shock, ':r','Choc','LineWidth',1.2);
title('Stock de GES'); xlabel('t');

sgtitle(sprintf('Choc de taxe "non anticipé" à t = %d', T_shock), 'FontWeight','bold');

saveas(gcf, sprintf('figures/unanticipated_tax_shock_levels_Tshock%d.png', T_shock));
