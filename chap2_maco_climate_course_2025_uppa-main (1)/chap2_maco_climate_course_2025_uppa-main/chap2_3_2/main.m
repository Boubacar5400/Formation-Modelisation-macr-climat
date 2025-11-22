% ========================================================================
% Script OCTAVE pour simuler des CHOCS FISCAUX TEMPORAIRES avec Dynare
% et EXPORTER UNIQUEMENT EN CSV (pas de graphiques)
% ========================================================================

clear all;
close all;
clc;

% --- Contrôle global du nombre de périodes à exporter ---
t_to_plot = 80;   % <-- choisis 20, 40, 60, etc.
trim = @(x) x(1:min(t_to_plot, numel(x)));
tN = t_to_plot;

% Crée les dossiers de sortie si besoin
if ~exist('figures', 'dir'), mkdir figures; end
if ~exist('data_raw', 'dir'), mkdir data_raw; end

% Nom de votre fichier .mod (sans extension)
mod_base = 'basic_rbc_with_state';

% ========================================================================
% 1. CONFIGURATION DES CHOCS TEMPORAIRES
% ========================================================================

% Amplitude des chocs (en points de pourcentage)
shock_size_tva = 0.10;    % +10 points de TVA
shock_size_inv = 0.10;    % +10 points de taxe sur investissement
shock_size_ir  = 0.10;    % +10 points d'IR
shock_size_ss  = 0.10;    % +10 points de cotisations sociales
shock_size_k   = 0.10;    % +10 points de taxe sur capital
shock_size_y   = 0.10;    % +10 points de taxe sur production

% Durée du choc (périodes dynare)
shock_start = 1;
shock_end   = 40;

% Scénarios de chocs (un seul type de taxe à la fois)
shock_scenarios = [
    shock_size_tva, 0, 0, 0, 0, 0;  % Choc TVA
    0, shock_size_inv, 0, 0, 0, 0;  % Choc INV
    0, 0, shock_size_ir, 0, 0, 0;   % Choc IR
    0, 0, 0, shock_size_ss, 0, 0;   % Choc SS
    0, 0, 0, 0, shock_size_k, 0;    % Choc K
    0, 0, 0, 0, 0, shock_size_y     % Choc Y
];

tax_names      = {'TVA', 'Investissement', 'Impôt revenu', 'Cotis. sociales', ...
                  'Capital', 'Production'};
tax_var_names  = {'tau_tva', 'tau_inv', 'tau_ir', 'tau_ss', 'tau_k', 'tau_y'};

