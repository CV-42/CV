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