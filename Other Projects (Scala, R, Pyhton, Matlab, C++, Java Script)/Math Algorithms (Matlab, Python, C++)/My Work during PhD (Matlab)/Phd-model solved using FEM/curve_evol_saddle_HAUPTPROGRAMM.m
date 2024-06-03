% ACHTUNG! Wenn sichergegangen werden soll, dass auch tatsächlich energiedichte.m 
% als Energie hier behandelt wird: Die Vorarbeit/Energieeen_und_Ableitungen löschen!
% Denn dort werden hilfmäßig die Ableitungen abgespeichert und
% wiederverwendet, falls sie dort gefunden werden, und ein paar gleiche
% Signaturen aufweisen (z.B. dass das N übereinstimmt)

clear;
addpath('Vorarbeit (Nebenrechnungen)')

% bc_types: 0 = clamped/clamped (Kompression ca. 0.6)
% clamped = Wert+Ableitung, fixed = nur Wert
bc_type = 0;

% N = Anzahl Intervalle, also N = nC-1, wobei nC = #Knotenpunkte
N = 11;
T_final = 150;
interpol = false;

L = 4;  % Länge der Platee
l = L * 3 / pi *sin(pi/3);  % Platte zusammengedrückt von L auf l
% l = l * 1/4;

[c4n,u,n] = u_ini(N, L, l, bc_type);    % c4n = Knotenkorrdinaten, u = Deformation, n = Direktor
% u =[x;y;z]
tau = 1/N;              % Zeitschrittweite
nC = size(c4n,1);
show_p3_curve(c4n,u, n);

[M,S,T] = p3_matrices(c4n);
Z = sparse(2*nC,2*nC);      % leere Hilfsmatrix
MM = [M,Z; Z,M]; % Massematrix für (u,v)_{L^2}       2 mal, weil "u in 2D"
SS = [S,Z; Z,S]; % Massematrix für (u',v')_{L^2}   2 mal, weil "u in 2D"
TT = [T,Z; Z,T]; % Massematrix für (u'',v'')_{L^2}   2 mal, weil "u in 2D"
AA = MM+tau*TT;             % Massematrix für H^2-kompatibles Skalarprodukt

[m,s] = p1_matrices(c4n);
z = sparse(nC, nC);      % leere Hilfsmatrix
mm = [m,z; z,m]; % Massematrix für (u,v)_{L^2}       2 mal, weil "u in 2D"
ss = [s,z; z,s]; % Massematrix für (u',v')_{L^2}   2 mal, weil "u in 2D"
aa = mm+tau*ss;             % Massematrix für H^2-kompatibles Skalarprodukt % oder doch für implizites Euler mit "+tau*TT", weil TT halt auch die Ableitung der Energie symbolisiert??

t = 0; k = 0;
        disp('Symbolische Berechnung der Energieableitung:');tic;
        gibts_schon = false;
        dateien = dir('./Vorarbeit (Nebenrechnungen)/Energieen und Ableitungen abspeichern/*.mat');
        anz_dat = length(dateien);
        
        for i = 1:anz_dat
            dat = load(strcat('./Vorarbeit (Nebenrechnungen)/Energieen und Ableitungen abspeichern/',dateien(i).name));
            if isequal(dat.c4n ,c4n) && isequal(interpol, dat.interpol)    % sollte eigentl. auch überprüfen, ob energie gleich war !!!!!! noch machen!
                dEu = dat.dEu;
                dEn = dat.dEn;
                dEu_lin_coeff = dat.dEu_lin_coeff;
                dEn_lin_coeff = dat. dEn_lin_coeff;
                gibts_schon = true;
            end
        end
        if not(gibts_schon) 
            [E, dEu, dEn, dEu_lin_coeff, dEn_lin_coeff] = E_und_dE_von_2d_Funktional_p3Elem_und_p1Elem(@energiedichte, c4n, interpol);
            save(strcat('./Vorarbeit (Nebenrechnungen)/Energieen und Ableitungen abspeichern/', string(now), '.mat'), "E", "c4n", "dEn", "dEu", "dEu_lin_coeff", "interpol", "dEn_lin_coeff");
        end
        toc;
        tic;
while t < T_final 
    k = k+1; t = k*tau;
    disp('Zeit           Länge')
    disp([t, u'*SS*u])
    % ertelle OC (orthogonality condition): Matrix für Isometriebedingung (dass Schritt im
    % Tangentialraum gemacht wird, und gleichzeitig Matrix für
    % Lagrangemultiplikatoren
    I = [1:nC;              1:nC];
    J = [0*nC+2*(1:nC);     2*nC+2*(1:nC)];
    X = [u(0*nC+2*(1:nC))'; u(2*nC+2*(1:nC))'];
    OC = sparse(I(:),J(:),X(:));
    
    % Je nach Randbedingung werden aus OC Zeilen frei gemacht. Die
    % zugehörigen Dofs bekommen dann mit OC direktere Kodierungen für die Randbedingungen:
    [BC,elim_cons] = bc_matrix(c4n,bc_type);    % Isometriebedingung-Lagrange-... bereinigt
    OC(elim_cons,:) = [];                       % Randbedingungen
    DD = [OC;BC];
    
    % explizite Lösung für Deformation:
%         XX = [AA,DD'; DD,sparse(size(DD,1),size(DD,1))];
    % implizite Lösung für Deformation:
    XX = [AA + tau * dEu_lin_coeff(n)',DD'; DD,sparse(size(DD,1),size(DD,1))]; % das "+ tau * dEu_lin_coeff'" macht es implizit
%         disp('2'); tic;
    yy = [-(dEu(u,n))';zeros(size(DD,1),1)];
%         toc;
%         disp('3'); tic;
    vv = XX\yy;
%         toc;
    v = vv(1:4*nC); % Lagrangemultiplikator wegwerfen.
    u = u+tau*v;
%         toc;
    
    nb = sparse(nC, 2*nC); 
    for kk = 1:nC    % noch explizit die Nebenbedingung drin.. :/
        nb(kk,kk) = n(kk);
        nb(kk,nC+kk) = n(nC+kk);
    end
    %explizite Lösung für Direktor-Schritt:
%     LSn = [aa, nb'; nb, sparse(size(nb,1), size(nb,1))];
%     RSn = [-(dEn(u,n))'; zeros(size(nb,1),1)];

    %   implizite Lösung für Direktor-Schritt:
    LSn = [aa + tau * dEn_lin_coeff(u)',nb'; nb, sparse(size(nb,1), size(nb,1))]; % das "+ tau * dEn_lin_coeff'" macht es implizit
    RSn = [-(dEn(u,n))'; zeros(size(nb,1),1)];
    dn = LSn\RSn;
    n = n + (tau) * dn(1:2*nC);
    
%         disp('4'); tic;
    show_p3_curve(c4n,u, n);
%     toc;
end
toc;
