function [residual, g1, g2, g3] = static_resid_g1_g2_g3(T, y, x, params, T_flag)
% function [residual, g1, g2, g3] = static_resid_g1_g2_g3(T, y, x, params, T_flag)
%
% Wrapper function automatically created by Dynare
%

    if T_flag
        T = basic_rbc_with_growth_and_ges.static_g3_tt(T, y, x, params);
    end
    [residual, g1, g2] = basic_rbc_with_growth_and_ges.static_resid_g1_g2(T, y, x, params, false);
    g3       = basic_rbc_with_growth_and_ges.static_g3(T, y, x, params, false);

end
