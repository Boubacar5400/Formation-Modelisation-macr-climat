%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RBC stationnarisé (BGP Harrod) avec travail endogène + Etat
% Variables "avec chapeau" implicites (toutes sont déjà dividées par (1+g)^t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Il faut lire toutes le variables comme des variables avec un chapeau:
% ie : c       => est en vérité \hat{c}
%      invest  => est en vérité \hat{invest}
%      k       => est en vérité \hat{k}
%      w       => est en vérité \hat{w}
%      l       => est en vérité \hat{l}
%      r       => est en vérité \hat{r}
%      y       => est en vérité \hat{y}
%      muc     => est en vérité \hat{muc}
%      g       => est en vérité \hat{g}


var c invest k w l r y muc g;
varexo A tau_tva tau_inv tau_ir tau_ss tau_k tau_y T;

% gbar => bgp
parameters alf bet sig delt nu gbar gamm;  // gbar = g net ; gamm = 1+g

%-------------------------
% Calibration
%-------------------------
alf  = 0.33;     % part du capital
bet  = 0.95;     % facteur d'actualisation
delt = 0.025;    % depreciation trimestrielle (ex.)
sig  = 3;        % aversion au risque (CRRA sur l'agrégat)
nu   = 0.5;      % poids de c dans X = c^nu (1-l)^(1-nu)

gbar = 0;     % taux de croissance "Harrod" (par période) 
gamm = 1+gbar;

%-------------------------
% Modèle (stationnarisé)
%-------------------------
model;
  % Utilité marginale de c (U_C) sur agrégat X = [c^nu * (1-l)^(1-nu)]
  muc = (c^nu * (1-l)^(1-nu))^(-sig) * nu * c^(nu-1) * (1-l)^(1-nu);

  % Euler stationnarisée :
  % muc*(1+tau_inv)/(1+tau_tva)
  %   = bet * muc(+1)/(1+tau_tva(+1)) * gamm^(nu*(1-sig)-1)
  %     * [ r(+1)*(1-tau_k(+1)) + (1-delt)*(1+tau_inv(+1)) ]
  muc * (1 + tau_inv) / (1 + tau_tva)
    = bet * muc(+1) / (1 + tau_tva(+1)) * gamm^(nu*(1-sig)-1)
      * ( r(+1) * (1 - tau_k(+1)) + (1 - delt) * (1 + tau_inv(+1)) );

  % Technologie Cobb-Douglas stationnarisée :
  
  y = A * (k(-1)/gamm)^alf * l^(1-alf);

  % Ressources
  y = c + invest + g;

  % Accumulation stationnarisée : k_t = (1-delt)/gamm * k_{t-1} + invest_t
  invest = k - (1 - delt)/gamm * k(-1);

  % Prix des facteurs (FOC firmes)
  r / (1 - tau_y) = alf * y * gamm / k(-1);

  % Travail : w * (1 + tau_ss)/(1 - tau_y) = (1 - alf) * y / l
  w * (1 + tau_ss) / (1 - tau_y) = (1 - alf) * y / l;

  % Intra-temporelle (MRS = salaire réel "taxé")
  w = ((1 - nu) / nu) * c / (1 - l) * (1 + tau_tva) / (1 - tau_ir);

  % Budget public stationnarisé (équilibré) -> g_t déterminé :

  g = tau_tva * c
    + tau_inv * invest
    + (tau_ir + tau_ss) * w * l
    + tau_k * r * k(-1) / gamm
    + tau_y * y
    + T;
end;

%-------------------------
% Init & Steady: valeurs de base (taxes, A)
%-------------------------
initval;
  A       = 1;
  tau_tva = 0;
  tau_inv = 0;
  tau_ir  = 0;
  tau_ss  = 0;
  tau_k   = 0;
  tau_y   = 0;
  T       = 0;
end;

%-------------------------
% Steady state analytique (stationnaire)
%-------------------------
steady_state_model;
  % 1) r issu de l'Euler stationnaire (taxes constantes)
  r = (1 + tau_inv) * ( 1/(bet * gamm^(nu*(1-sig)-1)) - (1 - delt) ) / (1 - tau_k);

  % 2) Ratios et auxiliaires
  % K/Y (zeta) : de r/(1-tau_y) = alf * y * gamm / k(-1)
  zeta = alf * (1 - tau_y) * gamm / r;          % zeta = k/y

  % Y/L (phi) : n'implique pas gamm au final
  phi  = A^(1/(1-alf)) * ( alf * (1 - tau_y) / r )^(alf/(1-alf));   % phi = y/l

  % Salaire
  w    = (1 - alf) * phi * (1 - tau_y) / (1 + tau_ss);

  % I/Y (eta)
  eta  = (gbar + delt)/gamm * zeta;

  % kappa via intratemporelle: c = kappa * (1 - l)
  kappa = (nu / (1 - nu)) * w * (1 - tau_ir) / (1 + tau_tva);

  % Budget Etat: G(L) = a0 + a1 * L
  a0 = tau_tva * kappa + T;
  a1 = - tau_tva * kappa
       + tau_inv * eta * phi
       + (tau_ir + tau_ss) * w
       + tau_k * r * zeta * phi / gamm
       + tau_y * phi;

  % L* (G endogène, T exogène)
  l = (kappa + a0) / (phi + kappa - eta * phi - a1);

  % Agrégats stationnaires
  y      = phi * l;
  c      = kappa * (1 - l);
  k      = zeta * y;
  invest = eta * y;
  g      = a0 + a1 * l;

  % U_C (utile si muc figure dans les équations)
  muc = (c^nu*(1-l)^(1-nu))^(-sig) * nu * c^(nu-1) * (1-l)^(1-nu);
end;

steady;

%-------------------------
% Chocs déterministes (exemples)
%-------------------------
%shocks;
  % choc de niveau de TFP (stationnaire car y est déjà "hat")
  %var A; periods 1:40; values 1;
  % hausse temporaire de cotisations
  %var tau_ss; periods 80; values 0.1;
%end;

%-------------------------
% Perfect foresight
%-------------------------
%perfect_foresight_setup(periods=300);
%perfect_foresight_solver;
