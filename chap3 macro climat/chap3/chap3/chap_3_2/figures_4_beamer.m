%% =========================================
% extract_figures_for_beamer.m
% Extraction de sous-graphiques individuels
% et calcul de statistiques pour les diapos
% =========================================

clear all; close all; clc;

%--------------------------------------------------
% 1. Charger les résultats
%--------------------------------------------------
load('data_raw/climate_feedback_results_levels.mat');

% Filtrer les résultats valides
results_valid = results(success_flags);
n_valid = sum(success_flags);

if n_valid < 2
    error('Pas assez de scénarios valides pour faire les comparaisons');
end

% Paramètres
colors = lines(n_valid);
T_display = 200;  % Ajuster si différent

% Baseline = premier scénario (sans dommages)
baseline = results_valid(1);

% Créer le dossier pour les figures Beamer
if ~exist('figures/Beamer', 'dir')
    mkdir('figures/Beamer');
end

%--------------------------------------------------
% 2. Extraire les sous-graphiques individuels
%--------------------------------------------------
fprintf('Extraction des sous-graphiques individuels...\n');

% 2.1 Production (stationnarisé)
figure('Position', [100 100 800 600]);
hold on; grid on; box on;
for j = 1:n_valid
    idx = min(T_display, length(results_valid(j).t)-1) + 1;
    t_plot = results_valid(j).t(1:idx);
    plot(t_plot, results_valid(j).y_hat(1:idx), 'LineWidth', 2.5, 'Color', colors(j,:));
