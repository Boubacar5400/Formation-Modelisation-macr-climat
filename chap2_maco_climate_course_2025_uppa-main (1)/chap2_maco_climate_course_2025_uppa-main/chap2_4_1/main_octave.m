% ========================================================================
% Script Octave/Dynare pour simuler des CHOCS FISCAUX TEMPORAIRES
%  export CSV pour R
% ========================================================================

clear all;
close all;
clc;
more off;   

% 
try
  graphics_toolkit("qt");
catch
  try
    graphics_toolkit("fltk");
  catch
    % on laisse le backend par défaut
  end
end

% --- Contrôle global du nombre de périodes à exporter ---
t_to_plot = 100;   % nb max de périodes qu'on garde pour le CSV
trim = @(x) x(1:min(t_to_plot, numel(x)));   % coupe prudemment un vecteur

% Crée les dossiers de sortie si besoin
if ~exist('data_raw', 'dir'), mkdir data_raw; end

% Nom du fichier dynare .mod (sans extension)
mod_base = 'basic_rbc_with_growth';

% ========================================================================
% 1. CONFIGURATION DES CHOCS TEMPORAIRES
% ========================================================================

% Définir l'amplitude des chocs (en points de pourcentage)
shock_size_tva = 0.10;    % +10 points de TVA
shock_size_inv = 0.10;    % +10 points de taxe sur investissement
shock_size_ir  = 0.10;    % +10 points d'IR
shock_size_ss  = 0.10;    % +10 points de cotisations sociales
shock_size_k   = 0.10;    % +10 points de taxe sur capital
shock_size_y   = 0.10;    % +10 points de taxe sur production

% Durée du choc (périodes dynare)
shock_start = 1;
shock_end   = 40;

% Créer les scénarios de chocs
shock_scenarios = [
    shock_size_tva, 0, 0, 0, 0, 0;  % Choc TVA
    0, shock_size_inv, 0, 0, 0, 0;  % Choc INV
    0, 0, shock_size_ir, 0, 0, 0;   % Choc IR
    0, 0, 0, shock_size_ss, 0, 0;   % Choc SS
    0, 0, 0, 0, shock_size_k, 0;    % Choc K
    0, 0, 0, 0, 0, shock_size_y     % Choc Y
];

tax_names = {'TVA', 'Investissement', 'Impôt revenu', 'Cotis. sociales', ...
             'Capital', 'Production'};
tax_var_names = {'tau_tva', 'tau_inv', 'tau_ir', 'tau_ss', 'tau_k', 'tau_y'};

n_scenarios = size(shock_scenarios, 1);

fprintf('Nombre de scénarios de chocs à simuler: %d\n', n_scenarios);
fprintf('Choc temporaire: périodes %d à %d\n\n', shock_start, shock_end);

% Structure pour stocker les résultats
results = struct();

% ========================================================================
% 2. BOUCLE PRINCIPALE - SIMULATIONS AVEC CHOCS TEMPORAIRES
% ========================================================================

