%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% name : basic_rbc_with_ges_with_retro_loop.mod
% RBC Harrod (gamma=1+g) + Travail endogène (CRRA) + GES + Dommages
% - Variables réelles stationnarisées (divisées par gamma^t)
% - y = d * y_g,  d = B * exp(-phi * ( s - Sbar_hat ))      [s est "hat"]
% - e = xi * y
% - s = e + (1 - deltae)/gamma * s(-1)
% - xi = (1 - rho_xi)*xi_bar + rho_xi*xi(-1)  -> xi_bar > 0 (émissions permanentes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

var c invest k w l r y y_g muc e s xi d;
varexo A;

parameters alf bet sig delt nu gbar gamm deltae rho_xi B phi Sbar_hat xi_bar;

% -----------------------
% Calibration
% -----------------------
alf   = 0.33;    % part du capital
bet   = 0.95;    % facteur d'actualisation
delt  = 0.025;   % dépréciation
sig   = 3;       % CRRA
nu    = 0.5;     % poids de c dans X = c^nu (1-l)^(1-nu)

gbar  = 0.02;            % taux Harrod (par période)
gamm  = 1 + gbar;        % gamma = 1+g

% Climat
deltae = 0.02;           % puits naturel (0<deltae<1)
rho_xi = 0.8;           % persistance
xi_bar = 0.20;           % intensité de LT (>0)

% Dommages (s est "hat")
B        = 1.00;
phi      = 0.01;
%phi      = 1e-10;
Sbar_hat = 0.0;

% -----------------------
% Modèle stationnarisé
% -----------------------
model;
  % Utilité marginale (X = c^nu (1-l)^(1-nu))
  muc = (c^nu * (1-l)^(1-nu))^(-sig) * nu * c^(nu-1) * (1-l)^(1-nu);

  % Euler (Harrod)
  muc = bet * muc(+1) * gamm^(nu*(1-sig) - 1) * ( r(+1) + 1 - delt );

  % Intra-temporelle (MRS = w)
  w = ((1 - nu) / nu) * c / (1 - l);

  % Production brute (stationnarisée)
  y_g = A * (k(-1)/gamm)^alf * l^(1-alf);

  % Dommages (fonction de s hat)
  d = B * exp( -phi * ( s - Sbar_hat ) );

  % Production nette
  y = d * y_g;

  % Ressources
  y = c + invest;

  % Accumulation (stationnarisée)
  invest = k - (1 - delt)/gamm * k(-1);

  % Prix des facteurs (stationnarisés)
  r = alf * y * gamm / k(-1);
  w = (1 - alf) * y / l;

  % Intensité (AR(1) autour de xi_bar > 0)
  xi = (1 - rho_xi) * xi_bar + rho_xi * xi(-1);

  % Emissions & stock (stationnarisés)
  e = xi * y;
  s = e + (1 - deltae)/gamm * s(-1);
end;

% -----------------------
% Guesses (aident steady)
% -----------------------
initval;
  A  = 1;
  l  = 0.33;
  k  = 12;
  d  = 0.98;
  y_g = A * (k/gamm)^alf * l^(1-alf);
  y   = d * y_g;

  r = alf * y * gamm / k;
  w = (1 - alf) * y / l;

  invest = k - (1 - delt)/gamm * k;
  c = y - invest;

  muc = (c^nu * (1-l)^(1-nu))^(-sig) * nu * c^(nu-1) * (1-l)^(1-nu);

  xi = xi_bar;
  e  = xi * y;
  s  = xi * y * gamm / (deltae + gbar);
end;

% -----------------------
% Steady state analytique via Lambert W (pas de boucle)
% -----------------------
steady_state_model;
  % 1) Taux d'intérêt (Euler, Harrod)
  r = 1/(bet * gamm^(nu*(1-sig) - 1)) - (1 - delt);

  % 2) Ratios "réels"
  zeta = alf * gamm / r;                      % K/Y
  eta  = (gbar + delt)/gamm * zeta;           % I/Y

  % 3) Travail endogène (fermé, via MRS & w_firme)
  %    l = (1-alf) / ( (1-alf) + ((1-nu)/nu)*(1-eta) )
  l = (1 - alf) / ( (1 - alf) + ((1 - nu)/nu) * (1 - eta) );

  % 4) Constante C (hors dommages) pour y = [d*A*zeta^alf*gamma^{-alf}]^{1/(1-alf)} * l
  C = ( A * ( zeta^alf ) * ( gamm^(-alf) ) )^( 1/(1-alf) );

  % 5) Paramètres de la Lambert W
  kappa = xi_bar * gamm / (deltae + gbar);    % s = kappa * y au SS
  a     = phi * kappa / (1 - alf);
  D     = C * l * ( B * exp( phi * Sbar_hat ) )^( 1/(1-alf) );

  % 6) Fermeture analytique : y = (1/a) * W(a*D)
  y = (1/a) * lambertw( a * D );

  % 7) Variables restantes
  d = B * exp( -phi * ( kappa * y - Sbar_hat ) );
  k = zeta * y;
  invest = eta * y;
  c = y - invest;

  w = (1 - alf) * y / l;
  y_g = y / d;
  xi = xi_bar;
  e  = xi * y;
  s  = kappa * y;

  muc = (c^nu * (1-l)^(1-nu))^(-sig) * nu * c^(nu-1) * (1-l)^(1-nu);
end;

steady;  
check;

% -----------------------
% Chocs déterministes 
% -----------------------
shocks;
  var A; periods 50:150 151:200; values 1.1 1;
end;

perfect_foresight_setup(periods=200);
perfect_foresight_solver;
