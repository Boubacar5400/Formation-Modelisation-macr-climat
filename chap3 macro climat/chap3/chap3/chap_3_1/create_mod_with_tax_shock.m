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