end
% Marquer la période du choc (supposé t=50-150)
xline(50, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
xline(150, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
xlabel('Temps', 'FontSize', 12);
ylabel('\hat{y}_t', 'FontSize', 12);
title('Production stationnarisée', 'FontSize', 14, 'FontWeight', 'bold');
legend({results_valid.label}, 'Location', 'best', 'Interpreter', 'tex', 'FontSize', 10);
set(gca, 'FontSize', 11);
saveas(gcf, 'figures/Beamer/climate_feedback_stationary_y.png');

% 2.2 Production (niveaux)
figure('Position', [100 100 800 600]);
hold on; grid on; box on;
for j = 1:n_valid
    idx = min(T_display, length(results_valid(j).t)-1) + 1;
    t_plot = results_valid(j).t(1:idx);
    plot(t_plot, results_valid(j).y_ns(1:idx), 'LineWidth', 2.5, 'Color', colors(j,:));
end
xline(50, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
xline(150, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
xlabel('Temps', 'FontSize', 12);
ylabel('Y_t', 'FontSize', 12);
title('Production (niveaux)', 'FontSize', 14, 'FontWeight', 'bold');
legend({results_valid.label}, 'Location', 'best', 'Interpreter', 'tex', 'FontSize', 10);
set(gca, 'FontSize', 11);
saveas(gcf, 'figures/Beamer/climate_feedback_levels_y.png');

% 2.3 Déviation production (stationnarisé)
figure('Position', [100 100 800 600]);
hold on; grid on; box on;
for j = 2:n_valid
    idx = min(T_display, length(results_valid(j).t)-1) + 1;
    idx_base = min(T_display, length(baseline.t)-1) + 1;
    t_plot = results_valid(j).t(1:idx);
    dev_y = 100 * (results_valid(j).y_hat(1:idx) - baseline.y_hat(1:idx_base)) ./ baseline.y_hat(1:idx_base);
    plot(t_plot, dev_y, 'LineWidth', 2.5, 'Color', colors(j,:));
end
xline(50, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
xline(150, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
yline(0, '--r', 'LineWidth', 1.2);
xlabel('Temps', 'FontSize', 12);
ylabel('Déviation (%)', 'FontSize', 12);
title('Perte de production vs baseline (stationnarisé)', 'FontSize', 14, 'FontWeight', 'bold');
legend({results_valid(2:end).label}, 'Location', 'best', 'Interpreter', 'tex', 'FontSize', 10);
set(gca, 'FontSize', 11);
saveas(gcf, 'figures/Beamer/climate_deviations_stationary_y.png');

% 2.4 Déviation production (niveaux)
figure('Position', [100 100 800 600]);
hold on; grid on; box on;
for j = 2:n_valid
    idx = min(T_display, length(results_valid(j).t)-1) + 1;
    idx_base = min(T_display, length(baseline.t)-1) + 1;
    t_plot = results_valid(j).t(1:idx);
    dev_y = 100 * (results_valid(j).y_ns(1:idx) - baseline.y_ns(1:idx_base)) ./ baseline.y_ns(1:idx_base);
    plot(t_plot, dev_y, 'LineWidth', 2.5, 'Color', colors(j,:));
end
xline(50, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
xline(150, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
yline(0, '--r', 'LineWidth', 1.2);
xlabel('Temps', 'FontSize', 12);
ylabel('Déviation (%)', 'FontSize', 12);
title('Perte de production vs baseline (niveaux)', 'FontSize', 14, 'FontWeight', 'bold');
legend({results_valid(2:end).label}, 'Location', 'best', 'Interpreter', 'tex', 'FontSize', 10);
set(gca, 'FontSize', 11);
saveas(gcf, 'figures/Beamer/climate_deviations_levels_y.png');

% 2.5 Facteur de dommage (niveau)
figure('Position', [100 100 800 600]);
hold on; grid on; box on;
for j = 1:n_valid
    idx = min(T_display, length(results_valid(j).t)-1) + 1;
    t_plot = results_valid(j).t(1:idx);
    plot(t_plot, results_valid(j).d_hat(1:idx), 'LineWidth', 2.5, 'Color', colors(j,:));
end
xline(50, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
xline(150, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
xlabel('Temps', 'FontSize', 12);
ylabel('d_t', 'FontSize', 12);
title('Facteur de dommage', 'FontSize', 14, 'FontWeight', 'bold');
legend({results_valid.label}, 'Location', 'best', 'Interpreter', 'tex', 'FontSize', 10);
set(gca, 'FontSize', 11);
saveas(gcf, 'figures/Beamer/climate_damage_factor_level.png');

% 2.6 Perte de productivité (1-d_t)
figure('Position', [100 100 800 600]);
hold on; grid on; box on;
for j = 2:n_valid
    idx = min(T_display, length(results_valid(j).t)-1) + 1;
    t_plot = results_valid(j).t(1:idx);
    perte = 100 * (1 - results_valid(j).d_hat(1:idx));
    plot(t_plot, perte, 'LineWidth', 2.5, 'Color', colors(j,:));
end
xline(50, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
xline(150, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
yline(0, '--r', 'LineWidth', 1.2);
xlabel('Temps', 'FontSize', 12);
ylabel('Perte (%)', 'FontSize', 12);
title('Perte de productivité (1-d_t)', 'FontSize', 14, 'FontWeight', 'bold');
legend({results_valid(2:end).label}, 'Location', 'best', 'Interpreter', 'tex', 'FontSize', 10);
set(gca, 'FontSize', 11);
saveas(gcf, 'figures/Beamer/climate_damage_factor_loss.png');

% 2.7 Émissions
figure('Position', [100 100 800 600]);
hold on; grid on; box on;
for j = 1:n_valid
    idx = min(T_display, length(results_valid(j).t)-1) + 1;
    t_plot = results_valid(j).t(1:idx);
    plot(t_plot, results_valid(j).e_hat(1:idx), 'LineWidth', 2.5, 'Color', colors(j,:));
end
xline(50, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
xline(150, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
xlabel('Temps', 'FontSize', 12);
ylabel('\hat{e}_t', 'FontSize', 12);
title('Émissions de GES', 'FontSize', 14, 'FontWeight', 'bold');
legend({results_valid.label}, 'Location', 'best', 'Interpreter', 'tex', 'FontSize', 10);
set(gca, 'FontSize', 11);
saveas(gcf, 'figures/Beamer/climate_emissions.png');

% 2.8 Stock de GES
figure('Position', [100 100 800 600]);
hold on; grid on; box on;
for j = 1:n_valid
    idx = min(T_display, length(results_valid(j).t)-1) + 1;
    t_plot = results_valid(j).t(1:idx);
    plot(t_plot, results_valid(j).s_hat(1:idx), 'LineWidth', 2.5, 'Color', colors(j,:));
end
xline(50, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
xline(150, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
xlabel('Temps', 'FontSize', 12);
ylabel('\hat{s}_t', 'FontSize', 12);
title('Stock atmosphérique de GES', 'FontSize', 14, 'FontWeight', 'bold');
legend({results_valid.label}, 'Location', 'best', 'Interpreter', 'tex', 'FontSize', 10);
set(gca, 'FontSize', 11);
saveas(gcf, 'figures/Beamer/climate_stock.png');

% 2.9 Consommation (déviation)
figure('Position', [100 100 800 600]);
hold on; grid on; box on;
for j = 2:n_valid
    idx = min(T_display, length(results_valid(j).t)-1) + 1;
    idx_base = min(T_display, length(baseline.t)-1) + 1;
    t_plot = results_valid(j).t(1:idx);
    dev_c = 100 * (results_valid(j).c_hat(1:idx) - baseline.c_hat(1:idx_base)) ./ baseline.c_hat(1:idx_base);
    plot(t_plot, dev_c, 'LineWidth', 2.5, 'Color', colors(j,:));
end
xline(50, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
xline(150, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
yline(0, '--r', 'LineWidth', 1.2);
xlabel('Temps', 'FontSize', 12);
ylabel('Déviation (%)', 'FontSize', 12);
title('Consommation - déviation vs baseline', 'FontSize', 14, 'FontWeight', 'bold');
legend({results_valid(2:end).label}, 'Location', 'best', 'Interpreter', 'tex', 'FontSize', 10);
set(gca, 'FontSize', 11);
saveas(gcf, 'figures/Beamer/climate_deviations_consumption.png');

% 2.10 Capital (déviation)
figure('Position', [100 100 800 600]);
hold on; grid on; box on;
for j = 2:n_valid
    idx = min(T_display, length(results_valid(j).t)-1) + 1;
    idx_base = min(T_display, length(baseline.t)-1) + 1;
    t_plot = results_valid(j).t(1:idx);
    dev_k = 100 * (results_valid(j).k_hat(1:idx) - baseline.k_hat(1:idx_base)) ./ baseline.k_hat(1:idx_base);
    plot(t_plot, dev_k, 'LineWidth', 2.5, 'Color', colors(j,:));
end
xline(50, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
xline(150, '--k', 'LineWidth', 1.5, 'Alpha', 0.4);
yline(0, '--r', 'LineWidth', 1.2);
xlabel('Temps', 'FontSize', 12);
ylabel('Déviation (%)', 'FontSize', 12);
title('Capital - déviation vs baseline', 'FontSize', 14, 'FontWeight', 'bold');
legend({results_valid(2:end).label}, 'Location', 'best', 'Interpreter', 'tex', 'FontSize', 10);
set(gca, 'FontSize', 11);
saveas(gcf, 'figures/Beamer/climate_deviations_capital.png');

%--------------------------------------------------
% 3. Graphique de persistance (zoom post-choc)
%--------------------------------------------------
fprintf('Création du graphique de persistance...\n');

figure('Position', [100 100 800 600]);
hold on; grid on; box on;
for j = 1:n_valid
    % Zoom sur t=140:200
    idx_start = find(results_valid(j).t >= 140, 1);
    idx_end = min(find(results_valid(j).t >= 200, 1), length(results_valid(j).t));
    if isempty(idx_end)
        idx_end = length(results_valid(j).t);
    end
    t_zoom = results_valid(j).t(idx_start:idx_end);
    s_zoom = results_valid(j).s_hat(idx_start:idx_end);
    plot(t_zoom, s_zoom, 'LineWidth', 2.5, 'Color', colors(j,:));
end
xline(150, '--k', 'LineWidth', 1.5, 'Alpha', 0.4, 'Label', 'Fin du choc', 'LabelHorizontalAlignment', 'left');
xlabel('Temps', 'FontSize', 12);
ylabel('\hat{s}_t', 'FontSize', 12);
title('Persistance du stock de GES après le choc', 'FontSize', 14, 'FontWeight', 'bold');
legend({results_valid.label}, 'Location', 'best', 'Interpreter', 'tex', 'FontSize', 10);
set(gca, 'FontSize', 11);
saveas(gcf, 'figures/Beamer/climate_stock_persistence.png');

%--------------------------------------------------
% 4. Calcul des statistiques
%--------------------------------------------------
fprintf('\nCalcul des statistiques...\n');

% Paramètres
beta = 0.95;  % Facteur d'actualisation

stats = struct();

for j = 1:n_valid
    idx = min(T_display, length(results_valid(j).t)-1) + 1;
    
    % Déviations par rapport à la baseline (si j>1)
    if j > 1
        idx_base = min(T_display, length(baseline.t)-1) + 1;
        dev_y_hat = 100 * (results_valid(j).y_hat(1:idx) - baseline.y_hat(1:idx_base)) ./ baseline.y_hat(1:idx_base);
        dev_y_ns = 100 * (results_valid(j).y_ns(1:idx) - baseline.y_ns(1:idx_base)) ./ baseline.y_ns(1:idx_base);
        
        % Statistiques descriptives
        stats(j).perte_moy_hat = mean(dev_y_hat);
        stats(j).perte_max_hat = min(dev_y_hat);  % min car négatif
        stats(j).perte_moy_ns = mean(dev_y_ns);
        stats(j).perte_max_ns = min(dev_y_ns);
        
        % Perte au dernier point (t=200 ou max disponible)
        stats(j).perte_finale_hat = dev_y_hat(end);
        stats(j).perte_finale_ns = dev_y_ns(end);
        
        % VAN des pertes (stationnarisé)
        discount_factors = beta.^(0:idx-1);
        perte_absolue_hat = baseline.y_hat(1:idx_base) .* (-dev_y_hat / 100);
        stats(j).VAN_perte_hat = sum(discount_factors' .* perte_absolue_hat);
        
        % VAN des pertes (niveaux)
        perte_absolue_ns = baseline.y_ns(1:idx_base) .* (-dev_y_ns / 100);
        stats(j).VAN_perte_ns = sum(discount_factors' .* perte_absolue_ns);
        
    else
        % Baseline : pas de perte
        stats(j).perte_moy_hat = 0;
        stats(j).perte_max_hat = 0;
        stats(j).perte_moy_ns = 0;
        stats(j).perte_max_ns = 0;
        stats(j).perte_finale_hat = 0;
        stats(j).perte_finale_ns = 0;
        stats(j).VAN_perte_hat = 0;
        stats(j).VAN_perte_ns = 0;
    end
    
    % Dommages max
    stats(j).damage_max = max(1 - results_valid(j).d_hat(1:idx)) * 100;
    stats(j).damage_final = (1 - results_valid(j).d_hat(idx)) * 100;
end

%--------------------------------------------------
% 5. Tableau récapitulatif
%--------------------------------------------------
fprintf('\n========================================\n');
fprintf('STATISTIQUES RÉCAPITULATIVES\n');
fprintf('========================================\n\n');

fprintf('%-25s | %-15s | %-15s | %-15s\n', 'Scénario', 'Baseline', results_valid(2).label, results_valid(3).label);
fprintf('--------------------------|-----------------|-----------------|------------------\n');
fprintf('%-25s | %14.2f%% | %14.2f%% | %14.2f%%\n', 'Perte moy. (statio.)', ...
    stats(1).perte_moy_hat, stats(2).perte_moy_hat, stats(3).perte_moy_hat);
fprintf('%-25s | %14.2f%% | %14.2f%% | %14.2f%%\n', 'Perte max (statio.)', ...
    stats(1).perte_max_hat, stats(2).perte_max_hat, stats(3).perte_max_hat);
fprintf('%-25s | %14.2f%% | %14.2f%% | %14.2f%%\n', 'Perte finale (statio.)', ...
    stats(1).perte_finale_hat, stats(2).perte_finale_hat, stats(3).perte_finale_hat);
fprintf('%-25s | %14.2f%% | %14.2f%% | %14.2f%%\n', 'Dommage max (1-d)', ...
    stats(1).damage_max, stats(2).damage_max, stats(3).damage_max);
fprintf('%-25s | %14.2f%% | %14.2f%% | %14.2f%%\n', 'Dommage final', ...
    stats(1).damage_final, stats(2).damage_final, stats(3).damage_final);
fprintf('%-25s | %14.4f | %14.4f | %14.4f\n', 'VAN pertes (statio.)', ...
    stats(1).VAN_perte_hat, stats(2).VAN_perte_hat, stats(3).VAN_perte_hat);
fprintf('\n');

%--------------------------------------------------
% 6. Graphique : Histogramme des pertes moyennes
%--------------------------------------------------
fprintf('Création du graphique comparatif des pertes...\n');

figure('Position', [100 100 800 600]);
x_cat = categorical({results_valid(2:end).label});
y_pertes = [stats(2:end).perte_moy_hat];
bar(x_cat, abs(y_pertes), 'FaceColor', [0.8 0.2 0.2], 'EdgeColor', 'k', 'LineWidth', 1.5);
ylabel('Perte moyenne (%)', 'FontSize', 12);
title('Coût macroéconomique moyen des dommages', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 11);
saveas(gcf, 'figures/Beamer/climate_cost_comparison.png');

%--------------------------------------------------
% 7. Sauvegarder les statistiques
%--------------------------------------------------
save('climate_statistics.mat', 'stats', 'results_valid');

fprintf('\n========================================\n');
fprintf('EXTRACTION TERMINÉE !\n');
fprintf('========================================\n');
fprintf('Figures sauvegardées dans : figures/Beamer/\n');
fprintf('Statistiques sauvegardées dans : climate_statistics.mat\n');
fprintf('\nUtiliser ces valeurs dans les diapos Beamer :\n');
fprintf('  - Perte moy. scénario modéré : %.2f%%\n', stats(2).perte_moy_hat);
fprintf('  - Perte max scénario modéré : %.2f%%\n', stats(2).perte_max_hat);
fprintf('  - Perte moy. scénario sévère : %.2f%%\n', stats(3).perte_moy_hat);
fprintf('  - Perte max scénario sévère : %.2f%%\n', stats(3).perte_max_hat);
fprintf('  - Dommage max modéré : %.2f%%\n', stats(2).damage_max);
fprintf('  - Dommage max sévère : %.2f%%\n', stats(3).damage_max);