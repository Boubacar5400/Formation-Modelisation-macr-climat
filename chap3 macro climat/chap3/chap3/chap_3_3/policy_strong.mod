%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% basic_rbc_with_climate.mod
%
% RBC Harrod (gamma = 1+g) + travail endogène
% + Climat simple :
%    - dommages : d = B * exp( -phi * (s - Sbar_hat) )
%    - stock : s_t = e_t + ((1 - deltae)/gamma) * s_{t-1}
%    - intensité des émissions xi_t (AR(1) autour de xi_bar)
% + Abattement mu_t (Psi = (chi/2)*mu^2*y)
% + Taxe carbone tau_co2 * e (rebattue en transfert tr)
%
% Toutes les variables réelles sont stationnarisées 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

var c invest k w l r y y_g muc e s xi d psi tr;
varexo A mu tau_co2;

parameters alf bet sig delt nu gbar gamm 
          B Sbar_hat 
          rho_xi xi_bar 
          phi deltae 
          chi;

% -----------------------
% Calibration
% -----------------------
alf   = 0.33;    % part du capital
bet   = 0.95;    % facteur d'actualisation
delt  = 0.025;   % dépréciation
sig   = 3;       % CRRA
nu    = 0.5;     % poids de c dans X = c^nu (1-l)^(1-nu)

gbar  = 0.02;           % croissance Harrod
gamm  = 1 + gbar;       % gamma = 1+g

B        = 1.00;        % niveau de dommage
Sbar_hat = 0.0;         % stock de référence

rho_xi  = 0.9;          % persistance de xi
xi_bar  = 0.25;         % intensité moyenne (sans abattement)

phi     = 0.001;        % pente des dommages
deltae  = 0.01;         % puits naturels

chi     = 0.5;          % convexité du coût d’abattement

% -----------------------
% Modèle dynamique
% -----------------------
model;
  % Utilité marginale (X = c^nu (1-l)^(1-nu))
  muc = (c^nu * (1-l)^(1-nu))^(-sig) 
        * nu * c^(nu-1) * (1-l)^(1-nu);

  % Euler stationnarisée (Harrod)
  muc = bet * muc(+1) 
        * gamm^(nu*(1-sig) - 1) 
        * ( r(+1) + 1 - delt );

  % Intra-temporelle
  w = ((1 - nu) / nu) * c / (1 - l);

  % Production brute (stationnarisée)
  y_g = A * (k(-1)/gamm)^alf * l^(1-alf);

  % Dommages climatiques
  d = B * exp( -phi * ( s - Sbar_hat ) );

  % Production nette
  y = d * y_g;

  % Intensité des émissions (AR(1) autour de xi_bar, modulée par mu)
  xi = (1 - mu) * ( (1 - rho_xi) * xi_bar + rho_xi * xi(-1) );

  % Emissions & stock
  e = xi * y;
  s = e + (1 - deltae)/gamm * s(-1);

  % Taxe carbone & coût d’abattement
  tr  = tau_co2 * e;
  psi = 0.5 * chi * (mu^2) * y;

  % Ressources (la taxe est un transfert)
  y = c + invest + psi;

  % Accumulation du capital (stationnarisée)
  invest = k - (1 - delt)/gamm * k(-1);

  % Prix des facteurs
  r = alf * y * gamm / k(-1);
  w = (1 - alf) * y / l;
end;

% ------------------------------------------------------
% Steady state analytique (PAS DE FICHIER _steadystate.m)
% ------------------------------------------------------

initval;
  A  = 1;
  mu = 0;
  tau_co2 = 0;
end;

steady_state_model;
  % ----- 1) Classement "RBC" : r, K/Y, I/Y, l -----

  % Taux d’intérêt au SS (Euler Harrod)
  r = 1/(bet * gamm^(nu*(1-sig) - 1)) - (1 - delt);

  % Ratios agrégés
  zeta = alf * gamm / r;               % K/Y
  eta  = (gbar + delt)/gamm * zeta;    % I/Y

  % Travail endogène (MRS = w_firme)
  % w_firme = (1-alf)*y/l ; c = (1-eta)*y
  l = (1 - alf) / ( (1 - alf) + ((1 - nu)/nu) * (1 - eta) );

  % ----- 2) Constantes climatiques -----

  % Stock de GES au SS : s = e + (1-deltae)/gamm * s  =>  s = kappa * y
  % avec e = xi_bar * y
  kappa = xi_bar * gamm / (gbar + deltae);


  % Constante technologique (sans dommages) dans y_g :
  % y_g = A * (k/gamm)^alf * l^(1-alf)
  % k = zeta * y, donc y_g = A * (zeta^alf) * gamm^(-alf) * l^(1-alf) * y^alf
  C0 = (zeta^alf) * (gamm^(-alf)) * l^(1-alf);   % coefficient devant y^alf dans y_g

  % On a :
  %   y = d * y_g
  %   d = B * exp( -phi (s - Sbar_hat) ) = B * exp( -phi (kappa y - Sbar_hat) )
  %
  % => y = B * exp( -phi (kappa y - Sbar_hat) ) * C0 * y^alf
  % => y^(1-alf) = B * C0 * exp( phi Sbar_hat ) * exp( -phi kappa y )
  %
  % En jouant un peu avec l’algebra, on arrive à :
  %    y = (1/a) * lambertw( a * D )
  % pour des constantes a, D :

  a = phi * kappa / (1 - alf);

  % C regroupe les constantes de prod (hors dommages), élevé à 1/(1-alf)
  C = (C0)^(1/(1-alf));

  % D regroupe C, B, le niveau de travail et Sbar_hat
  D = C * ( B * exp( phi * Sbar_hat ) )^(1/(1-alf));

  % ----- 3) Fermeture analytique avec Lambert W -----

  y = (1/a) * lambertw( a * D );

  % ----- 4) Reste des variables au steady state -----

  % Capital, investissement, conso
  k      = zeta * y;
  invest = eta  * y;
  c      = y - invest;

  xi      = xi_bar;

  % Emissions & stock
  e = xi * y;
  s = kappa * y;

  % Dommages & production brute
  d   = B * exp( -phi * ( s - Sbar_hat ) );
  y_g = y / d;

  % Salaires, transferts, coût d’abattement
  w   = (1 - alf) * y / l;
  tr  = tau_co2 * e;      % = 0
  psi = 0.5 * chi * (mu^2) * y;  % = 0

  % Utilité marginale
  muc = (c^nu * (1-l)^(1-nu))^(-sig) 
        * nu * c^(nu-1) * (1-l)^(1-nu);
end;



steady;
check;

% -----------------------
% Scénarios déterministes simples (pour TD)
% -----------------------
shocks;
  % TFP (exemple : A constant = 1.1)
  var A;      periods 1:240; values 1.1;
  % Politique climatique : mu actif de t=90 à t=239
  var mu;      periods 90:239 240:240; values 0.600 0;
  % Taxe carbone constante
  var tau_co2; periods 1:240; values 0.000;
end;

perfect_foresight_setup(periods = 240);
perfect_foresight_solver;