for i = 1:n_scenarios
    fprintf('\n=== Simulation choc %d/%d : %s ===\n', i, n_scenarios, tax_names{i});
    fprintf('Ampleur du choc: +%.1f points de pourcentage\n', shock_scenarios(i, i)*100);
    
    % Créer le fichier .mod avec le choc temporaire
    create_mod_with_shock(mod_base, shock_scenarios(i,:), tax_var_names, ...
                          shock_start, shock_end, i);
    
    % Exécuter Dynare
    temp_mod = sprintf('temp_shock_%d', i);
    
    try
        dynare(temp_mod, 'noclearall');
        
        % Stocker les informations du scénario
        results(i).tax_name   = tax_names{i};
        results(i).shock_size = shock_scenarios(i, i);
        results(i).scenario   = i;
        
        % Extraire les séries temporelles (niveaux)
        results(i).y      = oo_.endo_simul(strmatch('y', M_.endo_names, 'exact'), :);
        results(i).c      = oo_.endo_simul(strmatch('c', M_.endo_names, 'exact'), :);
        results(i).invest = oo_.endo_simul(strmatch('invest', M_.endo_names, 'exact'), :);
        results(i).k      = oo_.endo_simul(strmatch('k', M_.endo_names, 'exact'), :);
        results(i).l      = oo_.endo_simul(strmatch('l', M_.endo_names, 'exact'), :);
        results(i).g      = oo_.endo_simul(strmatch('g', M_.endo_names, 'exact'), :);
        results(i).w      = oo_.endo_simul(strmatch('w', M_.endo_names, 'exact'), :);
        results(i).r      = oo_.endo_simul(strmatch('r', M_.endo_names, 'exact'), :);
        
        % Ratios et prix relatifs (niveaux)
        results(i).k_over_l      = results(i).k ./ results(i).l;
        results(i).k_over_y      = results(i).k ./ results(i).y;
        results(i).w_over_r      = results(i).w ./ results(i).r;
        results(i).c_over_y      = results(i).c ./ results(i).y;
        results(i).invest_over_y = results(i).invest ./ results(i).y;
        results(i).g_over_y      = results(i).g ./ results(i).y;
        
        % IRF (écarts au SS en %) 
        y_ss      = oo_.steady_state(strmatch('y', M_.endo_names, 'exact'));
        c_ss      = oo_.steady_state(strmatch('c', M_.endo_names, 'exact'));
        l_ss      = oo_.steady_state(strmatch('l', M_.endo_names, 'exact'));
        k_ss      = oo_.steady_state(strmatch('k', M_.endo_names, 'exact'));
        g_ss      = oo_.steady_state(strmatch('g', M_.endo_names, 'exact'));
        invest_ss = oo_.steady_state(strmatch('invest', M_.endo_names, 'exact'));
        w_ss      = oo_.steady_state(strmatch('w', M_.endo_names, 'exact'));
        r_ss      = oo_.steady_state(strmatch('r', M_.endo_names, 'exact'));
        
        results(i).y_irf      = 100 * (results(i).y      / y_ss      - 1);
        results(i).c_irf      = 100 * (results(i).c      / c_ss      - 1);
        results(i).l_irf      = 100 * (results(i).l      / l_ss      - 1);
        results(i).k_irf      = 100 * (results(i).k      / k_ss      - 1);
        results(i).g_irf      = 100 * (results(i).g      / g_ss      - 1);
        results(i).invest_irf = 100 * (results(i).invest / invest_ss - 1);
        results(i).w_irf      = 100 * (results(i).w      / w_ss      - 1);
        results(i).r_irf      = 100 * (results(i).r      / r_ss      - 1);
        
        fprintf('Simulation réussie!\n');
        
    catch ME
        fprintf('Erreur: %s\n', ME.message);
        results(i).error = ME.message;
    end
    
    % Nettoyer les fichiers temporaires .mod générés
    if exist([temp_mod '.mod'], 'file')
        delete([temp_mod '.mod']);
    end
end


save('simulations_chocs_fiscaux_resultats.mat', 'results', 'shock_scenarios');

% ========================================================================
% 3. EXPORT DES RÉSULTATS POUR R
% ========================================================================

fprintf('\n=== Export des résultats IRF pour R ===\n');

fid = fopen('data_raw/resultats_chocs_fiscaux_pour_R.csv', 'w');
fprintf(fid, 'periode,taxe,y,c,l,k,invest,g,w,r,k_over_l,w_over_r,c_over_y\n');

for i = 1:n_scenarios
    Tloc = min(t_to_plot, length(results(i).y));
    for t = 1:Tloc
        fprintf(fid, '%d,%s,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n', ...
                t, tax_names{i}, ...
                results(i).y(t), results(i).c(t), ...
                results(i).l(t), results(i).k(t), results(i).invest(t), ...
                results(i).g(t), results(i).w(t), results(i).r(t), ...
                results(i).k_over_l(t), results(i).w_over_r(t), results(i).c_over_y(t));
    end
end
fclose(fid);

fprintf('Fichier CSV créé: data_raw/resultats_chocs_fiscaux_pour_R.csv\n');

