% ==================
% FONCTIONS LOCALES
% ==================

function create_modified_mod(base_name, taxes, scenario_num)
    % Lit le .mod de base et remplace les valeurs de tau_* dans initval
    in_name = [base_name '.mod'];
    fid = fopen(in_name, 'r');
    if fid < 0
        error('Impossible d''ouvrir %s', in_name);
    end
    content = fread(fid, '*char')';
    fclose(fid);

    % Remplacement via regex (hypothèse : initval contient "tau_xxx = ...;")
    content = regexprep(content, 'tau_tva\s*=\s*[0-9\.]+;', ...
                        sprintf('tau_tva = %.4f;', taxes(1)));
    content = regexprep(content, 'tau_inv\s*=\s*[0-9\.]+;', ...
                        sprintf('tau_inv = %.4f;', taxes(2)));
    content = regexprep(content, 'tau_ir\s*=\s*[0-9\.]+;', ...
                        sprintf('tau_ir = %.4f;', taxes(3)));
    content = regexprep(content, 'tau_ss\s*=\s*[0-9\.]+;', ...
                        sprintf('tau_ss = %.4f;', taxes(4)));
    content = regexprep(content, 'tau_k\s*=\s*[0-9\.]+;', ...
                        sprintf('tau_k = %.4f;', taxes(5)));
    content = regexprep(content, 'tau_y\s*=\s*[0-9\.]+;', ...
                        sprintf('tau_y = %.4f;', taxes(6)));

    temp_name = sprintf('temp_scenario_%d.mod', scenario_num);
    fid = fopen(temp_name, 'w');
    if fid < 0
        error('Impossible d''écrire %s', temp_name);
    end
    fprintf(fid, '%s', content);
    fclose(fid);
end
