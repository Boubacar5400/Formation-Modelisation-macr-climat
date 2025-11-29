%% =========================================
% extract_stats_for_beamer_octave.m
% Objectif :
%   - Charger les résultats Dynare (MAT)
%   - Calculer les statistiques pour les diapos
%   - Sauvegarder en MAT + CSV
%   - AUCUN GRAPHIQUE ici (tout sera fait sous R)
% =========================================

clear all; close all; clc;

%--------------------------------------------------
% 1. Charger les résultats
%--------------------------------------------------
load('data_raw/climate_feedback_results_levels.mat');  % results, success_flags, T_display (éventuel)

results_valid = results(success_flags);
n_valid = sum(success_flags);

if n_valid < 2
    error('Pas assez de scénarios valides pour faire les comparaisons');
end

% Si T_display n'est pas dans le MAT, on en fixe un par défaut
if ~exist('T_display','var')
    T_display = 200;
end

% Baseline = premier scénario (sans dommages)
baseline = results_valid(1);

%--------------------------------------------------
% 2. Calcul des statistiques
%--------------------------------------------------
fprintf('\nCalcul des statistiques...\n');

beta = 0.95;  % Facteur d'actualisation (comme dans le script original)

stats = struct();

for j = 1:n_valid
    % horizon commun tronqué
    idx = min(T_display, length(results_valid(j).t)-1) + 1;
    
    % Informations de base sur le scénario
    stats(j).label = results_valid(j).label;
    stats(j).mod_file = results_valid(j).mod_file;
    
    % Déviations par rapport à la baseline (si j>1)
    if j > 1
        idx_base = min(T_display, length(baseline.t)-1) + 1;
        
        % Production (stationnarisée et niveaux)
        dev_y_hat = 100 * (results_valid(j).y_hat(1:idx) - baseline.y_hat(1:idx_base)) ./ baseline.y_hat(1:idx_base);
        dev_y_ns  = 100 * (results_valid(j).y_ns(1:idx)  - baseline.y_ns(1:idx_base))  ./ baseline.y_ns(1:idx_base);
        
        % Statistiques descriptives
        stats(j).perte_moy_hat   = mean(dev_y_hat);
        stats(j).perte_max_hat   = min(dev_y_hat);  % min car négatif (perte max)
        stats(j).perte_moy_ns    = mean(dev_y_ns);
        stats(j).perte_max_ns    = min(dev_y_ns);
        
        % Perte au dernier point (t = T_display ou max disponible)
        stats(j).perte_finale_hat = dev_y_hat(end);
        stats(j).perte_finale_ns  = dev_y_ns(end);
        
        % VAN des pertes (stationnarisé)
        discount_factors = beta.^(0:idx-1);
        perte_absolue_hat = baseline.y_hat(1:idx_base) .* (-dev_y_hat / 100); % pertes en niveau
        stats(j).VAN_perte_hat = sum(discount_factors' .* perte_absolue_hat);
        
        % VAN des pertes (niveaux)
        perte_absolue_ns = baseline.y_ns(1:idx_base) .* (-dev_y_ns / 100);
        stats(j).VAN_perte_ns = sum(discount_factors' .* perte_absolue_ns);
        
    else
        % Baseline : pas de perte
        stats(j).perte_moy_hat    = 0;
        stats(j).perte_max_hat    = 0;
        stats(j).perte_moy_ns     = 0;
        stats(j).perte_max_ns     = 0;
        stats(j).perte_finale_hat = 0;
        stats(j).perte_finale_ns  = 0;
        stats(j).VAN_perte_hat    = 0;
        stats(j).VAN_perte_ns     = 0;
    end
    
    % Dommages max / final (1 - d_t)
    d_series = results_valid(j).d_hat(1:idx);
    stats(j).damage_max   = max(1 - d_series) * 100;
    stats(j).damage_final = (1 - d_series(end)) * 100;
end

%--------------------------------------------------
% 3. Sauvegarde des statistiques (MAT + CSV)
%--------------------------------------------------
if ~exist('data_raw','dir')
    mkdir('data_raw');
end

save('data_raw/climate_statistics.mat', 'stats', 'results_valid', 'T_display');

% Écriture CSV
csv_file = 'data_raw/climate_statistics.csv';
fid = fopen(csv_file, 'w');
if fid == -1
    error('Impossible de créer le fichier %s', csv_file);
end

% En-tête
fprintf(fid, ['scenario_label,mod_file,perte_moy_hat,perte_max_hat,', ...
              'perte_finale_hat,perte_moy_ns,perte_max_ns,perte_finale_ns,', ...
              'VAN_perte_hat,VAN_perte_ns,damage_max,damage_final\n']);

for j = 1:n_valid
    fprintf(fid, '"%s","%s",%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g\n', ...
        stats(j).label, stats(j).mod_file, ...
        stats(j).perte_moy_hat, stats(j).perte_max_hat, stats(j).perte_finale_hat, ...
        stats(j).perte_moy_ns,  stats(j).perte_max_ns,  stats(j).perte_finale_ns,  ...
        stats(j).VAN_perte_hat, stats(j).VAN_perte_ns, ...
        stats(j).damage_max,    stats(j).damage_final);
end

fclose(fid);

%--------------------------------------------------
% 4. Résumé console 
%--------------------------------------------------
fprintf('\n========================================\n');
fprintf('STATISTIQUES RÉCAPITULATIVES (T_display = %d)\n', T_display);
fprintf('========================================\n\n');

for j = 1:n_valid
    fprintf('Scénario : %s\n', stats(j).label);
    fprintf('  - Perte moy. (statio.)      : %.2f %%\n', stats(j).perte_moy_hat);
    fprintf('  - Perte max (statio.)       : %.2f %%\n', stats(j).perte_max_hat);
    fprintf('  - Perte finale (statio.)    : %.2f %%\n', stats(j).perte_finale_hat);
    fprintf('  - Dommage max (1-d)         : %.2f %%\n', stats(j).damage_max);
    fprintf('  - Dommage final (1-d)       : %.2f %%\n', stats(j).damage_final);
    fprintf('  - VAN pertes (statio.)      : %.4f\n', stats(j).VAN_perte_hat);
    fprintf('  - VAN pertes (niveaux)      : %.4f\n\n', stats(j).VAN_perte_ns);
end

fprintf('Statistiques sauvegardées dans :\n');
fprintf('  - data_raw/climate_statistics.mat\n');
fprintf('  - data_raw/climate_statistics.csv\n');
