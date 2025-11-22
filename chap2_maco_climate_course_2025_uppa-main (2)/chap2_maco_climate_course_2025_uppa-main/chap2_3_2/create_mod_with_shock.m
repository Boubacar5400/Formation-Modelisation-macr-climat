function create_mod_with_shock(base_name, shock_vals, tax_var_names, ...
                               shock_start, shock_end, scenario_num)
    % Lire le fichier .mod original
    fid = fopen([base_name '.mod'], 'r');
    if fid == -1
        error("Impossible d'ouvrir %s.mod", base_name);
    end
    content = fread(fid, '*char')';
    fclose(fid);
    
    % Trouver "shocks;"
    shock_block_start = regexp(content, 'shocks;');
    if isempty(shock_block_start)
        error('Bloc "shocks;" non trouvé dans le fichier .mod');
    end
    
    % Trouver le "end;" qui suit
    end_positions = regexp(content, 'end;');
    shock_block_end = [];
    for k = 1:numel(end_positions)
        if end_positions(k) > shock_block_start
            shock_block_end = end_positions(k);
            break;
        end
    end
    if isempty(shock_block_end)
        error('Fin de bloc "end;" pour le bloc shocks; non trouvée.');
    end
    
    % Nouveau bloc shocks
    new_shock_block = 'shocks;\n';
    for ii = 1:numel(shock_vals)
        if shock_vals(ii) ~= 0
            new_shock_block = [new_shock_block, ...
                sprintf(' var %s; periods %d:%d; values %.6f;\n', ...
                        tax_var_names{ii}, shock_start, shock_end, shock_vals(ii))];
        end
    end
    new_shock_block = [new_shock_block, 'end;'];
    
    % Remplacer l'ancien bloc
    content = [content(1:shock_block_start-1), ...
               sprintf(new_shock_block), ...
               content(shock_block_end+4:end)];
    
    % Écrire le .mod temporaire
    temp_name = sprintf('temp_shock_%d.mod', scenario_num);
    fid = fopen(temp_name, 'w');
    if fid == -1
        error('Impossible d''écrire le fichier %s', temp_name);
    end
    fprintf(fid, '%s', content);
    fclose(fid);
end
