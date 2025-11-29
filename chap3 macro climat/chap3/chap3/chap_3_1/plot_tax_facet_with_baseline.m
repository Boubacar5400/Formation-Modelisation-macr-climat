%% ============================================================
% Script : plot_tax_shocks_facet_with_baseline.m
% Objectif :
%   - charger all_results_tax_shocks.mat + baseline_tax_BAU.mat
%   - tracer :
%       (1) NIVEAUX non stationnaires avec baseline en pointillé
%       (2) ÉCARTS (%) par rapport à la baseline
% ============================================================

clear; close all; clc;

load('data_raw/all_results_tax_shocks.mat');   % all_res, tax_var_names, etc.
load('data_raw/baseline_tax_BAU.mat');         % base_res

n_taxes = numel(all_res);
colors  = lines(n_taxes);

% === PARAMÈTRE UTILISATEUR ===
Tmax = 150;   % nombre de périodes affichées
t_b  = base_res.t;
idxb = t_b <= Tmax;

% Variables à tracer (niveaux non stationnaires)
varnames_ns = {'Y_ns','C_ns','K_ns','I_ns','E_ns','S_ns'};
titles_ns   = {'PIB (Y)', 'Consommation (C)', 'Capital (K)', ...
               'Investissement (I)', 'Émissions (E)', 'Stock de GES (S)'};
n_vars = numel(varnames_ns);

%% --------- (1) NIVEAUX avec baseline pointillée ---------
figure('Position',[100 100 1400 900]);
tiledlayout(3,2, 'TileSpacing','compact', 'Padding','compact');

for v = 1:n_vars
    nexttile; hold on; box on; grid on;
    
    % Baseline
    yb = base_res.(varnames_ns{v});
    plot(t_b(idxb), yb(idxb), 'k--','LineWidth',2, ...
         'DisplayName','Baseline (sans choc)');
    
    % Scénarios de taxe
    for j = 1:n_taxes
        t = all_res(j).t;
        idx = t <= Tmax;
        yv  = all_res(j).(varnames_ns{v});
        
        plot(t(idx), yv(idx), ...
             'LineWidth', 1.5, 'Color', colors(j,:), ...
             'DisplayName', all_res(j).tax_name);
    end
    
    title(titles_ns{v}, 'FontWeight', 'bold');
    xlabel('');
    ylabel('Niveau');
    
    if v == 1
        legend('Location','bestoutside','Interpreter','none');
    end
end

sgtitle(sprintf('Chocs de taxes : niveaux non stationnaires (0–%d)', Tmax), ...
        'FontSize', 14, 'FontWeight','bold');

exportgraphics(gcf, sprintf('figures/tax_shocks_facet_levels_T%d.png',Tmax), ...
               'Resolution', 300);


%% --------- (2) ÉCARTS (%) vs baseline ---------
figure('Position',[100 100 1400 900]);
tiledlayout(3,2, 'TileSpacing','compact', 'Padding','compact');

for v = 1:n_vars
    nexttile; hold on; box on; grid on;
    
    yb_full = base_res.(varnames_ns{v});
    yb      = yb_full(idxb);
    
    for j = 1:n_taxes
        t   = all_res(j).t;
        idx = t <= Tmax;
        yv  = all_res(j).(varnames_ns{v});
        
        % On suppose que t est aligné avec base_res.t
        dev_pct = 100 * (yv(idx) - yb) ./ yb;
        
        plot(t(idx), dev_pct, ...
             'LineWidth', 1.8, 'Color', colors(j,:), ...
             'DisplayName', all_res(j).tax_name);
    end
    
    yline(0,'k--','LineWidth',1);
    title([titles_ns{v} ' — écart (%) vs baseline'], 'FontWeight','bold');
    xlabel('Temps (périodes)');
    ylabel('\Delta (%)');
    
    if v == 1
        legend('Location','bestoutside','Interpreter','none');
    end
end

sgtitle(sprintf('Chocs de taxes : écarts %% vs baseline (0–%d)', Tmax), ...
        'FontSize', 14, 'FontWeight','bold');

exportgraphics(gcf, sprintf('figures/tax_shocks_facet_dev_T%d.png',Tmax), ...
               'Resolution', 300);

fprintf(' Graphiques niveaux + écarts sauvegardés.\n');
