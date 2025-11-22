function export_dynare_run(run_label, outdir, outfile)
% EXPORT_DYNARE_RUN  Exporte (t, endogènes, exogènes) dans un CSV.
%   run_label : string pour info (ex. 'basic_rbc2')
%   outdir    : dossier de sortie (ex. 'data_raw')
%   outfile   : nom de fichier CSV (ex. 'simulation_basic_rbc2.csv')
%
% Utilise les variables globales Dynare M_ et oo_.

    % Dynare stocke tout dans des globales
    global M_ oo_;

    if nargin < 3
        error('export_dynare_run(run_label, outdir, outfile) : 3 arguments requis.');
    end

    % Crée le dossier s'il n'existe pas
    if ~exist(outdir, 'dir')
        mkdir(outdir);
    end

    % ---------- Endogènes ----------
    n_endo      = M_.endo_nbr;
    names_endo  = cellstr(M_.endo_names);      % noms des endo
    endo_data   = oo_.endo_simul.';            % (T_endo x n_endo)
    T_endo      = size(endo_data, 1);

    % ---------- Exogènes ----------
    n_exo      = M_.exo_nbr;
    names_exo  = cellstr(M_.exo_names);
    exo_data   = [];

    if n_exo > 0
        exo_raw = oo_.exo_simul;  % dimensions parfois T ou T+1 ou autre...

        % On harmonise les longueurs :
        T_exo = size(exo_raw, 1);

        if T_exo == T_endo
            % parfait, on prend tel quel
            exo_data = exo_raw;
        elseif T_exo == T_endo + 1
            % cas typique : exogènes sur 0..T alors que endo 0..T-1
            % => on coupe la dernière ligne
            exo_data = exo_raw(1:T_endo, :);
        else
            % Cas tordu : on tronque les deux à la plus petite longueur
            T = min(T_endo, T_exo);
            warning('export_dynare_run: T_endo=%d, T_exo=%d -> troncage à T=%d.', ...
                    T_endo, T_exo, T);
            endo_data = endo_data(1:T, :);
            exo_data  = exo_raw(1:T, :);
            T_endo    = T;
        end
    end

    % ---------- Temps ----------
    T    = T_endo;                % nombre final de périodes
    time = (0:T-1).';             % t=0,...,T-1

    % ---------- Fusion : t + endo + exo ----------
    full_data = [time, endo_data, exo_data];

    % ---------- En-tête CSV ----------
    header = 't';
    for i = 1:n_endo
        header = [header ',' names_endo{i}];
    end
    for i = 1:n_exo
        header = [header ',' names_exo{i}];
    end

    % ---------- Écriture ----------
    fullpath = fullfile(outdir, outfile);

    % 1) Écrire l'en-tête
    fid = fopen(fullpath, 'w');
    if fid == -1
        error('Impossible d''ouvrir %s en écriture.', fullpath);
    end
    fprintf(fid, '%s\n', header);
    fclose(fid);

    % 2) Append les données (avec des virgules)
    dlmwrite(fullpath, full_data, '-append', 'delimiter', ',');

    fprintf('\n[export_dynare_run] Export terminé pour %s -> %s\n', ...
            run_label, fullpath);
end
