% Testet E_und_dE_von_2d_Funktional_p3Elem an den Beispielen der L^2-Normen,
% deren Ableitung auch wieder mit den Funktionen selbst geschrieben werden
% können: de(u)[u] = 2*e(u), wenn e(u) = 1/2 * \int |u^{(k)}|^2

clear;
addpath('..');
addpath('../..');

c4n = (0:0.5:3)';
nC = length(c4n);

% g = @(x) [sin(x); x.^3];
% dg = @(x) [cos(x); 3*x.^2];
% ddg = @(x) [-sin(x); 6*x];

% v = [g(c4n'); dg(c4n')];
% v = v(:);


y_1 = @(x) x.^2+exp(x);
y_2 = @(x) sin(x);
dy_1 = @(x) 2 * x + exp(x);
dy_2 = @(x) cos(x);
ddy_1 = @(x) 2 + exp(x);
ddy_2 = @(x) -sin(x);
y = @(x)[y_1(x); y_2(x)];
dy = @(x) [dy_1(x); dy_2(x)];
ddy = @(x)[ddy_1(x); ddy_2(x)];
uu = [y_1(c4n'), y_2(c4n'); dy_1(c4n'), dy_2(c4n')];
u = uu(:);
nHut_1 = @(x) sin(x);
nHut_2 = @(x) cos(x);
dnHut_1 = @(x) cos(x);
dnHut_2 = @(x) -sin(x);
nHut = @(x) [nHut_1(x); nHut_2(x)];
dnHut = @(x) [dnHut_1(x); dnHut_2(x)];
n = nHut(c4n);


% show_p3_curve(c4n, u);
% axis(0.4*[-1,1,-1,1]);
% hold on;
% plot(y_1(c4n),y_2(c4n));
% hold off;


[M,S,T] = p3_matrices(c4n);
Z = sparse(2*nC,2*nC);      % leere Hilfsmatrix
MM = [M,Z; Z,M]; % Massematrix für (u,v)_{L^2}       2 mal, weil "u in 2D"
SS = [S,Z; Z,S]; % Massematrix für (u',v')_{L^2}     2 mal, weil "u in 2D"
TT = [T,Z; Z,T]; % Massematrix für (u'',v'')_{L^2}   2 mal, weil "u in 2D"

[m,s] = p1_matrices(c4n);
z = sparse(nC, nC);      % leere Hilfsmatrix
mm = [m,z; z,m]; % Massematrix für (u,v)_{L^2}       2 mal, weil "u in 2D"
ss = [s,z; z,s]; % Massematrix für (u',v')_{L^2}   2 mal, weil "u in 2D"

%% 
disp('dn::::::::::::::::::::::::::::::::::::::::::')
f = @(x,y,dy,ddy, n, dn) 1/2*sum(dn.^2, 1);
[E, dEu, dEn] = E_und_dE_von_2d_Funktional_p3Elem_und_p1Elem(f, c4n, 0);
EE = dEn(u, n);
vergleich0 = EE * cos(n);
vergleich1 = n' * ss * cos(n);
disp( max(abs(vergleich0 - vergleich1)) );

%% 
disp('n::::::::::::::::::::::::::::::::::::::::::')
f = @(x,y,dy,ddy, n, dn) 1/2*sum(n.^2, 1);
[E, dEu, dEn] = E_und_dE_von_2d_Funktional_p3Elem_und_p1Elem(f, c4n, 0);
EE = dEn(u, n);
vergleich0 = EE * exp(n);
vergleich1 = n' * mm * exp(n);
disp( max(abs(vergleich0 - vergleich1)) );

%% 
disp('n+dn ::::::::::::::::::::::::::::::::::::::::::')
f = @(x,y,dy,ddy, n, dn) 1/2 * sum((n+dn).^2,1);
[E, dEu, dEn] = E_und_dE_von_2d_Funktional_p3Elem_und_p1Elem(f, c4n, 0);
EE = dEn(u, n);
mHut1 = @(x) exp(x);
dmHut1 = @(x) exp(x);
mHut2 = @(x) exp(x);
dmHut2 = @(x) exp(x);
mHut = @(x) [mHut1(x); mHut2(x)];
dmHut = @(x) [dmHut1(x); dmHut2(x)];
m = [mHut1(c4n); mHut2(c4n)];
vergleich0 = EE * m;
vergleich1 =  integral(@(x) sum((nHut(x)+dnHut(x)).*(mHut(x)+dmHut(x))), c4n(1), c4n(length(c4n)));
disp( max(abs(vergleich0 - vergleich1)) );

