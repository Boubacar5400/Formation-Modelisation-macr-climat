%% 
% Compare 3 scénarios de politique climatique dans basic_rbc_with_climate :
%   - baseline      : inaction
%   - policy_light  : politique modérée et précoce
%   - policy_strong : politique forte mais tardive
%
% Le script :
%  1) lance Dynare pour chaque .mod
%  2) reconstruit les niveaux non stationnarisés
%  3) trace Y, E, S pour les 3 scénarios
%  4) trace un "MACC dynamique" :
%       - % d'émissions abattues vs baseline
%       - coût d'abattement (% du PIB)
%
% Nécessite :
%   - baseline.mod
%   - policy_light.mod
%   - policy_strong.mod
%   - basic_rbc_with_climate.mod (pour les paramètres, identiques)

clear; close all; clc;

%% ----------------------------------------------------
% 1. Définition des scénarios
% -----------------------------------------------------
scenarios = {
    'baseline',      'Baseline (inaction)';
    'policy_light',  'Politique modérée PRÉCOCE';
    'policy_strong', 'Politique FORTE mais TARDIVE';
};

n_scen = size(scenarios, 1);
colors = lines(n_scen);   % palette automatique

results = struct();

%% ----------------------------------------------------
% 2. Boucle sur les scénarios : lancer Dynare + récupérer les séries
% -----------------------------------------------------
for j = 1:n_scen
    modname = scenarios{j,1};
    label   = scenarios{j,2};
    
    fprintf('\n========================================\n');
    fprintf('=== Scénario %d / %d : %s ===\n', j, n_scen, label);
    fprintf('Fichier .mod : %s.mod\n', modname);
    fprintf('========================================\n');
    
    % Lancer Dynare en silencieux
    eval_output = evalc(['dynare ' modname ' noclearall']);
    
    % On suppose que perfect_foresight_solver a convergé
    if ~contains(eval_output, 'Perfect foresight solution found')
        warning('Attention : le scénario %s n''a peut-être pas convergé.', modname);
    end
    
    % Récupérer la grille de temps Dynare (t = 0..T)
    Tlen = size(oo_.endo_simul, 2);   % colonnes = t=0..T
    tgrid = 0:(Tlen-1);
    
    % Récupérer gamma
    param_names = cellstr(M_.param_names);
    idx_gamm = strcmp(param_names, 'gamm');
    if ~any(idx_gamm)
        error('Paramètre "gamm" introuvable dans M_.param_names');
    end
    gamma = M_.params(idx_gamm);
    
    % Tendance (1+g)^t
    trend = gamma.^tgrid;
    
    % Helper pour les endogènes
    endo_names = cellstr(M_.endo_names);
    getv = @(name) oo_.endo_simul(strcmp(endo_names, name), :);
    
    % Variables stationnarisées
    y_hat   = getv('y');
    c_hat   = getv('c');
    k_hat   = getv('k');
    e_hat   = getv('e');
    s_hat   = getv('s');
    psi_hat = getv('psi');   % coût d'abattement
    % (même si psi = 0 en baseline, ce sera utile pour les politiques)
    
    % Niveaux non stationnarisés
    Y_ns = y_hat .* trend;
    C_ns = c_hat .* trend;
    K_ns = k_hat .* trend;
    E_ns = e_hat .* trend;
    S_ns = s_hat .* trend;
    
    % Stocker dans la structure
    results(j).modname = modname;
    results(j).label   = label;
    results(j).t       = tgrid;
    results(j).gamma   = gamma;
    
    results(j).y_hat   = y_hat;
    results(j).c_hat   = c_hat;
    results(j).k_hat   = k_hat;
    results(j).e_hat   = e_hat;
    results(j).s_hat   = s_hat;
    results(j).psi_hat = psi_hat;
    
    results(j).Y_ns = Y_ns;
    results(j).C_ns = C_ns;
    results(j).K_ns = K_ns;
    results(j).E_ns = E_ns;
    results(j).S_ns = S_ns;
end

%% ----------------------------------------------------
% 3. Harmoniser l'horizon d'affichage
% -----------------------------------------------------
% On affiche jusqu'à T_display (min de tous les scénarios, max 240)
T_display = min(240, min(arrayfun(@(r) numel(r.t), results)) - 1);
idx = 1:(T_display+1);   % car t va de 0 à T_display

fprintf('\nHorizon d''affichage : 0..%d\n', T_display);

% Baseline = premier scénario
baseline = results(1);

%% ----------------------------------------------------
% 4. Créer dossier figures
% -----------------------------------------------------
if ~exist('figures', 'dir')
    mkdir('figures');
end

%% ----------------------------------------------------
% 5. Graphique Y (niveaux non stationnarisés)
% -----------------------------------------------------
figure('Position', [100 100 1200 700]); hold on; grid on; box on;

