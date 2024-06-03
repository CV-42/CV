% Löse die Plattengleichung aus der Masterarbeit (im Regime \alpha>3)

% Brauche drei Gleichungen, weil die Differentialgleichung vierten Grades
% ist, und Matlab nur zweiten Grad löst.
N=3;
Plattenmodell = createpde(N);

% Materialkonstanten
E = 1.0e6; % modulus of elasticity
nu = .3; % Poisson's ratio
Lamekonstante = 3*E*nu/(1+nu);      % erste Lamekonstante
Schubmodul = 3*E*(1-2*nu)/(2+2*nu); % zweite Lamekonstante


% Körpergrößen
thick = .1; % plate thickness
len = 10.0; % side length for the square plate
Kraft = 2; % external force

% Genauigkeit für Gitter
hmax = len/20; % mesh size parameter

% Geometrie
% 3 steht für "Rechteck"
% 4 steht für "4 Ecken"
% Rest sind x- und y-Koordinaten der Ecken
gdm = [3 4 0 len len 0 0 0 len len]';
g = decsg(gdm);

% Geometrieobjekt im Modell erzeugen
geometryFromEdges(Plattenmodell,g);

% Geometrie zeigen
figure(1); 
pdegplot(Plattenmodell,'EdgeLabels','on');
ylim([-len/10,len+len/10])
axis equal
title 'Geometry With Edge Labels Displayed';

% Koeffizientendefinition
% Um das zu verstehen, muss man sich sehr genau
% https://de.mathworks.com/help/pde/ug/c-coefficient-for-systems-for-specifycoefficients.html#bu5xabm-8
% durchlesen.
hilf = 2*Schubmodul*Lamekonstante/(2*Schubmodul+Lamekonstante)
Koef1 = 2*Schubmodul + hilf;
Koef2 = 4 * Schubmodul + hilf;
c = zeros(2*N);
c(1) = 1; c(6*3+4) = 1; c(6*2+5) = Koef1; c(4*6) = Koef2; c(4*6+5) = Koef2; c(6*6)= Koef1;
a = zeros(N);
a(1,2)=1; a(2,3)=1;
m = 0;
d = 0;
f = [0 0 Kraft]';
specifyCoefficients(Plattenmodell,'c',c(:),'a',a(:),'m',m,'d',d,'f',f);

% Randbedingungen
% Das läuft noch falsch!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
% Vielleicht muss ich ein "N=6"-System draus
% machen..
k = 1e7; % spring stiffness
applyBoundaryCondition(Plattenmodell,'dirichlet','Edge',(1:4));

% Gitter erzeugen
generateMesh(Plattenmodell,'HMax',hmax);


% Lösen
res = solvepde(Plattenmodell);
u = res.NodalSolution;

% Malen
numNodes = size(Plattenmodell.Mesh.Nodes,2);
figure(2);
pdeplot(Plattenmodell,'XYData',u(1:numNodes),'ZData',u(1:numNodes),'Mesh','on');
title 'Transverse Deflection'