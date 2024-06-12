function [c4n,u,n] = u_ini(M, L, l, bc_type)
% M +1 = Anzahl Diskretisierungpunkte (gleichmäßig von 0 bis 1 inklusive null und eins)
% bc_types: 0 = clamped/clamped
% c4n = coordinates for nodes im Intervall [0,l]
% u = [x; y], wobei
% x = [x0; dx0; x1; dx1; ...; xnC; dxnC] % beinhaltet also für die x-Koordinate von der Deformation abwechselnd die Werte und die Ableitungen in den Knotenpunkten 0 bis nC
% y = [y0; dy0; y1; dy1; ...; ynC; dynC]
switch bc_type
    case 0
        h = L/M;
%         L = pi * l / (3 * sin(pi/3))
        c4n = (0:h:L)';
        nC = size(c4n, 1);
%         if (nC ~= M+1) || (mod(M,2) == 1)
%             error('Anzahl der Intervalle muss gerade sein....')
%         end
%         x = nan(nC,1);
%         y = nan(nC,1);
%         dx = nan(nC,1);
%         dy = nan(nC,1);
%         w = acos((l-2*h)/(L-2*h));
%         for k = 3 : ((nC+1)/2)
%             x(k) = (c4n(k) - h) * cos(w) + h;
%             y(k) = (c4n(k) - h) * sin(w);
%             dx(k) = cos(w);
%             dy(k) = sin(w);
%         end
%         x(1) = 0; x(2) = h; y(1) = 0; y(2) = 0;
%         dx(1) = 1; dx(2) = cos(w / 2); dy(1) = 0; dy(2) = sin(w / 2);
%         dx((nC+1)/2) = 1; dy((nC+1)/2) = 0;
%         for k = 1:((nC-1)/2)
%             x((nC+1)/2 + k) = l/2 + l/2 - x((nC+1)/2 - k);
%             y((nC+1)/2 + k) = y((nC+1)/2 - k);
%             dx((nC+1)/2 + k) = dx((nC+1)/2 - k);
%             dy((nC+1)/2 + k) = -dy((nC+1)/2 - k);
%         end

    % L ... ursprl. Länge
    % l ... zusammengestaucht zu l
    % x ... Position auf L

    syms r A % Radius r und Winkel A des Kreisstücks
    assume(r>0);
    lsg = vpasolve([4*A*r == L, 4*sin(A) * r == l], [A,r], [-2*pi, 2*pi; 0, Inf]); 
    A = double(lsg.A);
    r = double(lsg.r);
    x = nan(nC,1);
    y = nan(nC,1);
    dx = nan(nC,1);
    dy = nan(nC,1);
    for i = 1:length(c4n)
        hilf = bogen(A,r,c4n(i));
        x(i) = hilf(1);
        y(i) = hilf(2);
        dx(i) = hilf(3);
        dy(i) = hilf(4);
    end

    uu = [x',y'; dx',dy'];
    u = uu(:);
%     winkel = pi / 5;
%     n = [cos(winkel) * ones(nC,1); sin(winkel)*ones(nC,1)+100*eps];
    winkel = pi / 2 * (1:nC)'/nC;
    n = [cos(winkel) ; sin(winkel)];
