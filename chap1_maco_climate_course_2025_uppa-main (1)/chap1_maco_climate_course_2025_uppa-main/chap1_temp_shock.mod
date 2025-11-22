%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deterministic Growth Model
% Study the impact of temporary shocks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------
% 1. Preamble Block
%----------------------------------------------------------------

var c k y i g_y;
varexo A;

parameters alf bet sig delt rhoo;

%----------------------------------------------------------------
% Calibration
%----------------------------------------------------------------
%
% U(c) = (c^(1-sigma))/(1-sigma)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

alf   = 0.33;
bet   = 0.95;
delt  = 0.025;
sig   = 3;
rhoo  = 0.7;

%----------------------------------------------------------------
% 2. Model
%----------------------------------------------------------------

model;
  c^(-sig) = bet*(c(+1)^(-sig))*(alf*A(+1)*k^(alf-1)+1-delt);
  y=A*k(-1)^(alf);
  y=c+i;
  i=k-(1-delt)*k(-1);
  g_y=(y(+1)-y)/y;
  %A = rho*A(-1)+e;
end;

%----------------------------------------------------------------
% 3. Steady State or Initial Values Block
%----------------------------------------------------------------

initval;
  k = 8.7;
  c = 1.82;
  i = 0.2175;
  y = 2.94;
  A = 1;
 %e = 0;
end;
steady;

%---------------------------------------------
% 4. Shocks Block
%---------------------------------


%Temporary shock

shocks;
var A ; periods 50:60;
values 1.1;
end;



%-----------------------------------------
% 5. Computation Block
%-----------------------------------------

perfect_foresight_setup(periods=300);
perfect_foresight_solver;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6. Result Block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Nombre de variables endogènes
    nvar       = M_.endo_nbr-1;
    var_names  = cellstr(M_.endo_names(1:5));  
    T          = size(oo_.endo_simul, 2) - 1;  % on enlève la colonne t=0
    tt         = 1:T;


        
    figure;
        % On trace de t=1 à T (colonnes 2 à fin)
        subplot(3, 2, 1);
        plot(tt, oo_.endo_simul(1, 2:end),'k', 'LineWidth', 1.5);
        title('Consumption', 'Interpreter', 'none');
        xlabel('t');

        subplot(3, 2, 2);
        plot(tt, oo_.endo_simul(2, 2:end),'k', 'LineWidth', 1.5);
        title('Capital', 'Interpreter', 'none');
        xlabel('t');

        subplot(3, 2, 3);
        plot(tt, oo_.endo_simul(3, 2:end),'k', 'LineWidth', 1.5);
        title('Production', 'Interpreter', 'none');
        xlabel('t');

        subplot(3, 2, 4);
        plot(tt, oo_.endo_simul(4, 2:end),'k', 'LineWidth', 1.5);
        title('Investment', 'Interpreter', 'none');
        xlabel('t');

        subplot(3, 2, 5);
        plot(tt, oo_.endo_simul(5, 2:end),'k', 'LineWidth', 1.5);
        title('Economic growth', 'Interpreter', 'none');
        xlabel('t');

saveas(gcf, 'endogenes_subplots_temporary.png');


%% export 
%matlab;
    % Variables Dynare
    nvar      = M_.endo_nbr;
    var_names = cellstr(M_.endo_names);
    T         = size(oo_.endo_simul, 2) - 1;  % t=1..T
    tt        = (1:T)';

    % On extrait les données simulées (colonnes 2 à fin pour ignorer t=0)
    data = oo_.endo_simul(:, 2:end)';

    % Construire une table avec les variables
    TBL = array2table(data, 'VariableNames', var_names);

    % Ajouter la variable temps
    TBL = addvars(TBL, tt, 'Before', 1, 'NewVariableNames', 'time');

    % Export CSV
    writetable(TBL, 'simulation_endogenes.csv');
%end;

 