n_scenarios = rows(shock_scenarios);

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
        
        % Infos de scénario
        results(i).tax_name   = tax_names{i};
        results(i).shock_size = shock_scenarios(i, i);
        results(i).scenario   = i;
        
        % Séries temporelles (niveaux)
        results(i).y      = oo_.endo_simul(strmatch('y',      M_.endo_names, 'exact'), :);
        results(i).c      = oo_.endo_simul(strmatch('c',      M_.endo_names, 'exact'), :);
        results(i).invest = oo_.endo_simul(strmatch('invest', M_.endo_names, 'exact'), :);
        results(i).k      = oo_.endo_simul(strmatch('k',      M_.endo_names, 'exact'), :);
        results(i).l      = oo_.endo_simul(strmatch('l',      M_.endo_names, 'exact'), :);
        results(i).g      = oo_.endo_simul(strmatch('g',      M_.endo_names, 'exact'), :);
        results(i).w      = oo_.endo_simul(strmatch('w',      M_.endo_names, 'exact'), :);
        results(i).r      = oo_.endo_simul(strmatch('r',      M_.endo_names, 'exact'), :);
        results(i).muc    = oo_.endo_simul(strmatch('muc',    M_.endo_names, 'exact'), :);
        
        % Taxes exogènes (vérification / export)
        results(i).tau_tva = oo_.exo_simul(:, strmatch('tau_tva', M_.exo_names, 'exact'))';
        results(i).tau_inv = oo_.exo_simul(:, strmatch('tau_inv', M_.exo_names, 'exact'))';
        results(i).tau_ir  = oo_.exo_simul(:, strmatch('tau_ir',  M_.exo_names, 'exact'))';
        results(i).tau_ss  = oo_.exo_simul(:, strmatch('tau_ss',  M_.exo_names, 'exact'))';
        results(i).tau_k   = oo_.exo_simul(:, strmatch('tau_k',   M_.exo_names, 'exact'))';
        results(i).tau_y   = oo_.exo_simul(:, strmatch('tau_y',   M_.exo_names, 'exact'))';
        
        % Ratios et prix relatifs
        results(i).k_over_l      = results(i).k ./ results(i).l;
        results(i).k_over_y      = results(i).k ./ results(i).y;
        results(i).w_over_r      = results(i).w ./ results(i).r;
        results(i).c_over_y      = results(i).c ./ results(i).y;
        results(i).invest_over_y = results(i).invest ./ results(i).y;
        results(i).g_over_y      = results(i).g ./ results(i).y;
        
        % Paramètres pour welfare
        bet = M_.params(strmatch('bet', M_.param_names, 'exact'));
        sig = M_.params(strmatch('sig', M_.param_names, 'exact'));
        nu  = M_.params(strmatch('nu',  M_.param_names, 'exact'));
        
        % Utilité intertemporelle
        composite = (results(i).c.^nu .* (1-results(i).l).^(1-nu));
        u_instant = (composite.^(1-sig) - 1) / (1-sig);
        
        Tfull     = length(u_instant);
        discount  = bet.^(0:Tfull-1);
        results(i).welfare = sum(discount .* u_instant);
        
        % Steady states
        y_ss      = oo_.steady_state(strmatch('y',      M_.endo_names, 'exact'));
        c_ss      = oo_.steady_state(strmatch('c',      M_.endo_names, 'exact'));
        l_ss      = oo_.steady_state(strmatch('l',      M_.endo_names, 'exact'));
        k_ss      = oo_.steady_state(strmatch('k',      M_.endo_names, 'exact'));
        g_ss      = oo_.steady_state(strmatch('g',      M_.endo_names, 'exact'));
        invest_ss = oo_.steady_state(strmatch('invest', M_.endo_names, 'exact'));
        w_ss      = oo_.steady_state(strmatch('w',      M_.endo_names, 'exact'));
        r_ss      = oo_.steady_state(strmatch('r',      M_.endo_names, 'exact'));
        
        results(i).y_ss      = y_ss;
        results(i).c_ss      = c_ss;
        results(i).l_ss      = l_ss;
        results(i).k_ss      = k_ss;
        results(i).g_ss      = g_ss;
        results(i).invest_ss = invest_ss;
        results(i).w_ss      = w_ss;
        results(i).r_ss      = r_ss;
        
        % IRF (écarts au SS en %)
        results(i).y_irf      = 100 * (results(i).y      / y_ss      - 1);
        results(i).c_irf      = 100 * (results(i).c      / c_ss      - 1);
        results(i).l_irf      = 100 * (results(i).l      / l_ss      - 1);
        results(i).k_irf      = 100 * (results(i).k      / k_ss      - 1);
        results(i).g_irf      = 100 * (results(i).g      / g_ss      - 1);
        results(i).invest_irf = 100 * (results(i).invest / invest_ss - 1);
        results(i).w_irf      = 100 * (results(i).w      / w_ss      - 1);
        results(i).r_irf      = 100 * (results(i).r      / r_ss      - 1);
        
        fprintf('Simulation réussie! Welfare total = %.4f\n', results(i).welfare);
        
    catch ME
        fprintf('Erreur: %s\n', ME.message);
        results(i).error = ME.message;
    end
    
    % Nettoyer le .mod temporaire
    if exist([temp_mod '.mod'], 'file')
        delete([temp_mod '.mod']);
    end
end

% Sauvegarde .mat brute si tu veux la garder
save('simulations_chocs_fiscaux_resultats.mat', 'results', 'shock_scenarios');

% ========================================================================
% 3. EXPORT DES RÉSULTATS POUR R (TRAJECTOIRES TEMPORELLES)
% ========================================================================

fprintf('\n=== Export des résultats IRF pour R (trajectoires) ===\n');

csv1 = 'data_raw/resultats_chocs_fiscaux_pour_R.csv';
fid = fopen(csv1, 'w');
% On exporte les NIVEAUX + quelques ratios de base
fprintf(fid, 'periode,tax_name,shock_size,y,c,l,k,invest,g,w,r,k_over_l,w_over_r,c_over_y,invest_over_y,g_over_y\n');

for i = 1:n_scenarios
    T = min(t_to_plot, length(results(i).y));
    for t = 1:T
        fprintf(fid, '%d,%s,', t, tax_names{i});
        fprintf(fid, '%.8f,', results(i).shock_size);
        fprintf(fid, '%.8f,%.8f,%.8f,%.8f,%.8f,%.8f,%.8f,%.8f,', ...
                results(i).y(t), ...
                results(i).c(t), ...
                results(i).l(t), ...
                results(i).k(t), ...
                results(i).invest(t), ...
                results(i).g(t), ...
                results(i).w(t), ...
                results(i).r(t));
        fprintf(fid, '%.8f,%.8f,%.8f,%.8f,%.8f\n', ...
                results(i).k_over_l(t), ...
                results(i).w_over_r(t), ...
                results(i).c_over_y(t), ...
                results(i).invest_over_y(t), ...
                results(i).g_over_y(t));
    end
