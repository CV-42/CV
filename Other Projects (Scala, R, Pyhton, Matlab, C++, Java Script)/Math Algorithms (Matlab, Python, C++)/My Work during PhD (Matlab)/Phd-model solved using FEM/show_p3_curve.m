function show_p3_curve(c4n, u, n)
% c4n = (0:h:1)' coordinates for nodes
% u = [x; z], wobei
% x = [x0; dx0; x1; dx1; ...; xnC; dxnC] % beinhaltet also für die x-Koordinate von der Deformation abwechselnd die Werte und die Ableitungen in den Knotenpunkten 0 bis nC
% z = [z0; dz0; z1; dz1; ...; znC; dxnC]
% n = [n1; n2], wobei
% n = nHut' aus Paper

nC = size(c4n,1);
x = (0:.05:1)'; % sind die "relativen" x-Werte innerhalb der Element-Intervalle, Kurve wird dann an (k-1)*h + h*x(i) für alle k und i ausgewertet.
vals_u = [1-3*x.^2+2*x.^3, x-2*x.^2+x.^3, 3*x.^2-2*x.^3, -x.^2+x.^3]; % Polynombasis [Wert0, Ableitung0, Wert1, Ableitung1]
vals_du = [6*x.^2 - 6*x, 3*x.^2 - 4*x + 1, - 6*x.^2 + 6*x, 3*x.^2 - 2*x]; % Polynombasis für Ableitung bzgl. [Wert0, Ableitung0, Wert1, Ableitung1]
vals_n = [1-x, x]; % Polynombasis für p1-Elemente [linkerWert, RechterWert]
H = c4n(2:nC)-c4n(1:(nC-1)); % Intervallbreiten, normalerweise bei gleichmäßgigen Abständen = [h,h,h...,h]' mit nC-1 Einträgen
fac = [ones(nC-1,1),H,ones(nC-1,1),H];   % some copies have ones(nC-1) % normalerweise = [1,h,1,h; 1,h,1,h; ...; 1,h,1,h] % Ist wichtig, weil in u auch die richtigen Ableitungen drin stehen, die als faktor für die Polynome aber mit h multipliziert werden müssen, weil die Polynome ja auch zusammengestaucht werden.
fac2 = [1./H,ones(nC-1,1),1./H,ones(nC-1,1)]; 
U1 = zeros(size(x,1),nC-1); % jede Zeile für einen  "relativen" x-Wert, jede Spalte für ein Element-Intervall
U2 = zeros(size(x,1),nC-1);
dU1 = zeros(size(x,1),nC-1);
dU2 = zeros(size(x,1),nC-1);
N1 = zeros(size(x,1),nC-1);
N2 = zeros(size(x,1),nC-1);
for k = 1:4 % geht die 4 Polynome aus der Basis durch und addiert die dann gewichtet zusammen
    U1 = U1 + vals_u(:,k) * (fac(:,k) .* u(0*nC + (0:2:2*(nC-2))+k))';
    U2 = U2 + vals_u(:,k) * (fac(:,k) .* u(2*nC + (0:2:2*(nC-2))+k))';
    dU1 = dU1 + vals_du(:,k) * (fac2(:,k) .*u(0*nC + (0:2:2*(nC-2))+k))'; % ohne "", denn mit wäre es nur der Wert der Ableitung im Referenzelement
    dU2 = dU2 + vals_du(:,k) * (fac2(:,k) .*u(2*nC + (0:2:2*(nC-2))+k))';
end
for k = 1:2 % geht die 2 Polynome aus der Basis durch und addiert die dann gewichtet zusammen
    N1 = N1 + vals_n(:,k) * n(0*nC + ((0: nC-2) + k))';  % n(0*nC + (0: nC-2+k))' = [n(k) n(1+k) n(2+k) ... n(nC-2+k)]
    N2 = N2 + vals_n(:,k) * n(1*nC + ((0: nC-2) + k))';
end
plot(U1(:),U2(:),'linewidth',2); hold on;
ids_n = round(linspace(1, length(U1(:)), 21));  % Stellen, wo Direktor gemalt werden soll.
quiver(U1(ids_n), U2(ids_n), N1(ids_n) .* dU1(ids_n), N1(ids_n) .* dU2(ids_n), 'AutoScale',0); % Zeichen Direktor entlang der Querschnitts-Tangente mit Länge = Projektion in Bildebene. (Weil: Direktor in Tangentialebene!)
hold off; drawnow;