% ========================================================================
% 4. RÉSUMÉ DES INSIGHTS ÉCONOMIQUES 
% ========================================================================

win_end = min(shock_end, t_to_plot);

% Calcul d'une petite demi-vie "à la main" sur l'IRF de Y
half_life = NaN(n_scenarios,1);
for i = 1:n_scenarios
    % Impact max (négatif) pendant la fenêtre du choc
    max_impact = min(results(i).y_irf(shock_start:win_end));
    
    start_idx = min(shock_end+1, t_to_plot);
    if start_idx <= numel(results(i).y_irf)
        post_shock = results(i).y_irf(start_idx:min(numel(results(i).y_irf), t_to_plot));
        idx = find(post_shock > max_impact * 0.5, 1, 'first');
    else
        idx = [];
    end
    
    if ~isempty(idx)
        half_life(i) = idx;
    else
        half_life(i) = NaN;
    end
end

fprintf('\n========================================\n');
fprintf('RÉSUMÉ - CHOCS FISCAUX TEMPORAIRES\n');
fprintf('========================================\n\n');

fprintf('Impact maximal sur le PIB (pendant le choc, fenêtre bornée):\n');
for i = 1:n_scenarios
    max_drop = min(results(i).y_irf(shock_start:win_end));
    fprintf('  %s: %.2f%%\n', tax_names{i}, max_drop);
end

fprintf('\nPersistance après le choc (demi-vie dans la fenêtre):\n');
for i = 1:n_scenarios
    if ~isnan(half_life(i))
        fprintf('  %s: %d périodes\n', tax_names{i}, half_life(i));
    else
        fprintf('  %s: > %d périodes (pas revenue à 50%%)\n', tax_names{i}, max(0, t_to_plot - shock_end));
    end
end

fprintf('\n========================================\n');
fprintf('Simulations terminées!\n');
fprintf('Toutes les données sauvegardées.\n');
fprintf('========================================\n');

% ========================================================================
% SOUS-FONCTION : CRÉATION DU .MOD AVEC CHOCS
% ========================================================================

function create_mod_with_shock(base_name, shock_vals, tax_var_names, ...
                               shock_start, shock_end, scenario_num)
    % Crée un fichier .mod Dynare temporaire avec un bloc de chocs adapté.

    % Lire le fichier .mod original
    fid = fopen([base_name '.mod'], 'r');
    if fid == -1
        error('Impossible d''ouvrir %s.mod', base_name);
    end
    content = fread(fid, '*char')';
    fclose(fid);
    
    % Trouver et remplacer le bloc shocks
    shock_block_start = regexp(content, 'shocks;');
    if isempty(shock_block_start)
        error('Bloc shocks; non trouvé dans le fichier .mod');
    end
    
    % Trouver le "end;" qui suit "shocks;"
    end_positions = regexp(content, 'end;');
    shock_block_end = end_positions(find(end_positions > shock_block_start, 1, 'first'));
    if isempty(shock_block_end)
        error('Fin de bloc "end;" du bloc shocks; non trouvée.');
    end
    
    % Construire le nouveau bloc de chocs
    new_shock_block = sprintf('shocks;\n');
    for ii = 1:length(shock_vals)
        if shock_vals(ii) ~= 0
            new_shock_block = [new_shock_block, ...
                sprintf(' var %s; periods %d:%d; values %.6f;\n', ...
                        tax_var_names{ii}, shock_start, shock_end, shock_vals(ii))];
        end
    end
    new_shock_block = [new_shock_block, 'end;'];
    
    % Remplacer l'ancien bloc par le nouveau
    content = [content(1:shock_block_start-1), new_shock_block, ...
               content(shock_block_end+4:end)];
    
    % Écrire le nouveau fichier
    temp_name = sprintf('temp_shock_%d.mod', scenario_num);
    fid = fopen(temp_name, 'w');
    if fid == -1
        error('Impossible d''écrire le fichier %s', temp_name);
    end
    fprintf(fid, '%s', content);
    fclose(fid);
end
