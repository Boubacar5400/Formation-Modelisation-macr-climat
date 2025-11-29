%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RBC stationnarisé (BGP Harrod) avec travail endogène + Etat + GES
% Toutes les variables sont déjà "avec chapeau" (divisées par (1+g)^t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Variables réelles (stationnarisées)
var c invest k w l r y muc g e s xi;

% Exogènes (niveaux stationnarisés)
varexo A tau_tva tau_inv tau_ir tau_ss tau_k tau_y T;

% Paramètres (gbar = g net ; gamm = 1+g)
parameters alf bet sig delt nu gbar gamm deltae rho_xi xi_bar;

%-------------------------
% Calibration
%-------------------------
alf    = 0.33;    % part du capital
bet    = 0.99;    % facteur d'actualisation
delt   = 0.025;   % dépréciation par période
sig    = 3;       % CRRA sur l'agrégat
nu     = 0.5;     % poids de c dans X = c^nu (1-l)^(1-nu)

gbar   = 0.015;    % taux de croissance Harrod
gamm   = 1+gbar;

% Climat
deltae = 0.02;    % "dégradation" du stock (sortie naturelle)
rho_xi = 0.9;    % persistance de l'intensité d'émissions
xi_bar = 0.40;    % niveau de LT de l'intensité

%-------------------------
% Modèle (stationnarisé)
%-------------------------
model;
  % Utilité marginale de c (U_C) sur X = [c^nu * (1-l)^(1-nu)]
  muc = (c^nu * (1-l)^(1-nu))^(-sig) * nu * c^(nu-1) * (1-l)^(1-nu);

  % Euler stationnarisée
  muc * (1 + tau_inv) / (1 + tau_tva)
    = bet * muc(+1) / (1 + tau_tva(+1)) * gamm^(nu*(1-sig)-1)
      * ( r(+1) * (1 - tau_k(+1)) + (1 - delt) * (1 + tau_inv(+1)) );

  % Technologie Cobb-Douglas (stationnarisée)
  y = A * (k(-1)/gamm)^alf * l^(1-alf);

  % Ressources
  y = c + invest + g;

  % Accumulation stationnarisée du capital
  invest = k - (1 - delt)/gamm * k(-1);

  % Prix des facteurs (FOC firmes)
  r / (1 - tau_y) = alf * y * gamm / k(-1);
  w * (1 + tau_ss) / (1 - tau_y) = (1 - alf) * y / l;

  % Intra-temporelle (MRS = salaire réel "taxé")
  w = ((1 - nu) / nu) * c / (1 - l) * (1 + tau_tva) / (1 - tau_ir);

  % Budget public stationnarisé (équilibré) -> g déterminé
  g = tau_tva * c
    + tau_inv * invest
    + (tau_ir + tau_ss) * w * l
    + tau_k * r * k(-1) / gamm
    + tau_y * y
    + T;

  % ---------- BLOC CLIMAT (stationnarisé) ----------
  % Emissions (flux) et stock atmosphérique
  e = xi * y;
  s = xi * y + (1 - deltae)/gamm * s(-1);

  % Intensité d'émissions : AR(1) déterministe en log
  log(xi) = (1 - rho_xi) * log(xi_bar) + rho_xi * log(xi(-1));
end;

%-------------------------
% Init (niveaux de base, taxes nulles)
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

  
  xi = xi_bar;
  e  = 0.0;
  s  = 0.0;
end;

%-------------------------
% Steady state analytique (stationnaire)
%-------------------------
steady_state_model;
  % --- Bloc réel (inchangé) ---
  r = (1 + tau_inv) * ( 1/(bet * gamm^(nu*(1-sig)-1)) - (1 - delt) ) / (1 - tau_k);

  zeta = alf * (1 - tau_y) * gamm / r;                                 % k/y
  phi  = A^(1/(1-alf)) * ( alf * (1 - tau_y) / r )^(alf/(1-alf));      % y/l
  w    = (1 - alf) * phi * (1 - tau_y) / (1 + tau_ss);                  % salaire
  eta  = (gbar + delt)/gamm * zeta;                                     % i/y
  kappa = (nu / (1 - nu)) * w * (1 - tau_ir) / (1 + tau_tva);           % c = kappa*(1-l)

  a0 = tau_tva * kappa + T;
  a1 = - tau_tva * kappa
       + tau_inv * eta * phi
       + (tau_ir + tau_ss) * w
       + tau_k * r * zeta * phi / gamm
       + tau_y * phi;

  l = (kappa + a0) / (phi + kappa - eta * phi - a1);

  y      = phi * l;
  c      = kappa * (1 - l);
  k      = zeta * y;
  invest = eta * y;
  g      = a0 + a1 * l;

  muc = (c^nu*(1-l)^(1-nu))^(-sig) * nu * c^(nu-1) * (1-l)^(1-nu);

  % --- Bloc climat (sans rétroaction) ---
  xi = xi_bar;
  e  = xi * y;
  s  = e / (1 - (1 - deltae)/gamm);   
end;
steady;

%-------------------------
% Chocs déterministes (exemples)
%-------------------------
shocks;
  % choc temporaire de TFP (stationnarisé)
  var A; periods 1:40; values 1;

  % hausse temporaire de cotisations
  var tau_ss; periods 1:200; values 0.3;

end;

%-------------------------
% Perfect foresight
%-------------------------
perfect_foresight_setup(periods=300);
perfect_foresight_solver;
