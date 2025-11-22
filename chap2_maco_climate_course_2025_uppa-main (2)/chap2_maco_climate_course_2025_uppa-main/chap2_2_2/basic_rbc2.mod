%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deterministic RBC (Perfect Foresight) with Terminal Condition in Differences
% DK = K - K(-1), and end-of-horizon condition DK = 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-------------------------------
% 1) Variables
%-------------------------------
var c invest k w l r y DK;
varexo A l_bar;

parameters alf bet sig delt;

%-------------------------------
% 2) Calibration
%-------------------------------
alf   = 0.33;     % capital share
bet   = 0.95;     % discount factor
delt  = 0.025;    % depreciation
sig   = 3;        % CRRA

%-------------------------------
% 3) Model
%-------------------------------
model;
  % Preferences / Euler
  c^(-sig) = bet * c(+1)^(-sig) * ( r(+1) + 1 - delt );

  % Technology
  y = A * k(-1)^alf * l^(1-alf);

  % Resource constraint
  y = c + invest;

  % Capital dynamics in differences
  DK     = k - k(-1);           // DK ≡ ΔK
  invest = DK + delt * k(-1);   // I = ΔK + δK_{t-1}

  % Factor prices
  r = alf * y / k(-1);
  w = (1 - alf) * y / l;

  % Exogenous labor supply
  l = l_bar;
end;

%-------------------------------
% 4) Initial exogenous values
%-------------------------------
initval;
  A     = 1;
  l_bar = 1;
end;

%-------------------------------
% 5) Steady state (analytical)
%-------------------------------
steady_state_model;
  % Exogenous (read from initval): A, l_bar
  l = l_bar;

  r        = 1/bet - 1 + delt;
  y_over_k = r/alf;

  % Y = A^(1/(1-alf)) * (alf/r)^(alf/(1-alf)) * l
  y = A^(1/(1-alf)) * (alf/r)^(alf/(1-alf)) * l;

  k      = y / y_over_k;
  DK     = 0;              % steady difference is zero
  invest = delt * k;
  c      = y - invest;
  w      = (1 - alf) * y / l;
end;

steady;
check;

%-------------------------------
% 6) Deterministic paths (PF)
%-------------------------------
shocks;
  % Keep labor at 1 for the whole horizon
%  var l_bar;
%periods 1:40;
%values 1.1;

  % Temporary TFP shock: +5% from t=1..40, then back to 1
  var A;
    periods 1:40 41:300;
    values 1.1 1;

end;

%-------------------------------
% 7) Terminal condition in differences
%-------------------------------
endval;
  DK = 0;   % -> k(T+1) = k(T)
end;

%-------------------------------
% 8) Solve
%-------------------------------
perfect_foresight_setup(periods=300);
perfect_foresight_solver;

save('run_TFP.mat','oo_','M_');
%save('run_LBAR.mat','oo_','M_');
