function res = energiedichte(x,y,dy,ddy,n,dn)
    % dy = [dy(1);dy(2)], ...
    % n = nHut' aus paper
    % Annahmen: Zylindrisch, Direktor auch der Zylinder-Richtung konstant,
    % Direktor tangential
    kappa_n = -dy(1)*ddy(2)+ddy(1)*dy(2);
    kappa_n_quadrat = ddy(1)^2 + ddy(2)^2;
    lam = 100;
    mu = 1;
    lQuer = mu * lam / (2*mu + lam);
    rQuer = 3;
    epsQuer = .01;
    w = n(1);
    
%     disp( abs(kappa^2 - sum(ddy.^2)))
    Qel = (ddy(1)^2 + ddy(2)^2) * (mu+lQuer)/12 + kappa_n * rQuer * (-lQuer/24 + mu/8*(1/3-w^2)) + (lQuer + 5 * mu) / 192 *rQuer^2;
    Eres = 0;
    OF = epsQuer^2 / 2 *(n(1)^2 * kappa_n_quadrat + dn(1)^2 + dn(2)^2);
    res = Qel + Eres + OF;
end
