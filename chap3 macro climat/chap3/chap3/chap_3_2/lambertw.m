function w = lambertw(z)
% LAMBERTW  Approximation numérique de la fonction Lambert W (branche principale)
%   w = lambertw(z) résout w*exp(w) = z pour z >= 0 (réel).
%
%   Limites :
%   - Implémentation simple, uniquement pour arguments réels >= 0
%   - Branche principale (W0) uniquement

    % Vérifications simples
    if any(~isreal(z(:)))
        error('lambertw.m : cette implémentation ne gère que les arguments réels.');
    end
    if any(z(:) < 0)
        error('lambertw.m : cette implémentation ne gère que z < 0.');
    end

    % Pré-allocation
    w = zeros(size(z));

    % Boucle élément par élément (assez rapide pour un usage en steady state)
    for k = 1:numel(z)
        zk = z(k);

        if zk == 0
            wk = 0;
        else
            % Point de départ raisonnable pour z > 0
            % (log(1+z) marche bien comme guess initial)
            x0 = log(zk + 1);

            % Fonction f(x) = x*exp(x) - z
            f = @(x) x .* exp(x) - zk;

            % On encadre un peu pour aider fzero (si possible)
            % Mais fzero se débrouille en général avec un seul guess
            try
                wk = fzero(f, x0);
            catch
                % fallback : intervalle [log(zk+1e-8)-2, log(zk+1e-8)+2]
                x1 = x0 - 2;
                x2 = x0 + 2;
                wk = fzero(f, [x1, x2]);
            end
        end

        w(k) = wk;
    end
end