end
fclose(fid);
fprintf('Fichier CSV créé: %s\n', csv1);

% ========================================================================
% 4. EXPORT DES STEADY STATES PAR SCÉNARIO
% ========================================================================

fprintf('\n=== Export des steady states pour R ===\n');

csv2 = 'data_raw/resultats_chocs_fiscaux_SS_pour_R.csv';
fid2 = fopen(csv2, 'w');
fprintf(fid2, ['scenario,tax_name,shock_size,', ...
               'y_ss,c_ss,l_ss,k_ss,g_ss,invest_ss,w_ss,r_ss,', ...
               'k_over_l_ss,w_over_r_ss,c_over_y_ss,invest_over_y_ss,g_over_y_ss,', ...
               'welfare\n']);

for i = 1:n_scenarios
    % ratios au SS
    k_over_l_ss      = results(i).k_ss / results(i).l_ss;
    w_over_r_ss      = results(i).w_ss / results(i).r_ss;
    c_over_y_ss      = results(i).c_ss / results(i).y_ss;
    invest_over_y_ss = results(i).invest_ss / results(i).y_ss;
    g_over_y_ss      = results(i).g_ss / results(i).y_ss;
    
    fprintf(fid2, '%d,%s,', i, tax_names{i});
    fprintf(fid2, '%.8f,', results(i).shock_size);
    fprintf(fid2, '%.8f,%.8f,%.8f,%.8f,%.8f,%.8f,%.8f,%.8f,', ...
            results(i).y_ss, ...
            results(i).c_ss, ...
            results(i).l_ss, ...
            results(i).k_ss, ...
            results(i).g_ss, ...
            results(i).invest_ss, ...
            results(i).w_ss, ...
            results(i).r_ss);
    fprintf(fid2, '%.8f,%.8f,%.8f,%.8f,%.8f,', ...
            k_over_l_ss, ...
            w_over_r_ss, ...
            c_over_y_ss, ...
            invest_over_y_ss, ...
            g_over_y_ss);
    fprintf(fid2, '%.8f\n', results(i).welfare);
end

fclose(fid2);
fprintf('Fichier CSV créé: %s\n', csv2);

fprintf('\n========================================\n');
fprintf('Simulations terminées!\n');
fprintf('Tous les résultats exportés en CSV dans data_raw/.\n');
fprintf('========================================\n');

% ========================================================================
% 5. FONCTION POUR CRÉER LES FICHIERS .MOD AVEC CHOCS
% ========================================================================

function create_mod_with_shock(base_name, shock_vals, tax_var_names, ...
                               shock_start, shock_end, scenario_num)
    % Lire le fichier .mod original
    fid = fopen([base_name '.mod'], 'r');
    if fid == -1
        error('Impossible d''ouvrir %s.mod', base_name);
    end
    content = fread(fid, '*char')';
    fclose(fid);
    
    % Trouver le bloc "shocks;"
    shock_block_start = regexp(content, 'shocks;');
    if isempty(shock_block_start)
        error('Bloc shocks; non trouvé dans le fichier .mod');
    end
    
    % Trouver le "end;" qui suit "shocks;"
    end_positions = regexp(content, 'end;');
    shock_block_end = [];
    for k = 1:length(end_positions)
        if end_positions(k) > shock_block_start
            shock_block_end = end_positions(k);
            break;
        end
    end
    if isempty(shock_block_end)
        error('Fin de bloc "end;" pour shocks; non trouvée.');
    end
    
    % Nouveau bloc shocks
    new_shock_block = sprintf('shocks;\n');
    for ii = 1:length(shock_vals)
        if shock_vals(ii) ~= 0
            new_shock_block = [new_shock_block, ...
                sprintf('  var %s; periods %d:%d; values %.6f;\n', ...
                        tax_var_names{ii}, shock_start, shock_end, shock_vals(ii))];
        end
    end
    new_shock_block = [new_shock_block, 'end;'];
    
    % Remplacer l'ancien bloc par le nouveau
    content = [content(1:shock_block_start-1), new_shock_block, ...
               content(shock_block_end+4:end)];
    
    % Écrire le nouveau fichier .mod temporaire
    temp_name = sprintf('temp_shock_%d.mod', scenario_num);
    fid2 = fopen(temp_name, 'w');
    if fid2 == -1
        error('Impossible d''écrire le fichier %s', temp_name);
    end
    fprintf(fid2, '%s', content);
    fclose(fid2);
end
