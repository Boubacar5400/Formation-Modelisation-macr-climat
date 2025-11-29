%% create_scenario_mods.m
% Crée 3 fichiers .mod pour :
%   - baseline (inaction)
%   - politique modérée PRÉCOCE
%   - politique FORTE mais TARDIVE
%
% Basé sur : basic_rbc_with_climate.mod 
% Le bloc shocks original est remplacé par un bloc spécifique à chaque scénario.

clear; clc;

% Nom du .mod "de base" (sans extension)
modname_base = 'basic_rbc_with_climate';

%% Lire le fichier .mod original
fid = fopen([modname_base '.mod'], 'r');
if fid == -1
    error('Impossible de lire le fichier %s.mod', modname_base);
end
txt = fread(fid, '*char')';
fclose(fid);

%% Configuration des scénarios
% [filename,  mu_start, mu_end,  mu_level, tau_co2,  description]
scenarios = {
    'baseline',       0,    0,    0.00,  0.00, 'Baseline (inaction)';
    'policy_light',   1,  239,    0.20,  0.00, 'Politique modérée PRÉCOCE';
    'policy_strong', 90,  239,    0.60,  0.00, 'Politique FORTE mais TARDIVE';
};

Tmax = 240;      % horizon des shocks

%% Créer chaque fichier .mod
for i = 1:size(scenarios, 1)
    filename  = scenarios{i, 1};
    mu_start  = scenarios{i, 2};
    mu_end    = scenarios{i, 3};
    mu_level  = scenarios{i, 4};
    tau_val   = scenarios{i, 5};
    desc      = scenarios{i, 6};
    
    fprintf('Création de %s.mod (%s)...\n', filename, desc);
    
    % Copier le texte original
    mod_txt = txt;
    
    % === Construire le nouveau bloc shocks ===
    if mu_level == 0 && tau_val == 0
        % ------- Baseline : pas de politique, mu=tau=0 -------
        new_shocks = sprintf([ ...
            'shocks;\n' ...
            '  %% TFP (exemple : A constant = 1.1)\n' ...
            '  var A;      periods 1:%d; values 1.1;\n' ...
            '  %% Pas de politique climatique\n' ...
            '  var mu;      periods 1:%d; values 0;\n' ...
            '  var tau_co2; periods 1:%d; values 0;\n' ...
            'end;'], Tmax, Tmax, Tmax);
    else
        % ------- Scénarios de politique -------
        % mu = mu_level sur [mu_start, mu_end], puis revient à 0
        % tau_co2 = tau_val sur tout l'horizon
        
        % On sécurise les bornes
        if mu_start < 1,  mu_start = 1;  end
        if mu_end   > Tmax, mu_end = Tmax; end
        
        new_shocks = sprintf([ ...
            'shocks;\n' ...
            '  %% TFP (exemple : A constant = 1.1)\n' ...
            '  var A;      periods 1:%d; values 1.1;\n' ...
            '  %% Politique climatique : mu actif de t=%d à t=%d\n' ...
            '  var mu;      periods %d:%d %d:%d; values %.3f 0;\n' ...
            '  %% Taxe carbone constante\n' ...
            '  var tau_co2; periods 1:%d; values %.3f;\n' ...
            'end;'], ...
            Tmax, ...                 % A
            mu_start, mu_end, ...     % commentaire
            mu_start, mu_end, ...     % mu > 0
            mu_end+1, Tmax, ...       % mu = 0
            mu_level, ...             % niveau de mu
            Tmax, tau_val);           % taxe carbone
    end
    
    % === Remplacer le bloc "shocks; ... end;" existant ===
    % pattern : "shocks;" suivi de n'importe quoi jusqu'à "end;"
    pattern = 'shocks;[\s\S]*?end;';
    if isempty(regexp(mod_txt, pattern, 'once'))
        warning('Aucun bloc "shocks; ... end;" trouve dans %s.mod. Ajouté en fin de fichier.', modname_base);
        % On ajoute le bloc en fin de fichier
        mod_txt = sprintf('%s\n\n%s\n', mod_txt, new_shocks);
    else
        % On remplace le bloc existant par le nouveau
        mod_txt = regexprep(mod_txt, pattern, new_shocks, 'once');
    end
    
    % === Écrire le nouveau fichier .mod ===
    fid = fopen([filename '.mod'], 'w');
    if fid == -1
        error('Impossible d''écrire le fichier %s.mod', filename);
    end
    fwrite(fid, mod_txt);
    fclose(fid);
    
    fprintf('  -> %s.mod créé\n', filename);
end

fprintf('\n=== Fichiers .mod créés avec succès ! ===\n');
fprintf('Scenarios : baseline, policy_light, policy_strong\n');
