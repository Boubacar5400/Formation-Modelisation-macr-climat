% ==================
% FONCTIONS LOCALES
% ==================

function val = get_ss(varname, M_, oo_)
    % Renvoie le steady state de la variable endogène "varname"
    idx = strmatch(varname, M_.endo_names, 'exact');
    if isempty(idx)
        error('Variable %s introuvable dans M_.endo_names', varname);
    end
    val = oo_.steady_state(idx);
end
