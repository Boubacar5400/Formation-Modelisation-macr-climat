% ===== irf_stationnarise.m =====
% À exécuter APRES: dynare ton_fichier.mod noclearall
assert(exist('oo_','var')==1 && isfield(oo_,'endo_simul'), 'Lance dynare avant.');

% === Variables à tracer (adapter librement) ===
vars = {'y','c','invest','k','l','w','r','e','s'};

% Créer dossier Figures si besoin
if ~exist('Figures','dir')
    mkdir Figures;
end

% --- Mapping noms → indices (Dynare 5.4 : cell array) ---
assert(iscell(M_.endo_names), 'Dynare 5.4: M_.endo_names devrait être une cell array.');
names = string(M_.endo_names(:));
% Sécuriser les noms de champs (rarement utile, mais safe)
names_valid = arrayfun(@(s) string(matlab.lang.makeValidName(char(s))), names);
% Dictionnaire nom→index
idxMap = containers.Map(cellstr(names_valid), num2cell(1:numel(names_valid)));

% Vérifier l’existence des variables demandées
for j = 1:numel(vars)
    if ~isKey(idxMap, vars{j})
        error('Variable "%s" introuvable. Disponible: %s', vars{j}, strjoin(cellstr(names_valid), ', '));
    end
end

% --- Données Dynare ---
X   = oo_.endo_simul;      % (nvar x T)
ss  = oo_.steady_state;    % (nvar x 1)
T   = size(X,2);

% On ne trace que jusqu'à Tplot (ici 189)
Tplot = min(T, 150);

% --- IRF en % vs SS stationnaire ---
% IRF = zeros(numel(vars), T);
% for j = 1:numel(vars)
%     i = idxMap(vars{j});
%     IRF(j,:) = 100*(X(i,:)/ss(i) - 1);   % Δ% par rapport au SS (stationnaire)
% end
IRF = zeros(numel(vars), Tplot);
for j = 1:numel(vars)
    i = idxMap(vars{j});
    IRF(j,:) = 100*(X(i,1:Tplot)/ss(i) - 1);   % Δ% par rapport au SS (stationnaire)
end

% --- Shading de chocs (adapté à ton .mod) ---
%shockBands = { [1 40], [80 80] };         % A: 1–40 ; tau_ss: 80
%colors     = [0.9 0.9 0.95; 0.95 0.9 0.9];

% --- Tracé ---
ymins = min(IRF,[],2); ymaxs = max(IRF,[],2);
ncol = 3; nrow = ceil(numel(vars)/ncol);
% 
ncol = 3; nrow = ceil(numel(vars)/ncol);
hfig_irf = figure('Name','IRF (%) – variables stationnarisées','Color','w');
for j=1:numel(vars)
    subplot(nrow,ncol,j); hold on; box on;
    plot(1:Tplot, IRF(j,:), 'LineWidth',1.6);
    yline(0,'k-');
    title(vars{j}, 'Interpreter','none');
    xlabel('Périodes'); xlim([1 Tplot]);
end
sgtitle('IRF (Δ% vs SS stationnaire)','FontWeight','bold');

% === Export en PNG ===
saveas(hfig_irf, fullfile('Figures','irf_rbc_ges_stationnaire.png'));
