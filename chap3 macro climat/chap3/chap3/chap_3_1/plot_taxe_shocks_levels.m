%% ============================================================
% Script : plot_tax_shocks_facet.m
% Objectif :
%   - charger all_results_tax_shocks.mat
%   - tracer sur un seul graphique (facet grid)
%     les principales variables macro et environnementales
%   - inclure un paramètre Tmax pour limiter l'horizon affiché
% ============================================================

clear; close all; clc;

% Chargement des résultats
load('all_results_tax_shocks.mat');   % charge all_res, tax_var_names, etc.

n_taxes = numel(all_res);
colors  = lines(n_taxes);

% === PARAMÈTRE UTILISATEUR ===
Tmax = 100;   % nombre de périodes à afficher (modifiable facilement)
output_file = sprintf('tax_shocks_facet_T%d.png', Tmax);

% Variables à tracer (avec labels propres)
varnames = {'Y_ns','C_ns','K_ns','I_ns','E_ns','S_ns'};
titles   = {'PIB (Y)', 'Consommation (C)', 'Capital (K)', ...
            'Investissement (I)', 'Émissions (E)', 'Stock de GES (S)'};

n_vars = numel(varnames);

% Taille de la figure
figure('Position',[100 100 1400 900]);
tiledlayout(3,2, 'TileSpacing','compact', 'Padding','compact');

for v = 1:n_vars
    nexttile; hold on; box on; grid on;
    
    for j = 1:n_taxes
        % Données tronquées à Tmax
        t = all_res(j).t;
        idx = t <= Tmax;
        yv = all_res(j).(varnames{v});
        
        plot(t(idx), yv(idx), ...
             'LineWidth', 1.8, 'Color', colors(j,:), ...
             'DisplayName', all_res(j).tax_name);
    end
    
    title(titles{v}, 'FontWeight', 'bold');
    xlabel('Temps (périodes)');
    ylabel('Niveau');
    
    if v == 1
        legend('Location','bestoutside','Interpreter','none');
    end
end

sgtitle(sprintf('Effet des chocs fiscaux (niveaux non stationnaires, %d premières périodes)', Tmax), ...
        'FontSize', 14, 'FontWeight','bold');

% Export PNG haute résolution
exportgraphics(gcf, output_file, 'Resolution', 300);

fprintf('✅ Graphique exporté : %s\n', output_file);
