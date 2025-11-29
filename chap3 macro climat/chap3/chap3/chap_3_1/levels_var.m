% ===== levels_from_hat.m =====
% À exécuter APRES: dynare ton_fichier.mod noclearall
assert(exist('oo_','var')==1 && isfield(oo_,'endo_simul'), 'Lance dynare avant.');

% Param de croissance (gamm = 1 + gbar) depuis les paramètres Dynare
pnames = string(M_.param_names(:));
pvals  = M_.params(:);
i_gbar = find(pnames=="gbar", 1);
assert(~isempty(i_gbar), 'Paramètre "gbar" introuvable.');
gbar = pvals(i_gbar);
gamm = 1 + gbar;

% Variables pour remise en niveaux
vars = {'y','c','invest','k','l','w','r','e','s'}; % muc souvent moins parlant

% Créer dossier Figures si besoin
if ~exist('Figures','dir')
    mkdir Figures;
end
% --- Mapping noms → indices (Dynare 5.4) ---
assert(iscell(M_.endo_names), 'Dynare 5.4: M_.endo_names devrait être une cell array.');
names = string(M_.endo_names(:));
names_valid = arrayfun(@(s) string(matlab.lang.makeValidName(char(s))), names);
idxMap = containers.Map(cellstr(names_valid), num2cell(1:numel(names_valid)));

for j = 1:numel(vars)
    if ~isKey(idxMap, vars{j})
        error('Variable "%s" introuvable. Disponible: %s', vars{j}, strjoin(cellstr(names_valid), ', '));
    end
end

% --- Données Dynare ---
Xhat = oo_.endo_simul;    % stationnarisé
ss   = oo_.steady_state;  % stationnaire (niveau chapeauté)
% T    = size(Xhat,2);
% t    = 0:(T-1);
% gammaPow = gamm.^t;
Tfull = size(Xhat,2);
Tplot = min(Tfull, 150);      % on ne montre que jusqu'à 189
t      = 0:(Tplot-1);
gammaPow = gamm.^t;

% --- Reconstruire niveaux & référence BGP ---
X_level = zeros(numel(vars), Tplot);
X_ref   = zeros(numel(vars), Tplot);

for j = 1:numel(vars)
    i      = idxMap(vars{j});
    xhat_t = Xhat(i,1:Tplot);
    xbar   = ss(i);
    X_level(j,:) = xhat_t .* gammaPow;  % niveaux simulés
    X_ref(j,:)   = xbar   .* gammaPow;  % BGP (sans choc)
end

% % --- Tracé (Simulé vs Réf. BGP) ---
% ncol = 3; nrow = ceil(numel(vars)/ncol);
% figure('Name','Niveaux (BGP vs simul)','Color','w');
% for j=1:numel(vars)
%     subplot(nrow,ncol,j); hold on; box on;
%     plot(1:T, X_ref(j,:),  '--', 'LineWidth',1.4);
%     plot(1:T, X_level(j,:),'-',  'LineWidth',1.6);
%     title(vars{j}, 'Interpreter','none');
%     xlabel('Périodes'); xlim([1 T]);
%     legend({'BGP (réf.)','Simulé'},'Location','best'); legend boxoff
% end
% sgtitle('Variables remises en niveaux (référence BGP vs simulé)','FontWeight','bold');

ncol = 3; nrow = ceil(numel(vars)/ncol);
hfig_levels = figure('Name','Niveaux (BGP vs simul)','Color','w');
for j=1:numel(vars)
    subplot(nrow,ncol,j); hold on; box on;
    plot(1:Tplot, X_ref(j,:),  '--', 'LineWidth',1.4);
    plot(1:Tplot, X_level(j,:),'-',  'LineWidth',1.6);
    title(vars{j}, 'Interpreter','none');
    xlabel('Périodes'); xlim([1 Tplot]);
    legend({'BGP (réf.)','Simulé'},'Location','best'); legend boxoff
end
sgtitle('Variables remises en niveaux (référence BGP vs simulé)','FontWeight','bold');

% === Export en PNG ===
saveas(hfig_levels, fullfile('Figures','levels_rbc_ges.png'));