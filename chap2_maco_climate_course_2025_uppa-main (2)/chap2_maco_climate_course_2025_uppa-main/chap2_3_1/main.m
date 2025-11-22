% ========================================================================
% simulate_taxes_octave.m
% Script OCTAVE pour simuler différentes taxes avec Dynare
% et exporter un CSV pour analyse sous R
% ========================================================================

clear all; close all; clc;
more off;

% Nom du fichier .mod de base (sans extension)
mod_base = 'basic_rbc_with_state';

% ------------------------------------------------------------------------
% 1. DÉFINITION DES SCÉNARIOS DE TAXES
% ------------------------------------------------------------------------

% Scénario de base (toutes taxes = 0)
base_scenario = [0, 0, 0, 0, 0, 0]; % [tau_tva, tau_inv, tau_ir, tau_ss, tau_k, tau_y]

% Grilles de valeurs
tau_tva_values = [0, 0.05, 0.10, 0.15, 0.20, .25, .30, .35, .40, .45, .50];
tau_inv_values = tau_tva_values;
tau_ir_values  = tau_tva_values;
tau_ss_values  = tau_tva_values;
tau_k_values   = tau_tva_values;
tau_y_values   = tau_tva_values;

tax_scenarios = [];
tax_names = {};

% 1) variation de tau_tva
for val = tau_tva_values
    tax_scenarios = [tax_scenarios; val, 0, 0, 0, 0, 0];
    tax_names{end+1} = sprintf('TVA=%.2f', val);
end

% 2) variation de tau_inv
for val = tau_inv_values
    tax_scenarios = [tax_scenarios; 0, val, 0, 0, 0, 0];
    tax_names{end+1} = sprintf('INV=%.2f', val);
end

% 3) variation de tau_ir
for val = tau_ir_values
    tax_scenarios = [tax_scenarios; 0, 0, val, 0, 0, 0];
    tax_names{end+1} = sprintf('IR=%.2f', val);
end

% 4) variation de tau_ss
for val = tau_ss_values
    tax_scenarios = [tax_scenarios; 0, 0, 0, val, 0, 0];
    tax_names{end+1} = sprintf('SS=%.2f', val);
end

% 5) variation de tau_k
for val = tau_k_values
    tax_scenarios = [tax_scenarios; 0, 0, 0, 0, val, 0];
    tax_names{end+1} = sprintf('K=%.2f', val);
end

% 6) variation de tau_y
for val = tau_y_values
    tax_scenarios = [tax_scenarios; 0, 0, 0, 0, 0, val];
    tax_names{end+1} = sprintf('Y=%.2f', val);
end

n_scenarios = rows(tax_scenarios);
printf('Nombre de scénarios à simuler : %d\n', n_scenarios);

% ------------------------------------------------------------------------
% 2. BOUCLE SUR LES SCÉNARIOS + RÉCUP DES RÉSULTATS
% ------------------------------------------------------------------------

% On stocke les résultats au SS dans une matrice pour export CSV
export_data = zeros(n_scenarios, 16); % 6 taxes + 10 variables
% colonnes : [tau_tva tau_inv tau_ir tau_ss tau_k tau_y
%             y_ss c_ss l_ss k_ss g_ss w_ss r_ss
%             k_over_l_ss w_over_r_ss welfare_ss]

for i = 1:n_scenarios
    printf('\n=== Simulation %d/%d ===\n', i, n_scenarios);
    printf('Scénario : %s\n', tax_names{i});
    printf('tau_tva=%.2f | tau_inv=%.2f | tau_ir=%.2f | tau_ss=%.2f | tau_k=%.2f | tau_y=%.2f\n', ...
           tax_scenarios(i,1), tax_scenarios(i,2), tax_scenarios(i,3), ...
           tax_scenarios(i,4), tax_scenarios(i,5), tax_scenarios(i,6));
    
    % Créer un .mod temporaire avec ces valeurs de taxes
    create_modified_mod(mod_base, tax_scenarios(i,:), i);
    temp_mod = sprintf('temp_scenario_%d', i);
    
    try
        % Lancer Dynare dans Octave
        dynare(temp_mod, 'noclearall');
        
        % --- Récup paramètres utiles pour welfare ---
        bet = M_.params(strmatch('bet', M_.param_names, 'exact'));
        sig = M_.params(strmatch('sig', M_.param_names, 'exact'));
        nu  = M_.params(strmatch('nu' , M_.param_names, 'exact'));
        
        % --- Récup des steady states (ordre = M_.endo_names) ---
        y_ss = get_ss('y',   M_, oo_);
        c_ss = get_ss('c',   M_, oo_);
        l_ss = get_ss('l',   M_, oo_);
        k_ss = get_ss('k',   M_, oo_);
        g_ss = get_ss('g',   M_, oo_);
        w_ss = get_ss('w',   M_, oo_);
        r_ss = get_ss('r',   M_, oo_);
        
        k_over_l_ss = k_ss / l_ss;
        w_over_r_ss = w_ss / r_ss;
        
        % --- Welfare au SS (flux constant, valeur actualisée) ---
        composite_ss = (c_ss^nu * (1 - l_ss)^(1 - nu));
        u_ss = (composite_ss^(1 - sig) - 1) / (1 - sig);
        welfare_ss = u_ss / (1 - bet);
        
        % Remplir la ligne i pour export_data
        export_data(i,:) = [ ...
            tax_scenarios(i,1:6), ...
            y_ss, c_ss, l_ss, k_ss, g_ss, w_ss, r_ss, ...
            k_over_l_ss, w_over_r_ss, welfare_ss ...
        ];
        
        printf('   -> Simulation OK. Welfare_ss = %.4f\n', welfare_ss);
        
    catch err
        fprintf(2, '   !! Erreur sur scénario %d : %s\n', i, err.message);
        % On met des NaN pour ce scénario
        export_data(i,:) = [tax_scenarios(i,1:6), NaN(1,10)];
    end
    
    % Nettoyage: supprimer le .mod temporaire si tu veux
    temp_name = [temp_mod '.mod'];
    if exist(temp_name, 'file')
        delete(temp_name);
    end
end

% ------------------------------------------------------------------------
% 3. EXPORT CSV POUR R
% ------------------------------------------------------------------------

outfile = 'data_raw/resultats_taxes_pour_R.csv';
fid = fopen(outfile, 'w');

headers = { ...
  'tau_tva', 'tau_inv', 'tau_ir', 'tau_ss', 'tau_k', 'tau_y', ...
  'y_ss', 'c_ss', 'l_ss', 'k_ss', 'g_ss', 'w_ss', 'r_ss', ...
  'k_over_l_ss', 'w_over_r_ss', 'welfare_ss'};

% ligne d'en-tête
for j = 1:length(headers)
    if j < length(headers)
        fprintf(fid, '%s,', headers{j});
    else
        fprintf(fid, '%s\n', headers{j});
    end
end

% données
for i = 1:rows(export_data)
    fprintf(fid, '%f', export_data(i,1));
    for j = 2:columns(export_data)
        fprintf(fid, ',%f', export_data(i,j));
    end
    fprintf(fid, '\n');
end

fclose(fid);

printf('\n=== Export terminé ===\n');
printf('Fichier CSV créé : %s\n', outfile);