%%
disp('ddy::::::::::::::::::::::::::::::::::::::::::')
f = @(x,y,dy,ddy, n, dn) 1/2*sum(ddy.^2, 1);
[E, dEu, dEn, dEu_lin_coeff] = E_und_dE_von_2d_Funktional_p3Elem_und_p1Elem(f, c4n, 0);
EE = dEu(u, n);
vergleich0 = EE * u;
vergleich1 = u' * TT * u;
vergleich2 = 2 * integral(@(x) f(x, y(x), dy(x), ddy(x)), c4n(1), c4n(length(c4n)));
vergleich3 = NaN;% (u' * dEu_lin_coeff(n) + dEu_nonlin(u,n)) * u;
disp([max(abs(vergleich0 - vergleich1)), ...
max(abs(vergleich0 - vergleich2)), ...
max(abs(vergleich1 - vergleich2)), ...
max(abs(vergleich3 -vergleich2)), ...
max(abs(u'*dEu_lin_coeff(n) - u' * TT))])

%%
disp('dy::::::::::::::::::::::::::::::::::::::::::')
f = @(x,y,dy,ddy, n, dn) 1/2*sum(dy.^2, 1);
[E, dEu, dEn] = E_und_dE_von_2d_Funktional_p3Elem_und_p1Elem(f, c4n, 0);
EE = dEu(u, n);
vergleich0 = EE * u;
vergleich1 = u' * SS * u;
vergleich2 = 2 * integral(@(x) f(x, y(x), dy(x), ddy(x)), c4n(1), c4n(length(c4n)));
disp([max(abs(vergleich0 - vergleich1)), ...
max(abs(vergleich0 - vergleich2)), ...
max(abs(vergleich1 - vergleich2))])

%%
disp('y::::::::::::::::::::::::::::::::::::::::::')
f = @(x,y,dy,ddy, n, dn) 1/2*sum(y.^2, 1);
[E, dEu, dEn] = E_und_dE_von_2d_Funktional_p3Elem_und_p1Elem(f, c4n, 0);
EE = dEu(u, n);
vergleich0 = EE * u;
vergleich1 = u' * MM * u;
vergleich2 = 2 * integral(@(x) f(x, y(x), dy(x), ddy(x)), c4n(1), c4n(length(c4n)));
disp([max(abs(vergleich0 - vergleich1)), ...
max(abs(vergleich0 - vergleich2)), ...
max(abs(vergleich1 - vergleich2))])
disp([E(u, n), integral(@(x) f(x, y(x), dy(x), ddy(x), nHut(x), dnHut(x)), c4n(1), c4n(length(c4n)))])

%%
disp('mit x::::::::::::::::::::::::::::::::::::::::::')
f = @(x,y,dy,ddy, n, dn) x.^2;
[E, dEu, dEn] = E_und_dE_von_2d_Funktional_p3Elem_und_p1Elem(f, c4n, 0);
EE = dEu(u, n);
vergleich0 = EE * u;
vergleich1 = u' * MM * u;
vergleich2 = 2 * integral(@(x) f(x, y(x), dy(x), ddy(x)), c4n(1), c4n(length(c4n)));
disp([max(abs(vergleich0 - vergleich1)), ...
max(abs(vergleich0 - vergleich2)), ...
max(abs(vergleich1 - vergleich2))])
disp([E(u, n), integral(@(x) f(x, y(x), dy(x), ddy(x), nHut(x), dnHut(x)), c4n(1), c4n(length(c4n)))])

%%
function [M,S,T] = p3_matrices(points)
% M ist für (v,u)_{L^2}
% S ist für (v', u')_{L^2}
% T ist für (v'', u'')_{L^2}
% aber alles nur "1d": Der Wertebereich der assoziierten Funktionen ist in \R^1, d.h. length(u) = 2*nC
nC = size(points,1);
M = sparse(2*nC,2*nC); S = sparse(2*nC,2*nC); T = sparse(2*nC,2*nC); 
m_loc = [156,22,54,-13;22,4,13,-3;54,13,156,-22;-13,-3,-22,4]/420;          % sind die Koeffizienten in (u,v)_{L^2((0,1))}      vor [u1*v1, u1*v2, u1*v3, u1*v4; u2*v1, u2*v2, u2*v3, u2*v4; u3*v1, u3*v2, u3*v3, u3*v4; u4*v1, u4*v2, u4*v3, u4*v4], wobei [u1, u2, u3, u4] = [u(0), u'(0), u(1), u'(1)]
s_loc = [252,21,-252,21;21,28,-21,-7;-252,-21,252,-21;21,-7,-21,28]/210;    % sind die Koeffizienten in (u',v')_{L^2(0,1)}      vor [u1*v1, u1*v2, u1*v3, u1*v4; u2*v1, u2*v2, u2*v3, u2*v4; u3*v1, u3*v2, u3*v3, u3*v4; u4*v1, u4*v2, u4*v3, u4*v4]
t_loc = 2*[6,3,-6,3;3,2,-3,1;-6,-3,6,-3;3,1,-3,2];                          % sind die Koeffizienten in (u'',v'')_{L^2(0,1)}    vor [u1*v1, u1*v2, u1*v3, u1*v4; u2*v1, u2*v2, u2*v3, u2*v4; u3*v1, u3*v2, u3*v3, u3*v4; u4*v1, u4*v2, u4*v3, u4*v4]
for j = 1 : nC-1                %Anzahl der Elemente (Intervalle)
    h = points(j+1)-points(j);  % Breite des Intervalls/Elements
    fac = [1,h,1,h];
    for k = 1 : 4
        for ell = 1 : 4
            M(2*(j-1)+k,2*(j-1)+ell) = M(2*(j-1)+k,2*(j-1)+ell)...
                +h*fac(k)*fac(ell)*m_loc(k,ell);
            S(2*(j-1)+k,2*(j-1)+ell) = S(2*(j-1)+k,2*(j-1)+ell)...
                +(1/h)*fac(k)*fac(ell)*s_loc(k,ell);
            T(2*(j-1)+k,2*(j-1)+ell) = T(2*(j-1)+k,2*(j-1)+ell)...
                +(1/h^3)*fac(k)*fac(ell)*t_loc(k,ell); 
        end
    end
end
end