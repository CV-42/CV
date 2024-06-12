clear

% femcode2.m

% Lösen hier Laplace(Laplace(u))=f
% indem wir ein Gleichungssystem draus machen
% Mit Laplace(u1) = u2 und Laplace(u2)=f

% Testproblem:
% syms x
% syms y
% f = piecewise(norm([x,y])>=1/2, 0,exp(-1/(1-4*(norm([x y]))^2)))

%figure(1)
%fmesh(f,[-1 1 -1 1])

u_exakt = @(x,y) testfunktionQuadr(x,y);
f = @(x,y) doppellaplaceQuadr(x,y);


% Darstellung von u_exakt
darstellungsfeinheit = 0.01;
x = 0:darstellungsfeinheit:1;
y = x;
[X,Y]=meshgrid(x,y);
X = X(:);
Y = Y(:);
Z = u_exakt(X(:),Y(:));
figure(1)
scatter3(X,Y,Z)


% Brauchen dazu Stiffnessmatrix K und load vecotr F (die ich von woanders reinkopiert habe.
% Und wir brauchen Gewichtsmatrix, die ich jetzt noch selber machen muss.
 
% [p,t,b] from distmesh tool
% make sure your matlab path includes the directory where distmesh is installed.
addpath('C:\Users\User1\Documents\promotion\Programmiertes\Matlab\Pakete\distmesh');
 
% % Rundes Gebiet
% gitterfeinheit = 0.3; % Sollte max. 0.5 sein. Für feinere Gitter kleiner. (0.03 dauert schon einige Minuten.
% figure(2)
% fd=@(p) sqrt(sum(p.^2,2))-1;
% [p,t]=distmesh2d(fd,@huniform,gitterfeinheit,[-1,-1;1,1],[]);
% b=unique(boundedges(p,t)); % Randknoten

% Eckiges Gebiet
param0 = 0.05; % Globale Feinheit. Die folgenden sind nur für die relative Feinheit zum Rand hin.
param1 = 0.1; % orig 0.025 % charakt. Abstand zum Rand
param2 = 0.3; % orig 0.3 %
param3 = 0.5; % orig 0.15
figure(2)
fd=@(p) drectangle(p,0,1,0,1);
fh=@(p) min( param1 + param2 * abs(dpoly(p,[0,0; 1,0; 1, 1; 0, 1; 0, 0])), param3);
[p,t]=distmesh2d(fd,fh,param0,[0,0;1,1],[0,0;1,0;0,1;1,1]);
b=unique(boundedges(p,t)); % Randknoten
disp("Gitter fertig")
 
 
% [K,F] = assemble(p,t) % K and F for any mesh of triangles: linear phi's
N=size(p,1);T=size(t,1); % number of nodes, number of triangles
% p lists x,y coordinates of N nodes, t lists triangles by 3 node numbers
K=sparse(N,N); % zero matrix in sparse format: zeros(N) would be "dense"
F=zeros(N,1); % load vector F to hold integrals of phi's times load f(x,y)
 
for e=1:T  % integration over one triangular element at a time
  nodes=t(e,:); % row of t = node numbers of the 3 corners of triangle e
  Pe=[ones(3,1),p(nodes,:)]; % 3 by 3 matrix with rows=[1 xcorner ycorner]
  Area=abs(det(Pe))/2; % area of triangle e = half of parallelogram area
  C=inv(Pe); % columns of C are coeffs in a+bx+cy to give phi=1,0,0 at nodes
  % now compute 3 by 3 Ke and 3 by 1 Fe for element e
  grad=C(2:3,:);Ke=Area*grad'*grad; % element matrix from slopes b,c in grad
  stuetzstelle_fuer_f = arrayfun(f, p(nodes(1),1), p(nodes(1),2));
  Fe=Area/3*stuetzstelle_fuer_f; % integral of phi over triangle is volume of pyramid
  % multiply Fe by f at centroid for load f(x,y): one-point quadrature!
  % centroid would be mean(p(nodes,:)) = average of 3 node coordinates
  K(nodes,nodes)=K(nodes,nodes)+Ke; % add Ke to 9 entries of global K
  F(nodes)=F(nodes)+Fe; % add Fe to 3 components of load vector F
end   % all T element matrices and vectors now assembled into K and F


M=sparse(N,N); % Massematrix
% Im Referenzdreieck mit Punkt 1: (0,0); Punkt 2: (1,0); Punkt 2: (0,1)
% Wird jetzt int(phi_i*phi_j) berechnet:
syms x
syms y
phi1 = (1-x-y);
phi2 = x;
phi3 = y;
m11 = int(int(phi1*phi1,y,0,1-x),x,0,1);
m22 = int(int(phi2*phi2,y,0,1-x),x,0,1);
m33 = int(int(phi3*phi3,y,0,1-x),x,0,1);
m12 = int(int(phi1*phi2,y,0,1-x),x,0,1);
m13 = int(int(phi1*phi3,y,0,1-x),x,0,1);
m23 = int(int(phi2*phi3,y,0,1-x),x,0,1);
m = [m11, m12, m13; m12, m22, m23; m13, m23, m33];
for e=1:T  % integration over one triangular element at a time
  nodes=t(e,:); % row of t = node numbers of the 3 corners of triangle e
  Pe=[ones(3,1),p(nodes,:)]; % 3 by 3 matrix with rows=[1 xcorner ycorner]
  Area=abs(det(Pe))/2; % area of triangle e = half of parallelogram area
  Me = 2 * Area * m; % Das ist das Integral über das Dreieck von den Basisfunktionen % Bin ehrlich gesagt nicht sicher, was passieren würde, wenn das nicht so stark symmetrisch wäre.
  M(nodes,nodes)=M(nodes,nodes)+Me; % add Me to 9 entries of global K
end   % all T element matrices and vectors now assembled into K and F

LO = K;
RO = -M;
RU = K;
RU(b,:) = 0;
LU = M*0;
LU(b,b) = speye(length(b),length(b));
Fb = F;
Fb(b) = 0;
rechte_seite = cat(1,zeros(length(Fb),1),Fb);
end_matrix = vertcat(horzcat(LO,RO),horzcat(LU,RU));

%  
% % [Kb,Fb] = dirichlet(K,F,b) % assembled K was singular! K*ones(N,1)=0
% % Implement Dirichlet boundary conditions U(b)=0 at nodes in list b
% K(b,:)=0; K(:,b)=0; F(b)=0; % put zeros in boundary rows/columns of K and F
% K(b,b)=speye(length(b),length(b)); % put I into boundary submatrix of K
% Kb=K; Fb=F; % Stiffness matrix Kb (sparse format) and load vector Fb
 
% Solving for the vector U will produce U(b)=0 at boundary nodes
U=end_matrix\rechte_seite;  % The FEM approximation is U_1 phi_1 + ... + U_N phi_N
u1 = U(1:length(U)/2); % Nur der erste Teil interessiert erstmal. Weil wir ja vorher die Dimension der DGL erhöht hatten.
 
% Plot the FEM approximation U(x,y) with values U_1 to U_N at the nodes
trisurf(t,p(:,1),p(:,2),0*p(:,1),u1,'edgecolor','k','facecolor','interp');
view(2),axis([0 1 0 1]),axis equal,colorbar

figure(3)
scatter3(p(:,1),p(:,2),u1)
