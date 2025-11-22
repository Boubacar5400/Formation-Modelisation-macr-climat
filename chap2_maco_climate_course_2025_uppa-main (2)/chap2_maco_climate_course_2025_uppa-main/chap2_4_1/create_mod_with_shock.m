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
