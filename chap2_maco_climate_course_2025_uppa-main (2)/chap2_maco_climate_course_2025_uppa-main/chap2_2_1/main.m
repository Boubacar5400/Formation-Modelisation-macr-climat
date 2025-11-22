%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main.m — lance Dynare + export CSV des simulations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc;

%----------------------------------------------------
% 1. Lancer Dynare
%----------------------------------------------------
dynare basic_rbc_endo_L.mod noclearall

% Après cette ligne, oo_ et M_ sont disponibles.

%----------------------------------------------------
% 2. Préparation du dossier de sortie
%----------------------------------------------------
outdir = 'data_raw';
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

%----------------------------------------------------
% 3. Récupération des données Dynare
%----------------------------------------------------

% --- Endogènes ---
n_endo      = M_.endo_nbr;
names_endo  = cellstr(M_.endo_names);
endo_data   = oo_.endo_simul.';      % (T+1) x n_endo

% --- Exogènes ---
n_exo       = M_.exo_nbr;
names_exo   = cellstr(M_.exo_names);
exo_data    = oo_.exo_simul;         % (T+1) x n_exo  -> NE PAS transposer

% --- Temps ---
T           = size(endo_data, 1);    % T+1 points (t=0,...,T-1 si 300 périodes)
time        = (0:T-1).';             % colonne

% --- Fusion : t + endogènes + exogènes ---
full_data   = [time, endo_data, exo_data];

%----------------------------------------------------
% 4. Écriture du CSV (header + données)
%----------------------------------------------------
outfile = fullfile(outdir, 'simulation_full.csv');

% ---- En-tête ----
header = 't';
for i = 1:n_endo
    header = [header ',' strtrim(names_endo{i})];
end
for i = 1:n_exo
    header = [header ',' strtrim(names_exo{i})];
end

fid = fopen(outfile, 'w');
if fid == -1
    error('Impossible d''ouvrir %s pour écriture.', outfile);
end

% écrire la ligne d’en-tête
fprintf(fid, '%s\n', header);

% écrire les données ligne par ligne
[n_rows, n_cols] = size(full_data);
for r = 1:n_rows
    % première colonne
    fprintf(fid, '%g', full_data(r,1));
    % colonnes suivantes précédées d’une virgule
    for c = 2:n_cols
        fprintf(fid, ',%g', full_data(r,c));
    end
    fprintf(fid, '\n');
end

fclose(fid);

fprintf('\ Export terminé : %s\n', outfile);