end
% if bc_type == 0
%     h = 1/M;
%     c4n = (0:h:1)';
%     nC = size(c4n,1); % nC = M
%     mod_du = sqrt(sum([-6*pi*sin(6*pi*c4n).*cos(4*pi*c4n)...
%         -4*pi*(2+cos(6*pi*c4n)).*sin(4*pi*c4n),...
%           -6*pi*sin(6*pi*c4n).*sin(4*pi*c4n)...
%         +4*pi*(2+cos(6*pi*c4n)).*cos(4*pi*c4n)...
%         6*pi*cos(6*pi*c4n)].^2,2));
%     psi = h*cumsum(mod_du);
%     u = zeros(6*nC,1);
%     u(0*nC+(1:2:2*nC)) = (2+cos(6*pi*c4n)).*cos(4*pi*c4n);
%     u(0*nC+(2:2:2*nC)) = (-6*pi*sin(6*pi*c4n).*cos(4*pi*c4n)...
%         -4*pi*(2+cos(6*pi*c4n)).*sin(4*pi*c4n))./mod_du;
%     u(2*nC+(1:2:2*nC)) = (2+cos(6*pi*c4n)).*sin(4*pi*c4n);
%     u(2*nC+(2:2:2*nC)) = (-6*pi*sin(6*pi*c4n).*sin(4*pi*c4n)...
%         +4*pi*(2+cos(6*pi*c4n)).*cos(4*pi*c4n))./mod_du;
%     u(4*nC+(1:2:2*nC)) = sin(6*pi*c4n);
%     u(4*nC+(2:2:2*nC)) = 6*pi*cos(6*pi*c4n)./mod_du;
%     T_final = 10;
%     c4n = psi;       
% elseif
% if    bc_type == 1
%     h = 4*pi/M;
%     c4n = (0:h:3*pi/2)';
%     nC = size(c4n,1);
%     u = zeros(4*nC,1);
%     u(0*nC+(1:2:2*nC)) = sin(c4n);
%     u(0*nC+(2:2:2*nC)) = cos(c4n);
%     u(2*nC+(1:2:2*nC)) = cos(c4n);
%     u(2*nC+(2:2:2*nC)) = -sin(c4n);
%     T_final = 10;
% elseif bc_type == 2
%     h = 4*pi/M;
%     c4n = (0:h:4*pi)';
%     nC = size(c4n,1);
%     u = zeros(6*nC,1);
%     fac1 = sqrt(99/100); fac2 = 1/10;
%     u(0*nC+(1:2:2*nC)) = sin(fac1*c4n);
%     u(0*nC+(2:2:2*nC)) = fac1*cos(fac1*c4n);
%     u(2*nC+(1:2:2*nC)) = cos(fac1*c4n);
%     u(2*nC+(2:2:2*nC)) = -fac1*sin(fac1*c4n);
%     u(4*nC+(1:2:2*nC)) = fac2*c4n;
%     u(4*nC+(2:2:2*nC)) = fac2;
%     T_final = 10;
% elseif bc_type == 3
%     h = 4*pi/M;
%     c4n = (0:h:4*pi)';
%     nC = size(c4n,1);
%     u = zeros(6*nC,1);
%     fac1 = sqrt(99/100); fac2 = 1/10;
%     u(0*nC+(1:2:2*nC)) = sin(fac1*c4n);
%     u(0*nC+(2:2:2*nC)) = fac1*cos(fac1*c4n);
%     u(2*nC+(1:2:2*nC)) = cos(fac1*c4n);
%     u(2*nC+(2:2:2*nC)) = -fac1*sin(fac1*c4n);
%     u(4*nC+(1:2:2*nC)) = fac2*c4n;
%     u(4*nC+(2:2:2*nC)) = fac2;
%     T_final = 10;
% elseif bc_type == 4
%     h = 4*pi/M;
%     c4n = (0:h:4*pi)';
%     nC = size(c4n,1);
%     u = zeros(6*nC,1);
%     fac1 = sqrt(99/100); fac2 = 1/10;
%     u(0*nC+(1:2:2*nC)) = sin(fac1*c4n);
%     u(0*nC+(2:2:2*nC)) = fac1*cos(fac1*c4n);
%     u(2*nC+(1:2:2*nC)) = cos(fac1*c4n);
%     u(2*nC+(2:2:2*nC)) = -fac1*sin(fac1*c4n);
%     u(4*nC+(1:2:2*nC)) = fac2*c4n;
%     u(4*nC+(2:2:2*nC)) = fac2;
%     T_final = 10;
end

function res = bogen(A,r,x)
%     res = [x; y; dx; dy]
    L = 4*A*r;
    l = sin(A) * L / A;
    hilf = 4*A/L*r;
    if x>=0 && x< L/4
        res = [r*sin(4*A/L*x); -r+r*cos(4*A/L*x); hilf * cos(4*A/L*x); -hilf * sin(4*A/L*x)];
    elseif x >=L/4 && x < 3*L/4
        res = [l/2-r*sin((L/2-x)/(L/4)*A); -r+2*r*cos(A)-r*cos((L/2-x)/(L/4)*A); hilf * cos((L/2-x)/(L/4)*A); -hilf * sin((L/2-x)/(L/4)*A)];
    elseif x >= 3*L/4 && x<=L
        res = [l-r*sin(((L-x)/(L/4))*A); -r+r*cos(((L-x)/(L/4))*A); hilf * cos(((L-x)/(L/4))*A); hilf * sin(((L-x)/(L/4))*A)];
    else
        error('x außerhalb [0,L]')
    end
end
