%% =========================================
% main.m
% Comparaison de 3 scénarios de dommages climatiques
% à partir de 3 fichiers .mod distincts
% =========================================

clear all; close all; clc;

%--------------------------------------------------
% 1. PARAMÈTRES DE CONTRÔLE
%--------------------------------------------------
% Horizon d'affichage sur les graphiques (en périodes)
T_display = 100;  % Modifier cette valeur pour zoomer/dézoomer

%--------------------------------------------------
% 2. Configuration des scénarios
%--------------------------------------------------
% Liste des fichiers .mod à exécuter (SANS l'extension .mod)
mod_files = {
    'damage_null'
    'damage_low'
    'damage_high'
};

% Valeurs de phi correspondantes (pour info)
phi_values = [1e-10, 0.01, 0.1];

% Labels pour les graphiques
phi_labels = {
    '\phi \approx 0 (baseline)'
    '\phi = 0{,}01 (modérés)'
    '\phi = 0{,}1 (forts)'
};

n_scen = length(mod_files);
colors = lines(n_scen);

results = struct();
success_flags = false(n_scen, 1);

%--------------------------------------------------
% 3. Boucle sur les scénarios
%--------------------------------------------------
for j = 1:n_scen
    fprintf('\n========================================\n');
    fprintf('=== Scénario %d / %d ===\n', j, n_scen);
    fprintf('Fichier : %s.mod\n', mod_files{j});
    fprintf('phi = %.6f\n', phi_values(j));
    fprintf('========================================\n');
    
    try
        % Exécuter Dynare
        eval_output = evalc(['dynare ' mod_files{j} ' noclearall']);
        
        % Vérifier la convergence
        if contains(eval_output, 'Perfect foresight solution found')
            
            % Helper pour récupérer une variable
            getv = @(name) oo_.endo_simul(strcmp(cellstr(M_.endo_names), name), :);
            
            % Grille temporelle
            tgrid = 0:(size(oo_.endo_simul, 2) - 1);
            
            % Récupérer gamma
            gamma_idx = strcmp(cellstr(M_.param_names), 'gamm');
            gamma = M_.params(gamma_idx);
            
            % Variables stationnarisées
            y_hat = getv('y');
            d_hat = getv('d');
            e_hat = getv('e');
            s_hat = getv('s');
            c_hat = getv('c');
            k_hat = getv('k');
            l_hat = getv('l');
            
            % Conversion en niveaux : X_ns = X_hat * gamma^t
            trend = gamma.^tgrid;
            y_ns = y_hat .* trend;
            e_ns = e_hat .* trend;
            s_ns = s_hat .* trend;
            c_ns = c_hat .* trend;
            k_ns = k_hat .* trend;
            d_ns = d_hat;  % pas de tendance
            l_ns = l_hat;  % pas de tendance
            
            % Stockage
            results(j).phi = phi_values(j);
            results(j).label = phi_labels{j};
            results(j).mod_file = mod_files{j};
            results(j).t = tgrid;
            
            % Variables stationnarisées
            results(j).y_hat = y_hat;
            results(j).e_hat = e_hat;
            results(j).s_hat = s_hat;
            results(j).d_hat = d_hat;
            results(j).c_hat = c_hat;
            results(j).k_hat = k_hat;
            results(j).l_hat = l_hat;
            
            % Variables en niveaux
            results(j).y_ns = y_ns;
            results(j).e_ns = e_ns;
            results(j).s_ns = s_ns;
            results(j).d_ns = d_ns;
            results(j).c_ns = c_ns;
            results(j).k_ns = k_ns;
            results(j).l_ns = l_ns;
            
            success_flags(j) = true;
            fprintf('>>> Scénario %d : SUCCÈS\n', j);
            
        else
            warning('Scénario %d : Pas de convergence', j);
            fprintf('>>> Scénario %d : ÉCHEC (pas de convergence)\n', j);
        end
        
    catch ME
        warning('Erreur pour le scénario %d : %s', j, ME.message);
        fprintf('>>> Scénario %d : ÉCHEC (%s)\n', j, ME.message);
    end
end

% Vérifier qu'au moins un scénario a réussi
if ~any(success_flags)
    error('Aucun scénario n''a convergé !');
end

fprintf('\n========================================\n');
fprintf('Résumé : %d scénario(s) réussi(s) sur %d\n', sum(success_flags), n_scen);
fprintf('========================================\n');

% Filtrer les résultats valides
results_valid = results(success_flags);
phi_labels_valid = phi_labels(success_flags);
colors_valid = colors(success_flags, :);
n_valid = sum(success_flags);

%--------------------------------------------------
% 4. Préparer les indices d'affichage
%--------------------------------------------------
% Limiter l'affichage à T_display périodes
for j = 1:n_valid
    t_max = min(T_display, length(results_valid(j).t) - 1);
    results_valid(j).t_display = results_valid(j).t(1:t_max+1);
    results_valid(j).idx_display = 1:(t_max+1);
end

%--------------------------------------------------
% 5. Créer le dossier Figures
%--------------------------------------------------
if ~exist('figures', 'dir')
    mkdir('figures');
end

%--------------------------------------------------
% 6. Graphiques : Variables stationnarisées (niveaux)
%--------------------------------------------------
figure('Position', [100 100 1400 900]);

subplot(2,2,1); hold on; grid on; box on;
for j = 1:n_valid
    idx = results_valid(j).idx_display;
    plot(results_valid(j).t_display, results_valid(j).y_hat(idx), ...
        'LineWidth', 2, 'Color', colors_valid(j,:));
end
xlabel('Temps'); ylabel('\hat{y}_t');
title('Production stationnarisée');
legend(phi_labels_valid, 'Location', 'best', 'Interpreter', 'tex');

subplot(2,2,2); hold on; grid on; box on;
for j = 1:n_valid
    idx = results_valid(j).idx_display;
    plot(results_valid(j).t_display, results_valid(j).d_hat(idx), ...
        'LineWidth', 2, 'Color', colors_valid(j,:));
end
xlabel('Temps'); ylabel('d_t');
title('Facteur de dommage');
legend(phi_labels_valid, 'Location', 'best', 'Interpreter', 'tex');

subplot(2,2,3); hold on; grid on; box on;
for j = 1:n_valid
    idx = results_valid(j).idx_display;
    plot(results_valid(j).t_display, results_valid(j).e_hat(idx), ...
        'LineWidth', 2, 'Color', colors_valid(j,:));
end
xlabel('Temps'); ylabel('\hat{e}_t');
title('Émissions stationnarisées');
legend(phi_labels_valid, 'Location', 'best', 'Interpreter', 'tex');

subplot(2,2,4); hold on; grid on; box on;
for j = 1:n_valid
    idx = results_valid(j).idx_display;
    plot(results_valid(j).t_display, results_valid(j).s_hat(idx), ...
        'LineWidth', 2, 'Color', colors_valid(j,:));
end
xlabel('Temps'); ylabel('\hat{s}_t');
title('Stock de GES stationnarisé');
legend(phi_labels_valid, 'Location', 'best', 'Interpreter', 'tex');

sgtitle(sprintf('Niveaux (stationnarisés) - Horizon = %d périodes', T_display), ...
    'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, 'figures/climate_feedback_stationary.png');

%--------------------------------------------------
% 7. Graphiques : Niveaux non stationnarisés
%--------------------------------------------------
figure('Position', [100 100 1400 900]);

subplot(2,2,1); hold on; grid on; box on;
for j = 1:n_valid
    idx = results_valid(j).idx_display;
    plot(results_valid(j).t_display, results_valid(j).y_ns(idx), ...
        'LineWidth', 2, 'Color', colors_valid(j,:));
end
xlabel('Temps'); ylabel('Y_t');
title('Production nette (niveaux)');
legend(phi_labels_valid, 'Location', 'best', 'Interpreter', 'tex');

subplot(2,2,2); hold on; grid on; box on;
for j = 1:n_valid
    idx = results_valid(j).idx_display;
    plot(results_valid(j).t_display, results_valid(j).d_ns(idx), ...
        'LineWidth', 2, 'Color', colors_valid(j,:));
end
xlabel('Temps'); ylabel('d_t');
title('Facteur de dommage');
legend(phi_labels_valid, 'Location', 'best', 'Interpreter', 'tex');

subplot(2,2,3); hold on; grid on; box on;
for j = 1:n_valid
    idx = results_valid(j).idx_display;
    plot(results_valid(j).t_display, results_valid(j).e_ns(idx), ...
        'LineWidth', 2, 'Color', colors_valid(j,:));
end
xlabel('Temps'); ylabel('E_t');
title('Émissions (niveaux)');
legend(phi_labels_valid, 'Location', 'best', 'Interpreter', 'tex');

subplot(2,2,4); hold on; grid on; box on;
for j = 1:n_valid
    idx = results_valid(j).idx_display;
    plot(results_valid(j).t_display, results_valid(j).s_ns(idx), ...
        'LineWidth', 2, 'Color', colors_valid(j,:));
end
xlabel('Temps'); ylabel('S_t');
title('Stock de GES (niveaux)');
legend(phi_labels_valid, 'Location', 'best', 'Interpreter', 'tex');

sgtitle(sprintf('Niveaux (non stationnarisés) - Horizon = %d périodes', T_display), ...
    'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, 'figures/climate_feedback_levels.png');

%--------------------------------------------------
% 8. Graphiques : DÉVIATIONS par rapport à la baseline (stationnarisé)
%--------------------------------------------------
if n_valid > 1
    figure('Position', [100 100 1400 900]);
    
    % Référence = premier scénario (sans dommages)
    baseline = results_valid(1);
    idx_base = baseline.idx_display;
    
    subplot(2,2,1); hold on; grid on; box on;
    for j = 2:n_valid
        idx = results_valid(j).idx_display;
        % Déviation en pourcentage
        dev_y = 100 * (results_valid(j).y_hat(idx) - baseline.y_hat(idx_base)) ./ baseline.y_hat(idx_base);
        plot(results_valid(j).t_display, dev_y, 'LineWidth', 2, 'Color', colors_valid(j,:));
    end
    xlabel('Temps'); ylabel('Déviation (%)');
    title('Production \hat{y}_t');
    legend(phi_labels_valid(2:end), 'Location', 'best', 'Interpreter', 'tex');
    yline(0, '--k', 'LineWidth', 1);
    
    subplot(2,2,2); hold on; grid on; box on;
    for j = 2:n_valid
        idx = results_valid(j).idx_display;
        % Déviation en pourcentage
        dev_c = 100 * (results_valid(j).c_hat(idx) - baseline.c_hat(idx_base)) ./ baseline.c_hat(idx_base);
        plot(results_valid(j).t_display, dev_c, 'LineWidth', 2, 'Color', colors_valid(j,:));
    end
    xlabel('Temps'); ylabel('Déviation (%)');
    title('Consommation \hat{c}_t');
    legend(phi_labels_valid(2:end), 'Location', 'best', 'Interpreter', 'tex');
    yline(0, '--k', 'LineWidth', 1);
    
    subplot(2,2,3); hold on; grid on; box on;
    for j = 2:n_valid
        idx = results_valid(j).idx_display;
        % Déviation en pourcentage
        dev_k = 100 * (results_valid(j).k_hat(idx) - baseline.k_hat(idx_base)) ./ baseline.k_hat(idx_base);
        plot(results_valid(j).t_display, dev_k, 'LineWidth', 2, 'Color', colors_valid(j,:));
    end
    xlabel('Temps'); ylabel('Déviation (%)');
    title('Capital \hat{k}_t');
    legend(phi_labels_valid(2:end), 'Location', 'best', 'Interpreter', 'tex');
    yline(0, '--k', 'LineWidth', 1);
    
    subplot(2,2,4); hold on; grid on; box on;
    for j = 2:n_valid
        idx = results_valid(j).idx_display;
        % Déviation en points de pourcentage pour le travail
        dev_l = 100 * (results_valid(j).l_hat(idx) - baseline.l_hat(idx_base));
        plot(results_valid(j).t_display, dev_l, 'LineWidth', 2, 'Color', colors_valid(j,:));
    end
    xlabel('Temps'); ylabel('Déviation (pp)');
    title('Travail l_t');
    legend(phi_labels_valid(2:end), 'Location', 'best', 'Interpreter', 'tex');
    yline(0, '--k', 'LineWidth', 1);
    
    sgtitle(sprintf('Déviations vs baseline (stationnarisé) - Horizon = %d périodes', T_display), ...
        'FontSize', 14, 'FontWeight', 'bold');
    saveas(gcf, 'figures/climate_deviations_stationary.png');
end

%--------------------------------------------------
% 9. Graphiques : DÉVIATIONS par rapport à la baseline (niveaux)
%--------------------------------------------------
if n_valid > 1
    figure('Position', [100 100 1400 900]);
    
    baseline = results_valid(1);
    idx_base = baseline.idx_display;
    
    subplot(2,2,1); hold on; grid on; box on;
    for j = 2:n_valid
        idx = results_valid(j).idx_display;
        dev_y = 100 * (results_valid(j).y_ns(idx) - baseline.y_ns(idx_base)) ./ baseline.y_ns(idx_base);
        plot(results_valid(j).t_display, dev_y, 'LineWidth', 2, 'Color', colors_valid(j,:));
    end
    xlabel('Temps'); ylabel('Déviation (%)');
    title('Production Y_t');
    legend(phi_labels_valid(2:end), 'Location', 'best', 'Interpreter', 'tex');
    yline(0, '--k', 'LineWidth', 1);
    
    subplot(2,2,2); hold on; grid on; box on;
    for j = 2:n_valid
        idx = results_valid(j).idx_display;
        dev_c = 100 * (results_valid(j).c_ns(idx) - baseline.c_ns(idx_base)) ./ baseline.c_ns(idx_base);
        plot(results_valid(j).t_display, dev_c, 'LineWidth', 2, 'Color', colors_valid(j,:));
    end
    xlabel('Temps'); ylabel('Déviation (%)');
    title('Consommation C_t');
    legend(phi_labels_valid(2:end), 'Location', 'best', 'Interpreter', 'tex');
    yline(0, '--k', 'LineWidth', 1);
    
    subplot(2,2,3); hold on; grid on; box on;
    for j = 2:n_valid
        idx = results_valid(j).idx_display;
        dev_e = 100 * (results_valid(j).e_ns(idx) - baseline.e_ns(idx_base)) ./ baseline.e_ns(idx_base);
        plot(results_valid(j).t_display, dev_e, 'LineWidth', 2, 'Color', colors_valid(j,:));
    end
    xlabel('Temps'); ylabel('Déviation (%)');
    title('Émissions E_t');
    legend(phi_labels_valid(2:end), 'Location', 'best', 'Interpreter', 'tex');
    yline(0, '--k', 'LineWidth', 1);
    
    subplot(2,2,4); hold on; grid on; box on;
    for j = 2:n_valid
        idx = results_valid(j).idx_display;
        dev_s = 100 * (results_valid(j).s_ns(idx) - baseline.s_ns(idx_base)) ./ baseline.s_ns(idx_base);
        plot(results_valid(j).t_display, dev_s, 'LineWidth', 2, 'Color', colors_valid(j,:));
    end
    xlabel('Temps'); ylabel('Déviation (%)');
    title('Stock de GES S_t');
    legend(phi_labels_valid(2:end), 'Location', 'best', 'Interpreter', 'tex');
    yline(0, '--k', 'LineWidth', 1);
    
    sgtitle(sprintf('Déviations vs baseline (niveaux) - Horizon = %d périodes', T_display), ...
        'FontSize', 14, 'FontWeight', 'bold');
    saveas(gcf, 'figures/climate_deviations_levels.png');
end

%--------------------------------------------------
% 10. Graphique : Facteur de dommage
%--------------------------------------------------
if n_valid > 1
    figure('Position', [100 100 1000 400]);
    
    baseline = results_valid(1);
    idx_base = baseline.idx_display;
    
    subplot(1,2,1); hold on; grid on; box on;
    for j = 1:n_valid
        idx = results_valid(j).idx_display;
        plot(results_valid(j).t_display, results_valid(j).d_hat(idx), ...
            'LineWidth', 2, 'Color', colors_valid(j,:));
    end
    xlabel('Temps'); ylabel('d_t');
    title('Facteur de dommage (niveau)');
    legend(phi_labels_valid, 'Location', 'best', 'Interpreter', 'tex');
    
    subplot(1,2,2); hold on; grid on; box on;
    for j = 2:n_valid
        idx = results_valid(j).idx_display;
        % Perte = 1 - d (en %)
        perte = 100 * (1 - results_valid(j).d_hat(idx));
        plot(results_valid(j).t_display, perte, 'LineWidth', 2, 'Color', colors_valid(j,:));
    end
    xlabel('Temps'); ylabel('Perte (%)');
    title('Perte de productivité (1-d_t)');
    legend(phi_labels_valid(2:end), 'Location', 'best', 'Interpreter', 'tex');
    yline(0, '--k', 'LineWidth', 1);
    
    sgtitle(sprintf('Facteur de dommage climatique - Horizon = %d périodes', T_display), ...
        'FontSize', 14, 'FontWeight', 'bold');
    saveas(gcf, 'figures/climate_damage_factor.png');
end

%--------------------------------------------------
% 11. Sauvegarde des résultats
%--------------------------------------------------
if ~exist('data_raw', 'dir')
    mkdir('data_raw');
end
save('data_raw/climate_feedback_results_levels.mat', 'results', 'success_flags', 'T_display');

fprintf('\n========================================\n');
fprintf('=== Analyse terminée ! ===\n');
fprintf('========================================\n');
fprintf('Scénarios réussis : %d / %d\n', sum(success_flags), n_scen);
fprintf('Horizon d''affichage : %d périodes\n', T_display);
fprintf('\nGraphiques sauvegardés dans : Figures/\n');
fprintf('  - climate_feedback_stationary.png (niveaux stationnarisés)\n');
fprintf('  - climate_feedback_levels.png (niveaux)\n');
if n_valid > 1
    fprintf('  - climate_deviations_stationary.png (déviations vs baseline, stationnarisé)\n');
    fprintf('  - climate_deviations_levels.png (déviations vs baseline, niveaux)\n');
    fprintf('  - climate_damage_factor.png (facteur de dommage)\n');
end
fprintf('\nRésultats sauvegardés dans : data_raw/climate_feedback_results_levels.mat\n');