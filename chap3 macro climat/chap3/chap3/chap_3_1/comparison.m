%% =========================================
% compare_anticipated_vs_unanticipated.m
% Objectif :
%   - Comparer choc de taxe anticipé vs non anticipé
%   - Niveaux non stationnaires (Y, C, K, E, S)
%   - BAU en pointillé comme benchmark
% ==========================================

clear; close all; clc;

%% ------------------------
% Paramètres globaux
% -------------------------
T_shock_calendar = 50;   % date à laquelle le choc est "révélé" (non anticipé)
T_sim_max        = 400;  % horizon max (pour ne pas tracer 1000 périodes)
T_plot           = 150;  % fenêtre max de tracé

%% Helper pour récupérer une variable endogène
getv = @(name, M, oo) oo.endo_simul(strcmp(cellstr(M.endo_names), name), :);

%% =========================================
% 1. Scénario BAU (sans choc)
%    -> mod file : basic_rbc_with_growth_noshock.mod
%       (même modèle que "tax" mais SANS bloc shocks)
% =========================================
dynare basic_rbc_no_shock noclearall

% Sauvegarder M_, oo_ (Dynare va les écraser après)
M_bau  = M_;
oo_bau = oo_;

% Paramètre de trend gamm = 1+g
param_names = cellstr(M_bau.param_names);
gamma = M_bau.params(strcmp(param_names,'gamm'));

% Longueur et tendance
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
%    -> mod file : basic_rbc_with_growth_tax.mod
%       (bloc shocks : ex. var tau_y; periods 1:40; values 0.3;)
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
%    Idée :
%      - De t = 0 à T_shock_calendar-1 : on suit BAU (aucune anticipation)
%      - A t = T_shock_calendar, on bascule sur la trajectoire "choc à t=1"
%        du scénario anticipé.
% =========================================

% On coupe BAU si besoin
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
% 4. Préparation pour le tracé
% =========================================

% Fenêtre max d’affichage
T_plot = min(T_plot, min([Tlen_bau, Tlen_tax + T_shock_calendar, L_unant]));

t_plot = 0:(T_plot-1);

% Interpoler/couper les séries sur t_plot
Y_bau_plot   = Y_bau(1:T_plot);
C_bau_plot   = C_bau(1:T_plot);
K_bau_plot   = K_bau(1:T_plot);
E_bau_plot   = E_bau(1:T_plot);
S_bau_plot   = S_bau(1:T_plot);

Y_tax_plot   = Y_tax(1:min(T_plot, length(Y_tax)));
C_tax_plot   = C_tax(1:min(T_plot, length(C_tax)));
K_tax_plot   = K_tax(1:min(T_plot, length(K_tax)));
E_tax_plot   = E_tax(1:min(T_plot, length(E_tax)));
S_tax_plot   = S_tax(1:min(T_plot, length(S_tax)));

Y_unant_plot = Y_unant(1:min(T_plot, length(Y_unant)));
C_unant_plot = C_unant(1:min(T_plot, length(C_unant)));
K_unant_plot = K_unant(1:min(T_plot, length(K_unant)));
E_unant_plot = E_unant(1:min(T_plot, length(E_unant)));
S_unant_plot = S_unant(1:min(T_plot, length(S_unant)));

%% =========================================
% 5. Graphiques : BAU vs choc anticipé vs non anticipé
% =========================================

figure('Position',[50 50 1500 900]);

style_bau   = {'--','Color',[0.3 0.3 0.3],'LineWidth',1.5};
style_ant   = {'-','Color',[0.85 0.1 0.1],'LineWidth',2};
style_unant = {'-','Color',[0.1 0.1 0.8],'LineWidth',2};

% --- PIB ---
subplot(2,3,1); hold on; box on; grid on;
plot(t_plot, Y_bau_plot,   style_bau{:});
plot(t_plot(1:length(Y_tax_plot)),   Y_tax_plot,   style_ant{:});
plot(t_plot(1:length(Y_unant_plot)), Y_unant_plot, style_unant{:});
%xline(1,              ':r','anticipé','LineWidth',1);
xline(100,              ':b','anticipé','LineWidth',1);
xline(T_shock_calendar,':b','non anticipé','LineWidth',1);
xlabel(''); ylabel('Y (niveau)');
title('PIB');
legend({'BAU','Choc anticipé','Choc non anticipé'},'Location','best');

% --- Consommation ---
subplot(2,3,2); hold on; box on; grid on;
plot(t_plot, C_bau_plot,   style_bau{:});
plot(t_plot(1:length(C_tax_plot)),   C_tax_plot,   style_ant{:});
plot(t_plot(1:length(C_unant_plot)), C_unant_plot, style_unant{:});
%xline(1,              ':r','anticipé','LineWidth',1);
xline(100,              ':b','anticipé','LineWidth',1);
xline(T_shock_calendar,':b','non anticipé','LineWidth',1);
xlabel(''); ylabel('C (niveau)');
title('Consommation');

% --- Capital ---
subplot(2,3,3); hold on; box on; grid on;
plot(t_plot, K_bau_plot,   style_bau{:});
plot(t_plot(1:length(K_tax_plot)),   K_tax_plot,   style_ant{:});
plot(t_plot(1:length(K_unant_plot)), K_unant_plot, style_unant{:});
%xline(1,              ':r','anticipé','LineWidth',1);
xline(100,              ':b','anticipé','LineWidth',1);
xline(T_shock_calendar,':b','non anticipé','LineWidth',1);
xlabel(''); ylabel('K (niveau)');
title('Capital');

% --- Emissions ---
subplot(2,3,4); hold on; box on; grid on;
plot(t_plot, E_bau_plot,   style_bau{:});
plot(t_plot(1:length(E_tax_plot)),   E_tax_plot,   style_ant{:});
plot(t_plot(1:length(E_unant_plot)), E_unant_plot, style_unant{:});
%xline(1,              ':r','anticipé','LineWidth',1);
xline(100,              ':b','anticipé','LineWidth',1);
xline(T_shock_calendar,':b','non anticipé','LineWidth',1);
xlabel(''); ylabel('E (niveau)');
title('Émissions');

% --- Stock de GES ---
subplot(2,3,5); hold on; box on; grid on;
plot(t_plot, S_bau_plot,   style_bau{:});
plot(t_plot(1:length(S_tax_plot)),   S_tax_plot,   style_ant{:});
plot(t_plot(1:length(S_unant_plot)), S_unant_plot, style_unant{:});
%xline(1,              ':r','anticipé','LineWidth',1);
xline(100,              ':b','anticipé','LineWidth',1);
xline(T_shock_calendar,':b','non anticipé','LineWidth',1);
xlabel(''); ylabel('S (niveau)');
title('Stock de GES');

sgtitle(sprintf('Choc de taxe anticipé (T_{shock} = 100) vs non anticipé (T_{shock} = %d)', ...
                T_shock_calendar), 'FontWeight','bold');

saveas(gcf, sprintf('figures/compare_tax_shock_anticipated_vs_unanticipated_T%d.png', ...
                    T_shock_calendar));
