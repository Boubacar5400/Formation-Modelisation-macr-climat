%% =========================================
% main_octave.m
% Comparaison de 3 scénarios de dommages climatiques
% -> exécute Dynare, reconstruit les séries
% -> exporte un CSV long pour graphiques dans R
% =========================================

clear all; close all; clc;

%--------------------------------------------------
% 1. PARAMÈTRES DE CONTRÔLE
%--------------------------------------------------
% Horizon d'affichage / d'export (en périodes)
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
    'phi = 0 (baseline)'
    'phi = 0,01 (modérés)'
    'phi = 0,1 (forts)'
};

n_scen = length(mod_files);
colors = lines(n_scen);  % utile si tu veux quand même faire des graphes un jour

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
        % Exécuter Dynare en capturant la sortie texte
        eval_output = evalc(['dynare ' mod_files{j} ' noclearall']);
        
        % Vérifier la convergence
        if ~isempty(strfind(eval_output, 'Perfect foresight solution found'))
            
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
phi_values_valid = phi_values(success_flags);
n_valid = sum(success_flags);

%--------------------------------------------------
% 4. Préparer les indices d'affichage / export
%--------------------------------------------------
for j = 1:n_valid
    t_max = min(T_display, length(results_valid(j).t) - 1);
    results_valid(j).t_display = results_valid(j).t(1:t_max+1);
    results_valid(j).idx_display = 1:(t_max+1);
end

%--------------------------------------------------
% 5. Sauvegarde MAT brute (pour debug si besoin)
%--------------------------------------------------
if ~exist('data_raw', 'dir')
    mkdir('data_raw');
end
save('data_raw/climate_feedback_results_levels.mat', 'results', 'success_flags', 'T_display');

%--------------------------------------------------
% 6. Export CSV long pour R
%   Colonnes :
%     scenario_id      (nom du .mod)
%     scenario_label   (phi_label)
%     phi
%     kind             ('hat' ou 'ns')
%     variable         ('y','d','e','s','c','k','l')
%     t
%     level
%     baseline_level   (niveau du scénario baseline, i.e. premier scénario valide)
%     dev_pct          (écart % vs baseline)
%--------------------------------------------------

outfile = 'data_raw/climate_feedback_all_levels.csv';
fid = fopen(outfile, 'w');
if fid == -1
    error('Impossible de créer le fichier %s', outfile);
end

fprintf(fid, 'scenario_id,scenario_label,phi,kind,variable,t,level,baseline_level,dev_pct\n');

% Baseline = premier scénario valide
baseline = results_valid(1);
t_base   = baseline.t_display;
len_base = length(t_base);

varnames = {'y','d','e','s','c','k','l'};
kinds    = {'hat','ns'};   % stationnarisé / non-stationnarisé

for j = 1:n_valid
    scen_id    = results_valid(j).mod_file;
    scen_label = phi_labels_valid{j};
    scen_phi   = phi_values_valid(j);
    
    t_s   = results_valid(j).t_display;
    len_s = length(t_s);
    
    % Longueur commune baseline/scénario
    T_len = min(len_s, len_base);
    
    for kk = 1:length(kinds)
        kind = kinds{kk};
        
        for v = 1:length(varnames)
            vname = varnames{v};
            
            % Série scénario & baseline pour cette variable / kind
            switch kind
                case 'hat'
                    switch vname
                        case 'y'
                            series_s = results_valid(j).y_hat(1:T_len);
                            series_b = baseline.y_hat(1:T_len);
                        case 'd'
                            series_s = results_valid(j).d_hat(1:T_len);
                            series_b = baseline.d_hat(1:T_len);
                        case 'e'
                            series_s = results_valid(j).e_hat(1:T_len);
                            series_b = baseline.e_hat(1:T_len);
                        case 's'
                            series_s = results_valid(j).s_hat(1:T_len);
                            series_b = baseline.s_hat(1:T_len);
                        case 'c'
                            series_s = results_valid(j).c_hat(1:T_len);
                            series_b = baseline.c_hat(1:T_len);
                        case 'k'
                            series_s = results_valid(j).k_hat(1:T_len);
                            series_b = baseline.k_hat(1:T_len);
                        case 'l'
                            series_s = results_valid(j).l_hat(1:T_len);
                            series_b = baseline.l_hat(1:T_len);
                    end
                case 'ns'
                    switch vname
                        case 'y'
                            series_s = results_valid(j).y_ns(1:T_len);
                            series_b = baseline.y_ns(1:T_len);
                        case 'd'
                            series_s = results_valid(j).d_ns(1:T_len);
                            series_b = baseline.d_ns(1:T_len);
                        case 'e'
                            series_s = results_valid(j).e_ns(1:T_len);
                            series_b = baseline.e_ns(1:T_len);
                        case 's'
                            series_s = results_valid(j).s_ns(1:T_len);
                            series_b = baseline.s_ns(1:T_len);
                        case 'c'
                            series_s = results_valid(j).c_ns(1:T_len);
                            series_b = baseline.c_ns(1:T_len);
                        case 'k'
                            series_s = results_valid(j).k_ns(1:T_len);
                            series_b = baseline.k_ns(1:T_len);
                        case 'l'
                            series_s = results_valid(j).l_ns(1:T_len);
                            series_b = baseline.l_ns(1:T_len);
                    end
            end
            
            for t_idx = 1:T_len
                tval   = t_s(t_idx);
                level  = series_s(t_idx);
                base_l = series_b(t_idx);
                
                if j == 1
                    % Baseline : dev = 0, baseline_level = level
                    dev_pct = 0;
                    base_l  = level;
                else
                    dev_pct = 100 * (level - base_l) ./ base_l;
                end
                
                fprintf(fid, '%s,"%s",%.10g,%s,%s,%d,%.10g,%.10g,%.10g\n', ...
                        scen_id, scen_label, scen_phi, kind, vname, tval, level, base_l, dev_pct);
            end
        end
    end
end

fclose(fid);

fprintf('\n========================================\n');
fprintf('=== Analyse terminée ! ===\n');
fprintf('========================================\n');
fprintf('Scénarios réussis : %d / %d\n', sum(success_flags), n_scen);
fprintf('Horizon exporté : %d périodes (max)\n', T_display);
fprintf('CSV exporté dans : %s\n', outfile);
fprintf('MAT exporté dans : data_raw/climate_feedback_results_levels.mat\n');
