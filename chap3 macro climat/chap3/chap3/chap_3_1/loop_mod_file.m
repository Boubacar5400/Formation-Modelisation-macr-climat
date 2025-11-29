%% ============================================================
% Script : run_tax_shocks_growth.m
% Objectif :
%   - partir d'un template .mod (basic_rbc_with_growth.mod)
%   - créer 1 .mod par taxe avec un bloc shocks spécifique
%   - lancer Dynare pour chaque fichier
%   - reconstruire les niveaux non stationnaires
%   - sauvegarder tout dans un gros .mat (all_results_tax_shocks.mat)
% ============================================================

clear; close all; clc;

% Nom du template .mod (SANS extension)
mod_template = 'template';   % <-- adapte si besoin

% Liste des taxes (noms EXACTS dans le .mod)
tax_var_names = {'tau_tva','tau_inv','tau_ir','tau_ss','tau_k','tau_y'};
n_taxes       = numel(tax_var_names);

% Choc de taxe
shock_size  = 0.50;    % +0.10 de taxe
shock_start = 1;       % début du choc
shock_end   = 280;      % fin du choc

fprintf('Nombre de taxes simulées : %d\n', n_taxes);
fprintf('Choc = +%.2f de %d à %d\n', shock_size, shock_start, shock_end);

% Structure pour tout stocker
all_res = struct();

for j = 1:n_taxes
    
    this_tax = tax_var_names{j};
    fprintf('\n=== Scénario %d/%d : choc sur %s ===\n', j, n_taxes, this_tax);
    
    % Nom du .mod spécifique à ce scénario
    temp_mod_name = sprintf('%s_%s_shock', mod_template, this_tax);  % sans .mod
    
    % 1. Créer un .mod à partir du template avec un bloc shocks adapté
    create_mod_with_tax_shock(mod_template, temp_mod_name, ...
                              this_tax, shock_size, shock_start, shock_end);
    
    % 2. Lancer Dynare sur ce .mod
    dynare(temp_mod_name, 'noclearall');
    
    % 3. Reconstituer les niveaux non stationnaires et stocker tout
    % ------------------------------------------------------------
    % Récupérer gamm = 1+g
    param_names = cellstr(M_.param_names);
    idx_gamm    = strcmp(param_names, 'gamm');
    if ~any(idx_gamm)
        error('Paramètre "gamm" introuvable dans M_.param_names');
    end
    gamma = M_.params(idx_gamm);   % = 1+g
    
    % Grille de temps Dynare (t = 0..T)
    T     = size(oo_.endo_simul, 2) - 1;
    tgrid = 0:T;
    trend = gamma.^tgrid;          % (1+g)^t
    
    % Helper pour récupérer une endogène par son nom
    endo_names = cellstr(M_.endo_names);
    getv = @(name) oo_.endo_simul(strcmp(endo_names, name), :);
    
    % Stationnaires
    c_hat = getv('c');
    y_hat = getv('y');
    k_hat = getv('k');
    i_hat = getv('invest');
    g_hat = getv('g');
    l_hat = getv('l');
    w_hat = getv('w');
    r_hat = getv('r');
    e_hat = getv('e');
    s_hat = getv('s');
    
    % Non stationnaires (X_ns = X_hat * (1+g)^t)
    C_ns = c_hat .* trend;
    Y_ns = y_hat .* trend;
    K_ns = k_hat .* trend;
    I_ns = i_hat .* trend;
    G_ns = g_hat .* trend;
    W_ns = w_hat .* trend;
    E_ns = e_hat .* trend;
    S_ns = s_hat .* trend;
    
    % Trajectoire de la taxe exogène
    exo_names = cellstr(M_.exo_names);
    idx_exo   = strcmp(exo_names, this_tax);
    tax_path  = oo_.exo_simul(:, idx_exo)';   % en ligne
    
    % 4. Stocker dans all_res(j)
    all_res(j).tax_name  = this_tax;
    all_res(j).shock_size  = shock_size;
    all_res(j).shock_start = shock_start;
    all_res(j).shock_end   = shock_end;
    
    all_res(j).t      = tgrid;
    all_res(j).gamma  = gamma;
    
    % stationnaires
    all_res(j).y_hat = y_hat;
    all_res(j).c_hat = c_hat;
    all_res(j).k_hat = k_hat;
    all_res(j).i_hat = i_hat;
    all_res(j).g_hat = g_hat;
    all_res(j).l_hat = l_hat;
    all_res(j).w_hat = w_hat;
    all_res(j).r_hat = r_hat;
    all_res(j).e_hat = e_hat;
    all_res(j).s_hat = s_hat;
    
    % non-stationnaires
    all_res(j).Y_ns = Y_ns;
    all_res(j).C_ns = C_ns;
    all_res(j).K_ns = K_ns;
    all_res(j).I_ns = I_ns;
    all_res(j).G_ns = G_ns;
    all_res(j).W_ns = W_ns;
    all_res(j).E_ns = E_ns;
    all_res(j).S_ns = S_ns;
    
    % taxe
    all_res(j).tax_path = tax_path;
    
    % 5. (option) supprimer le .mod temporaire
    if exist([temp_mod_name '.mod'],'file')
        delete([temp_mod_name '.mod']);
    end
    
end

% Sauvegarde unique
save('data_raw/all_results_tax_shocks.mat','all_res','tax_var_names','shock_size','shock_start','shock_end');

fprintf('\n=== Terminé. Résultats dans all_results_tax_shocks.mat ===\n');


%% ============================================================
% FONCTION : création d'un .mod à partir du template
%           en remplaçant le bloc "shocks; ... end;"
% ============================================================
function create_mod_with_tax_shock(template_name, dest_name, ...
                                   tax_var, shock_size, shock_start, shock_end)
    % template_name : SANS .mod
    % dest_name     : SANS .mod
    %
    % On prend template_name.mod, on remplace le bloc:
    %   shocks;
    %     ...
    %   end;
    % par :
    %   shocks;
    %     var tax_var; periods shock_start:shock_end; values shock_size;
    %   end;

    tmpl_file = [template_name '.mod'];
    fid = fopen(tmpl_file,'r');
    if fid == -1
        error('Impossible d''ouvrir le template %s', tmpl_file);
    end
    content = fread(fid,'*char')';
    fclose(fid);

    % Nouveau bloc shocks
    new_shock_block = sprintf('shocks;\n');
    new_shock_block = [new_shock_block, ...
        sprintf('  var %s; periods %d:%d; values %.4f;\n', ...
                tax_var, shock_start, shock_end, shock_size)];
    new_shock_block = [new_shock_block, 'end;'];

    % Pattern : "shocks; ... end;" (non-greedy, multi-lignes)
    pattern = 'shocks;[\s\S]*?end;';

    if ~isempty(regexp(content, pattern, 'once'))
        % On remplace l'ancien bloc shocks par le nouveau
        content_new = regexprep(content, pattern, new_shock_block, 'once');
    else
        % Pas de bloc shocks : on en ajoute un à la fin
        warning('Aucun bloc "shocks; ... end;" trouvé dans %s. Ajout en fin de fichier.', tmpl_file);
        content_new = sprintf('%s\n\n%s\n', content, new_shock_block);
    end

    % Écriture du nouveau .mod
    dest_file = [dest_name '.mod'];
    fid = fopen(dest_file, 'w');
    if fid == -1
        error('Impossible d''écrire le fichier %s', dest_file);
    end
    fprintf(fid, '%s', content_new);
    fclose(fid);
end
