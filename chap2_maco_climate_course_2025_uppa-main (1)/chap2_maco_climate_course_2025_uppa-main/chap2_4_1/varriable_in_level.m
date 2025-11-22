dynare basic_rbc_with_growth

% ================================
% Post-traitement : variables non stationnaires
% ================================
gamma = gamm;                             % paramètre du .mod : 1+g
T      = size(oo_.endo_simul, 2) - 1;     % colonnes = t=0..T
tgrid  = 0:T;
trend  = gamma.^tgrid;                     % (1+g)^t

% récupérer les variables par leur nom
getv = @(name) oo_.endo_simul(strcmp(cellstr(M_.endo_names), name), :);

% Reconstitution niveaux non stationnaires (X_ns = \hat X * (1+g)^t)
C_ns = getv('c')      .* trend;
Y_ns = getv('y')      .* trend;
K_ns = getv('k')      .* trend;
I_ns = getv('invest') .* trend;
G_ns = getv('g')      .* trend;
W_ns = getv('w')      .* trend;

% Variables sans trend :
L_ns = getv('l');       % l ne trend pas
R_ns = getv('r');       % r ne trend pas
A_ns = getv('A');       % ici A est déjà stationnaire (choc de TFP "hat")

% Stockage pratique dans la sortie Dynare
oo_.nonstationary.C = C_ns;
oo_.nonstationary.Y = Y_ns;
oo_.nonstationary.K = K_ns;
oo_.nonstationary.I = I_ns;
oo_.nonstationary.G = G_ns;
oo_.nonstationary.W = W_ns;
oo_.nonstationary.L = L_ns;
oo_.nonstationary.R = R_ns;
oo_.nonstationary.A = A_ns;
oo_.nonstationary.t = tgrid;



 % ================================
% Plot en niveaux 
% ================================
figure('Position',[100 100 900 450]);  % un peu plus large

% séries
Y = Y_ns;
C = C_ns;
I = I_ns;
G = G_ns;

plot(tgrid, Y, 'LineWidth', 2.2, 'Color', [0.22 0.49 0.72]); hold on;   % bleu
plot(tgrid, C, 'LineWidth', 2.2, 'Color', [0.30 0.75 0.53]);            % vert
plot(tgrid, I, 'LineWidth', 2.2, 'Color', [0.87 0.49 0.00]);            % orange

grid on;
box on;

xlabel('Périodes', 'Interpreter','latex', 'FontSize', 11);
ylabel('Niveau',   'Interpreter','latex', 'FontSize', 11);
title('Variables en niveau ', 'Interpreter','latex', 'FontSize', 12);

    legend({'PIB $Y_t$', 'Consommation $C_t$', 'Investissement $I_t$'}, ...
    'Interpreter','latex', 'Location','northwest', 'FontSize', 9);

set(gca, ...
    'FontName','Helvetica', ...
    'FontSize',10, ...
    'LineWidth',0.8, ...
    'XLim',[tgrid(1) tgrid(end)]);

% option : axes plus "propres"
yt = get(gca,'YTick');
set(gca,'YTickLabel',compose('%.2f', yt));

saveas(gcf, 'figures/niveaux_non_stationnaires.png');  % ou le dossier que tu v