for j = 1:n_scen
    plot(results(j).t(idx), results(j).Y_ns(idx), ...
        'LineWidth', 2, 'Color', colors(j,:));
end

xlabel('Temps (périodes)');
ylabel('Y_t (niveau)');
title('Production nette (niveaux) : baseline vs politiques');
legend({results.label}, 'Location', 'best', 'Interpreter', 'none');
set(gca, 'FontSize', 12);

saveas(gcf, 'figures/policies_Y_levels.png');

%% ----------------------------------------------------
% 6. Graphique E (émissions, niveaux non stationnarisés)
% -----------------------------------------------------
figure('Position', [150 150 1200 700]); hold on; grid on; box on;

for j = 1:n_scen
    plot(results(j).t(idx), results(j).E_ns(idx), ...
        'LineWidth', 2, 'Color', colors(j,:));
end

xlabel('Temps (périodes)');
ylabel('E_t (niveau)');
title('Émissions de GES (niveaux) : baseline vs politiques');
legend({results.label}, 'Location', 'best', 'Interpreter', 'none');
set(gca, 'FontSize', 12);

saveas(gcf, 'figures/policies_E_levels.png');

%% ----------------------------------------------------
% 7. Graphique S (stock de GES, niveaux non stationnarisés)
% -----------------------------------------------------
figure('Position', [200 200 1200 700]); hold on; grid on; box on;

for j = 1:n_scen
    plot(results(j).t(idx), results(j).S_ns(idx), ...
        'LineWidth', 2, 'Color', colors(j,:));
end

xlabel('Temps (périodes)');
ylabel('S_t (niveau)');
title('Stock de GES (niveaux) : baseline vs politiques');
legend({results.label}, 'Location', 'best', 'Interpreter', 'none');
set(gca, 'FontSize', 12);

saveas(gcf, 'figures/policies_S_levels.png');

%% ----------------------------------------------------
% 8. "MACC dynamique" :
%    - % d'émissions abattues vs baseline
%    - coût d'abattement (% du PIB)
% -----------------------------------------------------
% Baseline : émissions & y
E_bau = baseline.E_ns(idx);
y_bau_hat = baseline.y_hat(idx);   % pour normaliser les coûts (mais baseline psi=0)

% Pré-allocation
abatement_pct = nan(n_scen, numel(idx));
cost_pct      = nan(n_scen, numel(idx));

for j = 1:n_scen
    % % émissions abattues par rapport à la baseline
    % abatement = 100 * (1 - E_scen / E_bau)
    Ej = results(j).E_ns(idx);
    abatement_pct(j,:) = 100 * (1 - Ej ./ E_bau);
    
    % Coût d'abattement en % du PIB :
    % psi_hat / y_hat (stationnarisées) -> ratio indépendant de la tendance
    psi_hat_j = results(j).psi_hat(idx);
    y_hat_j   = results(j).y_hat(idx);
    cost_pct(j,:) = 100 * (psi_hat_j ./ y_hat_j);   % 0 pour baseline
end

% On trace uniquement pour les scénarios de politique (j >= 2)
figure('Position', [250 250 1200 800]);

subplot(2,1,1); hold on; grid on; box on;
for j = 2:n_scen
    plot(results(j).t(idx), abatement_pct(j,:), ...
         'LineWidth', 2, 'Color', colors(j,:));
end
xlabel('Temps (périodes)');
ylabel('Émissions abattues (% vs baseline)');
title('Émissions abattues par rapport à la baseline');
legend({results(2:end).label}, 'Location', 'best', 'Interpreter', 'none');
set(gca, 'FontSize', 12);
yline(0,'k--','LineWidth',1);

subplot(2,1,2); hold on; grid on; box on;
for j = 2:n_scen
    plot(results(j).t(idx), cost_pct(j,:), ...
         'LineWidth', 2, 'Color', colors(j,:));
end
xlabel('Temps (périodes)');
ylabel('Coût d''abattement (% du PIB)');
title('Coût d''abattement (Ψ/y) pour chaque politique');
legend({results(2:end).label}, 'Location', 'best', 'Interpreter', 'none');
set(gca, 'FontSize', 12);
yline(0,'k--','LineWidth',1);

saveas(gcf, 'figures/policies_dynamic_macc.png');

%% ----------------------------------------------------
% 9. Résumé
% -----------------------------------------------------
fprintf('\n=== Terminé. Graphiques créés dans le dossier "figures/" ===\n');
fprintf('  - policies_Y_levels.png : Y_t (niveaux)\n');
fprintf('  - policies_E_levels.png : E_t (niveaux)\n');
fprintf('  - policies_S_levels.png : S_t (niveaux)\n');
fprintf('  - policies_dynamic_macc.png : émissions abattues et coût (%% PIB)\n');
