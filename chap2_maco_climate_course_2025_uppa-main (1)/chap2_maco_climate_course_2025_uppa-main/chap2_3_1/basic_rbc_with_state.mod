%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RBC avec travail endogène + Etat (réel, P=1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

var c invest k w l r y muc g;
varexo A tau_tva tau_inv tau_ir tau_ss tau_k tau_y T;

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
  % Utilité marginale pure (U_C), sans taxes
  muc = (c^nu*(1-l)^(1-nu))^(-sig) * nu * c^(nu-1) * (1-l)^(1-nu);

  % Euler: muc*(1+tau_inv)/(1+tau_tva) = beta*muc(+1)/(1+tau_tva(+1))*[ r(+1)*(1-tau_k(+1)) + (1-delt)*(1+tau_inv(+1)) ]
  muc * (1 + tau_inv) / (1 + tau_tva)
    = bet * muc(+1) / (1 + tau_tva(+1)) * ( r(+1) * (1 - tau_k(+1)) + (1 - delt) * (1 + tau_inv(+1)) );

  % Technologie Cobb-Douglas
  y = A * k(-1)^alf * l^(1-alf);

  % Emplois = ressources
  y = c + invest + g;
  invest = k - (1 - delt) * k(-1);

  % Prix des facteurs (taxe de prod et cotisations)
  r / (1 - tau_y) = alf * y / k(-1);
  w * (1 + tau_ss) / (1 - tau_y) = (1 - alf) * y / l;

  % Intra-temporelle (MRS = salaire réel "taxé")
  w = ((1 - nu) / nu) * c / (1 - l) * (1 + tau_tva) / (1 - tau_ir);

% Budget de l'État (équilibré) -> g_t déterminé
  g = tau_tva * c
    + tau_inv * invest
    + (tau_ir + tau_ss) * w * l
    + tau_k * r * k(-1)
    + tau_y * y
    + T;
end;

%-------------------------
% Init & Steady
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

%  c = 0.5; l = 0.3; k = 10; r = 0.03; w = 1; y = 1; invest = 0.025*y; g = 0.2;
end;

steady_state_model;
  % 1) r de l'Euler stationnaire
  r = (1 + tau_inv) * (1 - bet * (1 - delt)) / (bet * (1 - tau_k));

  % 2) Ratios
  % K/Y
  zeta = alf * (1 - tau_y) / r;                 % zeta = K/Y
  % Y/L
  phi  = A^(1/(1-alf)) * ( alf * (1 - tau_y) / r )^(alf/(1-alf));  % phi = Y/L
  % Salaire
  w    = (1 - alf) * phi * (1 - tau_y) / (1 + tau_ss);
  % I/Y
  eta  = delt * zeta;

  % kappa via intratemporelle: C = kappa * (1 - L)
  kappa = (nu / (1 - nu)) * w * (1 - tau_ir) / (1 + tau_tva);

  % Budget Etat: G(L) = a0 + a1 * L
  a0 = tau_tva * kappa + T;
  a1 = - tau_tva * kappa + tau_inv * eta * phi + (tau_ir + tau_ss) * w + tau_k * r * zeta * phi + tau_y * phi;

  % L* (cas B: G endogène, T exogène)
  l = (kappa + a0) / (phi * (1 - eta) + kappa - a1);

  % Agrégats au SS
  y = phi * l;
  c = kappa * (1 - l);
  k = zeta * y;
  invest = eta * y;
  g = a0 + a1 * l;

  % U_C 
  muc = (c^nu*(1-l)^(1-nu))^(-sig) * nu * c^(nu-1) * (1-l)^(1-nu);
end;

steady;

%-------------------------
% Choc déterministe (exemple)
%-------------------------
shocks;
  var A; periods 1:40; values 1.2;
  var tau_ss; periods 80 ; values .1;
end;

%-------------------------
% Perfect foresight
%-------------------------
perfect_foresight_setup(periods=300);
perfect_foresight_solver;

