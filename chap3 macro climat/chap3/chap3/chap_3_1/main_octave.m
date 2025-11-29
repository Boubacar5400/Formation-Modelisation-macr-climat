%% ============================================================
% Script : main_octave.m
% Objectif :
%   Orchestrer toute la chaîne :
%   1) Baseline sans choc de taxe  -> baseline_tax_BAU.mat
%   2) Simulations avec chocs de taxe -> all_results_tax_shocks.mat
%   3) Graphiques en niveaux + écarts vs baseline
%   4) IRF des variables stationnarisées
%
%  les scripts suivants doivent être dans dans le même dossier :
%      - run_baseline_tax_BAU.m
%      - loop_mod_file.m
%      - plot_tax_facet_with_baseline.m
%      - irf.m
% ============================================================

clear; close all; clc;

fprintf('=== PIPELINE CHOCS DE TAXES AVEC CROISSANCE + CLIMAT ===\n\n');

%% 1) Baseline / BAU (sans choc de taxe)
fprintf('1) Simulation baseline (sans choc de taxe)...\n');

clear; close all; clc;

%mod_file = 'basic_rbc_with_growth_and_ges';
mod_file = 'basic_rbc_no_shock';

% --- Lancer Dynare sur le .mod de référence, SANS modifier le bloc shocks ---
dynare(mod_file, 'noclearall');

% ========= Reconstitution des niveaux non stationnaires =========
gamma = gamm;                             % paramètre du .mod : 1+g
T      = size(oo_.endo_simul, 2) - 1;     % colonnes = t=0..T
tgrid  = 0:T;
trend  = gamma.^tgrid;                    % (1+g)^t

getv = @(name) oo_.endo_simul(strcmp(cellstr(M_.endo_names), name), :);

% Stationnarisées (déjà "avec chapeau")
y_hat  = getv('y');
c_hat  = getv('c');
k_hat  = getv('k');
i_hat  = getv('invest');
g_hat  = getv('g');
e_hat  = getv('e');
s_hat  = getv('s');

% Niveau non stationnaire = chapeau * trend
Y_ns = y_hat .* trend;
C_ns = c_hat .* trend;
K_ns = k_hat .* trend;
I_ns = i_hat .* trend;
G_ns = g_hat .* trend;
E_ns = e_hat .* trend;
S_ns = s_hat .* trend;

% Stocker dans une structure baseline cohérente avec all_res
base_res = struct();
base_res.t      = tgrid;
base_res.y      = y_hat;
base_res.c      = c_hat;
base_res.k      = k_hat;
base_res.invest = i_hat;
base_res.g      = g_hat;
base_res.e      = e_hat;
base_res.s      = s_hat;

base_res.Y_ns = Y_ns;
base_res.C_ns = C_ns;
base_res.K_ns = K_ns;
base_res.I_ns = I_ns;
base_res.G_ns = G_ns;
base_res.E_ns = E_ns;
base_res.S_ns = S_ns;

base_res.tax_name = 'Baseline (sans choc de taxe)';

if ~exist('data_raw', 'dir')
    mkdir('data_raw');
end
save('data_raw/baseline_tax_BAU.mat','base_res');

fprintf(' Baseline sauvegardée dans baseline_tax_BAU.mat\n');

fprintf('   -> baseline_tax_BAU.mat créé.\n\n');

%% 2) Simulations avec chocs de taxe
fprintf('2) Simulations avec chocs de taxe (boucle Dynare)...\n');

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
shock_size  = 0.50;    % +0.50 de taxe
shock_start = 1;       % début du choc
shock_end   = 280;     % fin du choc

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
    all_res(j).tax_name    = this_tax;
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

if ~exist('data_raw','dir')
    mkdir('data_raw');
end
% Sauvegarde unique
save('data_raw/all_results_tax_shocks.mat','all_res','tax_var_names','shock_size','shock_start','shock_end');

fprintf('\n=== Terminé. Résultats dans all_results_tax_shocks.mat ===\n');
fprintf('   -> all_results_tax_shocks.mat créé.\n\n');

%% 3) Export CSV pour graphiques dans R
fprintf('3) Export CSV (niveaux + écarts %% vs baseline) pour R...\n');

clear; close all; clc;

load('data_raw/all_results_tax_shocks.mat');   % all_res, tax_var_names, etc.
load('data_raw/baseline_tax_BAU.mat');         % base_res

n_taxes = numel(all_res);

if ~exist('data_raw','dir')
    mkdir('data_raw');
end

% === PARAMÈTRE UTILISATEUR ===
Tmax = 150;   % nombre de périodes affichées
t_b  = base_res.t;
idxb = t_b <= Tmax;

% Variables à exporter (niveaux non stationnaires)
varnames_ns = {'Y_ns','C_ns','K_ns','I_ns','E_ns','S_ns'};
n_vars = numel(varnames_ns);

outfile = 'data_raw/tax_shocks_levels_and_dev.csv';
fid = fopen(outfile, 'w');
if fid == -1
    error('Impossible de créer le fichier %s', outfile);
end

% En-tête CSV
fprintf(fid, 'scenario,variable,t,level,baseline_level,dev_pct\n');

for v = 1:n_vars
    varname = varnames_ns{v};
    
    % Baseline
    yb_full = base_res.(varname);
    yb      = yb_full(idxb);
    t_sel   = t_b(idxb);
    
    % Lignes pour la baseline
    for k = 1:length(t_sel)
        fprintf(fid, 'baseline,%s,%d,%.10g,%.10g,%.10g\n', ...
                varname, t_sel(k), yb(k), yb(k), 0);
    end
    
    % Scénarios de taxe
    for j = 1:n_taxes
        scen = all_res(j).tax_name;        % nom de la taxe (tau_tva, etc.)
        t_s  = all_res(j).t;
        idxs = t_s <= Tmax;
        
        yv_full = all_res(j).(varname);
        yv      = yv_full(idxs);
        t_s     = t_s(idxs);
        
        % On suppose que la grille de temps est la même que pour la baseline
        % sur [0, Tmax]. On prend les yb sur la même longueur par prudence.
        yb_for_scen = yb(1:length(t_s));
        
        dev_pct = 100 * (yv - yb_for_scen) ./ yb_for_scen;
        
        for k = 1:length(t_s)
            fprintf(fid, '%s,%s,%d,%.10g,%.10g,%.10g\n', ...
                    scen, varname, t_s(k), yv(k), yb_for_scen(k), dev_pct(k));
        end
    end
end

fclose(fid);

fprintf('   -> CSV exporté dans %s\n\n', outfile);
%% 4) IRF des variables stationnarisées
% fprintf('4) IRF des variables stationnarisées (écarts %% vs baseline)...\n');
% run('irf.m');
% fprintf('   -> PNG des IRF stationnarisées sauvegardés.\n\n');
%
% fprintf('=== PIPELINE TERMINÉ  ===\n');
% fprintf('Vérifie les fichiers PNG et MAT générés dans le répertoire courant.\n');


