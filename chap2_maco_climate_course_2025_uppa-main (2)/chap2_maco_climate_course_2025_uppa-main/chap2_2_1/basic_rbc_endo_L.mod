%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RBC avec travail endogène — version cohérente (Euler + intratemporelle)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

var c invest k w l r y muc;
varexo A;

parameters alf bet sig delt nu;

%-------------------------
% Calibration
%-------------------------
alf  = 0.33;   % capital share
bet  = 0.95;   % discount factor
delt = 0.025;  % depreciation
sig  = 3;      % risk aversion
nu   = 0.5;    % poids de c dans l'agrégat c^nu (1-l)^(1-nu)

%-------------------------
% Model
%-------------------------
model;
  % Utilité marginale de c
  muc = (c^nu*(1-l)^(1-nu))^(-sig) * nu * c^(nu-1) * (1-l)^(1-nu);

  % Euler
  muc = bet * muc(+1) * ( r(+1) + 1 - delt );

  % Technologie et comptes
  y = A * k(-1)^alf * l^(1-alf);
  y = c + invest;
  invest = k - (1-delt) * k(-1);

  % Prix des facteurs
  r = alf * y / k(-1);
  w = (1-alf) * y / l;

  % Intra-temporelle (MRS = w) => w = ((1-nu)/nu) * c/(1-l)
  w = ((1-nu)/nu) * c / (1-l);
end;

%-------------------------
% Init & Steady
%-------------------------
initval;
  A = 1;
end;

steady_state_model;
  % 1) Taux d'intérêt d'équilibre
  r = 1/bet - 1 + delt;

  % 2) Ratios K/Y et C/Y
  k_over_y = alf * bet / (1 - bet*(1-delt));
  c_over_y = 1 - delt * k_over_y;

  % 3) y/l et salaire d'équilibre (dépendent de A, alf, r)
  y_over_l = A^(1/(1-alf)) * (alf/r)^(alf/(1-alf));
  w = (1-alf) * y_over_l;

  % 4) Partage travail/loisir via FOC intratemporelle
  %    w = ((1-nu)/nu) * c/(1-l) = ((1-nu)/nu) * c_over_y * (y_over_l * l)/(1-l)
  %    => l = w / ( w + ((1-nu)/nu) * c_over_y * y_over_l )
  l = w / ( w + ((1-nu)/nu) * c_over_y * y_over_l );

  % 5) Niveaux
  y = y_over_l * l;
  k = k_over_y * y;
  invest = delt * k;
  c = c_over_y * y;

  % 6) Utilité marginale cohérente (facultatif mais utile pour fermer muc)
  muc = (c^nu*(1-l)^(1-nu))^(-sig) * nu * c^(nu-1) * (1-l)^(1-nu);
end;

steady;

%-------------------------
% Choc déterministe
%-------------------------
shocks;
  var A; periods 1:40; values 1.1;
end;

%-------------------------
% Perfect foresight
%-------------------------
 perfect_foresight_setup(periods=300);
 perfect_foresight_solver;

save('rbc_endo_TFP.mat','oo_','M_');


