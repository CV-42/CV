function [M,S] = p1_matrices(points)
% M ist für (v,u)_{L^2}
% S ist für (v', u')_{L^2}
% aber alles nur "1d": Der Wertebereich der assoziierten Funktionen ist in
% \R^1, d.h. length(u) = nC
nC = size(points,1);
M = sparse(nC,nC); S = sparse(nC,nC);
m_loc = [1/3, 1/6; 1/6, 1/3];          % sind die Koeffizienten in (u,v)_{L^2((0,1))}      vor [u1*v1, u1*v2; u2*v1, u2*v2], wobei [u1, u2] = [u(0), u(1)]
s_loc = [1, -1; -1, 1];    % sind die Koeffizienten in (u',v')_{L^2(0,1)}  
for j = 1 : nC-1                %Anzahl der Elemente (Intervalle)
    h = points(j+1)-points(j);  % Breite des Intervalls/Elements
    for k = 1 : 2
        for ell = 1 : 2
            M((j-1)+k, (j-1)+ell) = M((j-1)+k, (j-1)+ell) + h*m_loc(k,ell);
            S((j-1)+k, (j-1)+ell) = S((j-1)+k, (j-1)+ell) +(1/h)*s_loc(k,ell);
        end
    end
end
end